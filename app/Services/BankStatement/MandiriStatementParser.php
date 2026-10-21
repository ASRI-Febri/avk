<?php

namespace App\Services\BankStatement;

use RuntimeException;
use Smalot\PdfParser\Parser;

/**
 * Pengurai PDF "Account Statement" Kopra by Mandiri.
 *
 * Teks hasil ekstraksi tiap transaksi berbentuk:
 *   01 Sep 2026,                          <- awal transaksi
 *   09:07:28 [awal remark]
 *   ...baris remark...
 *   <reference|->  <debit> <credit> <saldo>  <- akhir transaksi
 * Remark yang terpotong pindah halaman muncul SETELAH baris nominal di halaman
 * berikutnya, sehingga baris di luar transaksi ditempelkan ke transaksi
 * sebelumnya.
 *
 * Setiap baris diperiksa terhadap saldo berjalan (saldo sebelumnya - debit +
 * kredit) dan total debit/kredit dicocokkan dengan ringkasan di halaman 1.
 */
class MandiriStatementParser
{
    const MONTHS = ['Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
                    'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12];

    const DATE = '(\d{2}) ([A-Z][a-z]{2}) (\d{4})';
    const AMOUNT = '-?[\d,]+\.\d{2}';

    /**
     * @return array{header: array, rows: array, warnings: string[]}
     */
    public function parseFile(string $path): array
    {
        $pdf = file_get_contents($path);
        $decryptor = new PdfDecryptor();
        if ($decryptor->isEncrypted($pdf)) {
            $pdf = $decryptor->decrypt($pdf);
        }

        $text = '';
        foreach ((new Parser())->parseContent($pdf)->getPages() as $page) {
            $text .= $page->getText() . "\n";
        }

        return $this->parseText($text);
    }

    public function parseText(string $text): array
    {
        if (stripos($text, 'Account Statement') === false || stripos($text, 'Posting Date') === false) {
            throw new RuntimeException('Format PDF tidak dikenali. Gunakan Account Statement dari Kopra by Mandiri.');
        }

        $header = $this->parseHeader($text);
        $rows = $this->parseRows($text);
        if (!$rows) {
            throw new RuntimeException('Tidak ada transaksi yang terbaca dari PDF.');
        }

        return ['header' => $header, 'rows' => $rows, 'warnings' => $this->validate($header, $rows)];
    }

    private function parseHeader(string $text): array
    {
        $line = function (string $label) use ($text) {
            return preg_match('/' . $label . '[^\n]*\n([^\n]*)/', $text, $m) ? preg_split('/\t+/', trim($m[1])) : [];
        };

        $account = $line('Account No\.');
        $opening = $line('Opening Balance');
        $closing = $line('Closing Balance');
        preg_match('/' . self::DATE . ' - ' . self::DATE . '/', $text, $period);
        preg_match('/Period[^\n]*\n([A-Z]{3})?/', $text, $currency);

        return [
            'account_no'      => $account[0] ?? '',
            'account_name'    => $account[1] ?? '',
            'currency'        => $currency[1] ?? 'IDR',
            'period_start'    => $period ? $this->date($period[1], $period[2], $period[3]) : null,
            'period_end'      => $period ? $this->date($period[4], $period[5], $period[6]) : null,
            'opening_balance' => $this->amount($opening[0] ?? '0'),
            'closing_balance' => $this->amount($closing[0] ?? '0'),
            'total_debit'     => $this->amount($opening[2] ?? '0'),
            'total_credit'    => $this->amount($closing[2] ?? '0'),
        ];
    }

    private function parseRows(string $text): array
    {
        $noise = '/^(Account Statement|Created \d{2} \w{3} \d{4}|.*Posting Date$|.*Reference No\.|Page \d+ of|isit Kopra|For further questions)/';
        $amounts = '/^(.*?)\s*(' . self::AMOUNT . ')\s+(' . self::AMOUNT . ')\s+(' . self::AMOUNT . ')$/';

        $rows = [];
        $current = null;
        $inBody = false;

        foreach (preg_split('/\r?\n/', $text) as $line) {
            $line = trim(preg_replace('/[ \t]+/', ' ', $line));
            if (strpos($line, 'Posting Date') !== false) {
                $inBody = true;
                continue;
            }
            if (!$inBody || $line === '' || preg_match($noise, $line)) {
                continue;
            }

            if (preg_match('/^' . self::DATE . ',$/', $line, $m)) {
                $current = ['date' => $this->date($m[1], $m[2], $m[3]), 'time' => null, 'lines' => []];
                continue;
            }

            if ($current === null) {
                // Sisa remark transaksi sebelumnya yang terpotong ke halaman baru.
                if ($rows) {
                    $rows[count($rows) - 1]['remark'] .= ' ' . $line;
                }
                continue;
            }

            if ($current['time'] === null && preg_match('/^(\d{2}:\d{2}:\d{2})\s*(.*)$/', $line, $m)) {
                $current['time'] = $m[1];
                $line = $m[2];
                if ($line === '') {
                    continue;
                }
            }

            if (preg_match($amounts, $line, $m)) {
                // Baris nominal bisa diawali potongan remark terakhir, lalu Reference No. ("-" bila kosong).
                $reference = '';
                $remainder = $m[1];
                if (preg_match('/^(.*?)\s*-$/', $remainder, $r)) {
                    $remainder = $r[1];
                } elseif ($remainder !== '') {
                    $reference = $remainder;
                    $remainder = '';
                    $remark = implode(' ', $current['lines']);
                    // Referensi selalu diulang di dalam remark; yang tersisa di depannya adalah remark.
                    while (strpos($remark, $reference) === false && strpos($reference, ' ') !== false) {
                        [$head, $reference] = explode(' ', $reference, 2);
                        $remainder = trim($remainder . ' ' . $head);
                    }
                }
                if ($remainder !== '') {
                    $current['lines'][] = $remainder;
                }

                $rows[] = [
                    'seq'          => count($rows) + 1,
                    'posting_date' => $current['date'] . ' ' . ($current['time'] ?: '00:00:00'),
                    'remark'       => implode(' ', $current['lines']),
                    'reference_no' => $reference,
                    'debit'        => $this->amount($m[2]),
                    'credit'       => $this->amount($m[3]),
                    'balance'      => $this->amount($m[4]),
                ];
                $current = null;
                continue;
            }

            $current['lines'][] = $line;
        }

        foreach ($rows as $i => $row) {
            $rows[$i]['remark'] = trim(preg_replace('/\s+/', ' ', $row['remark']));
        }
        $remarks = array_column($rows, 'remark');
        foreach ($rows as $i => $row) {
            $rows[$i]['is_admin_fee'] = $this->isAdminFee($row, $remarks);
        }

        return $rows;
    }

    /**
     * Biaya admin: baris debit berupa "Biaya Adm" / "MONTHLY CARD CHARGE", atau
     * biaya transfer yang remark-nya hanya nomor referensi milik transaksi lain
     * diikuti kode transaksi (mis. "20260901BMRIIDJA010O9 930716135 99102").
     */
    private function isAdminFee(array $row, array $remarks): bool
    {
        if ($row['debit'] <= 0) {
            return false;
        }
        if (preg_match('/^(Biaya Adm|MONTHLY CARD CHARGE)/i', $row['remark'])) {
            return true;
        }
        if (!preg_match('/^(\S+ \d+) \d{5}$/', $row['remark'], $m)) {
            return false;
        }

        foreach ($remarks as $remark) {
            if ($remark !== $row['remark'] && strpos($remark, $m[1] . ' ') === 0) {
                return true;
            }
        }

        return false;
    }

    private function validate(array $header, array $rows): array
    {
        $warnings = [];
        $balance = $header['opening_balance'];
        foreach ($rows as $row) {
            $balance = round($balance - $row['debit'] + $row['credit'], 2);
            if (abs($balance - $row['balance']) > 0.005) {
                $warnings[] = sprintf('Saldo baris %d (%s) tidak sesuai perhitungan: %s vs %s.',
                    $row['seq'], $row['posting_date'], number_format($row['balance'], 2), number_format($balance, 2));
                $balance = $row['balance'];
            }
        }

        $debit = round(array_sum(array_column($rows, 'debit')), 2);
        $credit = round(array_sum(array_column($rows, 'credit')), 2);
        if ($header['total_debit'] && abs($debit - $header['total_debit']) > 0.005) {
            $warnings[] = 'Total debit ' . number_format($debit, 2) . ' tidak sama dengan ringkasan ' . number_format($header['total_debit'], 2) . '.';
        }
        if ($header['total_credit'] && abs($credit - $header['total_credit']) > 0.005) {
            $warnings[] = 'Total kredit ' . number_format($credit, 2) . ' tidak sama dengan ringkasan ' . number_format($header['total_credit'], 2) . '.';
        }
        if (abs(end($rows)['balance'] - $header['closing_balance']) > 0.005) {
            $warnings[] = 'Saldo akhir transaksi tidak sama dengan Closing Balance.';
        }

        return $warnings;
    }

    private function date(string $day, string $month, string $year): string
    {
        return sprintf('%04d-%02d-%02d', $year, self::MONTHS[$month] ?? 1, $day);
    }

    private function amount(string $value): float
    {
        return (float) str_replace(',', '', $value);
    }
}
