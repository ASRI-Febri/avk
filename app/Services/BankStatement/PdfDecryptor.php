<?php

namespace App\Services\BankStatement;

use RuntimeException;

/**
 * Membuka enkripsi PDF rekening koran yang dikunci "owner password" saja
 * (bisa dibuka tanpa password, tapi smalot/pdfparser menolak semua PDF
 * terenkripsi).
 *
 * Yang didukung: Standard Security Handler revisi 2/3 (RC4), dipakai
 * Kopra by Mandiri. RC4 tidak mengubah panjang data, sehingga isi stream
 * didekripsi di tempat dan offset tabel xref tetap valid. Penanda /Encrypt
 * di trailer ditimpa spasi dengan panjang sama.
 *
 * String literal di luar stream (mis. metadata /Info) tidak didekripsi
 * karena teks transaksi seluruhnya berada di content stream.
 */
class PdfDecryptor
{
    const PAD = "\x28\xBF\x4E\x5E\x4E\x75\x8A\x41\x64\x00\x4E\x56\xFF\xFA\x01\x08"
              . "\x2E\x2E\x00\xB6\xD0\x68\x3E\x80\x2F\x0C\xA9\xFE\x64\x53\x69\x7A";

    public function isEncrypted(string $pdf): bool
    {
        return (bool) preg_match('#/Encrypt\s+\d+\s+\d+\s+R#', $pdf);
    }

    public function decrypt(string $pdf): string
    {
        if (!preg_match('#/Encrypt\s+(\d+)\s+(\d+)\s+R#', $pdf, $m, PREG_OFFSET_CAPTURE)) {
            return $pdf;
        }
        $encryptRef = $m[0];
        $encryptObj = (int) $m[1][0];

        $dict = $this->objectDictionary($pdf, $encryptObj);
        if ($dict === null || strpos($dict, '/Standard') === false) {
            throw new RuntimeException('Jenis enkripsi PDF tidak didukung.');
        }

        $v = $this->dictInt($dict, 'V', 0);
        $r = $this->dictInt($dict, 'R', 2);
        if ($v > 2 || $r > 3) {
            throw new RuntimeException('Enkripsi PDF (AES) belum didukung. Simpan ulang PDF tanpa enkripsi lalu upload kembali.');
        }

        $keyLength = $r === 2 ? 5 : intdiv($this->dictInt($dict, 'Length', 40), 8);
        $o = $this->dictString($dict, 'O');
        $p = $this->dictInt($dict, 'P', 0);
        $id = preg_match('#/ID\s*\[\s*<([0-9A-Fa-f]*)>#', $pdf, $idm) ? hex2bin($idm[1]) : '';

        $key = $this->fileKey($o, $p, $id, $r, $keyLength);

        $out = $pdf;
        $offset = 0;
        while (preg_match('#(\d+)\s+(\d+)\s+obj\b#', $pdf, $om, PREG_OFFSET_CAPTURE, $offset)) {
            $objStart = $om[0][1];
            $num = (int) $om[1][0];
            $gen = (int) $om[2][0];
            $end = strpos($pdf, 'endobj', $objStart);
            if ($end === false) {
                break;
            }
            $offset = $end + 6;

            $body = substr($pdf, $objStart, $end - $objStart);
            $streamPos = strpos($body, 'stream');
            if ($streamPos === false || $num === $encryptObj || strpos($body, '/XRef') !== false) {
                continue;
            }

            $dataStart = $objStart + $streamPos + 6;
            if ($pdf[$dataStart] === "\r") {
                $dataStart++;
            }
            if ($pdf[$dataStart] === "\n") {
                $dataStart++;
            }

            $length = preg_match('#/Length\s+(\d+)(?!\s+\d+\s+R)#', substr($body, 0, $streamPos), $lm) ? (int) $lm[1] : null;
            if ($length === null) {
                // /Length berupa referensi objek: ambil data sampai "endstream" tanpa EOL penutupnya.
                $length = strlen(rtrim(substr($pdf, $dataStart, strrpos(substr($pdf, 0, $end), 'endstream') - $dataStart), "\r\n"));
            }

            $objectKey = substr(md5($key . substr(pack('V', $num), 0, 3) . substr(pack('V', $gen), 0, 2), true), 0, min($keyLength + 5, 16));
            $plain = $this->rc4($objectKey, substr($pdf, $dataStart, $length));
            $out = substr_replace($out, $plain, $dataStart, $length);
        }

        return substr_replace($out, str_repeat(' ', strlen($encryptRef[0])), $encryptRef[1], strlen($encryptRef[0]));
    }

    private function fileKey(string $o, int $p, string $id, int $r, int $keyLength): string
    {
        $hash = md5(self::PAD . $o . pack('V', $p) . $id, true);
        if ($r >= 3) {
            for ($i = 0; $i < 50; $i++) {
                $hash = md5(substr($hash, 0, $keyLength), true);
            }
        }

        return substr($hash, 0, $keyLength);
    }

    private function rc4(string $key, string $data): string
    {
        $s = range(0, 255);
        $j = 0;
        $keyLength = strlen($key);
        for ($i = 0; $i < 256; $i++) {
            $j = ($j + $s[$i] + ord($key[$i % $keyLength])) & 0xFF;
            [$s[$i], $s[$j]] = [$s[$j], $s[$i]];
        }

        $i = $j = 0;
        $out = '';
        $dataLength = strlen($data);
        for ($k = 0; $k < $dataLength; $k++) {
            $i = ($i + 1) & 0xFF;
            $j = ($j + $s[$i]) & 0xFF;
            [$s[$i], $s[$j]] = [$s[$j], $s[$i]];
            $out .= chr(ord($data[$k]) ^ $s[($s[$i] + $s[$j]) & 0xFF]);
        }

        return $out;
    }

    private function objectDictionary(string $pdf, int $num): ?string
    {
        if (!preg_match('#(?<!\d)' . $num . '\s+0\s+obj\s*#', $pdf, $m, PREG_OFFSET_CAPTURE)) {
            return null;
        }
        $start = $m[0][1] + strlen($m[0][0]);
        $end = strpos($pdf, 'endobj', $start);

        return $end === false ? null : substr($pdf, $start, $end - $start);
    }

    private function dictInt(string $dict, string $key, int $default): int
    {
        return preg_match('#/' . $key . '\s+(-?\d+)#', $dict, $m) ? (int) $m[1] : $default;
    }

    /**
     * Membaca string PDF (literal "(...)" dengan escape, atau hex "<...>").
     */
    private function dictString(string $dict, string $key): string
    {
        if (!preg_match('#/' . $key . '\s*([(<])#', $dict, $m, PREG_OFFSET_CAPTURE)) {
            throw new RuntimeException("Nilai /$key pada dictionary enkripsi PDF tidak ditemukan.");
        }
        $pos = $m[1][1];

        if ($m[1][0] === '<') {
            $close = strpos($dict, '>', $pos);

            return hex2bin(preg_replace('/\s+/', '', substr($dict, $pos + 1, $close - $pos - 1)));
        }

        $escapes = ['n' => "\n", 'r' => "\r", 't' => "\t", 'b' => "\x08", 'f' => "\x0C", '(' => '(', ')' => ')', '\\' => '\\'];
        $out = '';
        $depth = 0;
        $length = strlen($dict);
        for ($i = $pos + 1; $i < $length; $i++) {
            $c = $dict[$i];
            if ($c === '\\') {
                $next = $dict[++$i];
                if (isset($escapes[$next])) {
                    $out .= $escapes[$next];
                } elseif (ctype_digit($next) && $next < '8') {
                    $octal = $next;
                    while (strlen($octal) < 3 && ctype_digit($dict[$i + 1]) && $dict[$i + 1] < '8') {
                        $octal .= $dict[++$i];
                    }
                    $out .= chr(octdec($octal) & 0xFF);
                } elseif ($next === "\r") {
                    if ($dict[$i + 1] === "\n") {
                        $i++;
                    }
                } elseif ($next !== "\n") {
                    $out .= $next;
                }
            } elseif ($c === '(') {
                $depth++;
                $out .= $c;
            } elseif ($c === ')') {
                if ($depth === 0) {
                    break;
                }
                $depth--;
                $out .= $c;
            } else {
                $out .= $c;
            }
        }

        return $out;
    }
}
