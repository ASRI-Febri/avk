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

class FinancialReceiveController extends MyController
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
        $this->data['form_title'] = 'Financial Receive';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Financial Receive'); 

        // URL
        $this->data['url_create'] = url('fm-financial-receive/create');
        $this->data['url_search'] = url('fm-financial-receive-list');           
        $this->data['url_update'] = url('fm-financial-receive/update/'); 
        $this->data['url_cancel'] = url('fm-financial-receive'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-FR-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Financial Receive List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
        
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_FinancialReceiveHeader', 'IDX_M_Company', 'IDX_M_Branch', 'Company Name', 'Receive ID', 'Voucher No Manual', 'Financial Account ID', 'Receive Date', 'Partner Name', 'Receive Amount', 'Remark',
            'Status', 'Action');         

            $this->data['table_footer'] = array('', '', '', '', 'CompanyName', 'ReceiveID', 'VoucherNoManual', 'FinancialAccountID', 'ReceiveDate', 'PartnerName', 'ReceiveAmount', 'RemarkHeader', '', 'Action');

            $this->data['array_filter'] = array('IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'ReceiveID','VoucherNoManual','FinancialAccountID','ReceiveDate','PartnerName','ReceiveAmount','RemarkHeader');

            // VIEW
            $this->data['view'] = 'finance/financial_receive_list';  
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
        $array_filter['ReceiveID'] = $request->input('ReceiveID');
        $array_filter['VoucherNoManual'] = $request->input('VoucherNoManual');
        $array_filter['FinancialAccountID'] = $request->input('FinancialAccountID');
        $array_filter['ReceiveDate'] = $request->input('ReceiveDate');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['ReceiveAmount'] = $request->input('ReceiveAmount');  
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_FinancialReceive_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_FinancialReceiveHeader', 'IDX_M_Company', 'IDX_M_Branch', 'CompanyName', 'ReceiveID', 'VoucherNoManual', 'FinancialAccountID', 'ReceiveDate', 'PartnerName', 
            'ReceiveAmount', 'RemarkHeader', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-FR-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Receive';
        $this->data['form_sub_title'] = 'Create Financial Receive';
        $this->data['form_desc'] = 'Create Financial Receive';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_FinancialReceiveHeader = 0;        
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
        $this->data['form_id'] = 'FM-FR-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Receive';
        $this->data['form_sub_title'] = 'Update Financial Receive';
        $this->data['form_desc'] = 'Update Financial Receive';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];
            
            // DEFAULT VALUE & FORMAT
            $this->data['fields']->ReceiveAmount = number_format($this->data['fields']->ReceiveAmount,0,'.',',');

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
        $this->data['url_save_header'] = url('/fm-financial-receive/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_FinancialReceiveHeader'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialReceiveDetail_List',$param,'list','sqlsrv');
            $this->data['allocation_detail'] = $this->exec_sp('USP_CM_ReceiveAllocation_List',$param,'list','sqlsrv');
            // $this->data['tax_detail'] = $this->exec_sp('USP_CM_SalesInvoiceTax_List',$param,'list','sqlsrv');
            $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialReceive_Journal_List',$param,'list','sqlsrv');
            $this->data['journal_detail'] = $this->exec_sp('USP_CM_FinancialReceive_Journal_List',$param,'list','sqlsrv');
        }

        // VIEW        
        $this->data['form_remark'] = 'Master Financial Receive';        
        $this->data['view'] = 'finance/financial_receive_form';
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

        // $sql = "SELECT DISTINCT PIH.IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, PIH.InvoiceNo AS DocumentNo 
        //         FROM CM_T_SalesInvoiceHeader PIH
        //             LEFT JOIN CM_T_SalesInvoiceDetail PID ON PIH.IDX_T_SalesInvoiceHeader = PID.IDX_T_SalesInvoiceHeader
        //             LEFT JOIN CM_T_FinancialReceiveDetail FPD ON PIH.InvoiceNo = FPD.DocumentNo 
        //         WHERE (((PID.Quantity * PID.UntaxedAmount) - PID.DiscountAmount + PID.TaxAmount) - ISNULL(FPD.ReceiveAmount,0) > 0 
        //         OR FPD.DocumentNo = PIH.InvoiceNo)
        //         AND InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $partnerid;

        $IDX_M_Branch = $request->input('IDX_M_Branch','0'); 
        $IDX_M_Partner = $request->input('IDX_M_Partner','0');  

        // $sql = "SELECT a.IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo,
	    //         CASE WHEN ISNULL(A.TotalSalesAmount,0) > 0 
	    //              THEN 
	    //     	     	a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,A.TotalSalesAmount) 
	    //              ELSE
	    //     	     	a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,sum(DPP.DPP+TAX.TAX)) 
        //              END AS DocumentNo2
        //         FROM CM_T_SalesInvoiceHeader a WITH(NOLOCK)
        //             LEFT JOIN
        //             (
        //                 SELECT IDX_T_SalesInvoiceHeader, IDX_T_SalesInvoiceDetail, Quantity * (UntaxedAmount - ISNULL(DiscountAmount,0)) AS DPP 
        //                 FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
        //             ) DPP ON a.IDX_T_SalesInvoiceHeader = DPP.IDX_T_SalesInvoiceHeader
        //             LEFT JOIN
        //             (
        //                 SELECT a.IDX_T_SalesInvoiceDetail, a.Quantity * SUM(ISNULL(b.TaxAmount,0)) AS TAX
        //                 FROM CM_T_SalesInvoiceDetail a WITH(NOLOCK)
        //                     LEFT JOIN CM_T_SalesInvoiceTax b WITH(NOLOCK) ON a.IDX_T_SalesInvoiceDetail = b.IDX_T_SalesInvoiceDetail
        //                 GROUP BY a.IDX_T_SalesInvoiceDetail, a.Quantity
        //             ) TAX ON DPP.IDX_T_SalesInvoiceDetail = TAX.IDX_T_SalesInvoiceDetail
        //             LEFT JOIN
        //             (
        //                 SELECT a.IDX_DocumentNo, a.DocumentNo, SUM(a.AllocationAmount) AS ReceiveAmount
		// 				FROM CM_T_ReceiveAllocation a WITH(NOLOCK)
		// 					INNER JOIN CM_T_SalesInvoiceHeader b WITH(NOLOCK) ON a.IDX_DocumentNo = b.IDX_T_SalesInvoiceHeader and a.DocumentNo = b.InvoiceNo
		// 				GROUP BY a.IDX_DocumentNo, a.DocumentNo
        //             ) REVENUE ON a.IDX_T_SalesInvoiceHeader = REVENUE.IDX_DocumentNo
        //             WHERE a.InvoiceStatus IN ('A','F') AND IDX_M_Partner = " . $partnerid . "
        //         GROUP BY a.IDX_T_SalesInvoiceHeader, a.InvoiceNo, a.InvoiceDate, REVENUE.ReceiveAmount, A.TotalSalesAmount
        //         HAVING 
        //             CASE WHEN ISNULL(A.TotalSalesAmount,0) > 0 
        //             THEN 
        //                 A.TotalSalesAmount-ISNULL(REVENUE.ReceiveAmount,0) 
        //             ELSE 
        //                 SUM(DPP.DPP+TAX.TAX)-ISNULL(REVENUE.ReceiveAmount,0) 
        //             END
        //         >1";

        // $result['data'] =  DB::connection('sqlsrv')->select($sql);

        $param['IDX_M_Branch'] = $IDX_M_Branch;  
        $param['IDX_M_Partner'] = $IDX_M_Partner;   
        $result['data'] = $this->exec_sp('USP_CM_FinancialReceive_GetAllocation_List',$param,'list','sqlsrv');


        //$result['data'] =  DB::connection('sqlsrv')->select($sql);

        return response()->json($result);
    
    }

    // Fetch records
    public function getDocumentInfo($documentid=0)
    {
        // $sql = "SELECT InvoiceDate, InvoiceDueDate,
        //         ISNULL(((PID.Quantity * PID.UntaxedAmount) - PID.DiscountAmount + PID.TaxAmount) - ISNULL(FPD.AllocationAmount,0),0) AS OutstandingAmount
        //         FROM CM_T_SalesInvoiceHeader PIH WITH(NOLOCK)
        //         LEFT JOIN CM_T_SalesInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_SalesInvoiceHeader = PID.IDX_T_SalesInvoiceHeader
        //         LEFT JOIN CM_T_ReceiveAllocation FPD WITH(NOLOCK) ON PIH.InvoiceNo = FPD.DocumentNo 
        //         WHERE PIH.InvoiceStatus = 'A' AND PIH.InvoiceNo = '" . $documentid . "'";

        $sql = "SELECT InvoiceDate, InvoiceDueDate, 
                CASE WHEN ISNULL(TotalSalesAmount,0) > 0 THEN TotalSalesAmount 
                     ELSE SUM(DPP.DPP+TAX.TAX) END AS InvoiceAmount, 
                ISNULL(ReceiveAmount,0) AS ReceiveAmount,
                CASE WHEN ISNULL(TotalSalesAmount,0) > 0 THEN TotalSalesAmount - ISNULL(ReceiveAmount,0)
                    -- ELSE SUM(SID.Quantity * (SID.UntaxedAmount + SID.TaxAmount - SID.DiscountAmount)) - ISNULL(ReceiveAmount,0) END AS OutstandingAmount 
                     ELSE SUM(DPP.DPP+TAX.TAX) - ISNULL(ReceiveAmount,0) END AS OutstandingAmount 
                FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
                    LEFT JOIN
                    (
                        SELECT IDX_T_SalesInvoiceHeader, IDX_T_SalesInvoiceDetail, Quantity * (UntaxedAmount - ISNULL(DiscountAmount,0)) AS DPP 
                        FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
                    ) DPP ON SIH.IDX_T_SalesInvoiceHeader = DPP.IDX_T_SalesInvoiceHeader
                    LEFT JOIN
                    (
                        SELECT a.IDX_T_SalesInvoiceDetail, a.Quantity * SUM(ISNULL(b.TaxAmount,0)) AS TAX
                        FROM CM_T_SalesInvoiceDetail a WITH(NOLOCK)
                            LEFT JOIN CM_T_SalesInvoiceTax b WITH(NOLOCK) ON a.IDX_T_SalesInvoiceDetail = b.IDX_T_SalesInvoiceDetail
                        GROUP BY a.IDX_T_SalesInvoiceDetail, a.Quantity
                    ) TAX ON DPP.IDX_T_SalesInvoiceDetail = TAX.IDX_T_SalesInvoiceDetail
                JOIN CM_T_SalesInvoiceDetail SID WITH(NOLOCK) ON SIH.IDX_T_SalesInvoiceHeader = SID.IDX_T_SalesInvoiceHeader
                LEFT JOIN ( SELECT DocumentNo, ISNULL(SUM(AllocationAmount),0) AS ReceiveAmount 
                            FROM CM_T_ReceiveAllocation WITH(NOLOCK)
                            WHERE IDX_DocumentNo = '$documentid' GROUP BY DocumentNo) FRD ON RTRIM(SIH.InvoiceNo) = RTRIM(FRD.DocumentNo)
                WHERE SIH.InvoiceStatus = 'A' AND RTRIM(SIH.IDX_T_SalesInvoiceHeader) = '$documentid'
                GROUP BY InvoiceDate, InvoiceDueDate, TotalSalesAmount, ReceiveAmount";

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
        $array_filter['PartnerType'] = 'C';
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
        $this->data['url_search'] = url('/fm-partner-list-fr');

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
        $this->sp_create = '[dbo].[USP_CM_FinancialReceiveHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_FinancialReceiveHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-financial-receive/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialReceiveHeader' => 'required',
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
                $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];    
            }
            
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];
            $param['IDX_M_DocumentType'] = $data['IDX_M_DocumentType'];
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_PaymentType'] = $data['IDX_M_PaymentType'];
            $param['COAHeader'] = $data['COAHeader'];
            $param['ReceiveID'] = $data['ReceiveID'];
            $param['VoucherNoManual'] = $data['VoucherNoManual'];
            $param['ReceiveDate'] = $data['ReceiveDate'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['ReceiveStatus'] = 'D';

            $param['ReceiveAmount'] = (double)str_replace(',','',$data['ReceiveAmount']);
            // $param['ReceiveAmount'] = filter_var($data['ReceiveAmount'], FILTER_SANITIZE_NUMBER_INT);

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
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Approval Financial Receive';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Financial Receive';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialReceiveHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->ReceiveDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-receive/save-approve');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_receive_approval_form';
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
            'IDX_T_FinancialReceiveHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialReceiveHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialReceive_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-receive/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];
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
        $this->data['form_id'] = 'FM-FR-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $access = TRUE;
       
        $this->data['form_title'] = 'Reverse Financial Receive';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Financial Receive';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialReceiveHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->ReceiveDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-receive/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_receive_reverse_form';
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
            'IDX_T_FinancialReceiveHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialReceiveHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialReceive_ReverseValidate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-receive/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // VOID/CANCEL
    // =========================================================================================
    public function cancel_payment(Request $request)
    {
        $this->data['form_id'] = 'FM-FR-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Void Financial Receive';
        $this->data['form_sub_title'] = 'Void';        
        $this->data['form_desc'] = 'Void Financial Receive';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialReceiveHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->VoidReason = '';           
            $this->data['fields']->VoidDate = date('Y-m-d',strtotime($this->data['fields']->ApprovalDate));
            $this->data['fields']->VoidBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-receive/save-cancel');            

            // VIEW                          
            $this->data['view'] = 'finance/financial_receive_cancel_form';
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
            'IDX_T_FinancialReceiveHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialReceiveHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialReceive_Void]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-receive/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];
            $param['VoidDate'] = $data['VoidDate'];
            $param['VoidReason'] = $data['VoidReason'];
            $param['UserID'] = 'XXX'.$data['VoidBy']; 

            return $this->store($state,$param);
        }   
    }

//------------------------------------------------------------------------------------------------------------------

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_FinancialReceiveHeader'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_FinancialReceiveHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Voucher Penerimaan';  
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_FinancialReceive_PrintJournal',$param,'list','sqlsrv');      

        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->ReceiveAmount);

        $pdf = PDF::loadView('finance/financial_receive_pdf', $data);

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
        $this->data['form_id'] = 'FM-FR-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Financial Receive';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Financial Receive';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceive_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_FinancialReceiveHeader)[0];        
                  
            // RECORDS
            $param['IDX_T_FinancialReceiveHeader'] = $request->IDX_T_FinancialReceiveHeader;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialReceiveDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-receive/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'finance/financialreceive_duplicate_form';
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
            'IDX_T_FinancialReceiveHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialReceiveHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_FinancialReceive_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-financial-receive/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

}