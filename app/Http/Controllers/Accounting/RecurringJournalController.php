<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RecurringJournalController extends MyController
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
        $this->data['form_title'] = 'Journal Recurring';
        $this->data['form_remark'] = 'Template jurnal berulang yang digenerate setiap akhir periode, '
            . 'contoh: amortisasi sewa dibayar dimuka menjadi biaya sewa bulanan';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Transaction','Journal Recurring');

        // URL
        $this->data['url_create'] = url('ac-recurring-journal/create');
        $this->data['url_search'] = url('ac-recurring-journal-list');
        $this->data['url_update'] = url('ac-recurring-journal/update/');
        $this->data['url_cancel'] = url('ac-recurring-journal');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES - TEMPLATE
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'Daftar Template';
        $this->data['form_desc'] = 'Daftar template journal recurring';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_RecurringJournal','Kode','Nama','Cabang',
            'Akun Debet','Akun Kredit','Nilai / Periode','Total Kontrak','Penyesuaian Akhir',
            'Mulai','Akhir','Terakhir Generate','RecurringStatus','Status','Action');

        $this->data['table_footer'] = array('','','RecurringCode','RecurringName','',
            '','','','','','','','','','','Action');

        $this->data['array_filter'] = array('SearchText','RecurringStatus');

        // VIEW
        $this->data['view'] = 'accounting/recurring_journal_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['SearchText'] = $request->input('SearchText');
        $array_filter['RecurringStatus'] = $request->input('RecurringStatus');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_RecurringJournal_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_RecurringJournal','RecurringCode','RecurringName','BranchName',
            'COADebet','COACredit','RecurringAmount','TotalAmount','AdjustLastPeriodDesc',
            'StartPeriod','EndPeriod','LastPeriod','RecurringStatus','RecurringStatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Create Template';
        $this->data['form_desc'] = 'Create Template Journal Recurring';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_RecurringJournal_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_RecurringJournal = '0';
            $this->data['fields']->IDX_M_Company = '';
            $this->data['fields']->IDX_M_Branch = '';
            $this->data['fields']->IDX_M_COA_Debet = '';
            $this->data['fields']->IDX_M_COA_Credit = '';
            $this->data['fields']->RecurringAmount = '0';
            $this->data['fields']->TotalAmount = '0';
            $this->data['fields']->AdjustLastPeriod = 'N';
            $this->data['fields']->StartPeriod = date('Ym');
            $this->data['fields']->EndPeriod = '';
            $this->data['fields']->RecurringStatus = 'A';
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Update Template';
        $this->data['form_desc'] = 'Update Template Journal Recurring';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_RecurringJournal_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            return $this->show_form($id, 'update');
        }
        else
        {
            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();
        $this->data['dd_branch'] = (array) $dd->branch();
        $this->data['dd_coa'] = (array) $dd->coa();
        $this->data['dd_active_status'] = array('' => '--SELECT--', 'A' => 'Aktif', 'I' => 'Non-Aktif');
        $this->data['dd_yes_no'] = (array) $dd->yes_no();

        // URL
        $this->data['url_save_header'] = url('/ac-recurring-journal/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW
        $this->data['view'] = 'accounting/recurring_journal_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_RecurringJournal_Create]';
        $this->sp_update = '[dbo].[USP_GL_RecurringJournal_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-recurring-journal/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-recurring-journal/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_RecurringJournal' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'RecurringCode' => 'required',
            'RecurringName' => 'required',
            'IDX_M_COA_Debet' => 'required',
            'IDX_M_COA_Credit' => 'required|different:IDX_M_COA_Debet',
            'RecurringAmount' => 'required',
            'AdjustLastPeriod' => 'required|in:Y,N',
            'TotalAmount' => 'required_if:AdjustLastPeriod,Y',
            'StartPeriod' => ['required', 'regex:/^\d{6}$/'],
            'EndPeriod' => ['nullable', 'regex:/^\d{6}$/', 'required_if:AdjustLastPeriod,Y'],
            'RecurringStatus' => 'required',
        ], [
            'IDX_M_COA_Credit.different' => 'Akun debet dan kredit tidak boleh sama!',
            'TotalAmount.required_if' => 'Nilai total kontrak wajib diisi bila penyesuaian periode terakhir aktif!',
            'StartPeriod.regex' => 'Periode mulai harus format YYYYMM!',
            'EndPeriod.regex' => 'Periode akhir harus format YYYYMM atau kosong!',
            'EndPeriod.required_if' => 'Periode akhir wajib diisi bila penyesuaian periode terakhir aktif!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_RecurringJournal'] = $data['IDX_M_RecurringJournal'];
            }

            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['RecurringCode'] = 'XXX'.$data['RecurringCode'];
            $param['RecurringName'] = 'XXX'.str_replace("'", "''", $data['RecurringName']);
            $param['RecurringDesc'] = 'XXX'.str_replace("'", "''", $data['RecurringDesc']);
            $param['IDX_M_COA_Debet'] = $data['IDX_M_COA_Debet'];
            $param['IDX_M_COA_Credit'] = $data['IDX_M_COA_Credit'];
            $param['RecurringAmount'] = str_replace(',', '', $data['RecurringAmount']);
            $param['TotalAmount'] = str_replace(',', '', $data['TotalAmount'] != '' ? $data['TotalAmount'] : '0');
            $param['AdjustLastPeriod'] = 'XXX'.$data['AdjustLastPeriod'];
            $param['StartPeriod'] = 'XXX'.$data['StartPeriod'];
            $param['EndPeriod'] = 'XXX'.$data['EndPeriod'];
            $param['RecurringStatus'] = $data['RecurringStatus'];

            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // GENERATE - SHOW MODAL
    // =========================================================================================
    public function generate(Request $request)
    {
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();

        $this->data['fields'] = (object) [
            'IDX_M_Company' => '',
            'Period' => date('Ym'),
            'RecordStatus' => 'A',
        ];

        $this->data['state'] = 'create';
        $this->data['form_desc'] = 'Generate Journal Recurring';
        $this->data['url_save_modal'] = url('ac-recurring-journal/save-generate');

        return view('accounting/recurring_journal_generate_form', $this->data);
    }

    // =========================================================================================
    // GENERATE - EXECUTE STORED PROCEDURE
    // =========================================================================================
    public function save_generate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => 'required',
            'Period' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'IDX_M_Company.required' => 'Company belum dipilih!',
            'Period.required' => 'Periode belum diisi!',
            'Period.regex' => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $param = [];
        $param['IDX_M_Company'] = $request->input('IDX_M_Company');
        $param['Period'] = 'XXX' . $request->input('Period');
        $param['UserID'] = 'XXX' . $this->data['user_id'];

        $rows = $this->exec_sp('[dbo].[USP_GL_RecurringJournal_Generate]', $param, 'list', 'sqlsrv');

        $errors = '';
        $messages = '';
        foreach ($rows as $row) {
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'error') {
                $errors .= '<span style="display:block;" class="text-danger">' . trim($row->LogDesc) . '</span>';
            }
            if (isset($row->Result) && strtolower(trim($row->Result)) === 'success') {
                $messages .= '<span style="display:block;">' . trim($row->LogDesc) . '</span>';
            }
        }

        if ($errors !== '') {
            echo json_encode(['flag' => 'error', 'id' => '', 'message' => $errors]);
            return;
        }

        echo json_encode([
            'flag' => 'success',
            'id' => '',
            'message' => $messages,
            'url' => url('ac-recurring-journal-log'),
        ]);
    }

    // =========================================================================================
    // DATATABLES - LOG
    // =========================================================================================
    public function log_inquiry(Request $request)
    {
        $this->data['form_title'] = 'Log Journal Recurring';
        $this->data['form_sub_title'] = 'Riwayat Generate';
        $this->data['form_desc'] = 'Riwayat generate journal recurring per periode';
        $this->data['form_remark'] = 'Riwayat jurnal recurring yang sudah digenerate per template per periode';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Transaction','Journal Recurring','Log');

        // URL
        $this->data['url_create'] = url('ac-recurring-journal/create');
        $this->data['url_search'] = url('ac-recurring-journal-log-list');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_T_RecurringJournalLog','IDX_M_RecurringJournal','Kode','Nama',
            'Periode','Nilai','No Jurnal','Tgl Jurnal','Status Jurnal','Generate Oleh','Tgl Generate');

        $this->data['table_footer'] = array('','','','RecurringCode','RecurringName',
            '','','','','','','');

        $this->data['array_filter'] = array('SearchText','RecurringPeriod');

        // VIEW
        $this->data['view'] = 'accounting/recurring_journal_log_list';
        return view($this->data['view'], $this->data);
    }

    public function log_inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['SearchText'] = $request->input('SearchText');
        $array_filter['RecurringPeriod'] = $request->input('RecurringPeriod');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_RecurringJournalLog_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_RecurringJournalLog','IDX_M_RecurringJournal','RecurringCode','RecurringName',
            'RecurringPeriod','GeneratedAmount','JournalRef','JournalDate','PostingStatusDesc','GeneratedBy','GeneratedDate');

        return $this->get_datatables($request);
    }
}
