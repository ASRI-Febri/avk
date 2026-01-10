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

class JournalItemController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/accounting.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'ACCOUNTING';
        $this->data['form_title'] = 'Journal Item';
        $this->data['form_remark'] = 'Journal Item';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Accounting','Transaction','Journal Item'); 

        // URL
        $this->data['url_create'] = url('ac-journal/create');
        $this->data['url_search'] = url('ac-journal-item-list');           
        $this->data['url_update'] = url('ac-journal/update/'); 
        $this->data['url_cancel'] = url('ac-journal'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Journal Item List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Company','Company Name','IDX_M_Branch','Branch Name','IDX_T_JournalHeader','IDX_T_JournalDetail',
            'IDX_M_Partner','Business Partner','Voucher No','Journal Date','Remark Header','PostingStatus','Status',
            'COA ID','COA Desc','COADesc2','Remark Detail','OriginalCurrencyID','ODebetAmount','OCreditAmount','BaseCurrencyID',
            'Debet','Credit','Action');         

        $this->data['table_footer'] = array('','IDX_M_Company','CompanyName','IDX_M_Branch','BranchName','IDX_T_JournalHeader','IDX_T_JournalDetail',
            'IDX_M_Partner','PartnerDesc','VoucherNo','JournalDate','RemarkHeader','PostingStatus','PostingStatusDesc',
            'COAID','COADesc','COADesc2','RemarkDetail','OriginalCurrencyID','ODebetAmount','OCreditAmount','BaseCurrencyID',
            'BDebetAmount','BCreditAmount','Action');

        $this->data['array_filter'] = array('IDX_M_Company','IDX_M_Branch','COAID','COADesc','VoucherNo','RemarkHeader','PostingStatus','PartnerDesc',
            'RemarkDetail','BDebetAmount','BCreditAmount');

        // VIEW
        $this->data['view'] = 'accounting/journal_item_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['IDX_M_Company'] = $request->input('IDX_M_Company');
        $array_filter['IDX_M_Branch'] = $request->input('IDX_M_Branch');
        $array_filter['COAID'] = $request->input('COAID');
        $array_filter['COADesc'] = $request->input('COADesc');
        $array_filter['VoucherNo'] = $request->input('VoucherNo');  
        $array_filter['RemarkHeader'] = $request->input('RemarkHeader'); 
        $array_filter['PostingStatus'] = $request->input('PostingStatus');  
        $array_filter['PartnerDesc'] = $request->input('PartnerDesc'); 
        $array_filter['RemarkDetail'] = $request->input('RemarkDetail'); 
        $array_filter['BDebetAmount'] = $request->input('BDebetAmount'); 
        $array_filter['BCreditAmount'] = $request->input('BCreditAmount'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_JournalItem_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Company','CompanyName','IDX_M_Branch','BranchName','IDX_T_JournalHeader','IDX_T_JournalDetail',
            'IDX_M_Partner','PartnerDesc','VoucherNo','JournalDate','RemarkHeader','PostingStatus','PostingStatusDesc',
            'COAID','COADesc','COADesc2','RemarkDetail','OriginalCurrencyID','ODebetAmount','OCreditAmount','BaseCurrencyID',
            'BDebetAmount','BCreditAmount');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Journal';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Journal';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_COA_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_COA = '0';            
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

        $this->data['form_title'] = 'Journal';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Journal';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_COA_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

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
        $this->data['dd_coa_flag'] = (array) $dd->coa_flag();
        $this->data['dd_debet_credit'] = (array) $dd->debet_credit();                

        // URL
        $this->data['url_save_header'] = url('/ac-journal/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

       
        // VIEW                      
        $this->data['view'] = 'accounting/journal_list';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_COA_Save]';
        $this->sp_update = '[dbo].[USP_GL_COA_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-journal/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_COA' => 'required',
            'IDX_M_COAType' => 'required',
            'FormID' => 'required',
            'FormName' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['IDX_M_COAType'] = $data['IDX_M_COAType'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['ChargeID'] = $data['ChargeID'];
            $param['ChargeDesc'] = $data['ChargeDesc'];
            $param['StampDutyFlag'] = $data['StampDutyFlag'];
            $param['StampDutyCOA'] = $data['StampDutyCOA'];
            $param['VAT_Index'] = $data['VAT_Index'];
            $param['VATFlag'] = $data['VATFlag'];
            $param['VATBase'] = $data['VATBase'];
            $param['VATRate'] = $data['VATRate'];
            $param['PPH_Index'] = $data['PPH_Index'];
            $param['PPHFlag'] = $data['PPHFlag'];
            $param['PPHBase'] = $data['PPHBase'];
            $param['PPHRate'] = $data['PPHRate'];
            $param['IsPPHFinal'] = $data['IsPPHFinal'];
            $param['AdvArr'] = $data['AdvArr'];
            $param['TermInMonth'] = $data['TermInMonth'];
            $param['InstallmentType'] = $data['InstallmentType'];
            $param['DueDayTerm'] = $data['DueDayTerm'];
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
   
}