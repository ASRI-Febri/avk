<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class COGSCalculationController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'AVK';

        $this->data['form_title'] = 'Perhitungan HPP';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'Perhitungan HPP');

        // URL
        $this->data['url_create'] = url('mc-cogs-calculation/create');
        $this->data['url_search'] = url('mc-cogs-calculation-list');
        $this->data['url_cancel'] = url('mc-cogs-calculation');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Daftar Periode Perhitungan HPP';
        $this->data['form_remark'] = 'Daftar periode perhitungan HPP / COGS valas yang sudah diproses.';

        if ($access == TRUE) {
            $this->data['table_header'] = array('No', 'COGSPeriod', 'Periode', 'Action');
            $this->data['table_footer'] = array('', '', '', 'Action');
            $this->data['array_filter'] = array();

            $this->data['view'] = 'money_changer/cogs_calculation_list';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    public function inquiry_data(Request $request)
    {
        $rows = DB::connection('sqlsrv')->select("
            SELECT COGSPeriod
            FROM MC_T_COGSValasCalculation
            GROUP BY COGSPeriod
            ORDER BY COGSPeriod ASC
        ");

        $bulan = [
            '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
            '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
            '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
        ];

        $aaData = [];
        $no = 1;
        foreach ($rows as $row) {
            $period = trim($row->COGSPeriod);
            $year = substr($period, 0, 4);
            $month = substr($period, 4, 2);
            $periodDesc = isset($bulan[$month]) ? $bulan[$month] . ' ' . $year : $period;

            $aaData[] = [
                'RowNumber'  => $no++,
                'COGSPeriod' => $period,
                'PeriodDesc' => $periodDesc,
            ];
        }

        $output = [
            'sEcho' => intval($request->input('draw')),
            'iTotalRecords' => count($aaData),
            'iTotalDisplayRecords' => count($aaData),
            'aaData' => $aaData,
        ];

        echo json_encode($output);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Perhitungan HPP';
        $this->data['form_sub_title'] = 'Proses Perhitungan HPP Baru';
        $this->data['form_desc'] = 'Proses Perhitungan HPP';
        $this->data['form_remark'] = 'Masukkan periode COGS (YYYYMM) yang akan diproses, contoh: 202605.';
        $this->data['state'] = 'create';

        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {
            $this->data['fields'] = (object) [
                'COGSPeriod' => date('Ym'),
                'RecordStatus' => 'A',
            ];

            $this->data['url_save_header'] = url('/mc-cogs-calculation/save');

            $this->data['view'] = 'money_changer/cogs_calculation_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // SAVE (PROCESS)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'COGSPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'COGSPeriod.required' => 'COGS Period belum diisi!',
            'COGSPeriod.regex'    => 'COGS Period harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('COGSPeriod');
        $month = (int) substr($period, 4, 2);
        if ($month < 1 || $month > 12) {
            return $this->validation_fails(
                ['COGSPeriod' => ['Bulan pada COGS Period tidak valid (01-12)!']],
                ''
            );
        }

        $param = [];
        $param['IDX_M_Company'] = 1;
        $param['COGSPeriod']    = $period;
        $param['UserID']        = 'XXX' . $this->data['user_id'];

        $this->exec_sp('[dbo].[USP_MC_COGSValasCalculation]', $param, 'list', 'sqlsrv');

        return redirect(url('/mc-cogs-calculation/success') . '?COGSPeriod=' . $period);
    }

    // =========================================================================================
    // GENERATE JOURNAL - SHOW MODAL
    // =========================================================================================
    public function generate_journal(Request $request)
    {
        $period = trim($request->input('COGSPeriod', ''));

        // Journal period mengikuti tahun & bulan dari periode yang dipilih (format YYYYMM).
        $journalPeriod = (strlen($period) >= 6) ? substr($period, 0, 6) : $period;

        $bulan = [
            '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
            '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
            '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
        ];

        $periodDesc = $journalPeriod;
        if (strlen($journalPeriod) == 6) {
            $year = substr($journalPeriod, 0, 4);
            $month = substr($journalPeriod, 4, 2);
            $periodDesc = isset($bulan[$month]) ? $bulan[$month] . ' ' . $year : $journalPeriod;
        }

        $this->data['fields'] = (object) [
            'JournalPeriod' => $journalPeriod,
            'RecordStatus'  => 'A',
        ];
        $this->data['state'] = 'create';
        $this->data['form_desc'] = 'Generate Jurnal HPP - ' . $periodDesc;
        $this->data['url_save_modal'] = url('mc-cogs-calculation/save-generate-journal');

        return view('money_changer/cogs_calculation_generate_journal_form', $this->data);
    }

    // =========================================================================================
    // GENERATE JOURNAL - EXECUTE STORED PROCEDURE
    // =========================================================================================
    public function save_generate_journal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'JournalPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'JournalPeriod.required' => 'Journal Period belum diisi!',
            'JournalPeriod.regex'    => 'Journal Period harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $period = $request->input('JournalPeriod');
        $month = (int) substr($period, 4, 2);
        if ($month < 1 || $month > 12) {
            return $this->validation_fails(
                ['JournalPeriod' => ['Bulan pada Journal Period tidak valid (01-12)!']],
                ''
            );
        }

        $param = [];
        $param['IDX_M_Company'] = 1;
        $param['COGSPeriod']    = $period;
        $param['UserID']        = 'XXX' . $this->data['user_id'];

        $rows = $this->exec_sp('[dbo].[USP_MC_GenerateJournalCOGSValas]', $param, 'list', 'sqlsrv');

        $errors = '';
        foreach ($rows as $row) {
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'error') {
                $errors .= '<span style="display:block;" class="text-danger">' . trim($row->LogDesc) . '</span>';
            }
        }

        if ($errors !== '') {
            echo json_encode(['flag' => 'error', 'id' => '', 'message' => $errors]);
            return;
        }

        echo json_encode([
            'flag' => 'success',
            'id'   => '',
            'url'  => url('mc-cogs-calculation'),
        ]);
    }

    // =========================================================================================
    // SUCCESS PAGE
    // =========================================================================================
    public function success(Request $request)
    {
        $period = $request->input('COGSPeriod', '');

        $bulan = [
            '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
            '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
            '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
        ];

        $periodDesc = '';
        if (strlen($period) == 6) {
            $year = substr($period, 0, 4);
            $month = substr($period, 4, 2);
            $periodDesc = isset($bulan[$month]) ? $bulan[$month] . ' ' . $year : $period;
        }

        $this->data['form_sub_title'] = 'Proses Perhitungan HPP';
        $this->data['form_title']     = 'Perhitungan HPP';
        $this->data['COGSPeriod']     = $period;
        $this->data['PeriodDesc']     = $periodDesc;
        $this->data['url_report']     = url('mc-rpt-cogs-calculation');
        $this->data['url_back']       = url('mc-cogs-calculation');

        array_push($this->data['breads'], 'Success');

        $this->data['view'] = 'money_changer/cogs_calculation_success';
        return view($this->data['view'], $this->data);
    }
}
