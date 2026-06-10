<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

class AnalyticController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'AVK';
        $this->data['module_name'] = 'Money Changer';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        $this->data['state'] = 'read';

        parent::__construct($request);
    }

    // Resolve report period (YYYYMM) -> start/end date + as-of date.
    private function resolve_period(Request $request)
    {
        $period = $request->input('Period', date('Ym'));
        if (!preg_match('/^\d{6}$/', $period)) {
            $period = date('Ym');
        }

        $year  = (int) substr($period, 0, 4);
        $month = (int) substr($period, 4, 2);
        if ($month < 1 || $month > 12) {
            $period = date('Ym');
            $year  = (int) substr($period, 0, 4);
            $month = (int) substr($period, 4, 2);
        }

        $start = sprintf('%04d-%02d-01', $year, $month);
        $end   = date('Y-m-t', strtotime($start));

        // Jika periode = bulan berjalan, gunakan tanggal hari ini sebagai as-of.
        $asOf = ($period === date('Ym')) ? date('Y-m-d') : $end;

        $bulan = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember',
        ];

        return [
            'period'      => $period,
            'period_desc' => $bulan[$month] . ' ' . $year,
            'start'       => $start,
            'end'         => $end,
            'as_of'       => $asOf,
        ];
    }

    private function base(Request $request, $title, $sub, $remark, $activeId)
    {
        $p = $this->resolve_period($request);

        $this->data['form_title']     = $title;
        $this->data['form_sub_title'] = $sub;
        $this->data['form_remark']    = $remark;

        $this->data['breads'] = array('Money Changer', 'Analytic', $sub);

        $this->data['Period']      = $p['period'];
        $this->data['PeriodDesc']  = $p['period_desc'];
        $this->data['StartDate']   = $p['start'];
        $this->data['EndDate']     = $p['end'];
        $this->data['AsOfDate']    = $p['as_of'];
        $this->data['active_id']   = $activeId;

        return $p;
    }

    // =========================================================================================
    // 1. PROFITABILITAS & MARGIN
    // =========================================================================================
    public function profitability(Request $request)
    {
        $p = $this->base($request, 'Analytic', 'Profitabilitas & Margin',
            'Tren laba (Revenue, HPP, Laba Bersih) dan analisa spread beli-jual per mata uang.',
            'nav-li-analytic-profitability');

        $this->data['records_trend'] = $this->exec_sp('USP_MC_A_Profitability_Trend',
            ['AsOfDate' => $p['as_of']], 'list', 'sqlsrv');

        $this->data['records_margin'] = $this->exec_sp('USP_MC_A_Margin_ByCurrency',
            ['StartDate' => $p['start'], 'EndDate' => $p['end']], 'list', 'sqlsrv');

        return view('money_changer.analytic_profitability', $this->data);
    }

    // =========================================================================================
    // 2. POSISI VALAS & EKSPOSUR FX
    // =========================================================================================
    public function position(Request $request)
    {
        $p = $this->base($request, 'Analytic', 'Posisi Valas & Eksposur FX',
            'Net open position per mata uang, nilai eksposur (IDR), dan konsentrasi risiko.',
            'nav-li-analytic-position');

        $this->data['records_position'] = $this->exec_sp('USP_MC_A_Position_ByCurrency',
            ['AsOfDate' => $p['as_of']], 'list', 'sqlsrv');

        return view('money_changer.analytic_position', $this->data);
    }

    // =========================================================================================
    // 3. VOLUME & PERPUTARAN
    // =========================================================================================
    public function volume(Request $request)
    {
        $p = $this->base($request, 'Analytic', 'Volume & Perputaran',
            'Tren volume jual/beli, jumlah transaksi, rata-rata tiket, dan kontribusi per mata uang.',
            'nav-li-analytic-volume');

        $this->data['records_trend'] = $this->exec_sp('USP_MC_A_Volume_Trend',
            ['AsOfDate' => $p['as_of']], 'list', 'sqlsrv');

        $this->data['records_currency'] = $this->exec_sp('USP_MC_A_Volume_ByCurrency',
            ['StartDate' => $p['start'], 'EndDate' => $p['end']], 'list', 'sqlsrv');

        return view('money_changer.analytic_volume', $this->data);
    }

    // =========================================================================================
    // 4. LIKUIDITAS & MODAL KERJA
    // =========================================================================================
    public function liquidity(Request $request)
    {
        $p = $this->base($request, 'Analytic', 'Likuiditas & Modal Kerja',
            'Posisi kas & bank, persediaan valas, piutang/hutang, modal kerja, dan tren saldo kas.',
            'nav-li-analytic-liquidity');

        $summary = $this->exec_sp('USP_MC_A_Liquidity_Summary',
            ['AsOfDate' => $p['as_of']], 'list', 'sqlsrv');
        $this->data['summary'] = (count($summary) > 0) ? $summary[0] : null;

        $this->data['records_trend'] = $this->exec_sp('USP_MC_A_Cash_Trend',
            ['AsOfDate' => $p['as_of']], 'list', 'sqlsrv');

        return view('money_changer.analytic_liquidity', $this->data);
    }
}
