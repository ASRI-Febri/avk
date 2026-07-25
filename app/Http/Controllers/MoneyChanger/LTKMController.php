<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class LTKMController extends MyController
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

        $this->data['form_title'] = 'LTKM';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'LTKM');

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
    // PROSES LTKM - FORM PILIH PERIODE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Proses LTKM';
        $this->data['form_sub_title'] = 'Proses LTKM (Laporan Transaksi Keuangan Mencurigakan)';
        $this->data['form_remark'] = 'Pilih bulan dan tahun yang akan diproses. Sistem akan menampilkan seluruh transaksi penjualan
            pada periode tersebut (tidak ada batasan nominal). Tandai transaksi yang ditetapkan sebagai TKM
            beserta indikatornya, lalu lakukan proses data. Batas waktu lapor 3 hari sejak ditetapkan sebagai TKM.';
        $this->data['state'] = 'create';

        array_push($this->data['breads'], 'Proses');

        if ($access == TRUE) {
            $this->period_dropdown();

            $this->data['PeriodMonth'] = date('m');
            $this->data['PeriodYear'] = date('Y');

            $this->data['url_preview'] = url('mc-ltkm/preview');
            $this->data['url_cancel'] = url('mc-ltkm');

            $this->data['view'] = 'money_changer/ltkm_process_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // PROSES LTKM - PREVIEW DATA
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
        $param['LTKMPeriod'] = 'XXX' . $period;

        $this->data['records'] = $this->exec_sp('USP_MC_LTKM_Preview', $param, 'list', 'sqlsrv');

        $this->data['form_title'] = 'Proses LTKM';
        $this->data['form_sub_title'] = 'Preview Data LTKM';
        $this->data['LTKMPeriod'] = $period;
        $this->data['PeriodDesc'] = $this->period_desc($period);
        $this->data['TKMDate'] = date('Y-m-d');

        $this->data['url_process'] = url('mc-ltkm/process');
        $this->data['url_cancel'] = url('mc-ltkm');

        array_push($this->data['breads'], 'Preview');

        $this->data['view'] = 'money_changer/ltkm_process_preview';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // PROSES LTKM - SIMPAN TRANSAKSI TERPILIH KE MC_T_LTKM
    // =========================================================================================
    public function process(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'LTKMPeriod' => ['required', 'regex:/^\d{6}$/'],
            'TKMDate' => ['required', 'date_format:Y-m-d'],
        ], [
            'LTKMPeriod.required' => 'Periode belum diisi!',
            'LTKMPeriod.regex' => 'Periode harus 6 angka dengan format YYYYMM!',
            'TKMDate.required' => 'Tanggal penetapan TKM belum diisi!',
            'TKMDate.date_format' => 'Tanggal penetapan TKM harus format YYYY-MM-DD!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('LTKMPeriod');
        $tkm_date = $request->input('TKMDate');
        $selected = $request->input('selected', []);
        $indicators = $request->input('TKMIndicator', []);

        // HAPUS DATA PERIODE, LALU SIMPAN ULANG TRANSAKSI YANG DITANDAI
        $param_clear['LTKMPeriod'] = 'XXX' . $period;
        $this->exec_sp('USP_MC_LTKM_Clear', $param_clear, 'list', 'sqlsrv');

        $total = 0;
        foreach ($selected as $idx_sales_order) {
            if (!is_numeric($idx_sales_order)) {
                continue;
            }

            $indicator = isset($indicators[$idx_sales_order]) ? $indicators[$idx_sales_order] : '';
            $indicator = str_replace("'", "''", trim($indicator));

            $param = [];
            $param['LTKMPeriod'] = 'XXX' . $period;
            $param['IDX_T_SalesOrder'] = $idx_sales_order;
            $param['TKMDate'] = $tkm_date;
            $param['TKMIndicator'] = 'XXX' . $indicator;
            $param['UserID'] = 'XXX' . $this->data['user_id'];

            $this->exec_sp('USP_MC_LTKM_Save', $param, 'list', 'sqlsrv');
            $total++;
        }

        return redirect(url('/mc-ltkm/success') . '?LTKMPeriod=' . $period . '&Total=' . $total);
    }

    // =========================================================================================
    // PROSES LTKM - SUCCESS PAGE
    // =========================================================================================
    public function success(Request $request)
    {
        $period = $request->input('LTKMPeriod', '');

        $this->data['form_title'] = 'Proses LTKM';
        $this->data['form_sub_title'] = 'Proses LTKM';
        $this->data['LTKMPeriod'] = $period;
        $this->data['PeriodDesc'] = $this->period_desc($period);
        $this->data['Total'] = (int) $request->input('Total', 0);
        $this->data['url_report'] = url('mc-rpt-ltkm');
        $this->data['url_back'] = url('mc-ltkm');

        array_push($this->data['breads'], 'Success');

        $this->data['view'] = 'money_changer/ltkm_process_success';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // LAPORAN LTKM - FORM PILIH PERIODE
    // =========================================================================================
    public function report()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Laporan LTKM';
        $this->data['form_sub_title'] = 'Laporan Transaksi Keuangan Mencurigakan (LTKM)';
        $this->data['form_desc'] = 'Laporan LTKM';
        $this->data['form_remark'] = 'Laporan transaksi keuangan mencurigakan (tidak ada batasan nominal transaksi)
            dari hasil Proses LTKM. Jalankan Proses LTKM terlebih dahulu untuk periode yang dipilih.';

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
            $this->data['url_show_repoprt'] = url('mc-rpt-ltkm');

            return view('money_changer/rpt_ltkm_form', $this->data);
        } else {
            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // LAPORAN LTKM - TAMPILKAN LAPORAN
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
            $this->data['page_title'] = 'LAPORAN TRANSAKSI KEUANGAN MENCURIGAKAN (LTKM)';
            $this->data['title'] = 'Laporan LTKM';
            $this->data['form_title'] = 'Laporan LTKM';
            $this->data['LTKMPeriod'] = $period;
            $this->data['PeriodDesc'] = $this->period_desc($period);

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['LTKMPeriod'] = 'XXX' . $period;

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_LTKM_List', $param, 'list', 'sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_ltkm_report';
            return view($this->data['view'], $this->data);
        }
    }
}
