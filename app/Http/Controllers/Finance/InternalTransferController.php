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

class InternalTransferController extends MyController
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
        $this->data['form_title'] = 'Internal Transfer';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';
        $this->data['sidebar'] = 'navigation.sidebar_finance';

        // BREADCRUMB
        $this->data['breads'] = array('Finance', 'Transaction', 'Internal Transfer');

        // URL
        $this->data['url_create'] = url('fm-internal-transfer/create');
        $this->data['url_search'] = url('fm-internal-transfer-list');
        $this->data['url_update'] = url('fm-internal-transfer/update/');
        $this->data['url_cancel'] = url('fm-internal-transfer');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_id'] = 'FM-IT-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Internal Transfer List';

        // BREADCRUMB
        array_push($this->data['breads'], 'List');

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_InternalTransferHeader', 'IDX_M_Company', 'IDX_M_Branch', 'Company Name', 'Transfer ID', 'Voucher No Manual', 'From Account', 'To Account', 'Transfer Date', 'Transfer Amount', 'Remark',
            'Status', 'Action');

            $this->data['table_footer'] = array('', '', '', '', 'CompanyName', 'TransferID', 'VoucherNoManual', 'FromAccountID', 'ToAccountID', 'TransferDate', 'TransferAmount', 'RemarkHeader', '', 'Action');

            $this->data['array_filter'] = array('IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'TransferID', 'VoucherNoManual', 'FromAccountID', 'ToAccountID', 'TransferDate', 'TransferAmount', 'RemarkHeader');

            // VIEW
            $this->data['view'] = 'finance/internal_transfer_list';
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
        $array_filter['TransferID'] = $request->input('TransferID');
        $array_filter['VoucherNoManual'] = $request->input('VoucherNoManual');
        $array_filter['FromAccountID'] = $request->input('FromAccountID');
        $array_filter['ToAccountID'] = $request->input('ToAccountID');
        $array_filter['TransferDate'] = $request->input('TransferDate');
        $array_filter['TransferAmount'] = $request->input('TransferAmount');
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id'];

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_InternalTransfer_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_InternalTransferHeader', 'IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'TransferID', 'VoucherNoManual', 'FromAccountID', 'ToAccountID', 'TransferDate',
            'TransferAmount', 'RemarkHeader', 'StatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-IT-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Internal Transfer';
        $this->data['form_sub_title'] = 'Create Internal Transfer';
        $this->data['form_desc'] = 'Create Internal Transfer';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_InternalTransferHeader = 0;
            $this->data['fields']->TransferStatus = 'D';
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
        $this->data['form_id'] = 'FM-IT-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Internal Transfer';
        $this->data['form_sub_title'] = 'Update Internal Transfer';
        $this->data['form_desc'] = 'Update Internal Transfer';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->TransferAmount = number_format($this->data['fields']->TransferAmount, 0, '.', ',');

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
        $this->data['dd_document_type'] = (array) $dd->document_type();
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);

        // URL
        $this->data['url_save_header'] = url('/fm-internal-transfer/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // RECORDS
        if($state !== 'create')
        {
            $param['IDX_T_InternalTransferHeader'] = $id;
            $this->data['journal_detail'] = $this->exec_sp('USP_CM_InternalTransfer_Journal_List', $param, 'list', 'sqlsrv');
        }

        // VIEW
        $this->data['form_remark'] = 'Master Internal Transfer';
        $this->data['view'] = 'finance/internal_transfer_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_InternalTransferHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_InternalTransferHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-internal-transfer/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_InternalTransferHeader' => 'required',
            'IDX_M_FromFinancialAccount' => 'required',
            'IDX_M_ToFinancialAccount' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_InternalTransferHeader'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            // RESOLVE COA OF FROM & TO FINANCIAL ACCOUNT
            $data['FromCOA'] = $this->get_financial_account_coa($data['IDX_M_FromFinancialAccount']);
            $data['ToCOA'] = $this->get_financial_account_coa($data['IDX_M_ToFinancialAccount']);

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_T_InternalTransferHeader'] = $data['IDX_T_InternalTransferHeader'];
            }

            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_DocumentType'] = $data['IDX_M_DocumentType'];
            $param['IDX_M_FromFinancialAccount'] = $data['IDX_M_FromFinancialAccount'];
            $param['IDX_M_ToFinancialAccount'] = $data['IDX_M_ToFinancialAccount'];
            $param['FromCOA'] = $data['FromCOA'];
            $param['ToCOA'] = $data['ToCOA'];
            $param['TransferID'] = $data['TransferID'];
            $param['VoucherNoManual'] = $data['VoucherNoManual'];
            $param['TransferDate'] = $data['TransferDate'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['TransferStatus'] = 'D';

            $param['TransferAmount'] = (double) str_replace(',', '', $data['TransferAmount']);

            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }

    private function get_financial_account_coa($idx_financial_account)
    {
        $sql = "SELECT IDX_M_COA
            FROM CM_M_FinancialAccount
            WHERE RecordStatus = 'A' AND IDX_M_FinancialAccount = " . (int) $idx_financial_account;

        $result = DB::connection('sqlsrv')->select($sql);

        $coa = '';
        foreach ($result as $row){
            $coa = trim($row->IDX_M_COA);
        }

        return $coa;
    }

    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function approve(Request $request)
    {
        $this->data['form_id'] = 'FM-IT-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Approval Internal Transfer';
        $this->data['form_sub_title'] = 'Approval';
        $this->data['form_desc'] = 'Approval Internal Transfer';

        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_InternalTransferHeader)[0];

            // DEFAULT VALUE
            $this->data['fields']->ApprovalRemark = '';
            $this->data['fields']->ApprovalDate = date('Y-m-d', strtotime($this->data['fields']->TransferDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-internal-transfer/save-approve');

            // VIEW
            $this->data['view'] = 'finance/internal_transfer_approval_form';
            $this->data['submit_title'] = 'Approve';

            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_approve(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_InternalTransferHeader' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_InternalTransferHeader'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_InternalTransfer_Approve]';
            $this->next_action = 'reload';
            $this->next_url = url("/fm-internal-transfer/update");

            $state = 'approve';

            $data = $request->all();

            $param['IDX_T_InternalTransferHeader'] = $data['IDX_T_InternalTransferHeader'];
            $param['ApprovalDate'] = date('Y-m-d', strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['UserID'] = 'XXX'.$data['ApprovalBy'];

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // REVERSE
    // =========================================================================================
    public function reverse(Request $request)
    {
        $this->data['form_id'] = 'FM-IT-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Reverse Internal Transfer';
        $this->data['form_sub_title'] = 'Reverse';
        $this->data['form_desc'] = 'Reverse Internal Transfer';

        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_InternalTransferHeader)[0];

            // DEFAULT VALUE
            $this->data['fields']->ApprovalRemark = '';
            $this->data['fields']->ApprovalDate = date('Y-m-d', strtotime($this->data['fields']->TransferDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-internal-transfer/save-reverse');

            // VIEW
            $this->data['view'] = 'finance/internal_transfer_reverse_form';
            $this->data['submit_title'] = 'Reverse';

            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_reverse(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_InternalTransferHeader' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_InternalTransferHeader'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_InternalTransfer_ReverseValidate]';
            $this->next_action = 'reload';
            $this->next_url = url("/fm-internal-transfer/update");

            $state = 'approve';

            $data = $request->all();

            $param['IDX_T_InternalTransferHeader'] = $data['IDX_T_InternalTransferHeader'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id'];

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // VOID/CANCEL
    // =========================================================================================
    public function cancel(Request $request)
    {
        $this->data['form_id'] = 'FM-IT-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Void Internal Transfer';
        $this->data['form_sub_title'] = 'Void';
        $this->data['form_desc'] = 'Void Internal Transfer';

        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_InternalTransferHeader)[0];

            // DEFAULT VALUE
            $this->data['fields']->VoidReason = '';
            $this->data['fields']->VoidDate = date('Y-m-d', strtotime($this->data['fields']->ApprovalDate));
            $this->data['fields']->VoidBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-internal-transfer/save-void');

            // VIEW
            $this->data['view'] = 'finance/internal_transfer_void_form';
            $this->data['submit_title'] = 'Void';

            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_cancel(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_InternalTransferHeader' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_InternalTransferHeader'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_InternalTransfer_Void]';
            $this->next_action = 'reload';
            $this->next_url = url("/fm-internal-transfer/update");

            $state = 'approve';

            $data = $request->all();

            $param['IDX_T_InternalTransferHeader'] = $data['IDX_T_InternalTransferHeader'];
            $param['VoidDate'] = $data['VoidDate'];
            $param['VoidReason'] = $data['VoidReason'];
            $param['UserID'] = 'XXX'.$data['VoidBy'];

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DOWNLOAD PDF
    // =========================================================================================
    public function download_pdf($id, Request $request)
    {
        $data = $request->all();

        $data['IDX_T_InternalTransferHeader'] = $id;

        return $this->generate_pdf($data, 'stream');
    }

    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '90';
        $data['img_logo_h'] = '';
        $data['img_logo'] = public_path('assets/images/logo-avk-print.png');

        $this->sp_getdata = '[dbo].[USP_CM_InternalTransfer_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_InternalTransferHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Voucher Internal Transfer';

        $data['show_action'] = FALSE;

        // GET JOURNAL RECORDS
        $param['IDX_T_InternalTransferHeader'] = $data['IDX_T_InternalTransferHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_InternalTransfer_Journal_List', $param, 'list', 'sqlsrv');

        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->TransferAmount);

        $pdf = PDF::loadView('finance/internal_transfer_pdf', $data);

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }
    }
}
