<?php

namespace App\Services\Accounting;

/**
 * Builds a standard-format Balance Sheet from rows returned by
 * USP_GL_R_BalanceSheet_V2. The SP already injects "Laba Tahun Berjalan"
 * into the Current Earning equity account, so the totals will balance
 * automatically when the trial balance is correct.
 *
 * Every amount is provided in three flavours (columns):
 *   - prior   : saldo per akhir bulan sebelumnya / M-1 (BBBalanceAmount)
 *   - current : mutasi bulan berjalan (BDebetAmount - BCreditAmount)
 *   - ending  : saldo per tanggal akhir periode (Amount = prior + current)
 *
 * Sign handling: SP hanya mem-flip kolom Amount (ending) untuk LI/EQ.
 * Kolom prior & current di-flip di sini dengan aturan yang sama supaya
 * ketiga kolom konsisten (LI/EQ tampil positif).
 *
 * Output shape:
 * [
 *   'period_end' => '2026-06-30',
 *   'labels'     => ['prior' => 'Per 31 Mei 2026', 'current' => 'Mutasi Jun 2026', 'ending' => 'Per 30 Jun 2026'],
 *   'sections'   => [
 *      'asset'     => Section,
 *      'liability' => Section,
 *      'equity'    => Section,
 *   ],
 *   'totals'     => [
 *      'asset'        => ['prior' => N, 'current' => N, 'ending' => N],
 *      'liability'    => [...],
 *      'equity'       => [...],
 *      'liab_plus_eq' => [...],
 *      'difference'   => [...],   // asset - (liab+equity) per kolom
 *      'is_balanced'  => ['prior' => bool, 'current' => bool, 'ending' => bool],
 *   ],
 * ]
 *
 * Section shape:
 * [
 *   'title'    => 'ASET',
 *   'groups'   => [
 *      [
 *        'title'    => 'Aset Lancar',
 *        'rows'     => [ ['COA','COADesc','amount_prior','amount_current','amount'], ... ],
 *        'subtotal' => ['prior' => N, 'current' => N, 'ending' => N],
 *      ],
 *      ...
 *   ],
 *   'total'    => ['prior' => N, 'current' => N, 'ending' => N],
 * ]
 */
class BalanceSheetReportBuilder
{
    private $sectionMap = [
        'AS' => ['key' => 'asset',     'title' => 'ASET'],
        'LI' => ['key' => 'liability', 'title' => 'LIABILITAS'],
        'EQ' => ['key' => 'equity',    'title' => 'EKUITAS'],
    ];

    /** Toleransi pembulatan untuk balance check */
    private $balanceTolerance = 0.01;

    public function build(iterable $rawRows, string $startDate, string $endDate): array
    {
        $zero = ['prior' => 0.0, 'current' => 0.0, 'ending' => 0.0];

        $sections = [
            'asset'     => ['title' => 'ASET',       'groups' => [], 'total' => $zero],
            'liability' => ['title' => 'LIABILITAS', 'groups' => [], 'total' => $zero],
            'equity'    => ['title' => 'EKUITAS',    'groups' => [], 'total' => $zero],
        ];

        // -- buffer per section: groupKey => ['title','rows','subtotal']
        $buffers = ['asset' => [], 'liability' => [], 'equity' => []];

        foreach ($rawRows as $row) {
            if (!isset($this->sectionMap[$row->AccountType])) continue;

            $sectionKey = $this->sectionMap[$row->AccountType]['key'];
            $groupKey   = trim($row->COAGroup1ID ?? '') ?: '_ungrouped';
            $groupTitle = trim($row->COAGroup1Name1 ?? '') ?: '(Tanpa Grup)';

            if (!isset($buffers[$sectionKey][$groupKey])) {
                $buffers[$sectionKey][$groupKey] = [
                    'title'    => $groupTitle,
                    'rows'     => [],
                    'subtotal' => $zero,
                ];
            }

            // SP sudah mem-flip Amount (ending) untuk LI/EQ; prior & current di-flip di sini.
            $sign = ($row->AccountType === 'AS') ? 1 : -1;

            $amounts = [
                'prior'   => $sign * (float) $row->BBBalanceAmount,
                'current' => $sign * ((float) $row->BDebetAmount - (float) $row->BCreditAmount),
                'ending'  => (float) $row->Amount,
            ];

            $buffers[$sectionKey][$groupKey]['rows'][] = [
                'COA'            => $row->COA,
                'COADesc'        => $row->COADesc,
                'amount_prior'   => $amounts['prior'],
                'amount_current' => $amounts['current'],
                'amount'         => $amounts['ending'],
            ];

            foreach ($amounts as $col => $val) {
                $buffers[$sectionKey][$groupKey]['subtotal'][$col] += $val;
            }
        }

        // -- materialize buffers into ordered group arrays + section totals
        foreach ($buffers as $sectionKey => $groupBuffer) {
            $groups = array_values($groupBuffer);
            $sections[$sectionKey]['groups'] = $groups;

            $total = $zero;
            foreach ($groups as $group) {
                foreach ($group['subtotal'] as $col => $val) {
                    $total[$col] += $val;
                }
            }
            $sections[$sectionKey]['total'] = $total;
        }

        $totals = [
            'asset'        => $sections['asset']['total'],
            'liability'    => $sections['liability']['total'],
            'equity'       => $sections['equity']['total'],
            'liab_plus_eq' => $zero,
            'difference'   => $zero,
            'is_balanced'  => [],
        ];

        foreach (array_keys($zero) as $col) {
            $totals['liab_plus_eq'][$col] = $totals['liability'][$col] + $totals['equity'][$col];
            $totals['difference'][$col]   = $totals['asset'][$col] - $totals['liab_plus_eq'][$col];
            $totals['is_balanced'][$col]  = abs($totals['difference'][$col]) <= $this->balanceTolerance;
        }

        return [
            'period_end' => $endDate,
            'labels'     => $this->buildColumnLabels($startDate, $endDate),
            'sections'   => $sections,
            'totals'     => $totals,
        ];
    }

    /**
     * Label kolom dari periode terpilih, mis. 2026-06-01 s/d 2026-06-30:
     *   prior = 'Per 31 Mei 2026', current = 'Mutasi 1 - 30 Jun 2026', ending = 'Per 30 Jun 2026'.
     */
    private function buildColumnLabels(string $startDate, string $endDate): array
    {
        $bulan = [
            1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'Mei', 6 => 'Jun',
            7 => 'Jul', 8 => 'Agu', 9 => 'Sep', 10 => 'Okt', 11 => 'Nov', 12 => 'Des',
        ];

        $format = function ($ts) use ($bulan) {
            return date('j', $ts) . ' ' . $bulan[(int) date('n', $ts)] . ' ' . date('Y', $ts);
        };

        $start = strtotime($startDate);
        $end   = strtotime($endDate);
        $prior = strtotime('-1 day', $start);

        return [
            'prior'   => 'Per ' . $format($prior),
            'current' => 'Mutasi ' . $format($start) . ' - ' . $format($end),
            'ending'  => 'Per ' . $format($end),
        ];
    }
}
