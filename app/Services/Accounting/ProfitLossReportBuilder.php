<?php

namespace App\Services\Accounting;

/**
 * Builds a structured Profit & Loss report from raw stored-procedure rows
 * returned by USP_GL_R_ProfitLoss.
 *
 * Output shape (designed to be view-friendly and recursion-friendly):
 *
 * [
 *   'period'   => '202604',
 *   'sections' => [
 *      [
 *        'key'    => 'gross_profit',
 *        'title'  => 'PERHITUNGAN LABA KOTOR',
 *        'nodes'  => [ Node, Node, ... ],
 *        'result' => ['label' => 'PENDAPATAN KOTOR', 'amount' => 1234.56],
 *      ],
 *      ...
 *   ],
 *   'summary'  => [
 *      'total_pendapatan' => N,
 *      'total_biaya'      => N,
 *      'laba_bersih'      => N,
 *   ],
 * ]
 *
 * Node shape (recursive — view does not need to know depth):
 * [
 *   'title'    => 'PENDAPATAN USAHA',
 *   'level'    => 0,
 *   'sign'     => +1 | -1,   // sign applied when contributing to parent result
 *   'rows'     => [ { COA, COADesc, amount, ... }, ... ],
 *   'children' => [ Node, ... ],
 *   'subtotal' => float,
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
            'sections' => $sections,
            'summary'  => $summary,
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
     * Normalize raw SP row -> display row.
     * IC accounts have natural credit balance (negative) — flip sign so amounts display positive.
     */
    private function normalizeRow($row): array
    {
        $amount = ($row->AccountType === 'IC')
            ? ($row->BEBalanceAmount * -1)
            : $row->BEBalanceAmount;

        return [
            'COA'      => $row->COA,
            'COADesc'  => $row->COADesc,
            'amount'   => (float) $amount,
            'raw'      => $row,
        ];
    }

    private function makeLeafNode(string $title, array $rows, int $sign = 1, int $level = 0): array
    {
        $subtotal = array_sum(array_column($rows, 'amount'));

        return [
            'title'    => $title,
            'level'    => $level,
            'sign'     => $sign,
            'rows'     => $rows,
            'children' => [],
            'subtotal' => (float) $subtotal,
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
                'label'  => 'PENDAPATAN KOTOR (Pendapatan Usaha - HPP)',
                'amount' => $this->sumNodes($nodes),
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
                'label'  => 'SUBTOTAL LAIN-LAIN (Pendapatan Lain-lain - (Biaya Operasional + Biaya Lain-lain))',
                'amount' => $this->sumNodes($nodes),
            ],
        ];
    }

    private function buildSummary(array $buckets): array
    {
        $total_pendapatan = array_sum(array_column($buckets['PO'], 'amount'))
                          + array_sum(array_column($buckets['PL'], 'amount'));

        $total_biaya      = array_sum(array_column($buckets['HPP'], 'amount'))
                          + array_sum(array_column($buckets['BO'],  'amount'))
                          + array_sum(array_column($buckets['BL'],  'amount'));

        return [
            'total_pendapatan' => (float) $total_pendapatan,
            'total_biaya'      => (float) $total_biaya,
            'laba_bersih'      => (float) ($total_pendapatan - $total_biaya),
        ];
    }

    /**
     * Sum a list of nodes, applying each node's sign.
     * Recursive — handles arbitrarily deep trees.
     */
    private function sumNodes(array $nodes): float
    {
        $sum = 0.0;
        foreach ($nodes as $node) {
            $value = $node['subtotal'];
            if (!empty($node['children'])) {
                $value += $this->sumNodes($node['children']);
            }
            $sum += $node['sign'] * $value;
        }
        return $sum;
    }
}
