<?php

namespace App\Http\Controllers\Finance;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;
use App\File;
use Image;

class PettyCashController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo']  = url('public/images/logo/finance.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'Finance';
        $this->data['form_title'] = 'Petty Cash';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';
        $this->data['sidebar'] = 'navigation.sidebar_finance';

        // BREADCRUMB
        $this->data['breads'] = array('Finance', 'Transaction', 'Petty Cash');

        // URL
        $this->data['url_create'] = url('fm-petty-cash/create');
        $this->data['url_search'] = url('fm-petty-cash-list');
        $this->data['url_update'] = url('fm-petty-cash/update/');
        $this->data['url_cancel'] = url('fm-petty-cash');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_id'] = 'FM-PC-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Petty Cash List';

        // BREADCRUMB
        array_push($this->data['breads'], 'List');

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_PettyCashHeader', 'IDX_M_Company', 'IDX_M_Branch', 'Company Name', 'Transaction ID', 'Opening Date', 'Description',
            'Cashier', 'Total Amount', 'Status', 'Action');

            $this->data['table_footer'] = array('', '', '', '', 'CompanyName', 'TransactionID', 'OpeningDate', 'TransactionDesc', 'CashierName', 'TotalAmount', '', 'Action');

            $this->data['array_filter'] = array('IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'TransactionID', 'TransactionDesc', 'OpeningDate');

            // VIEW
            $this->data['view'] = 'finance/petty_cash_list';
            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_M_Company'] = $request->input('IDX_M_Company');
        $array_filter['IDX_M_Branch'] = $request->input('IDX_M_Branch');
        $array_filter['CompanyName'] = $request->input('CompanyName');
        $array_filter['TransactionID'] = $request->input('TransactionID');
        $array_filter['TransactionDesc'] = $request->input('TransactionDesc');
        $array_filter['OpeningDate'] = $request->input('OpeningDate');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id'];

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_PettyCash_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_PettyCashHeader', 'IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'TransactionID', 'OpeningDate',
            'TransactionDesc', 'CashierName', 'TotalAmount', 'StatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-PC-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Petty Cash';
        $this->data['form_sub_title'] = 'Create Petty Cash';
        $this->data['form_desc'] = 'Create Petty Cash';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_PettyCash_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_PettyCashHeader = 0;
            $this->data['fields']->IDX_M_FinancialAccount = '';
            $this->data['fields']->TransactionType = 'PC';
            $this->data['fields']->OpeningDate = date('Y-m-d');
            $this->data['fields']->PettyCashStatus = 'O';
            $this->data['fields']->TotalAmount = 0;
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-PC-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Petty Cash';
        $this->data['form_sub_title'] = 'Update Petty Cash';
        $this->data['form_desc'] = 'Update Petty Cash';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_PettyCash_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            return $this->show_form($id, 'update');
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_branch'] = (array) $dd->branch($this->data['user_id']);
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);
        $this->data['dd_document_type'] = (array) $dd->document_type();
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);

        // DEFAULT VALUE ON CREATE (Company, Branch, Akun Kas Kecil)
        if($state === 'create')
        {
            // FIRST ACCESSIBLE COMPANY & BRANCH (skip the '' => --SELECT-- entry)
            $company_keys = array_keys($this->data['dd_company']);
            $branch_keys  = array_keys($this->data['dd_branch']);
            $this->data['fields']->IDX_M_Company = $company_keys[1] ?? '';
            $this->data['fields']->IDX_M_Branch  = $branch_keys[1] ?? '';

            // PETTY CASH ACCOUNT (FinancialAccountID = 'PCSH')
            foreach($this->data['dd_financial_account'] as $idx => $label)
            {
                if($idx !== '' && stripos($label, 'PCSH') === 0)
                {
                    $this->data['fields']->IDX_M_FinancialAccount = $idx;
                    break;
                }
            }
        }

        // URL
        $this->data['url_save_header'] = url('/fm-petty-cash/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // RECORDS
        if($state !== 'create')
        {
            $param['IDX_T_PettyCashHeader'] = $id;
            $this->data['records_detail'] = $this->exec_sp('USP_CM_PettyCashDetail_List', $param, 'list', 'sqlsrv');
            $this->data['journal_detail'] = $this->exec_sp('USP_CM_PettyCash_Journal_List', $param, 'list', 'sqlsrv');
        }

        // VIEW
        $this->data['form_remark'] = 'Master Petty Cash';
        $this->data['view'] = 'finance/petty_cash_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_PettyCashHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_PettyCashHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-petty-cash/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_PettyCashHeader' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_FinancialAccount' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PettyCashHeader'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_T_PettyCashHeader'] = $data['IDX_T_PettyCashHeader'];
            }

            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];
            $param['OpeningDate'] = $data['OpeningDate'];
            $param['TransactionType'] = $data['TransactionType'];
            $param['TransactionDesc'] = $data['TransactionDesc'];
            $param['CashierID'] = $this->data['user_index'];
            $param['PettyCashStatus'] = 'O';

            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // CLOSE (IMPREST - REIMBURSE / SETTLE)
    // =========================================================================================
    public function close(Request $request)
    {
        $this->data['form_id'] = 'FM-PC-Close';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Close Petty Cash';
        $this->data['form_sub_title'] = 'Close';
        $this->data['form_desc'] = 'Close Petty Cash';

        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_PettyCash_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_PettyCashHeader)[0];

            // DEFAULT VALUE
            $this->data['fields']->ClosingNotes = '';
            $this->data['fields']->ClosingDate = date('Y-m-d');
            $this->data['fields']->ClosingBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-petty-cash/save-close');

            // VIEW
            $this->data['view'] = 'finance/petty_cash_close_form';
            $this->data['submit_title'] = 'Close';

            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_close(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_PettyCashHeader' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PettyCashHeader'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_PettyCash_Close]';
            $this->next_action = 'reload';
            $this->next_url = url("/fm-petty-cash/update");

            $state = 'approve';

            $data = $request->all();

            $param['IDX_T_PettyCashHeader'] = $data['IDX_T_PettyCashHeader'];
            $param['ClosingDate'] = date('Y-m-d', strtotime($data['ClosingDate']));
            $param['ClosingNotes'] = $data['ClosingNotes'];
            $param['UserID'] = 'XXX'.$data['ClosingBy'];

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // REOPEN
    // =========================================================================================
    public function reopen(Request $request)
    {
        $this->data['form_id'] = 'FM-PC-Close';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Reopen Petty Cash';
        $this->data['form_sub_title'] = 'Reopen';
        $this->data['form_desc'] = 'Reopen Petty Cash';

        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_PettyCash_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_PettyCashHeader)[0];

            // DEFAULT VALUE
            $this->data['fields']->ClosingNotes = '';
            $this->data['fields']->ClosingBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-petty-cash/save-reopen');

            // VIEW
            $this->data['view'] = 'finance/petty_cash_reopen_form';
            $this->data['submit_title'] = 'Reopen';

            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_reopen(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_PettyCashHeader' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PettyCashHeader'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_PettyCash_Reopen]';
            $this->next_action = 'reload';
            $this->next_url = url("/fm-petty-cash/update");

            $state = 'approve';

            $data = $request->all();

            $param['IDX_T_PettyCashHeader'] = $data['IDX_T_PettyCashHeader'];
            $param['ClosingNotes'] = $data['ClosingNotes'];
            $param['UserID'] = 'XXX'.$data['ClosingBy'];

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DOWNLOAD PDF
    // =========================================================================================
    public function download_pdf($id, Request $request)
    {
        $data = $request->all();

        $data['IDX_T_PettyCashHeader'] = $id;

        return $this->generate_pdf($data, 'stream');
    }

    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '90';
        $data['img_logo_h'] = '';
        $data['img_logo'] = public_path('assets/images/logo-avk-print.png');

        $this->sp_getdata = '[dbo].[USP_CM_PettyCash_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_PettyCashHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Laporan Petty Cash';

        $data['show_action'] = FALSE;

        // GET DETAIL RECORDS
        $param['IDX_T_PettyCashHeader'] = $data['IDX_T_PettyCashHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_PettyCashDetail_List', $param, 'list', 'sqlsrv');

        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->TotalAmount);

        $pdf = PDF::loadView('finance/petty_cash_pdf', $data);

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }
    }
}
