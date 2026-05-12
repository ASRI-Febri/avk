<?php

namespace App\Services\Accounting;

/**
 * Builds a standard-format Balance Sheet from rows returned by
 * USP_GL_R_BalanceSheet_V2. The SP already injects "Laba Tahun Berjalan"
 * into the Current Earning equity account, so the totals will balance
 * automatically when the trial balance is correct.
 *
 * Output shape:
 * [
 *   'period_end' => '2026-04-30',
 *   'sections'   => [
 *      'asset'     => Section,
 *      'liability' => Section,
 *      'equity'    => Section,
 *   ],
 *   'totals'     => [
 *      'asset'           => float,
 *      'liability'       => float,
 *      'equity'          => float,
 *      'liab_plus_eq'    => float,
 *      'difference'      => float,   // asset - (liab+equity)
 *      'is_balanced'     => bool,
 *   ],
 * ]
 *
 * Section shape:
 * [
 *   'title'    => 'ASET',
 *   'groups'   => [
 *      [
 *        'title'    => 'Aset Lancar',
 *        'rows'     => [ ['COA','COADesc','amount'], ... ],
 *        'subtotal' => float,
 *      ],
 *      ...
 *   ],
 *   'total'    => float,
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

    public function build(iterable $rawRows, string $endDate): array
    {
        $sections = [
            'asset'     => ['title' => 'ASET',       'groups' => [], 'total' => 0.0],
            'liability' => ['title' => 'LIABILITAS', 'groups' => [], 'total' => 0.0],
            'equity'    => ['title' => 'EKUITAS',    'groups' => [], 'total' => 0.0],
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
                    'subtotal' => 0.0,
                ];
            }

            $amount = (float) $row->Amount;

            $buffers[$sectionKey][$groupKey]['rows'][] = [
                'COA'     => $row->COA,
                'COADesc' => $row->COADesc,
                'amount'  => $amount,
            ];
            $buffers[$sectionKey][$groupKey]['subtotal'] += $amount;
        }

        // -- materialize buffers into ordered group arrays + section totals
        foreach ($buffers as $sectionKey => $groupBuffer) {
            $groups = array_values($groupBuffer);
            $sections[$sectionKey]['groups'] = $groups;
            $sections[$sectionKey]['total']  = array_sum(array_column($groups, 'subtotal'));
        }

        $totalAsset   = $sections['asset']['total'];
        $totalLiab    = $sections['liability']['total'];
        $totalEquity  = $sections['equity']['total'];
        $liabPlusEq   = $totalLiab + $totalEquity;
        $difference   = $totalAsset - $liabPlusEq;

        return [
            'period_end' => $endDate,
            'sections'   => $sections,
            'totals'     => [
                'asset'        => $totalAsset,
                'liability'    => $totalLiab,
                'equity'       => $totalEquity,
                'liab_plus_eq' => $liabPlusEq,
                'difference'   => $difference,
                'is_balanced'  => abs($difference) <= $this->balanceTolerance,
            ],
        ];
    }
}
