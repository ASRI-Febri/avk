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

class FinancialReceiveDetailController extends MyController
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
        $this->data['form_title'] = 'Financial Receive Detail Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Financial Receive Detail'); 

        // URL
        $this->data['url_create'] = url('fm-financial-receive-detail/create');
        $this->data['url_search'] = url('fm-financial-receive-detail-list');           
        $this->data['url_update'] = url('fm-financial-receive-detail/update/'); 
        $this->data['url_cancel'] = url('fm-financial-receive-detail'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        //dd($id);
        $param['IDX_T_FinancialReceiveHeader'] = $id;
          
        $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialReceiveDetail_List',$param,'list','sqlsrv');
        $this->data['allocation_detail'] = $this->exec_sp('USP_CM_ReceiveAllocation_List',$param,'list','sqlsrv');
        
        return view('finance/financial_receive_detail_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_T_FinancialReceiveHeader'] = $request->input('IDX_T_FinancialReceiveHeader');

        // // SET STORED PROCEDURE
        // $this->sp_getinquiry = 'dbo.[usp_CM_PurchaseInvoiceDetail_List]';

        // // ARRAY COLUMN AND FILTER FOR DATATABLES
        // $this->array_filter = $array_filter;

        // $this->array_column = array(
        //     'RowNumber','IDX_T_PurchaseInvoiceDetail','ItemSKU','ItemAlias','ItemDesc'
        //         ,'UOMID','UOMDesc','BrandAlias','BrandDesc','CurrencyDesc','IDX_M_Partner'
        //         ,'InvoiceStatus','StatusDesc','COAID','COADesc','IDX_M_COA');

        // return $this->get_datatables($request);

        $this->data['records_detail'] = $this->exec_sp('USP_CM_FinancialReceiveDetail_List',$param,'list','sqlsrv');
        $this->data['allocation_detail'] = $this->exec_sp('USP_CM_ReceiveAllocation_List',$param,'list','sqlsrv');
        
        return view('finance/financial_receive_detail_list', $this->data);
    }
    
    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'FM-FRD-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Financial Receive Detail';
        $this->data['form_sub_title'] = 'Create Financial Receive Detail';
        $this->data['form_desc'] = 'Create Financial Receive Detail';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceiveDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_FinancialReceiveDetail = '0';
            $this->data['fields']->IDX_T_FinancialReceiveHeader = $request->IDX_T_FinancialReceiveHeader;
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-FRD-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Financial Receive Detail';
        $this->data['form_sub_title'] = 'Update Financial Receive Detail';
        $this->data['form_desc'] = 'Update Financial Receive Detail';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_FinancialReceiveDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->ReceiveAmount = number_format($this->data['fields']->ReceiveAmount,0,'.',',');
           

            return $this->show_form($id, 'update');
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;  
        $this->data['dd_project'] = (array) $dd->project($this->data['user_id']);

        // URL
        $this->data['url_save_modal'] = url('/fm-financial-receive-detail/save');
       

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Financial Receive Detail';        
        $this->data['view'] = 'finance/financial_receive_detail_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_FinancialReceiveDetail_Create]';
        $this->sp_update = '[dbo].[USP_CM_FinancialReceiveDetail_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-financial-receive-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_FinancialReceiveDetail' => 'required',
        ]);

        if ($validator->fails()) {
            // return $this->validation_fails($validator->errors(), $request->input('FormID'));
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_FinancialReceiveDetail'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update'){
                $param['IDX_T_FinancialReceiveDetail'] = $data['IDX_T_FinancialReceiveDetail'];    
            }   

            $param['IDX_T_FinancialReceiveHeader'] = $data['IDX_T_FinancialReceiveHeader'];
            $param['IDX_M_Project'] = $data['IDX_M_Project'];
            $param['IDX_M_DocumentType'] = 1;
            $param['IDX_DocumentNo'] = 0;
            $param['DocumentNo'] = "";
            $param['COADetail'] = $data['IDX_M_COA'];

            $param['ReceiveAmount'] = (double)str_replace(',','',$data['ReceiveAmount']);
            // $param['ReceiveAmount'] = filter_var($data['ReceiveAmount'], FILTER_SANITIZE_NUMBER_INT);
            
            $param['RemarkDetail'] = $data['RemarkDetail'];           
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';
            
            // '',89,'',1,9,1,'SKU-89 - LEM PIPA KALENG',1,3,3,2,3,4,2301013,'A'

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DELETE
    // =========================================================================================
    public function delete(Request $request)
    {
        $this->data['form_id'] = 'FM-FRD-D';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $this->data['form_desc'] = 'Delete Data';        

        if ($access == TRUE)
        { 
            $this->data['item_index'] = $request->IDX_T_FinancialReceiveDetail;
            $this->data['item_description'] = $request->ItemDesc;

            $this->data['state'] = 'delete'; 

            // URL SAVE
            $this->data['url_save_modal'] = url('fm-financial-receive-detail/save-delete');

            return view('finance/financial_receive_detail_delete', $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_CM_FinancialReceiveDetail_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-financial-receive-detail/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_T_FinancialReceiveDetail'] = $data['item_index'];            
            
            //$param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // ALLOCATE
    // =========================================================================================
        // =========================================================================================
        // CREATE
        // =========================================================================================
        public function create_allocation($id)
        {
            $this->data['form_id'] = 'FM-FRD-Create-Allocation';

            $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

            //$access = TRUE;

            $this->data['form_title'] = 'Financial Receive Allocation';
            $this->data['form_sub_title'] = 'Create Financial Receive Allocation';
            $this->data['form_desc'] = 'Create Financial Receive Allocation';       
            $this->data['state'] = 'create';

            // BREADCRUMB
            array_push($this->data['breads'], 'Create');  

            if ($access == TRUE) {

                $this->sp_getdata = '[dbo].[USP_CM_ReceiveAllocation_Info]';
                $this->data['fields'] = (object) $this->get_detail_by_id(0);

                $this->sp_getdata = '[dbo].[USP_CM_FinancialReceiveDetail_Info]';
                $this->data['partnerid'] = $this->get_detail_by_id($id)[0];

                // SET DEFAULT VALUE
                $this->data['fields']->IDX_T_ReceiveAllocation = 0;      
                $this->data['fields']->COAAllocation = $this->data['partnerid']->COADetail; 
                $this->data['fields']->COADesc1 = $this->data['partnerid']->COAID . ' - '  . $this->data['partnerid']->COADesc;      
                $this->data['fields']->AllocationDate = date('Y-m-d', strtotime($this->data['partnerid']->ReceiveDate));  
                $this->data['fields']->RecordStatus = 'A';

                return $this->show_allocation_form(0, 'create', $this->data['partnerid']->IDX_M_Partner);
            } else {

                return $this->show_no_access($this->data);
            }
        }

        // =========================================================================================
        // UPDATE
        // =========================================================================================
        public function update_allocation($id)
        {
            $this->data['form_id'] = 'FM-FRD-Update-Allocation';

            $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

            // $access = TRUE;

            $this->data['form_title'] = 'Financial Receive Allocation';
            $this->data['form_sub_title'] = 'Update Financial Receive Allocation';
            $this->data['form_desc'] = 'Update Financial Receive Allocation';              
            $this->data['state'] = 'update';

            // BREADCRUMB
            array_push($this->data['breads'], 'Update');  

            if ($access == TRUE)
            {
                $this->sp_getdata = '[dbo].[USP_CM_ReceiveAllocation_Info]';
                $this->data['fields'] = $this->get_detail_by_id($id)[0];
                
                $this->sp_getdata = '[dbo].[USP_CM_FinancialReceiveDetail_Info]';
                $this->data['partnerid'] = $this->get_detail_by_id($this->data['fields']->IDX_T_FinancialReceiveDetail)[0];

                // DEFAULT VALUE & FORMAT
                $this->data['fields']->AllocationAmount = number_format($this->data['fields']->AllocationAmount,0,'.',',');
                $this->data['fields']->COADesc1 = $this->data['fields']->COA2 . ' - '  . $this->data['fields']->COADesc21;

                return $this->show_allocation_form($id, 'update', $this->data['partnerid']->IDX_M_Partner);
            } 
            else 
            {
                return $this->show_no_access($this->data);
            }
        }

        // =========================================================================================
        // SHOW FORM
        // =========================================================================================
        function show_allocation_form($id, $state, $IDX_M_Partner)
        {
            // // DROPDOWN
            // $dd = new DropdownController;        
            // $this->data['dd_document_no'] = (array) $dd->document_no_fr('sqlsrv', $IDX_M_Partner);

            // URL
            $this->data['url_save_modal'] = url('/fm-financial-receive-detail/save-allocation');
        

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
                // $this->data['journal_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Journal_List',$param,'list','sqlsrv');
            }

            // VIEW        
            $this->data['form_remark'] = 'Financial Receive Allocation';        
            $this->data['view'] = 'finance/financial_receive_allocate_form';
            return view($this->data['view'], $this->data);
        }

        // =========================================================================================
        // SAVE DATA
        // =========================================================================================
        public function save_allocation(Request $request)
        {
            $this->sp_create = '[dbo].[USP_CM_ReceiveAllocation_Create]';
            $this->sp_update = '[dbo].[USP_CM_ReceiveAllocation_Update]';
            $this->next_action = 'reload';
            $this->next_url = url('/fm-financial-receive-detail/reload');

            $validator = Validator::make($request->all(), [
                'IDX_T_ReceiveAllocation' => 'required',
            ]);

            if ($validator->fails()) {
                return $this->validation_fails($validator->errors(), $request->input('IDX_T_ReceiveAllocation'));
            } else {

                $data = $request->all();
                
                $state = $data['state'];

                // SET PARAMETER
                if($state == 'update'){
                    $param['IDX_T_ReceiveAllocation'] = $data['IDX_T_ReceiveAllocation'];    
                }
                
                $param['IDX_T_FinancialReceiveDetail'] = $data['IDX_T_FinancialReceiveDetail'];
                $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
                $param['IDX_M_DocumentType'] = '1';
                $param['IDX_DocumentNo'] = $data['IDX_DocumentNo'];
                $param['AllocationID'] = '-';
                $param['DocumentNo'] = $data['DocumentNo'];
                $param['COAAllocation'] = $data['COAAllocation'];
                $param['AllocationDate'] = $data['AllocationDate'];
                $param['AllocationAmount'] = (double)str_replace(',','',$data['AllocationAmount']); 
                $param['RemarkAllocation'] = $data['RemarkAllocation'];
                $param['AllocationStatus'] = 'D';

                $param['UserID'] = 'XXX'.$this->data['user_id'];
                $param['RecordStatus'] = 'A';            

                return $this->store($state, $param);
            }
        }

        // =========================================================================================
        // DELETE
        // =========================================================================================
        public function delete_allocation(Request $request)
        {
            $this->data['form_id'] = 'FM-FRD-Delete-Allocation';

            $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

            // $access = TRUE;
            
            $this->data['form_desc'] = 'Delete Data';        

            if ($access == TRUE)
            { 
                $this->data['item_index'] = $request->IDX_T_ReceiveAllocation;
                $this->data['item_description'] = '';

                $this->data['state'] = 'delete'; 

                // URL SAVE
                $this->data['url_save_modal'] = url('fm-financial-receive-detail/save-delete-allocation');

                return view('finance/financial_receive_allocate_delete', $this->data);
            } 
            else 
            {
                return $this->show_no_access_modal($this->data);
            }
        }

        public function save_delete_allocation(Request $request)
        {
            $this->sp_delete = '[dbo].[USP_CM_ReceiveAllocation_Delete]';
            $this->next_action = 'reload';
            $this->next_url = url('/fm-financial-receive-detail/reload');

            $validator = Validator::make($request->all(),[            
                'item_index' => 'required',
            ]);

            if ($validator->fails()) {
                return $this->validation_fails($validator->errors(), $request->input('item_index'));
            } else {

                $data = $request->all();
                
                $state = 'delete';
                
                $param['IDX_T_ReceiveAllocation'] = $data['item_index'];            
                
                //$param['UserID'] = $this->data['user_id'];
                //$param['RecordStatus'] = 'A';            

                return $this->store($state, $param);
            }
        }

        // =========================================================================================
        // APPROVE
        // =========================================================================================
        public function approve_allocation(Request $request)
        {
            $this->data['form_id'] = 'FM-FRD-Approve-Allocation';

            $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

            // $access = TRUE;
        
            $this->data['form_title'] = 'Approval Financial Receive Allocation';
            $this->data['form_sub_title'] = 'Approval';        
            $this->data['form_desc'] = 'Approval Financial Receive Allocation';
            
            $this->data['state'] = 'approve';

            if ($access == TRUE)
            {
                // GET DATA
                $this->sp_getdata = '[dbo].[USP_CM_ReceiveAllocation_Info]';
                $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_ReceiveAllocation)[0];         

                // DEFAULT VALUE                                  
                $this->data['fields']->ApprovalRemark = '';           
                $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->ReceiveDate));
                $this->data['fields']->ApprovalBy = $this->data['user_id'];

                // URL
                $this->data['url_save_modal'] = url('/fm-financial-receive-detail/save-approve-allocation');            

                // VIEW                          
                $this->data['view'] = 'finance/financial_receive_allocate_approve';
                $this->data['submit_title'] = 'Approve';

                return view($this->data['view'], $this->data);
            } 
            else 
            {
                return $this->show_no_access_modal($this->data);
            }
        }

        public function save_approve_allocation(Request $request)
        {
            $validator = Validator::make($request->all(), [
                'IDX_T_ReceiveAllocation' => 'required'                                  
            ]);

            if ($validator->fails()) {
                return $this->validation_fails($validator->errors(), $request->input('IDX_T_ReceiveAllocation'));
            } 
            else
            {
                $this->sp_approval = '[dbo].[USP_CM_ReceiveAllocation_Approve]'; 
                $this->next_action = 'reload';
                $this->next_url = url('/fm-financial-receive/update');

                $state = 'approve';
                
                $data = $request->all();
                
                $param['IDX_T_ReceiveAllocation'] = $data['IDX_T_ReceiveAllocation'];
                $param['ApprovalRemark'] = $data['ApprovalRemark'];
                $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
                $param['UserID'] = 'XXX'.$data['ApprovalBy']; 

                return $this->store($state,$param);
            }   
        }
}
