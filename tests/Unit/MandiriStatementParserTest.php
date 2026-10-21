<?php

namespace Tests\Unit;

use App\Services\BankStatement\MandiriStatementParser;
use PHPUnit\Framework\TestCase;

class MandiriStatementParserTest extends TestCase
{
    /**
     * Teks meniru hasil ekstraksi PDF Kopra by Mandiri, termasuk remark yang
     * terpotong ke halaman berikutnya dan baris biaya transfer.
     */
    private function statementText()
    {
        return implode("\n", [
            'Account Statement',
            'Created 01 Oct 2026, 09:45:05',
            'Account Statement Summary',
            "Opening Balance\tTotal Amount DebitedNo. of Debit",
            "1,000,000.00\t3\t515,000.00",
            "Closing Balance\tTotal Amount CreditedNo. of Credit",
            "1,985,000.00\t2\t1,500,000.00",
            "Account No.\tAccount Name\tAlias",
            "1270000000001\tPT CONTOH\tPT CONTOH",
            "Period\tCurrency\tBranch",
            "IDR01 Sep 2026 - 30 Sep 2026\tKCP Contoh",
            "CreditReference No.Remark\tDebit\tBalancePosting Date",
            '01 Sep 2026,',
            '09:07:28',
            '20260901BMRIIDJA010O9',
            '930716135',
            'CENAIDJA/BUDI A-',
            '780266099102',
            "-\t500,000.00\t0.00 500,000.00",
            '01 Sep 2026,',
            '09:07:28',
            '20260901BMRIIDJA010O9',
            '930716135            99102',
            "-\t2,500.00\t0.00 497,500.00",
            '02 Sep 2026,',
            '10:00:00',
            '20260902CENAIDJA010O0',
            '224792412',
            "-\t0.00 1,000,000.00 1,497,500.00",
            'Page 1 ofkoprabymandiri.com/help 2For further questions, v',
            'isit Kopra by Mandiri Help Center: ',
            'Account Statement',
            'Created 01 Oct 2026, 09:45:05',
            'CENAIDJA/SITI',
            '437180292999102',
            "CreditReference No.Remark\tDebit\tBalancePosting Date",
            '10 Sep 2026,',
            '09:54:05',
            'tukar uang 600 real 600 real',
            'MCM InhouseTrf DARI ANI',
            "600 real\t0.00 500,000.00 1,997,500.00",
            '30 Sep 2026,',
            '23:59:00 Biaya Adm 12708',
            "-\t12,500.00\t0.00 1,985,000.00",
        ]);
    }

    public function testParsesHeaderAndRows()
    {
        $result = (new MandiriStatementParser())->parseText($this->statementText());

        $this->assertSame('1270000000001', $result['header']['account_no']);
        $this->assertSame('2026-09-01', $result['header']['period_start']);
        $this->assertSame('2026-09-30', $result['header']['period_end']);
        $this->assertSame([], $result['warnings']);

        $rows = $result['rows'];
        $this->assertCount(5, $rows);
        $this->assertSame('2026-09-02 10:00:00', $rows[2]['posting_date']);
        $this->assertSame('20260902CENAIDJA010O0 224792412 CENAIDJA/SITI 437180292999102', $rows[2]['remark']);
        $this->assertSame('600 real', $rows[3]['reference_no']);
        $this->assertSame('Biaya Adm 12708', $rows[4]['remark']);
        $this->assertSame([false, true, false, false, false], array_column($rows, 'is_admin_fee'));
    }

    public function testWarnsWhenBalanceDoesNotMatch()
    {
        $text = str_replace('1,497,500.00', '1,497,000.00', $this->statementText());

        $result = (new MandiriStatementParser())->parseText($text);

        $this->assertNotEmpty($result['warnings']);
    }
}
