<?php

namespace App\Services\Accounting;

/**
 * Builds a structured Profit & Loss report from raw stored-procedure rows
 * returned by USP_GL_R_ProfitLoss.
 *
 * Every amount is provided in three flavours (columns):
 *   - prior   : akumulasi awal tahun s/d bulan sebelum periode (BBBalanceAmount)
 *   - current : mutasi periode berjalan (BDebetAmount - BCreditAmount)
 *   - ytd     : year-to-date s/d akhir periode (BEBalanceAmount = prior + current)
 *
 * Output shape (designed to be view-friendly and recursion-friendly):
 *
 * [
 *   'period'   => '202606',
 *   'labels'   => ['prior' => 'Jan - Mei 2026', 'current' => 'Jun 2026', 'ytd' => 'YTD Jun 2026'],
 *   'sections' => [
 *      [
 *        'key'    => 'gross_profit',
 *        'title'  => 'PERHITUNGAN LABA KOTOR',
 *        'nodes'  => [ Node, Node, ... ],
 *        'result' => ['label' => ..., 'amount_prior' => N, 'amount_current' => N, 'amount' => N],
 *      ],
 *      ...
 *   ],
 *   'summary'  => [
 *      'total_pendapatan_prior' => N, 'total_pendapatan_current' => N, 'total_pendapatan' => N,
 *      'total_biaya_prior'      => N, 'total_biaya_current'      => N, 'total_biaya'      => N,
 *      'laba_bersih_prior'      => N, 'laba_bersih_current'      => N, 'laba_bersih'      => N,
 *   ],
 * ]
 *
 * Node shape (recursive — view does not need to know depth):
 * [
 *   'title'            => 'PENDAPATAN USAHA',
 *   'level'            => 0,
 *   'sign'             => +1 | -1,   // sign applied when contributing to parent result
 *   'rows'             => [ { COA, COADesc, amount_prior, amount_current, amount, ... }, ... ],
 *   'children'         => [ Node, ... ],
 *   'subtotal_prior'   => float,
 *   'subtotal_current' => float,
 *   'subtotal'         => float,     // ytd
 * ]
 */
class ProfitLossReportBuilder
{
    /**
     * Classification rules — single source of truth.
     * Order matters: first match wins.
     */
    private $rules = [
        'PO'  => ['account_type' => 'IC', 'group_desc' => 'Pendapatan Usaha'],
        'HPP' => ['account_type' => 'EX', 'group_desc' => 'Harga Pokok Penjualan'],
        'BO'  => ['account_type' => 'EX', 'group_id_prefix' => '6'],
        'PL'  => ['account_type' => 'IC'],
        'BL'  => ['account_type' => 'EX'],
    ];

    public function build(iterable $rawRows, string $period): array
    {
        $buckets = $this->classify($rawRows);

        $sections = [
            $this->buildGrossProfitSection($buckets),
            $this->buildOtherSection($buckets),
        ];

        $summary = $this->buildSummary($buckets);

        return [
            'period'   => $period,
            'labels'   => $this->buildColumnLabels($period),
            'sections' => $sections,
            'summary'  => $summary,
        ];
    }

    /**
     * Column labels derived from the selected period, e.g. period 202606:
     *   prior = 'Jan - Mei 2026', current = 'Jun 2026', ytd = 'YTD Jun 2026'.
     * For January the prior column has no months — label it '-'.
     */
    private function buildColumnLabels(string $period): array
    {
        $bulan = [
            1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'Mei', 6 => 'Jun',
            7 => 'Jul', 8 => 'Agu', 9 => 'Sep', 10 => 'Okt', 11 => 'Nov', 12 => 'Des',
        ];

        $year  = (int) substr($period, 0, 4);
        $month = (int) substr($period, 4, 2);

        $current = ($bulan[$month] ?? '?') . ' ' . $year;

        if ($month <= 1) {
            $prior = '-';
        } elseif ($month == 2) {
            $prior = 'Jan ' . $year;
        } else {
            $prior = 'Jan - ' . $bulan[$month - 1] . ' ' . $year;
        }

        return [
            'prior'   => $prior,
            'current' => $current,
            'ytd'     => 'YTD ' . $current,
        ];
    }

    /**
     * Walks the raw SP rows once and bins each into the right bucket.
     */
    private function classify(iterable $rawRows): array
    {
        $buckets = [
            'PO' => [], 'HPP' => [], 'BO' => [], 'PL' => [], 'BL' => [],
        ];

        foreach ($rawRows as $row) {
            $key = $this->classifyRow($row);
            $buckets[$key][] = $this->normalizeRow($row);
        }

        return $buckets;
    }

    private function classifyRow($row): string
    {
        $type      = $row->AccountType ?? '';
        $groupDesc = trim($row->COAGroupDesc ?? '');
        $groupId   = trim($row->COAGroupID ?? '');

        foreach ($this->rules as $key => $rule) {
            if (isset($rule['account_type']) && $rule['account_type'] !== $type)            continue;
            if (isset($rule['group_desc'])   && $rule['group_desc']   !== $groupDesc)       continue;
            if (isset($rule['group_id_prefix']) &&
                substr($groupId, 0, strlen($rule['group_id_prefix'])) !== $rule['group_id_prefix']) continue;

            return $key;
        }

        // Fallback — should not happen for well-formed COA, but safe default.
        return ($type === 'IC') ? 'PL' : 'BL';
    }

    /**
     * Normalize raw SP row -> display row with the three amount columns.
     * IC accounts have natural credit balance (negative) — flip sign so amounts display positive.
     */
    private function normalizeRow($row): array
    {
        $sign = ($row->AccountType === 'IC') ? -1 : 1;

        $prior   = $sign * (float) $row->BBBalanceAmount;
        $current = $sign * ((float) $row->BDebetAmount - (float) $row->BCreditAmount);
        $ytd     = $sign * (float) $row->BEBalanceAmount;

        return [
            'COA'            => $row->COA,
            'COADesc'        => $row->COADesc,
            'amount_prior'   => $prior,
            'amount_current' => $current,
            'amount'         => $ytd,
            'raw'            => $row,
        ];
    }

    private function makeLeafNode(string $title, array $rows, int $sign = 1, int $level = 0): array
    {
        return [
            'title'            => $title,
            'level'            => $level,
            'sign'             => $sign,
            'rows'             => $rows,
            'children'         => [],
            'subtotal_prior'   => (float) array_sum(array_column($rows, 'amount_prior')),
            'subtotal_current' => (float) array_sum(array_column($rows, 'amount_current')),
            'subtotal'         => (float) array_sum(array_column($rows, 'amount')),
        ];
    }

    /**
     * Section 1: Pendapatan Usaha - HPP = Pendapatan Kotor (Gross Profit)
     */
    private function buildGrossProfitSection(array $buckets): array
    {
        $nodes = [
            $this->makeLeafNode('PENDAPATAN USAHA',      $buckets['PO'],  +1),
            $this->makeLeafNode('HARGA POKOK PENJUALAN', $buckets['HPP'], -1),
        ];

        return [
            'key'    => 'gross_profit',
            'title'  => 'PERHITUNGAN LABA KOTOR',
            'nodes'  => $nodes,
            'result' => [
                'label'          => 'PENDAPATAN KOTOR (Pendapatan Usaha - HPP)',
                'amount_prior'   => $this->sumNodes($nodes, 'subtotal_prior'),
                'amount_current' => $this->sumNodes($nodes, 'subtotal_current'),
                'amount'         => $this->sumNodes($nodes, 'subtotal'),
            ],
        ];
    }

    /**
     * Section 2: Pendapatan Lain-lain - (Biaya Operasional + Biaya Lain-lain)
     */
    private function buildOtherSection(array $buckets): array
    {
        $nodes = [
            $this->makeLeafNode('PENDAPATAN LAIN-LAIN', $buckets['PL'], +1),
            $this->makeLeafNode('BIAYA OPERASIONAL',    $buckets['BO'], -1),
            $this->makeLeafNode('BIAYA LAIN-LAIN',      $buckets['BL'], -1),
        ];

        return [
            'key'    => 'other',
            'title'  => 'PENDAPATAN & BIAYA LAIN-LAIN',
            'nodes'  => $nodes,
            'result' => [
                'label'          => 'SUBTOTAL LAIN-LAIN (Pendapatan Lain-lain - (Biaya Operasional + Biaya Lain-lain))',
                'amount_prior'   => $this->sumNodes($nodes, 'subtotal_prior'),
                'amount_current' => $this->sumNodes($nodes, 'subtotal_current'),
                'amount'         => $this->sumNodes($nodes, 'subtotal'),
            ],
        ];
    }

    private function buildSummary(array $buckets): array
    {
        $summary = [];

        foreach (['amount_prior' => '_prior', 'amount_current' => '_current', 'amount' => ''] as $field => $suffix) {
            $total_pendapatan = array_sum(array_column($buckets['PO'], $field))
                              + array_sum(array_column($buckets['PL'], $field));

            $total_biaya      = array_sum(array_column($buckets['HPP'], $field))
                              + array_sum(array_column($buckets['BO'],  $field))
                              + array_sum(array_column($buckets['BL'],  $field));

            $summary['total_pendapatan' . $suffix] = (float) $total_pendapatan;
            $summary['total_biaya' . $suffix]      = (float) $total_biaya;
            $summary['laba_bersih' . $suffix]      = (float) ($total_pendapatan - $total_biaya);
        }

        return $summary;
    }

    /**
     * Sum a list of nodes on the given subtotal field, applying each node's sign.
     * Recursive — handles arbitrarily deep trees.
     */
    private function sumNodes(array $nodes, string $field = 'subtotal'): float
    {
        $sum = 0.0;
        foreach ($nodes as $node) {
            $value = $node[$field];
            if (!empty($node['children'])) {
                $value += $this->sumNodes($node['children'], $field);
            }
            $sum += $node['sign'] * $value;
        }
        return $sum;
    }
}
