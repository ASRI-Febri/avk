<?php

namespace App\Services;

/**
 * Pengurai teks tabel kurs Bank BCA (hasil copy-paste dari https://www.bca.co.id/id/informasi/kurs).
 *
 * Sama seperti Panin, situs BCA tidak bisa di-scrape dari server; operator
 * menyalin tabel lalu menempelnya ke form. Saat disalin, kode mata uang dan
 * angkanya umumnya berada di baris terpisah, sehingga parser bekerja berbasis
 * token (menyusuri seluruh teks; tiap kode mata uang mengumpulkan angka yang
 * mengikutinya sampai kode berikutnya).
 *
 * BCA punya 3 set kurs -> 6 angka berurutan per mata uang:
 *   [e-Rate Beli] [e-Rate Jual] [TT Beli] [TT Jual] [Bank Notes Beli] [Bank Notes Jual]
 *
 * Format angka Indonesia: pemisah ribuan TITIK, desimal KOMA
 *   (mis. "18.000,00", "112,14", "0,00"). Nilai 0 (mis. Bank Notes tak tersedia)
 *   dianggap tidak valid dan dilewati.
 */
class BcaKursParser
{
    /** Indeks angka [Beli, Jual] untuk tiap pilihan kolom. */
    const COLUMNS = [
        'erate'     => [0, 1],
        'tt'        => [2, 3],
        'banknotes' => [4, 5],
    ];

    /** @var array<int,string> kode mata uang dikenal tapi jumlah angkanya kurang / 0 */
    private $unparsed = [];

    /** @var array<int,string> kode mirip mata uang tapi tidak ada di master aktif */
    private $skipped = [];

    /**
     * @param string   $text     teks yang ditempel operator
     * @param string   $rateset  'erate' | 'tt' | 'banknotes'
     * @param string[] $known    daftar kode mata uang valid (dari MC_M_Currency aktif).
     * @return array<int,array{currency:string,buy:float,sell:float}>
     */
    public function parse(string $text, string $rateset = 'erate', array $known = []): array
    {
        $this->unparsed = [];
        $this->skipped = [];
        $known = array_map('strtoupper', $known);
        $stop  = ['WIB', 'RATE', 'BELI', 'JUAL', 'MATA', 'UANG', 'NOTES', 'COUNTER', 'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'AUG', 'SEP', 'OKT', 'OCT', 'NOV', 'DES', 'DEC'];

        if (!isset(self::COLUMNS[$rateset])) {
            $rateset = 'erate';
        }

        // Samakan semua jenis spasi (termasuk non-breaking space) lalu pecah jadi token.
        $text   = preg_replace('/[\x{00A0}\x{202F}\x{2007}\x{2009}]/u', ' ', $text);
        $tokens = preg_split('/\s+/', trim($text));

        $rows    = [];
        $current = null; // ['code' => string, 'nums' => float[]]

        foreach ($tokens as $tok) {
            if ($tok === '') {
                continue;
            }

            // Token kode mata uang: tepat 3 huruf (mis. USD, e-Rate "RATE" disaring stoplist).
            $code = strtoupper($tok);
            if (preg_match('/^[A-Z]{3}$/', $code)) {
                if (in_array($code, $stop, true)) {
                    continue;
                }
                $this->flush($current, $known, $rateset, $rows);
                $current = ['code' => $code, 'nums' => []];
                continue;
            }

            // Token angka format Indonesia: "18.000,00" | "112,14" | "0,00" | "543,99"
            if (preg_match('/^\d{1,3}(?:\.\d{3})+(?:,\d+)?$|^\d+(?:,\d+)?$/', $tok)) {
                if ($current !== null) {
                    $current['nums'][] = $this->toFloat($tok);
                }
                continue;
            }

            // Token lain (tanggal, "/", "Beli", "e-Rate", dll.) -> abaikan.
        }

        $this->flush($current, $known, $rateset, $rows);

        return array_values($rows);
    }

    /** "18.000,00" -> 18000.00 ; "112,14" -> 112.14 */
    private function toFloat(string $tok): float
    {
        return (float) str_replace(',', '.', str_replace('.', '', $tok));
    }

    private function flush($current, array $known, string $rateset, array &$rows)
    {
        if ($current === null) {
            return;
        }
        $code = $current['code'];
        $nums = $current['nums'];

        if (!empty($known) && !in_array($code, $known, true)) {
            if (count($nums) >= 2) {
                $this->skipped[$code] = $code;
            }
            return;
        }

        list($bi, $si) = self::COLUMNS[$rateset];

        $buy = null;
        $sell = null;
        if (count($nums) > max($bi, $si)) {
            $buy  = $nums[$bi];
            $sell = $nums[$si];
        } elseif (count($nums) === 2) {
            // Operator hanya menyalin satu kolom (Beli/Jual).
            $buy  = $nums[0];
            $sell = $nums[1];
        }

        if ($buy !== null && $sell !== null && $buy > 0 && $sell > 0) {
            $rows[$code] = ['currency' => $code, 'buy' => $buy, 'sell' => $sell];
        } else {
            // Termasuk nilai 0,00 (mis. Bank Notes tak tersedia).
            $this->unparsed[$code] = $code;
        }
    }

    /** @return array<int,string> kode mata uang dikenal tapi angkanya tak lengkap / 0 */
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
