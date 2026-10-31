<?php

namespace Tests\Unit;

use App\Services\BankStatement\LedgerReconciler;
use PHPUnit\Framework\TestCase;

class LedgerReconcilerTest extends TestCase
{
    private function bank($id, $date, $in, $out, $journal = null)
    {
        return ['id' => $id, 'date' => $date, 'datetime' => $date . ' 10:00:00', 'remark' => "B$id",
                'in' => $in, 'out' => $out, 'journal_id' => $journal];
    }

    private function ledger($id, $date, $in, $out, $journal = null, $inPeriod = true)
    {
        return ['id' => $id, 'journal_id' => $journal ?: 1000 + $id, 'voucher' => "V$id", 'date' => $date,
                'remark' => "L$id", 'in' => $in, 'out' => $out, 'posted' => true, 'in_period' => $inPeriod];
    }

    private function types(array $result)
    {
        $types = [];
        foreach ($result['groups'] as $group) {
            $types[] = $group['type'] . ':' . implode(',', array_column($group['bank'], 'id'))
                . '|' . implode(',', array_column($group['ledger'], 'id'));
        }
        sort($types);

        return $types;
    }

    public function testMatchesByAmountDirectionAndNearestDate()
    {
        $result = (new LedgerReconciler())->reconcile(
            [$this->bank(1, '2026-09-21', 0, 30000), $this->bank(2, '2026-09-23', 0, 30000), $this->bank(3, '2026-09-05', 500, 0)],
            [$this->ledger(1, '2026-09-23', 0, 30000), $this->ledger(2, '2026-09-05', 0, 500), $this->ledger(3, '2026-09-06', 500, 0)]
        );

        $this->assertSame(['bank_only:1|', 'date:3|3', 'exact:2|1', 'ledger_only:|2'], $this->types($result));
    }

    public function testMatchesCombinationsOnBothSides()
    {
        $result = (new LedgerReconciler())->reconcile(
            [$this->bank(1, '2026-09-01', 0, 39367), $this->bank(2, '2026-09-01', 10270, 0), $this->bank(3, '2026-09-01', 450, 0)],
            [$this->ledger(1, '2026-09-01', 0, 11180), $this->ledger(2, '2026-09-01', 0, 28187), $this->ledger(3, '2026-09-01', 10720, 0)]
        );

        $this->assertSame(['combo:1|1,2', 'combo:2,3|3'], $this->types($result));
    }

    public function testMatchesRowsJournaledFromStatementAndFlagsDifference()
    {
        $result = (new LedgerReconciler())->reconcile(
            [$this->bank(1, '2026-09-28', 0, 4500, 77), $this->bank(2, '2026-09-28', 0, 2800, 77), $this->bank(3, '2026-09-30', 0, 13, 78)],
            [$this->ledger(1, '2026-09-28', 0, 7300, 77), $this->ledger(2, '2026-09-30', 0, 12, 78)]
        );

        $this->assertSame(['link:1,2|1', 'link_diff:3|2'], $this->types($result));
    }

    public function testIgnoresUnmatchedLedgerLinesOutsidePeriod()
    {
        $result = (new LedgerReconciler())->reconcile(
            [$this->bank(1, '2026-09-30', 900, 0)],
            [$this->ledger(1, '2026-10-01', 900, 0, null, false), $this->ledger(2, '2026-10-02', 50, 0, null, false)]
        );

        $this->assertSame(['date:1|1'], $this->types($result));
        $this->assertSame(0.0, (float) $result['summary']['ledger_in']);
    }

    public function testGroupsAdjustedTransactionsWithAdjustmentJournal()
    {
        $result = (new LedgerReconciler())->reconcile(
            [$this->bank(1, '2026-09-02', 1500000, 0), $this->bank(2, '2026-09-02', 2050, 0)],
            [$this->ledger(1, '2026-09-02', 1497950, 0), $this->ledger(2, '2026-09-02', 2050, 0, 90), $this->ledger(3, '2026-09-02', 2050, 0)],
            [90 => ['bank' => [1], 'ledger' => [1]]]
        );

        $this->assertSame(['adjusted:1|1,2', 'exact:2|3'], $this->types($result));
    }
}
