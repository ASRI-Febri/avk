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

class FinancialAccountController extends MyController
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
        $this->data['form_title'] = 'Financial Account';
        $this->data['form_remark'] = 'Financial Account (FA) atau fund deposit adalah akun kas atau bank yang digunakan untuk 
            penerimaan dan pengeluaran uang';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('Finance','Setting','Financial Account'); 

        // URL
        $this->data['url_create'] = url('fm-financial-account/create');
        $this->data['url_search'] = url('fm-financial-account-list');           
        $this->data['url_update'] = url('fm-financial-account/update/'); 
        $this->data['url_cancel'] = url('fm-financial-account'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-FA-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Financial Account List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');

        if ($access == TRUE)
        {       

            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_M_FinancialAccount', 'ID', 'Description', 'Account No', 'Account Name', 'Status', 'Action');         

            $this->data['table_footer'] = array('', '', 'FinancialAccountID', 'FinancialAccountDesc', 'AccountNo', 'AccountName', '', 'Action');

            $this->data['array_filter'] = array('FinancialAccountID','FinancialAccountDesc','AccountNo','AccountName');

            // VIEW
            $this->data['view'] = 'finance/financial_account_list';  
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
        $array_filter['FinancialAccountID'] = $request->input('FinancialAccountID');
        $array_filter['FinancialAccountDesc'] = $request->input('FinancialAccountDesc');
        $array_filter['AccountNo'] = $request->input('AccountNo');  
        $array_filter['AccountName'] = $request->input('AccountName');
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_FinancialAccount_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_FinancialAccount', 'FinancialAccountID', 'FinancialAccountDesc', 'AccountNo', 
            'AccountName', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-FA-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Account';
        $this->data['form_sub_title'] = 'Create Financial Account';
        $this->data['form_desc'] = 'Create Financial Account';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_FinancialAccount_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_FinancialAccount = 0;        
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
        $this->data['form_id'] = 'FM-FA-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Financial Account';
        $this->data['form_sub_title'] = 'Update Financial Account';
        $this->data['form_desc'] = 'Update Financial Account';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_FinancialAccount_Info]';
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
        $this->data['dd_account_type'] = (array) $dd->account_type();
        $this->data['dd_currency'] = (array) $dd->currency();
        $this->data['dd_bank'] = (array) $dd->bank();

        // URL
        $this->data['url_save_header'] = url('/fm-financial-account/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW  
        $this->data['view'] = 'finance/financial_account_form';
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
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_FinancialAccount_Create]';
        $this->sp_update = '[dbo].[USP_CM_FinancialAccount_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-financial-account/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_FinancialAccount' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_Bank' => 'required',
            'IDX_M_Currency' => 'required',
            'IDX_M_COA' => 'required',
            'FinancialAccountID' => 'required',
            'FinancialAccountDesc' => 'required',
            'FinancialAccountType' => 'required',
            'AccountName' => 'required',
            'AccountNo' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_FinancialAccount'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // SET PARAMETER
            if($state == 'update'){
                $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];    
            }
            
            $param['IDX_M_Company'] = 0;
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_Bank'] = $data['IDX_M_Bank'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['FinancialAccountID'] = $data['FinancialAccountID'];
            $param['FinancialAccountDesc'] = $data['FinancialAccountDesc'];
            $param['FinancialAccountType'] = $data['FinancialAccountType'];
            $param['AccountName'] = $data['AccountName'];
            $param['AccountNo'] = $data['AccountNo'];
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}