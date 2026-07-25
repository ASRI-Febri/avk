<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class LTKTController extends MyController
{
    protected $month_names = [
        '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
        '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
        '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
    ];

    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'AVK';

        $this->data['form_title'] = 'LTKT';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'LTKT');

        parent::__construct($request);
    }

    protected function period_desc($period)
    {
        if (strlen($period) != 6) {
            return $period;
        }

        $year = substr($period, 0, 4);
        $month = substr($period, 4, 2);

        return isset($this->month_names[$month]) ? $this->month_names[$month] . ' ' . $year : $period;
    }

    protected function period_dropdown()
    {
        $this->data['dd_month'] = $this->month_names;

        $years = [];
        for ($y = (int) date('Y'); $y >= (int) date('Y') - 5; $y--) {
            $years[$y] = $y;
        }
        $this->data['dd_year'] = $years;
    }

    // =========================================================================================
    // PROSES LTKT - FORM PILIH PERIODE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Proses LTKT';
        $this->data['form_sub_title'] = 'Proses LTKT (Laporan Transaksi Keuangan Tunai)';
        $this->data['form_remark'] = 'Pilih bulan dan tahun yang akan diproses. Sistem akan menampilkan preview transaksi penjualan
            dengan total pembayaran tunai per nasabah per hari sebesar Rp 500.000.000 ke atas.
            Batas waktu lapor 14 hari kerja sejak tanggal transaksi.';
        $this->data['state'] = 'create';

        array_push($this->data['breads'], 'Proses');

        if ($access == TRUE) {
            $this->period_dropdown();

            $this->data['PeriodMonth'] = date('m');
            $this->data['PeriodYear'] = date('Y');

            $this->data['url_preview'] = url('mc-ltkt/preview');
            $this->data['url_cancel'] = url('mc-ltkt');

            $this->data['view'] = 'money_changer/ltkt_process_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // PROSES LTKT - PREVIEW DATA
    // =========================================================================================
    public function preview(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PeriodMonth' => ['required', 'regex:/^(0[1-9]|1[0-2])$/'],
            'PeriodYear' => ['required', 'regex:/^\d{4}$/'],
        ], [
            'PeriodMonth.required' => 'Bulan belum dipilih!',
            'PeriodMonth.regex' => 'Bulan tidak valid!',
            'PeriodYear.required' => 'Tahun belum dipilih!',
            'PeriodYear.regex' => 'Tahun tidak valid!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('PeriodYear') . $request->input('PeriodMonth');

        // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
        $param['LTKTPeriod'] = 'XXX' . $period;

        $this->data['records'] = $this->exec_sp('USP_MC_LTKT_Preview', $param, 'list', 'sqlsrv');

        $this->data['processed_rows'] = 0;
        foreach ($this->data['records'] as $row) {
            $this->data['processed_rows'] = $row->ProcessedRows;
            break;
        }

        $this->data['form_title'] = 'Proses LTKT';
        $this->data['form_sub_title'] = 'Preview Data LTKT';
        $this->data['LTKTPeriod'] = $period;
        $this->data['PeriodDesc'] = $this->period_desc($period);

        $this->data['url_process'] = url('mc-ltkt/process');
        $this->data['url_cancel'] = url('mc-ltkt');

        array_push($this->data['breads'], 'Preview');

        $this->data['view'] = 'money_changer/ltkt_process_preview';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // PROSES LTKT - SIMPAN DATA KE MC_T_LTKT
    // =========================================================================================
    public function process(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'LTKTPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'LTKTPeriod.required' => 'Periode belum diisi!',
            'LTKTPeriod.regex' => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('LTKTPeriod');

        // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
        $param['LTKTPeriod'] = 'XXX' . $period;
        $param['UserID'] = 'XXX' . $this->data['user_id'];

        $this->exec_sp('USP_MC_LTKT_Process', $param, 'list', 'sqlsrv');

        return redirect(url('/mc-ltkt/success') . '?LTKTPeriod=' . $period);
    }

    // =========================================================================================
    // PROSES LTKT - SUCCESS PAGE
    // =========================================================================================
    public function success(Request $request)
    {
        $period = $request->input('LTKTPeriod', '');

        $this->data['form_title'] = 'Proses LTKT';
        $this->data['form_sub_title'] = 'Proses LTKT';
        $this->data['LTKTPeriod'] = $period;
        $this->data['PeriodDesc'] = $this->period_desc($period);
        $this->data['url_report'] = url('mc-rpt-ltkt');
        $this->data['url_back'] = url('mc-ltkt');

        array_push($this->data['breads'], 'Success');

        $this->data['view'] = 'money_changer/ltkt_process_success';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // LAPORAN LTKT - FORM PILIH PERIODE
    // =========================================================================================
    public function report()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Laporan LTKT';
        $this->data['form_sub_title'] = 'Laporan Transaksi Keuangan Tunai (LTKT)';
        $this->data['form_desc'] = 'Laporan LTKT';
        $this->data['form_remark'] = 'Laporan transaksi keuangan tunai (nominal Rp 500.000.000 ke atas per nasabah per hari)
            dari hasil Proses LTKT. Jalankan Proses LTKT terlebih dahulu untuk periode yang dipilih.';

        // BREADCRUMB
        array_push($this->data['breads'], 'Laporan');

        $this->data['state'] = 'update';

        if ($access == TRUE) {
            $this->data['fields'] = (object) array();

            $this->period_dropdown();

            // DEFAULT PARAMETER
            $this->data['PeriodMonth'] = date('m');
            $this->data['PeriodYear'] = date('Y');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-ltkt');

            return view('money_changer/rpt_ltkt_form', $this->data);
        } else {
            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // LAPORAN LTKT - TAMPILKAN LAPORAN
    // =========================================================================================
    public function report_show(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'PeriodMonth' => 'required',
            'PeriodYear' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        } else {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            $period = $request->input('PeriodYear') . $request->input('PeriodMonth');

            // REPORT INFORMATION
            $this->data['page_title'] = 'LAPORAN TRANSAKSI KEUANGAN TUNAI (LTKT)';
            $this->data['title'] = 'Laporan LTKT';
            $this->data['form_title'] = 'Laporan LTKT';
            $this->data['LTKTPeriod'] = $period;
            $this->data['PeriodDesc'] = $this->period_desc($period);

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['LTKTPeriod'] = 'XXX' . $period;

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_LTKT_List', $param, 'list', 'sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_ltkt_report';
            return view($this->data['view'], $this->data);
        }
    }
}
