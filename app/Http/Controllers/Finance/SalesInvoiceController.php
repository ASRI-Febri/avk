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

class SalesInvoiceController extends MyController
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
        $this->data['form_title'] = 'Sales Invoice';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Sales Invoice'); 

        // URL
        $this->data['url_create'] = url('fm-sales-invoice/create');
        $this->data['url_search'] = url('fm-sales-invoice-list');           
        $this->data['url_update'] = url('fm-sales-invoice/update/'); 
        $this->data['url_cancel'] = url('fm-sales-invoice'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-SI-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;
        
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Sales Invoice List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        { 
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_SalesInvoiceHeader', 'Company Name', 'LocationID', 'Location Name', 'Invoice No', 'Partner Name', 'Invoice Date', 'Due Date', 'Remark', 
            'Total Invoice', 'Receive Amount', 'Outstanding', 'Status', 'Action');         

            $this->data['table_footer'] = array('', '', 'CompanyName', 'ProjectID', '', 'InvoiceNo', 'PartnerName', 'InvoiceDate', 'InvoiceDueDate', 'RemarkHeader', 'TotalInvoice', '', '', '', 'Action');

            $this->data['array_filter'] = array('CompanyName','ProjectID','InvoiceNo','RemarkHeader','PartnerName','InvoiceDate','InvoiceDueDate', 'TotalInvoice');

            // VIEW
            $this->data['view'] = 'finance/sales_invoice_list';  
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
        $this->sp_getinquiry = 'dbo.[USP_CM_SalesInvoice_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_SalesInvoiceHeader', 'CompanyName', 'ProjectID', 'ProjectName', 'InvoiceNo', 'PartnerName', 'InvoiceDate', 
            'InvoiceDueDate', 'RemarkHeader', 'TotalInvoice', 'ReceiveAmount', 'Outstanding', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-SI-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Sales Invoice';
        $this->data['form_sub_title'] = 'Create Sales Invoice';
        $this->data['form_desc'] = 'Create Sales Invoice';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_SalesInvoiceHeader = 0;        
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
        $this->data['form_id'] = 'FM-SI-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Sales Invoice';
        $this->data['form_sub_title'] = 'Update Sales Invoice';
        $this->data['form_desc'] = 'Update Sales Invoice';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];         
            
            $this->data['fields']->InvoiceDate = date('Y-m-d', strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->InvoiceDueDate = date('Y-m-d', strtotime($this->data['fields']->InvoiceDueDate));

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
        $this->data['dd_salesperson'] = (array) $dd->salesperson();

        // URL
        $this->data['url_save_header'] = url('/fm-sales-invoice/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_SalesInvoiceHeader'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');
            $this->data['tax_detail'] = $this->exec_sp('USP_CM_SalesInvoiceTax_List',$param,'list','sqlsrv');
            $this->data['payment_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Payment_List',$param,'list','sqlsrv');
            $this->data['journal_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Journal_List',$param,'list','sqlsrv');
        }

        // VIEW        
        $this->data['form_remark'] = 'Master Sales Invoice';        
        $this->data['view'] = 'finance/sales_invoice_form';
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
        $this->data['url_search'] = url('/fm-partner-list-si');

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
    // LOOKUP & SELECT TAX
    // =========================================================================================
    // public function inquiry_data_tax(Request $request)
    // { 
    //     // FILTER FOR STORED PROCEDURE   
    //     $array_filter['PartnerID'] = $request->input('PartnerID');
    //     $array_filter['PartnerName'] = $request->input('PartnerName');
    //     $array_filter['BarcodeMember'] = $request->input('BarcodeMember');
    //     $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber');
    //     $array_filter['PartnerType'] = 'C';
    //     $array_filter['Street'] = $request->input('Street');
                
    //     // SET STORED PROCEDURE
    //     $this->sp_getinquiry = 'dbo.[USP_CM_Tax_List]';

    //     // ARRAY COLUMN AND FILTER FOR DATATABLES
    //     $this->array_filter = $array_filter;
    //     $this->array_column = array('RowNumber', 'IDX_M_Partner', 'PartnerID', 'PartnerName', 'IsCustomer', 'IsSupplier',
    //      'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'StatusDesc');

    //     return $this->get_datatables($request);
    // }

    // public function show_lookup_tax(Request $request)
    // {
    //     $this->data['form_title'] = 'Tax';
    //     $this->data['form_sub_title'] = 'Select Tax';
    //     $this->data['form_desc'] = 'Select Tax';		
        
    //     // URL TO DATATABLES
    //     $this->data['url_search'] = url('/fm-tax-list');

    //     // TABLE HEADER & FOOTER
    //     $this->data['table_header'] = array('No', 'IDX_M_Partner', 'Partner ID', 'Partner Name', 'Is Customer', 'Is Supplier',
    //      'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'Status', 'Action');         

    //     $this->data['table_footer'] = array('', '',
    //         'PartnerID', 'PartnerName', '', '', '', 'Street', '', '');

    //     $this->data['array_filter'] = array('PartnerID','PartnerName','Street');

    //     $this->data['target_index'] = $request->target_index;
    //     $this->data['target_name'] = $request->target_name;

        

    //     return view('finance/m_select_tax_list', $this->data);
    // }

    // =========================================================================================
    // AJAX REQUEST
    // =========================================================================================
    public function search_so_no(Request $request)
    {
        $search_value = $request->input('q','');          

        $param['SearchValue'] = $search_value;
        $records = $this->exec_sp('USP_CM_SalesOrderSearchByValue_List',$param,'list','sqlsrv');

        $items = array();
        $row_array = array();

        foreach ($records as $row){
        
            $row_array['label'] = $row->OrderNo;				
            
            // $row_array['IDX_T_PurchaseOrder'] = $row->IDX_T_PurchaseOrder;
            
            array_push($items, $row_array);	            
        }

        $result["rows"] = $items;
			
        echo json_encode($items);

    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_SalesInvoiceHeader_Create]';
        $this->sp_update = '[dbo].[USP_CM_SalesInvoiceHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-sales-invoice/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_SalesInvoiceHeader' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_Currency' => 'required',
            'IDX_M_Partner' => 'required',
            'IDX_M_SalesPerson' => 'required',
            'ReferenceNo' => 'required',
            'InvoiceDate' => 'required',
            'InvoiceDueDate' => 'required',
            'RemarkHeader' => 'required',
            'COAHeader' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];    
            }
            
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_LocationInventory'] = 0;
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_DocumentType'] = 1;
            $param['IDX_ReferenceNo'] = 0;
            $param['IDX_M_SalesPerson'] = $data['IDX_M_SalesPerson'];
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['TaxInvoiceNo'] = '';
            $param['InvoiceNo'] = '';
            $param['InvoiceDate'] = $data['InvoiceDate'];
            $param['InvoiceDueDate'] = $data['InvoiceDueDate'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['AuditNotes'] = $data['AuditNotes'];
            $param['InvoiceStatus'] = 'D';
            $param['COAHeader'] = $data['IDX_M_COA'];
            
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
        $this->data['form_id'] = 'FM-SI-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Approval Sales Invoice';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Sales Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesInvoiceHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-sales-invoice/save-approve');            

            // VIEW                          
            $this->data['view'] = 'finance/sales_invoice_approval_form';
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
            'IDX_T_SalesInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_SalesInvoice_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-sales-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
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
        $this->data['form_id'] = 'FM-SI-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Reverse Sales Invoice';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Sales Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesInvoiceHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-sales-invoice/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'finance/sales_invoice_reverse_form';
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
            'IDX_T_SalesInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_SalesInvoice_ReverseValidate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-sales-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // VOID
    // =========================================================================================
    public function void(Request $request)
    {
        $this->data['form_id'] = 'FM-SI-V';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        // $access = TRUE;
       
        $this->data['form_title'] = 'Void Sales Invoice';
        $this->data['form_sub_title'] = 'Void';        
        $this->data['form_desc'] = 'Void Sales Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesInvoiceHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/fm-sales-invoice/save-void');            

            // VIEW                          
            $this->data['view'] = 'finance/sales_invoice_void_form';
            $this->data['submit_title'] = 'Void';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_void(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_SalesInvoice_Void]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-sales-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // DOWNLOAD PDF INVOICE
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_SalesInvoiceHeader'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_SalesInvoiceHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Sales Invoice';  
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');      

        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->TotalAmount);

        $pdf = PDF::loadView('finance/sales_invoice_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }
    }

    // DOWNLOAD PDF RECEIPT
    public function downloadreceipt_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_SalesInvoiceHeader'] = $id;        

        return $this->generatereceipt_pdf($data,'stream');
    }
    
    public function generatereceipt_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_SalesInvoiceHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Sales Invoice';  
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');      

        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->TotalAmount);

        $pdf = PDF::loadView('finance/sales_receipt_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }
    }

    // DOWNLOAD PDF REKAP HARIAN
    public function daily_summary_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_SalesInvoiceHeader'] = $id;        

        return $this->generate_daily_summary_pdf($data,'stream');
    }
    
    public function generate_daily_summary_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_SalesInvoiceHeader'])[0];
        $data['fields']->DocumentTypeDesc = 'Rekap Harian';  
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
        $data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');    

        $uniqid = $data['fields']->ReferenceNo;

        // RECORDS SUMMARY
        $param_summary['UploadID'] = $uniqid;   
        $data['records_sales_sumamry'] = $this->exec_sp('USP_QP_UploadSummary_Sales',$param_summary,'list','sqlsrv');
        $data['records_member_sumamry'] = $this->exec_sp('USP_QP_UploadSummary_Member',$param_summary,'list','sqlsrv');
        
        // RECORDS DETAIL SALES
        $sql = "SELECT * 
                FROM [dbo].[X_SalesSummary_Quality]
                WHERE UploadID = '" . $uniqid . "'
                ORDER BY CompanyID, LocationID ";
        
        $data['records_sales'] = $this->exec_sql($sql,'list','sqlsrv'); 

        // RECORDS DETAIL MEMBER
        $sql_member = "SELECT * 
                FROM [dbo].[X_MemberSummary_Quality]
                WHERE UploadID = '" . $uniqid . "'
                ORDER BY CompanyID, LocationID ";
        
        $data['records_member'] = $this->exec_sql($sql_member,'list','sqlsrv'); 


        $data['fields']->AmountTerbilang = $this->terbilang($data['fields']->TotalAmount);

        $pdf = PDF::loadView('finance/sales_invoice_daily_summary_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }
    }

    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'FM-SI-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Sales Invoice';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Sales Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesInvoiceHeader)[0];        
                  
            // RECORDS
            $param['IDX_T_SalesInvoiceHeader'] = $request->IDX_T_SalesInvoiceHeader;   
            $this->data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/fm-sales-invoice/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'finance/salesinvoice_duplicate_form';
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
            'IDX_T_SalesInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_SalesInvoice_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-sales-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // AUDIT NOTES
    // =========================================================================================
    public function auditnotes(Request $request)
    {
        // $this->data['form_id'] = 'FM-SI-A';
        // $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Update Audit Notes Information';
        $this->data['form_sub_title'] = 'Update';        
        $this->data['form_desc'] = 'Update Audit Notes Information';
        
        $this->data['state'] = 'approve';


            // GET DATA
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesInvoiceHeader)[0];         

            // URL
            $this->data['url_save_modal'] = url('/fm-sales-invoice/save-auditnotes');            

            // VIEW                          
            $this->data['view'] = 'finance/sales_invoice_updateauditnotes_form';
            $this->data['submit_title'] = 'Update';

            return view($this->data['view'], $this->data);
    }

    public function save_auditnotes(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesInvoiceHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_SalesInvoice_UpdateAuditNotes]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/fm-sales-invoice/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
            $param['AuditNotes'] = $data['AuditNotes'];
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

}