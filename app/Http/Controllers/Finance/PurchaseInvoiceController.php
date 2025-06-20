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

class PurchaseInvoiceController extends MyController
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
        $this->data['form_title'] = 'Purchase Invoice';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Purchase Invoice'); 

        // URL
        $this->data['url_create'] = url('fm-purchase-invoice/create');
        $this->data['url_search'] = url('fm-purchase-invoice-list');           
        $this->data['url_update'] = url('fm-purchase-invoice/update/'); 
        $this->data['url_cancel'] = url('fm-purchase-invoice'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-PI-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        // $access = TRUE;
        
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Purchase Invoice List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {       
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'Company Name', 'LocationID', 'Location Name', 'IDX_T_PurchaseInvoiceHeader', 'Invoice No', 'Partner Name', 'Invoice Date', 'Due Date', 'Remark', 
            'Detail Invoice', 'Total Invoice', 'Payment Amount', 'Outstanding', 'Status', 'Action');         

            $this->data['table_footer'] = array('', 'CompanyName', 'ProjectID', '', '', 'InvoiceNo', 'PartnerName', 'InvoiceDate', 'InvoiceDueDate', 'RemarkHeader', '', 'TotalInvoice', '', '', '', 'Action');

            $this->data['array_filter'] = array('CompanyName','ProjectID','InvoiceNo','RemarkHeader','PartnerName','InvoiceDate','InvoiceDueDate', 'TotalInvoice');

            // VIEW
            $this->data['view'] = 'finance/purchase_invoice_list';  
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
        $array_filter['CompanyName'] = $request->input('CompanyName');  
        $array_filter['ProjectID'] = $request->input('ProjectID'); 
        $array_filter['InvoiceNo'] = $request->input('InvoiceNo');
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['InvoiceDate'] = $request->input('InvoiceDate');  
        $array_filter['InvoiceDueDate'] = $request->input('InvoiceDueDate');
        $array_filter['TotalInvoice'] = $request->input('TotalInvoice');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_PurchaseInvoice_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'CompanyName', 'ProjectID', 'ProjectName', 'IDX_T_PurchaseInvoiceHeader', 'InvoiceNo', 'PartnerName', 'InvoiceDate', 
            'InvoiceDueDate', 'RemarkHeader', 'DetailAmount', 'TotalInvoice', 'PaymentAmount', 'Outstanding', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-PI-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Purchase Invoice';
        $this->data['form_sub_title'] = 'Create Purchase Invoice';
        $this->data['form_desc'] = 'Create Purchase Invoice';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_PurchaseInvoice_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_PurchaseInvoiceHeader = 0;        
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
        $this->data['form_id'] = 'FM-PI-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Purchase Invoice';
        $this->data['form_sub_title'] = 'Update Purchase Invoice';
        $this->data['form_desc'] = 'Update Purchase Invoice';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_PurchaseInvoice_Info]';
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
        $this->data['dd_currency'] = (array) $dd->currency();
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);

        // URL
        $this->data['url_save_header'] = url('/fm-purchase-invoice/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Master Purchase Invoice';        
        $this->data['view'] = 'finance/purchase_invoice_form';

        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_PurchaseInvoiceHeader'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_PurchaseInvoiceDetail_List',$param,'list','sqlsrv');
            $this->data['tax_detail'] = $this->exec_sp('USP_CM_PurchaseInvoiceTax_List',$param,'list','sqlsrv');
            $this->data['payment_detail'] = $this->exec_sp('USP_CM_PurchaseInvoice_Payment_List',$param,'list','sqlsrv');
            $this->data['journal_detail'] = $this->exec_sp('USP_CM_PurchaseInvoice_Journal_List',$param,'list','sqlsrv');
        }

        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // LOOKUP & SELECT COA
    // =========================================================================================
    public function inquiry_data_coa(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE   
        $array_filter['COAID'] = $request->input('COAID');
        $array_filter['COADesc'] = $request->input('COADesc');
        $array_filter['COADesc2'] = $request->input('COADesc2');
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_COA_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_COA', 'COAID', 'COADesc', 'COADesc2', 'StatusDesc');

        return $this->get_datatables($request);
    }

    public function show_lookup_coa(Request $request)
    {
        $this->data['form_title'] = 'COA';
        $this->data['form_sub_title'] = 'Select COA';
        $this->data['form_desc'] = 'Select COA';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/fm-coa-list');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_COA', 'COA ID', 'COA Description', 'COA Description 2', 'Action');         

        $this->data['table_footer'] = array('', '',
            'COAID', 'COADesc', 'COADesc2', 'Action');

        $this->data['array_filter'] = array('COAID','COADesc','COADesc2');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        

        return view('finance/m_select_coa_list', $this->data);
    }

    // =========================================================================================
    // LOOKUP & SELECT VENDOR
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
        $this->data['url_search'] = url('/fm-partner-list-pi');

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
    // AJAX REQUEST
    // =========================================================================================
    public function search_po_no(Request $request)
    {
        $search_value = $request->input('q','');          

        $param['SearchValue'] = $search_value;
        $records = $this->exec_sp('USP_CM_PurchaseOrderSearchByValue_List',$param,'list','sqlsrv');

        $items = array();
        $row_array = array();

        foreach ($records as $row){
        
            $row_array['label'] = $row->PONumber;				
            
            // $row_array['IDX_T_PurchaseOrder'] = $row->IDX_T_PurchaseOrder;
            
            array_push($items, $row_array);	            
        }

        $result["rows"] = $items;
			
        echo json_encode($items);

    }

    // // Fetch records
    // public function getInvoiceInfo($id=0){

    //     $sql = "SELECT SUM((UntaxedAmount * Quantity) + DiscountAmount - TaxAmount) - SUM(PaymentAmount)
    //     FROM CM_T_PurchaseInvoiceHeader PIH
    //     JOIN CM_T_PurchaseInvoiceDetail PID ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
    //     LEFT JOIN CM_T_FinancialPaymentDetail FPD ON PIH.IDX_T_PurchaseInvoiceHeader = FPD.IDX_DocumentNo
    //     WHERE PIH.IDX_T_PurchaseInvoiceHeader = ". $id;

    //     $result['data'] =  DB::connection('sqlsrv')->select($sql);

    //     return response()->json($result);
    
    // }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_PurchaseInvoiceHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_PurchaseInvoiceHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-purchase-invoice/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_PurchaseInvoiceHeader' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_Currency' => 'required',
            'IDX_M_Partner' => 'required',
            'ReferenceNo' => 'required',
            'InvoiceDate' => 'required',
            'InvoiceDueDate' => 'required',
            'SupplierDeliveryNo' => 'required',
            'RemarkHeader' => 'required',
            'VendorInvoiceNo' => 'required',
            'FakturPajak' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PurchaseInvoice'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_T_PurchaseInvoiceHeader'] = $data['IDX_T_PurchaseInvoiceHeader'];    
            }
            
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_LocationInventory'] = 0;
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_DocumentType'] = 2;
            $param['IDX_ReferenceNo'] = 0;
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['InvoiceNo'] = '';
            $param['InvoiceDate'] = $data['InvoiceDate'];
            $param['InvoiceDueDate'] = $data['InvoiceDueDate'];
            $param['SupplierDeliveryNo'] = $data['SupplierDeliveryNo'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['InvoiceStatus'] = 'D';
            $param['COAHeader'] = $data['IDX_M_COA'];
            $param['VendorInvoiceNo'] = $data['VendorInvoiceNo'];
            $param['FakturPajak'] = $data['FakturPajak'];

            if (isset($_POST['IsTaxChecked'])) 
            {   $data['IsTaxChecked'] = 1;    } 
            else 
            {   $data['IsTaxChecked'] = 0;    }
            $param['IsTaxChecked'] = $data['IsTaxChecked'];
            
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
        $this->data['form_id'] = 'FM-PI-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Approval Purchase Invoice';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Purchase Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_PurchaseInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_PurchaseInvoiceHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-purchase-invoice/save-approve');            

            // VIEW                          
            $this->data['view'] = 'finance/purchase_invoice_approval_form';
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
            'IDX_T_PurchaseInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PurchaseInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_PurchaseInvoice_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-purchase-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_PurchaseInvoiceHeader'] = $data['IDX_T_PurchaseInvoiceHeader'];
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
        $this->data['form_id'] = 'FM-PI-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Reverse Purchase Invoice';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Purchase Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_PurchaseInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_PurchaseInvoiceHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-purchase-invoice/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'finance/purchase_invoice_reverse_form';
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
            'IDX_T_PurchaseInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PurchaseInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_PurchaseInvoice_ReverseValidate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-purchase-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_PurchaseInvoiceHeader'] = $data['IDX_T_PurchaseInvoiceHeader'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_PurchaseOrder'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_PR_PurchaseOrder_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_PurchaseOrder'])[0];
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_PurchaseOrder'] = $data['IDX_T_PurchaseOrder'];
        $data['records_detail'] = $this->exec_sp('USP_PR_PurchaseOrderDetail_List',$param,'list','sqlsrv');              

        $pdf = PDF::loadView('procurement/purchase_order_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }

        if ($return_type == 'download')
        {            
            return $pdf->download($data['fields']->PONumber.'.pdf');   
        }

        if ($return_type == 'email')
        {
            \Storage::put('public/temp/purchase_order-'.$data['fields']->PONumber.'.pdf', $pdf->output());
            
            //echo storage_path().'/app/public/temp/invoice.pdf';

            return storage_path().'/app/public/temp/purchase_order-'.$data['fields']->PONumber.'.pdf'; 
        }
    }


    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'FM-PI-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Purcase Invoice';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Purcase Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_PurchaseInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_PurchaseInvoiceHeader)[0];        
                  
            // RECORDS
            $param['IDX_T_PurchaseInvoiceHeader'] = $request->IDX_T_PurchaseInvoiceHeader;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_PurchaseInvoiceDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/fm-purchase-invoice/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'finance/purchaseinvoice_duplicate_form';
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
            'IDX_T_PurchaseInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PurchaseInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_PurchaseInvoice_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-purchase-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_PurchaseInvoiceHeader'] = $data['IDX_T_PurchaseInvoiceHeader'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

}