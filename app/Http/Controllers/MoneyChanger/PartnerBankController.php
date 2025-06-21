<?php

namespace App\Http\Controllers\MoneyChanger;

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

class PartnerBankController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/procurement.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'General';
        $this->data['form_title'] = 'Business Partner';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_chanager';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('General','Transaction','Business Partner'); 

        // URL
        $this->data['url_create'] = url('mc-partner-bank/create');
        $this->data['url_search'] = url('mc-partner-bank-list');           
        $this->data['url_update'] = url('mc-partner-bank/update/'); 
        $this->data['url_cancel'] = url('mc-partner-bank'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($idx_header)
    {	
        // RECORDS        
        $param['IDX_M_Partner'] = $idx_header;
        $this->data['records_bank'] = $this->exec_sp('USP_GN_PartnerBank_List',$param,'list','sqlsrv'); 
        
        return view('money_changer/partner_bank_list', $this->data);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Add Bank';
        $this->data['form_desc'] = 'Add Partner Bank';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_PartnerBank_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_PartnerBank = '0';  
            $this->data['fields']->IDX_M_Partner = $request->IDX_M_Partner;                      
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
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Update Bank';
        $this->data['form_desc'] = 'Update Vendor Bank';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_PartnerBank_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            //$this->data['fields']->PODate = date('Y-m-d', strtotime($this->data['fields']->PODate));
            //$this->data['fields']->POExpectedDate = date('Y-m-d', strtotime($this->data['fields']->POExpectedDate));
            //$this->data['fields']->MeterStart = number_format($this->data['fields']->MeterStart,2,'.',',');
           

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
        $this->data['dd_bank'] = (array)$dd->bank();         

        // URL
        $this->data['url_save_modal'] = url('/mc-partner-bank/save');         

        // VIEW                
        $this->data['view'] = 'money_changer/partner_bank_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_PartnerBank_Save]';
        $this->sp_update = '[dbo].[USP_GN_PartnerBank_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-partner-bank/reload');

        $validator = Validator::make($request->all(), [
            'IDX_M_PartnerBank' => 'required',
            'IDX_M_Bank' => 'required',            
            'BankAccountNo' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('Street'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
                      
            $param['IDX_M_PartnerBank'] = $data['IDX_M_PartnerBank'];
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_Bank'] = $data['IDX_M_Bank'];
            $param['IsDefault'] = isset($_POST['IsDefault']) ? 'Y' : 'N'; 
            $param['BankAccountNo'] = $data['BankAccountNo'];
            $param['BankAccountName'] = $data['BankAccountName'];
            $param['BankAccountBranch'] = $data['BankAccountBranch'];
            $param['Remarks'] = $data['Remarks'];            
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DELETE
    // =========================================================================================
    public function delete(Request $request)
    {
        $this->data['form_desc'] = 'Delete Data';        

        $this->data['item_index'] = $request->IDX_M_PartnerBank;
        $this->data['item_description'] = $request->BankName;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $this->data['url_save_modal'] = url('mc-partner-bank/save-delete');

        return view('money_changer/partner_bank_delete_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_GN_PartnerBank_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-partner-bank/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_M_PartnerBank'] = $data['item_index']; 
            $param['IDX_M_Partner'] = $data['item_index'];                        
            $param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}
