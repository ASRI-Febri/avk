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

class FinancialPaymentController extends MyController
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
        $this->data['form_title'] = 'Financial Payment';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Financial Payment'); 

        // URL
        $this->data['url_create'] = url('fm-financial-payment/create');
        $this->data['url_search'] = url('fm-financial-payment-list');           
        $this->data['url_update'] = url('fm-financial-payment/update/'); 
        $this->data['url_cancel'] = url('fm-financial-payment'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-FP-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Financial Payment List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List'); 
        
        if ($access == TRUE)
        { 

            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_FinancialPaymentHeader', 'IDX_M_Company', 'IDX_M_Branch', 'Company Name', 'Payment ID', 'Voucher No Manual', 'Financial Account ID',
            'PDC No', 'Payment Date', 'Partner Name', 'Payment Amount', 'Remark', 'Status', 'Action');         

            $this->data['table_footer'] = array('', '', '', '', 'CompanyName', 'PaymentID', 'VoucherNoManual', 'FinancialAccountID', 'PDCNo', 'PaymentDate', 'PartnerName', 'PaymentAmount', 'RemarkHeader', '', 'Action');

            $this->data['array_filter'] = array('IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'PaymentID','VoucherNoManual','FinancialAccountID','PDCNo','PaymentDate','PartnerName','PaymentAmount','RemarkHeader');

            // VIEW
            $this->data['view'] = 'finance/financial_payment_list';  
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
        $array_filter['PaymentID'] = $request->input('PaymentID');
        $array_filter['VoucherNoManual'] = $request->input('VoucherNoManual');
        $array_filter['FinancialAccountID'] = $request->input('FinancialAccountID');
        $array_filter['PDCNo'] = $request->input('PDCNo');
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['PaymentDate'] = $request->input('PaymentDate');
        $array_filter['PaymentAmount'] = $request->input('PaymentAmount');  
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 
        
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_FinancialPayment_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_FinancialPaymentHeader', 'IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'PaymentID','VoucherNoManual','FinancialAccountID',
         'PDCNo', 'PaymentDate', 'PartnerName', 'PaymentAmount', 'RemarkHeader', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-FP-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Payment';
        $this->data['form_sub_title'] = 'Create Financial Payment';
        $this->data['form_desc'] = 'Create Financial Payment';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_FinancialPaymentHeader = 0;        
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
        $this->data['form_id'] = 'FM-FP-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Payment';
        $this->data['form_sub_title'] = 'Update Financial Payment';
        $this->data['form_desc'] = 'Update Financial Payment';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];
            
            // DEFAULT VALUE & FORMAT
            $this->data['fields']->PaymentAmount = number_format($this->data['fields']->PaymentAmount,0,'.',',');

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
        $this->data['dd_currency'] = (array) $dd->currency();
        $this->data['dd_payment_method'] = (array) $dd->payment_method();
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);

        // URL
        $this->data['url_save_header'] = url('/fm-financial-payment/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_FinancialPaymentHeader'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialPaymentDetail_List',$param,'list','sqlsrv');
            $this->data['allocation_detail'] = $this->exec_sp('USP_CM_PaymentAllocation_List',$param,'list','sqlsrv');
            // $this->data['tax_detail'] = $this->exec_sp('USP_CM_SalesInvoiceTax_List',$param,'list','sqlsrv');
            $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialPayment_Journal_List',$param,'list','sqlsrv');
            // $this->data['journal_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Journal_List',$param,'list','sqlsrv');
        }

        // VIEW        
        $this->data['form_remark'] = 'Financial Payment';        
        $this->data['view'] = 'finance/financial_payment_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SEARCH AJAX
    // =========================================================================================
    // Fetch records
    public function getDocumentNo($partnerid=0, Request $request){

        // Fetch Employees by Departmentid
        // $empData['data'] = Employees::orderby("name","asc")
        //             ->select('id','name')
        //             ->where('department',$departmentid)
        //             ->get();

        // $sql = "SELECT DISTINCT PIH.IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, PIH.InvoiceNo AS DocumentNo 
        //         FROM CM_T_PurchaseInvoiceHeader PIH
        //             LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
        //             LEFT JOIN CM_T_FinancialPaymentDetail FPD ON PIH.InvoiceNo = FPD.DocumentNo 
        //         WHERE (((PID.Quantity * PID.UntaxedAmount) - PID.DiscountAmount + PID.TaxAmount) - ISNULL(FPD.PaymentAmount,0) > 0
        //         OR FPD.DocumentNo = PIH.InvoiceNo)
        //         AND InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $partnerid;

        // $sql = "SELECT a.IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo, a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) 
        //                 + ' - Amount: ' + CONVERT(varchar,SUM(DPP.DPP+TAX.TAX)) AS DocumentNo2
        //         FROM CM_T_PurchaseInvoiceHeader a WITH(NOLOCK)
        //             LEFT JOIN
        //             (
        //                 SELECT IDX_T_PurchaseInvoiceHeader, IDX_T_PurchaseInvoiceDetail, Quantity * (UntaxedAmount - ISNULL(DiscountAmount,0)) AS DPP 
        //                 FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
        //             ) DPP ON a.IDX_T_PurchaseInvoiceHeader = DPP.IDX_T_PurchaseInvoiceHeader
        //             LEFT JOIN
        //             (
        //                 SELECT a.IDX_T_PurchaseInvoiceDetail, a.Quantity * SUM(ISNULL(b.TaxAmount,0)) AS TAX
        //                 FROM CM_T_PurchaseInvoiceDetail a WITH(NOLOCK)
        //                     LEFT JOIN CM_T_PurchaseInvoiceTax b WITH(NOLOCK) ON a.IDX_T_PurchaseInvoiceDetail = b.IDX_T_PurchaseInvoiceDetail
        //                 GROUP BY a.IDX_T_PurchaseInvoiceDetail, a.Quantity
        //             ) TAX ON DPP.IDX_T_PurchaseInvoiceDetail = TAX.IDX_T_PurchaseInvoiceDetail
        //             LEFT JOIN
		// 			(
		// 				SELECT a.IDX_T_FinancialPaymentHeader, ISNULL(b.IDX_DocumentNo,0) AS IDX_DocumentNo, SUM(ISNULL(b.PaymentAmount,0)) AS PaymentAmount
		// 				FROM CM_T_FinancialPaymentHeader a WITH(NOLOCK)
        //                     LEFT JOIN CM_T_FinancialPaymentDetail b WITH(NOLOCK) ON a.IDX_T_FinancialPaymentHeader = b.IDX_T_FinancialPaymentHeader
		// 				WHERE a.PaymentStatus <> 'V'
		// 				GROUP BY a.IDX_T_FinancialPaymentHeader, b.IDX_DocumentNo
		// 			) PAYMENT ON a.IDX_T_PurchaseInvoiceHeader = PAYMENT.IDX_DocumentNo
        //             WHERE a.InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $partnerid . "
        //         GROUP BY a.IDX_T_PurchaseInvoiceHeader, a.InvoiceNo, a.InvoiceDate, PAYMENT.PaymentAmount
        //         HAVING SUM(DPP.DPP+TAX.TAX)-ISNULL(PAYMENT.PaymentAmount,0) > 1";

        //$result['data'] =  DB::connection('sqlsrv')->select($sql);

        $IDX_M_Branch = $request->input('IDX_M_Branch','0'); 
        $IDX_M_Partner = $request->input('IDX_M_Partner','0'); 

        $param['IDX_M_Branch'] = $IDX_M_Branch;  
        $param['IDX_M_Partner'] = $IDX_M_Partner;   
        $result['data'] = $this->exec_sp('USP_CM_FinancialPayment_GetAllocation_List',$param,'list','sqlsrv');

        return response()->json($result);
    
    }

    // Fetch records
    public function getDocumentInfo($documentid=0)
    {
        // $sql = "SELECT InvoiceDate, InvoiceDueDate,
        //         ISNULL(((PID.Quantity * PID.UntaxedAmount) - PID.DiscountAmount + PID.TaxAmount) - FPD.PaymentAmount,0) AS OutstandingAmount
        //         FROM CM_T_PurchaseInvoiceHeader PIH
        //         JOIN CM_T_PurchaseInvoiceDetail PID ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
        //         LEFT JOIN CM_T_FinancialPaymentDetail FPD ON PIH.InvoiceNo = FPD.DocumentNo 
        //         WHERE PIH.InvoiceStatus = 'A' AND PIH.InvoiceNo = '" . $documentid . "'";

        $sql = "SELECT InvoiceDate, InvoiceDueDate, 
                    SUM(PID.Quantity * (PID.UntaxedAmount + PID.TaxAmount - PID.DiscountAmount)) AS InvoiceAmount, 
                    ISNULL(PaymentAmount,0) AS PaymentAmount,
                    OutstandingAmount = SUM(PID.Quantity * (PID.UntaxedAmount + PID.TaxAmount - PID.DiscountAmount)) - ISNULL(PaymentAmount,0)
                FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
                JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
                LEFT JOIN ( SELECT DocumentNo, ISNULL(SUM(AllocationAmount),0) AS PaymentAmount 
                            FROM CM_T_PaymentAllocation WITH(NOLOCK)
                            WHERE DocumentNo = '$documentid' GROUP BY DocumentNo) FPD ON RTRIM(PIH.InvoiceNo) = RTRIM(FPD.DocumentNo)
                WHERE PIH.InvoiceStatus = 'A' AND RTRIM(PIH.IDX_T_PurchaseInvoiceHeader) = '$documentid'
                GROUP BY InvoiceDate, InvoiceDueDate, PaymentAmount";

        $result['data'] =  DB::connection('sqlsrv')->select($sql);

        return response()->json($result);
    
    }

    // =========================================================================================
    // LOOKUP & SELECT PARTNER
    // =========================================================================================
    public function inquiry_data_partner(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE   
        $array_filter['PartnerID'] = $request->input('PartnerID');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['BarcodeMember'] = $request->input('BarcodeMember');
        $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber');
        $array_filter['PartnerType'] = 'S';
        $array_filter['Street'] = $request->input('Street');
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_Partner_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Partner', 'PartnerID', 'PartnerName', 'IsCustomer', 'IsSupplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'StatusDesc');

        // { data: 'RowNumber', name: 'DT_RowIndex' },
        // { data: "IDX_M_Partner", visible: false },
        // { data: "PartnerID", visible: true },
        // { data: "PartnerName", visible: true },
        // { data: "IsCustomer", visible: true },
        // { data: "IsSupplier", visible: true },
        // { data: "Remarks", visible: true },
        // { data: "BarcodeMember", visible: false },
        // { data: "SingleIdentityNumber", visible: false },
        // { data: "Street", visible: true },
        // { data: "PartnerType", visible: false },
        // { data: "StatusDesc", visible: true },

        return $this->get_datatables($request);
    }

    public function show_lookup_partner(Request $request)
    {
        $this->data['form_title'] = 'Partner';
        $this->data['form_sub_title'] = 'Select Partner';
        $this->data['form_desc'] = 'Select Partner';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/fm-partner-list-fp');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'Partner ID', 'Partner Name', 'Is Customer', 'Is Supplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'Status', 'Action');         

        $this->data['table_footer'] = array('', '',
            'PartnerID', 'PartnerName', '', '', '', '', '', 'Street', '', 'Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','Street');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        

        return view('finance/m_select_partner_list', $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_FinancialPaymentHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_FinancialPaymentHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-financial-payment/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialPaymentHeader' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_FinancialAccount'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            $sql = "SELECT IDX_M_COA 
            FROM CM_M_FinancialAccount
            WHERE RecordStatus = 'A' AND IDX_M_FinancialAccount = " . $data['IDX_M_FinancialAccount'];

            $result =  DB::connection('sqlsrv')->select($sql);

            foreach ($result as $row){
                $data['COAHeader'] = trim($row->IDX_M_COA);
            }

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];    
            }
            
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];
            $param['IDX_M_DocumentType'] = $data['IDX_M_DocumentType'];
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_PaymentType'] = $data['IDX_M_PaymentType'];
            $param['COAHeader'] = $data['COAHeader'];
            $param['PaymentID'] = $data['PaymentID'];
            $param['VoucherNoManual'] = $data['VoucherNoManual'];
            $param['PaymentDate'] = $data['PaymentDate'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['PaymentStatus'] = 'D';

            $param['PaymentAmount'] = (double)str_replace(',','',$data['PaymentAmount']);
            // $param['PaymentAmount'] = filter_var($data['PaymentAmount'], FILTER_SANITIZE_NUMBER_INT);

            $param['DestinationAccountName'] = $data['DestinationAccountName'];
            $param['DestinationBank'] = $data['DestinationBank'];
            $param['DestinationAccountNo'] = $data['DestinationAccountNo'];
            $param['PDCNo'] = $data['PDCNo'];

            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function approve(Request $request)
    {
        $this->data['form_id'] = 'FM-FP-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Approval Financial Payment';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Financial Payment';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialPaymentHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->PaymentDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-payment/save-approve');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_payment_approval_form';
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
            'IDX_T_FinancialPaymentHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialPaymentHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialPayment_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-payment/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['UserID'] = 'XXX'.$data['ApprovalBy']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // REVERSE
    // =========================================================================================
    public function reverse(Request $request)
    {
        $this->data['form_id'] = 'FM-FP-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Reverse Financial Payment';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Financial Payment';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialPaymentHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->PaymentDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-payment/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_payment_reverse_form';
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
            'IDX_T_FinancialPaymentHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialPaymentHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialPayment_ReverseApproval]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-payment/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // VALIDATE
    // =========================================================================================
    public function validate_payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FP-Validate';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Validate Financial Payment';
        $this->data['form_sub_title'] = 'Validate';        
        $this->data['form_desc'] = 'Validate Financial Payment';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialPaymentHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ValidateRemark = '';           
            $this->data['fields']->ValidationDate = date('Y-m-d',strtotime($this->data['fields']->PaymentDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-payment/save-validate');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_payment_validate_form';
            $this->data['submit_title'] = 'Validate';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_validate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialPaymentHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialPaymentHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialPayment_Validate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-payment/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
            $param['ValidationDate'] = date('Y-m-d',strtotime($data['ValidationDate']));

            if($data['VoucherNoManual'] == $data['PDCNo']){
                $param['VoucherNoManual'] = '-';
            } else {
                $param['VoucherNoManual'] = $data['VoucherNoManual'];
            }
            
            $param['PDCNo'] = $data['PDCNo'];
            $param['ValidateRemark'] = $data['ValidateRemark'];
            $param['UserID'] = 'XXX'.$data['ApprovalBy']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // VOID/CANCEL
    // =========================================================================================
    public function cancel_payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FP-Validate';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Void Financial Payment';
        $this->data['form_sub_title'] = 'Void';        
        $this->data['form_desc'] = 'Void Financial Payment';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialPaymentHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->VoidReason = '';           
            $this->data['fields']->VoidDate = date('Y-m-d',strtotime($this->data['fields']->ValidationDate));
            $this->data['fields']->VoidBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-payment/save-cancel');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_payment_cancel_form';
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
            'IDX_T_FinancialPaymentHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialPaymentHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialPayment_Void]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-payment/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
            $param['VoidDate'] = $data['VoidDate'];
            $param['VoidReason'] = $data['VoidReason'];
            $param['UserID'] = 'XXX'.$data['VoidBy']; 

            return $this->store($state,$param);
        }   
    }

    //============================================================================================================

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_FinancialPaymentHeader'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_FinancialPaymentHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Voucher Pembayaran';  
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_FinancialPayment_PrintJournal',$param,'list','sqlsrv');     
        
        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->PaymentAmount);

        $pdf = PDF::loadView('finance/financial_payment_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }

        // if ($return_type == 'download')
        // {            
        //     return $pdf->download($data['fields']->PONumber.'.pdf');   
        // }

        // if ($return_type == 'email')
        // {
        //     \Storage::put('public/temp/purchase_order-'.$data['fields']->PONumber.'.pdf', $pdf->output());
            
        //     //echo storage_path().'/app/public/temp/invoice.pdf';

        //     return storage_path().'/app/public/temp/purchase_order-'.$data['fields']->PONumber.'.pdf'; 
        // }
    }

    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'FM-FP-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Financial Payment';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Financial Payment';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialPayment_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialPaymentHeader)[0];        
                  
            // RECORDS
            $param['IDX_T_FinancialPaymentHeader'] = $request->IDX_T_FinancialPaymentHeader;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialPaymentDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-payment/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'finance/financialpayment_duplicate_form';
            $this->data['submit_title'] = 'Duplicate';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_duplicate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialPaymentHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialPaymentHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialPayment_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-payment/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

}