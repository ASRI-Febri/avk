<?php

namespace App\Http\Controllers\Accounting;

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

class JournalDetailController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/accounting.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Journal';
        $this->data['form_title'] = 'Journal';
        $this->data['form_remark'] = 'Journal accounting';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Accounting','Transaction','Journal'); 

        // URL
        $this->data['url_create'] = url('ac-journal/create');
        $this->data['url_search'] = url('ac-journal-item-list');           
        $this->data['url_update'] = url('ac-journal/update/'); 
        $this->data['url_cancel'] = url('ac-journal'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        //dd($id);
        $param['IDX_T_JournalHeader'] = $id;
          
        $this->data['records_detail'] = $this->exec_sp('dbo.USP_GL_JournalDetail_List',$param,'list','sqlsrv');
        
        return view('accounting/journal_detail_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Journal List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Company','Company','IDX_M_Branch','Branch','IDX_T_JournalHeader',
            'IDX_M_Partner','Partner','Reference No','Voucher No','Journal Date','Remark','PostingStatus','Status','Action');         

        $this->data['table_footer'] = array('','IDX_M_Company','CompanyName','IDX_M_Branch','BranchName','',
            '','PartnerDesc','ReferenceNo','VoucherNo','JournalDate','RemarkHeader','','PostingStatusDesc','Action');

        $this->data['array_filter'] = array('IDX_M_Company','IDX_M_Branch','ReferenceNo','VoucherNo','RemarkHeader','PostingStatus','PartnerDesc');

        // VIEW
        $this->data['view'] = 'accounting/journal_item_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['IDX_M_Company'] = $request->input('IDX_M_Company');
        $array_filter['IDX_M_Branch'] = $request->input('IDX_M_Branch');
        $array_filter['ReferenceNo'] = $request->input('ReferenceNo');
        $array_filter['VoucherNo'] = $request->input('VoucherNo');  
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader'); 
        $array_filter['PostingStatus'] = $request->input('PostingStatus');  
        $array_filter['PartnerDesc'] = $request->input('PartnerDesc'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_JournalItem_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Company','CompanyName','IDX_M_Branch','BranchName','IDX_T_JournalHeader',
            'IDX_M_Partner','PartnerDesc','ReferenceNo','VoucherNo','JournalDate','RemarkHeader','PostingStatus','PostingStatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'PR-PO-C';

        //$access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Journal Detail';
        $this->data['form_sub_title'] = 'Create Journal Detail';
        $this->data['form_desc'] = 'Create Journal Detail';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_JournalDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_JournalDetail = '0';
            $this->data['fields']->IDX_T_JournalHeader = $request->IDX_T_JournalHeader;
            $this->data['fields']->ExchangeRate = '1.00';
            $this->data['fields']->OriginalCurrencyID = '1';
            $this->data['fields']->ODebetAmount = '0.00';
            $this->data['fields']->OCreditAmount = '0.00';
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
        $this->data['form_id'] = 'PR-PO-U';

        //$access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Journal Detail';
        $this->data['form_sub_title'] = 'Update Journal Detail';
        $this->data['form_desc'] = 'Update Journal Detail';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_JournalDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->COADesc = $this->data['fields']->COAID . ' - ' . $this->data['fields']->COADesc;
            $this->data['fields']->ODebetAmount = number_format($this->data['fields']->ODebetAmount,2,'.',',');
            $this->data['fields']->OCreditAmount = number_format($this->data['fields']->OCreditAmount,2,'.',',');

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
        $this->data['dd_department'] = (array) $dd->department();
        $this->data['dd_currency'] = (array) $dd->currency();

        // URL
        $this->data['url_save_modal'] = url('/ac-journal-detail/save');       

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Journal detail terdiri dari chart of account, journal description dan nominal debet credit ';        
        $this->data['view'] = 'accounting/journal_detail_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_JournalDetail_Create]';
        $this->sp_update = '[dbo].[USP_GL_JournalDetail_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-journal-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_JournalDetail' => 'required',
            'IDX_M_Project' => 'required',
        ]);

        if ($validator->fails()) {
            // return $this->validation_fails($validator->errors(), $request->input('FormID'));
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_JournalDetail'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update'){
                $param['IDX_T_JournalDetail'] = $data['IDX_T_JournalDetail'];    
            }   

            $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];
            $param['IDX_M_Project'] = $data['IDX_M_Project'];
            $param['IDX_M_Department'] = $data['IDX_M_Department'];
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['IDX_M_Partner'] = isset($data['IDX_M_Partner']) ? $data['IDX_M_Partner'] : '0';
            $param['JournalSeqNo'] = isset($data['JournalSeqNo']) ? $data['JournalSeqNo'] : '0';
            $param['COADescription'] = $data['COADesc'];
            $param['RemarkDetail'] = $data['RemarkDetail'];
            $param['OriginalCurrencyID'] = $data['OriginalCurrencyID'];

            $param['ODebetAmount'] = (double)str_replace(',','',$data['ODebetAmount']);
            $param['OCreditAmount'] = (double)str_replace(',','',$data['OCreditAmount']);
            $param['ExchangeRate'] = (double)str_replace(',','',$data['ExchangeRate']);
            $param['BaseCurrencyID'] = isset($data['BaseCurrencyID']) ? $data['BaseCurrencyID'] : '0';
            $param['BDebetAmount'] = (double)str_replace(',','',$param['ODebetAmount'] * $param['ExchangeRate']);
            $param['BCreditAmount'] = (double)str_replace(',','',$param['OCreditAmount'] * $param['ExchangeRate']);           
            
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

        $this->data['item_index'] = $request->IDX_T_JournalDetail;
        $this->data['item_description'] = $request->COADesc;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $this->data['url_save_modal'] = url('ac-journal-detail/save-delete');

        return view('accounting/journal_detail_delete_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_GL_JournalDetail_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-journal-detail/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_T_JournalDetail'] = $data['item_index'];            
            
            //$param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate($id)
    {
        $this->data['form_id'] = 'PR-PO-U';

        //$access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Journal Detail';
        $this->data['form_sub_title'] = 'Duplicate Journal Detail';
        $this->data['form_desc'] = 'Duplicate Journal Detail';              
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_JournalDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->COADesc = $this->data['fields']->COAID . ' - ' . $this->data['fields']->COADesc;
            $this->data['fields']->ODebetAmount = number_format($this->data['fields']->ODebetAmount,2,'.',',');
            $this->data['fields']->OCreditAmount = number_format($this->data['fields']->OCreditAmount,2,'.',',');

            return $this->show_form($id, 'update');
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }
}