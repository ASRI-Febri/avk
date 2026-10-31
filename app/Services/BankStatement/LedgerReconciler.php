<?php

namespace App\Services\BankStatement;

/**
 * Mencocokkan baris rekening koran dengan baris ledger COA bank pada periode
 * yang sama. Hasilnya hanya untuk ditampilkan (tidak disimpan).
 *
 * Arah disamakan lebih dulu: uang masuk = kredit di rekening koran = debit COA
 * bank di ledger; uang keluar sebaliknya. Pencocokan berjalan bertahap, baris
 * yang sudah cocok tidak dipakai lagi:
 *   0. adjusted : transaksi yang diberi jurnal penyesuaian dari halaman
 *              rekonsiliasi, dikelompokkan bersama baris COA bank pada jurnal
 *              penyesuaian tersebut.
 *   0. manual : transaksi yang ditandai cocok manual oleh user (tanpa jurnal),
 *              mis. satu transfer bank yang dicatat dua penerimaan di hari lain.
 *   1. link  : baris rekening koran yang dijurnal lewat menu Rekening Koran,
 *              dicocokkan ke baris COA bank pada jurnal tersebut.
 *   2. exact / date : nominal dan arah sama, selisih tanggal maks. MAX_DAYS
 *              (tanggal terdekat diutamakan).
 *   3. combo : satu baris di satu sisi sama dengan jumlah 2-3 baris di sisi lain
 *              pada tanggal yang sama (mis. satu transfer dibayar untuk dua nota).
 *              Bisa kebetulan, jadi ditandai untuk diperiksa.
 * Sisanya menjadi bank_only / ledger_only.
 */
class LedgerReconciler
{
    const MAX_DAYS = 3;
    const MAX_COMBO = 3;
    const MAX_CANDIDATES = 25;

    /**
     * @param array $bank   baris: id, date (Y-m-d), datetime, remark, in, out, journal_id
     * @param array $ledger baris: id, journal_id, voucher, date (Y-m-d), remark, in, out, posted, in_period
     * @param array $adjustments [journal_id jurnal penyesuaian => ['bank' => [id...], 'ledger' => [id...]]]
     * @param array $matches     [id pasangan manual => ['bank' => [id...], 'ledger' => [id...]]]
     * @return array{groups: array, summary: array}
     */
    public function reconcile(array $bank, array $ledger, array $adjustments = [], array $matches = []): array
    {
        $bank = $this->keyed($bank);
        $ledger = $this->keyed($ledger);
        $groups = [];

        $this->matchAdjusted($bank, $ledger, $groups, $adjustments);
        $this->matchManual($bank, $ledger, $groups, $matches);
        $this->matchLinked($bank, $ledger, $groups);
        $this->matchSingle($bank, $ledger, $groups);
        $this->matchCombos($bank, $ledger, $groups, 'bank');
        $this->matchCombos($ledger, $bank, $groups, 'ledger');

        foreach ($bank as $row) {
            $groups[] = $this->group('bank_only', [$row], []);
        }
        foreach ($ledger as $row) {
            // Baris ledger di luar periode hanya diambil sebagai kandidat untuk selisih tanggal.
            if ($row['in_period']) {
                $groups[] = $this->group('ledger_only', [], [$row]);
            }
        }

        usort($groups, function ($a, $b) {
            return [$a['sort'], $a['type'] === 'ledger_only'] <=> [$b['sort'], $b['type'] === 'ledger_only'];
        });

        return ['groups' => $groups, 'summary' => $this->summary($groups)];
    }

    private function matchAdjusted(array &$bank, array &$ledger, array &$groups, array $adjustments)
    {
        foreach ($adjustments as $journal => $sources) {
            $rows = array_values(array_intersect_key($bank, array_flip($sources['bank'] ?? [])));
            $lines = array_values(array_filter($ledger, function ($line) use ($journal, $sources) {
                return $line['journal_id'] == $journal || in_array($line['id'], $sources['ledger'] ?? []);
            }));
            if (!$rows && !$lines) {
                continue;
            }
            $group = $this->group('adjusted', $rows, $lines);
            if (abs($group['difference']) >= 0.005) {
                $group['type'] = 'link_diff';
            }
            $group['adjustment'] = $journal;
            $groups[] = $group;
            $this->remove($bank, $rows);
            $this->remove($ledger, $lines);
        }
    }

    private function matchManual(array &$bank, array &$ledger, array &$groups, array $matches)
    {
        foreach ($matches as $match => $sources) {
            $rows = array_values(array_intersect_key($bank, array_flip($sources['bank'] ?? [])));
            $lines = array_values(array_intersect_key($ledger, array_flip($sources['ledger'] ?? [])));
            if (!$rows && !$lines) {
                continue;
            }
            $group = $this->group('manual', $rows, $lines);
            if (abs($group['difference']) >= 0.005) {
                $group['type'] = 'link_diff';
            }
            $group['manual'] = $match;
            $groups[] = $group;
            $this->remove($bank, $rows);
            $this->remove($ledger, $lines);
        }
    }

    private function matchLinked(array &$bank, array &$ledger, array &$groups)
    {
        $byJournal = [];
        foreach ($bank as $id => $row) {
            if ($row['journal_id']) {
                $byJournal[$row['journal_id']][] = $row;
            }
        }

        foreach ($byJournal as $journal => $rows) {
            $lines = array_filter($ledger, function ($line) use ($journal) {
                return $line['journal_id'] == $journal;
            });
            if (!$lines) {
                continue;
            }
            $group = $this->group('link', $rows, array_values($lines));
            if (abs($group['difference']) >= 0.005) {
                $group['type'] = 'link_diff';
            }
            $groups[] = $group;
            $this->remove($bank, $rows);
            $this->remove($ledger, $lines);
        }
    }

    /**
     * Per selisih hari: semua pasangan bertanggal sama dicocokkan dulu, baru selisih
     * 1 hari, dst., supaya transaksi bernominal sama di hari lain tidak merebut
     * pasangan yang tanggalnya tepat.
     */
    private function matchSingle(array &$bank, array &$ledger, array &$groups)
    {
        for ($days = 0; $days <= self::MAX_DAYS; $days++) {
            foreach ($bank as $id => $row) {
                foreach ($ledger as $line) {
                    if ($this->days($row['date'], $line['date']) === $days && $this->sameAmount($row, [$line])) {
                        $groups[] = $this->group($days === 0 ? 'exact' : 'date', [$row], [$line]);
                        unset($bank[$id], $ledger[$line['id']]);
                        break;
                    }
                }
            }
        }
    }

    /**
     * Satu baris $single (sisi $singleSide) = jumlah 2..MAX_COMBO baris $many pada tanggal sama.
     */
    private function matchCombos(array &$single, array &$many, array &$groups, string $singleSide)
    {
        foreach ($single as $id => $row) {
            $candidates = array_values(array_filter($many, function ($other) use ($row) {
                return $other['date'] === $row['date']
                    && (($row['in'] > 0 && $other['in'] > 0 && $other['in'] < $row['in'])
                        || ($row['out'] > 0 && $other['out'] > 0 && $other['out'] < $row['out']));
            }));
            if (count($candidates) < 2 || count($candidates) > self::MAX_CANDIDATES) {
                continue;
            }

            $combo = $this->findCombo($candidates, round($row['in'] + $row['out'], 2));
            if ($combo === null) {
                continue;
            }

            $groups[] = $singleSide === 'bank'
                ? $this->group('combo', [$row], $combo)
                : $this->group('combo', $combo, [$row]);
            unset($single[$id]);
            $this->remove($many, $combo);
        }
    }

    private function findCombo(array $candidates, float $target, int $start = 0, array $picked = [], float $sum = 0)
    {
        if (count($picked) >= 2 && abs($sum - $target) < 0.005) {
            return $picked;
        }
        if (count($picked) >= self::MAX_COMBO) {
            return null;
        }
        for ($i = $start; $i < count($candidates); $i++) {
            $amount = $candidates[$i]['in'] + $candidates[$i]['out'];
            if ($sum + $amount > $target + 0.005) {
                continue;
            }
            $found = $this->findCombo($candidates, $target, $i + 1, array_merge($picked, [$candidates[$i]]), $sum + $amount);
            if ($found !== null) {
                return $found;
            }
        }

        return null;
    }

    private function group(string $type, array $bank, array $ledger): array
    {
        $bankNet = array_sum(array_column($bank, 'in')) - array_sum(array_column($bank, 'out'));
        $ledgerNet = array_sum(array_column($ledger, 'in')) - array_sum(array_column($ledger, 'out'));
        $dates = array_merge(array_column($bank, 'datetime'), array_column($ledger, 'date'));

        return [
            'type'       => $type,
            'bank'       => $bank,
            'ledger'     => $ledger,
            'difference' => round($bankNet - $ledgerNet, 2),
            'sort'       => $bank ? min(array_column($bank, 'datetime')) : min($dates) . ' 99',
            'adjustment' => null,
            'manual'     => null,
        ];
    }

    private function summary(array $groups): array
    {
        $summary = ['bank_in' => 0, 'bank_out' => 0, 'ledger_in' => 0, 'ledger_out' => 0, 'counts' => []];
        foreach ($groups as $group) {
            $summary['counts'][$group['type']] = ($summary['counts'][$group['type']] ?? 0) + 1;
            foreach ($group['bank'] as $row) {
                $summary['bank_in'] += $row['in'];
                $summary['bank_out'] += $row['out'];
            }
            foreach ($group['ledger'] as $line) {
                if ($line['in_period']) {
                    $summary['ledger_in'] += $line['in'];
                    $summary['ledger_out'] += $line['out'];
                }
            }
        }

        return $summary;
    }

    private function sameAmount(array $row, array $lines): bool
    {
        return abs($row['in'] - array_sum(array_column($lines, 'in'))) < 0.005
            && abs($row['out'] - array_sum(array_column($lines, 'out'))) < 0.005;
    }

    private function days(string $a, string $b): int
    {
        return (int) round(abs(strtotime($a) - strtotime($b)) / 86400);
    }

    private function keyed(array $rows): array
    {
        return array_column($rows, null, 'id');
    }

    private function remove(array &$rows, array $remove)
    {
        foreach ($remove as $row) {
            unset($rows[$row['id']]);
        }
    }
}
