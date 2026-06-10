<?php

namespace App\Services;

/**
 * Pengurai teks tabel kurs Bank Panin (hasil copy-paste dari https://www.panin.co.id/id/kurs).
 *
 * Situs Panin diproteksi Akamai Bot Manager sehingga tidak bisa di-scrape dari
 * server; alur yang dipakai adalah operator menyalin tabel lalu menempelnya ke
 * form di AVK.
 *
 * Saat tabel disalin, kode mata uang dan angkanya bisa berada di baris terpisah:
 *   USD
 *   17,990.00   18,020.00   17,980.00   18,030.00
 * atau pada satu baris (tab/spasi). Untuk menangani keduanya, parser bekerja
 * berbasis token: menyusuri seluruh teks, dan setiap kali bertemu kode mata uang
 * ia mengumpulkan angka yang mengikutinya sampai kode mata uang berikutnya.
 *
 * Tiap mata uang punya 4 angka berurutan:
 *   [Spesial Beli] [Spesial Jual] [TT Beli] [TT Jual]
 * Format angka: pemisah ribuan koma, desimal titik (mis. "17,980.00", "111.71").
 */
class PaninKursParser
{
    /** @var array<int,string> kode mata uang dikenal tapi jumlah angkanya kurang */
    private $unparsed = [];

    /** @var array<int,string> kode mirip mata uang tapi tidak ada di master aktif */
    private $skipped = [];

    /**
     * @param string   $text     teks yang ditempel operator
     * @param string   $rateset  'tt' (TT Counter, angka ke-3 & ke-4) atau 'special' (angka ke-1 & ke-2)
     * @param string[] $known    daftar kode mata uang valid (dari MC_M_Currency aktif).
     * @return array<int,array{currency:string,buy:float,sell:float}>
     */
    public function parse(string $text, string $rateset = 'tt', array $known = []): array
    {
        $this->unparsed = [];
        $this->skipped = [];
        $known = array_map('strtoupper', $known);
        $stop  = ['WIB', 'RATE', 'BELI', 'JUAL', 'MATA', 'UANG', 'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'AUG', 'SEP', 'OKT', 'OCT', 'NOV', 'DES', 'DEC'];

        // Samakan semua jenis spasi (termasuk non-breaking space) lalu pecah jadi token.
        $text   = preg_replace('/[\x{00A0}\x{202F}\x{2007}\x{2009}]/u', ' ', $text);
        $tokens = preg_split('/\s+/', trim($text));

        $rows    = [];
        $current = null; // ['code' => string, 'nums' => float[]]

        foreach ($tokens as $tok) {
            if ($tok === '') {
                continue;
            }

            // Token kode mata uang: tepat 3 huruf.
            $code = strtoupper($tok);
            if (preg_match('/^[A-Z]{3}$/', $code)) {
                if (in_array($code, $stop, true)) {
                    continue; // header/bulan -> abaikan, bukan batas mata uang
                }
                // Batas baru: finalkan mata uang sebelumnya.
                $this->flush($current, $known, $rateset, $rows);
                $current = ['code' => $code, 'nums' => []];
                continue;
            }

            // Token angka: "17,980.00" | "111.71" | "2,284.58" | "18000"
            if (preg_match('/^\d{1,3}(?:,\d{3})+(?:\.\d+)?$|^\d+(?:\.\d+)?$/', $tok)) {
                if ($current !== null) {
                    $current['nums'][] = (float) str_replace(',', '', $tok);
                }
                continue;
            }

            // Token lain (tanggal, "/", "Beli", dll.) -> abaikan.
        }

        $this->flush($current, $known, $rateset, $rows);

        return array_values($rows);
    }

    /**
     * Finalkan satu mata uang: ambil Beli/Jual sesuai kolom, atau catat sebagai
     * dilewati (tak dikenal) / tak terbaca (angka kurang).
     */
    private function flush($current, array $known, string $rateset, array &$rows)
    {
        if ($current === null) {
            return;
        }
        $code = $current['code'];
        $nums = $current['nums'];

        // Kode tak ada di master aktif: lewati (laporkan bila mirip baris data).
        if (!empty($known) && !in_array($code, $known, true)) {
            if (count($nums) >= 2) {
                $this->skipped[$code] = $code;
            }
            return;
        }

        $buy = null;
        $sell = null;
        if ($rateset === 'special') {
            if (count($nums) >= 2) {
                $buy  = $nums[0];
                $sell = $nums[1];
            }
        } else { // tt
            if (count($nums) >= 4) {
                $buy  = $nums[2];
                $sell = $nums[3];
            } elseif (count($nums) === 2) {
                // Operator hanya menyalin kolom TT.
                $buy  = $nums[0];
                $sell = $nums[1];
            }
        }

        if ($buy !== null && $sell !== null && $buy > 0 && $sell > 0) {
            $rows[$code] = ['currency' => $code, 'buy' => $buy, 'sell' => $sell];
        } else {
            $this->unparsed[$code] = $code;
        }
    }

    /** @return array<int,string> kode mata uang dikenal tapi angkanya tak lengkap */
    public function unparsed(): array
    {
        return array_values($this->unparsed);
    }

    /** @return array<int,string> kode mirip mata uang yang dilewati (tak ada di master aktif) */
    public function skipped(): array
    {
        return array_values($this->skipped);
    }
}
