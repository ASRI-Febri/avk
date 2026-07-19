<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class FADepreciationController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo']  = url('public/images/logo/accounting.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'ACCOUNTING';
        $this->data['form_title'] = 'Penyusutan Aset Tetap';
        $this->data['form_remark'] = 'Proses penyusutan bulanan aset tetap (PSAK 16)';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Fixed Asset','Penyusutan Bulanan');

        // URL
        $this->data['url_create'] = url('ac-fa-depreciation/create');
        $this->data['url_search'] = url('ac-fa-depreciation-list');
        $this->data['url_cancel'] = url('ac-fa-depreciation');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'Daftar Periode Penyusutan';
        $this->data['form_desc'] = 'Daftar periode penyusutan aset tetap yang sudah diproses';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_T_Depreciation','IDX_M_Company','DeprPeriod','Periode',
            'Jumlah Aset','Total Penyusutan','Total Fiskal','DeprStatus','Status','No Jurnal','Action');

        $this->data['table_footer'] = array('','','','','',
            '','','','','','','Action');

        $this->data['array_filter'] = array('IDX_M_Company','DeprPeriod');

        // VIEW
        $this->data['view'] = 'accounting/fa_depreciation_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_M_Company'] = $request->input('IDX_M_Company');
        $array_filter['DeprPeriod'] = $request->input('DeprPeriod');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_FA_Depreciation_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_Depreciation','IDX_M_Company','DeprPeriod','PeriodDesc',
            'TotalAsset','TotalDepr','TotalFiscalDepr','DeprStatus','DeprStatusDesc','JournalRef');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE (FORM PROSES PERHITUNGAN)
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Proses Penyusutan Bulanan';
        $this->data['form_desc'] = 'Proses Penyusutan Bulanan';
        $this->data['form_remark'] = 'Masukkan periode penyusutan (YYYYMM) yang akan dihitung, contoh: '.date('Ym').'. '
            .'Periode harus urut dan periode sebelumnya harus sudah digenerate jurnalnya.';
        $this->data['state'] = 'create';

        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();

            $this->data['fields'] = (object) [
                'IDX_M_Company' => '',
                'DeprPeriod' => date('Ym'),
                'RecordStatus' => 'A',
            ];

            $this->data['url_save_header'] = url('/ac-fa-depreciation/save');

            $this->data['view'] = 'accounting/fa_depreciation_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // SAVE (PROSES PERHITUNGAN)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => ['required'],
            'DeprPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'IDX_M_Company.required' => 'Company belum dipilih!',
            'DeprPeriod.required' => 'Periode belum diisi!',
            'DeprPeriod.regex'    => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return redirect(url('/ac-fa-depreciation/create'))
                ->withErrors($validator);
        }

        $period = $request->input('DeprPeriod');
        $month = (int) substr($period, 4, 2);
        if ($month < 1 || $month > 12) {
            return redirect(url('/ac-fa-depreciation/create'))
                ->withErrors(['DeprPeriod' => 'Bulan pada periode tidak valid (01-12)!']);
        }

        $param = [];
        $param['IDX_M_Company'] = $request->input('IDX_M_Company');
        $param['DeprPeriod']    = 'XXX' . $period;
        $param['UserID']        = 'XXX' . $this->data['user_id'];

        $rows = $this->exec_sp('[dbo].[USP_FA_Depreciation_Calculate]', $param, 'list', 'sqlsrv');

        $errors = '';
        foreach ($rows as $row) {
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'error') {
                $errors .= trim($row->LogDesc) . ' ';
            }
        }

        if ($errors !== '') {
            return redirect(url('/ac-fa-depreciation/create'))
                ->withErrors(['DeprPeriod' => $errors]);
        }

        return redirect(url('/ac-fa-depreciation/success') . '?DeprPeriod=' . $period);
    }

    // =========================================================================================
    // GENERATE JOURNAL - SHOW MODAL
    // =========================================================================================
    public function generate_journal(Request $request)
    {
        $period = trim($request->input('DeprPeriod', ''));

        $this->data['fields'] = (object) [
            'IDX_M_Company' => $request->input('IDX_M_Company', ''),
            'DeprPeriod'    => $period,
            'IDX_M_Branch'  => '',
            'RecordStatus'  => 'A',
        ];

        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_branch'] = (array) $dd->branch();

        $this->data['state'] = 'create';
        $this->data['form_desc'] = 'Generate Jurnal Penyusutan - ' . $this->period_desc($period);
        $this->data['url_save_modal'] = url('ac-fa-depreciation/save-generate-journal');

        return view('accounting/fa_depreciation_generate_journal_form', $this->data);
    }

    // =========================================================================================
    // GENERATE JOURNAL - EXECUTE STORED PROCEDURE
    // =========================================================================================
    public function save_generate_journal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => ['required'],
            'IDX_M_Branch' => ['required'],
            'DeprPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'IDX_M_Company.required' => 'Company tidak ditemukan!',
            'IDX_M_Branch.required' => 'Cabang pembukuan belum dipilih!',
            'DeprPeriod.required' => 'Periode belum diisi!',
            'DeprPeriod.regex'    => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $param = [];
        $param['IDX_M_Company'] = $request->input('IDX_M_Company');
        $param['IDX_M_Branch']  = $request->input('IDX_M_Branch');
        $param['DeprPeriod']    = 'XXX' . $request->input('DeprPeriod');
        $param['UserID']        = 'XXX' . $this->data['user_id'];

        $rows = $this->exec_sp('[dbo].[USP_FA_GenerateJournalDepreciation]', $param, 'list', 'sqlsrv');

        return $this->process_result_json($rows);
    }

    // =========================================================================================
    // CANCEL - SHOW MODAL
    // =========================================================================================
    public function cancel(Request $request)
    {
        $period = trim($request->input('DeprPeriod', ''));

        $this->data['fields'] = (object) [
            'IDX_M_Company' => $request->input('IDX_M_Company', ''),
            'DeprPeriod'    => $period,
            'RecordStatus'  => 'A',
        ];

        $this->data['state'] = 'create';
        $this->data['form_desc'] = 'Batalkan Perhitungan Penyusutan - ' . $this->period_desc($period);
        $this->data['url_save_modal'] = url('ac-fa-depreciation/save-cancel');

        return view('accounting/fa_depreciation_cancel_form', $this->data);
    }

    // =========================================================================================
    // CANCEL - EXECUTE STORED PROCEDURE
    // =========================================================================================
    public function save_cancel(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => ['required'],
            'DeprPeriod' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'IDX_M_Company.required' => 'Company tidak ditemukan!',
            'DeprPeriod.required' => 'Periode belum diisi!',
            'DeprPeriod.regex'    => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $param = [];
        $param['IDX_M_Company'] = $request->input('IDX_M_Company');
        $param['DeprPeriod']    = 'XXX' . $request->input('DeprPeriod');
        $param['UserID']        = 'XXX' . $this->data['user_id'];

        $rows = $this->exec_sp('[dbo].[USP_FA_Depreciation_Cancel]', $param, 'list', 'sqlsrv');

        return $this->process_result_json($rows);
    }

    // =========================================================================================
    // SUCCESS PAGE
    // =========================================================================================
    public function success(Request $request)
    {
        $period = $request->input('DeprPeriod', '');

        $this->data['form_sub_title'] = 'Proses Penyusutan Bulanan';
        $this->data['DeprPeriod']     = $period;
        $this->data['PeriodDesc']     = $this->period_desc($period);
        $this->data['url_back']       = url('ac-fa-depreciation');

        array_push($this->data['breads'], 'Success');

        $this->data['view'] = 'accounting/fa_depreciation_success';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function period_desc($period)
    {
        $bulan = [
            '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
            '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
            '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
        ];

        if (strlen($period) == 6) {
            $year = substr($period, 0, 4);
            $month = substr($period, 4, 2);
            return isset($bulan[$month]) ? $bulan[$month] . ' ' . $year : $period;
        }

        return $period;
    }

    private function process_result_json($rows)
    {
        $errors = '';
        $message = '';
        foreach ($rows as $row) {
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'error') {
                $errors .= '<span style="display:block;" class="text-danger">' . trim($row->LogDesc) . '</span>';
            }
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'success') {
                $message .= '<span style="display:block;">' . trim($row->LogDesc) . '</span>';
            }
        }

        if ($errors !== '') {
            echo json_encode(['flag' => 'error', 'id' => '', 'message' => $errors]);
            return;
        }

        echo json_encode([
            'flag' => 'success',
            'id'   => '',
            'message' => $message,
            'url'  => url('ac-fa-depreciation'),
        ]);
    }
}
