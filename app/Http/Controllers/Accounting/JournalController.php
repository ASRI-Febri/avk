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

class JournalController extends MyController
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
        $this->data['form_title'] = 'Journal';
        $this->data['form_remark'] = 'Journal accounting';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Accounting','Transaction','Journal'); 

        // URL
        $this->data['url_create'] = url('ac-journal/create');
        $this->data['url_search'] = url('ac-journal-list');           
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
        $this->data['view'] = 'accounting/journal_list';  
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
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_Journal_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Company','CompanyName','IDX_M_Branch','BranchName','IDX_T_JournalHeader',
            'IDX_M_Partner','PartnerDesc','ReferenceNo','VoucherNo','JournalDate','RemarkHeader','PostingStatus','PostingStatusDesc');

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

            $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_JournalHeader = '0';
            $this->data['fields']->IDX_M_JournalType = '0';
            $this->data['fields']->IDX_M_Partner = '0';
            $this->data['fields']->IDX_ReferenceNo = '0';            
            $this->data['fields']->PostingStatus = 'U';
            $this->data['fields']->JournalSource = 'M'; // M = Manual Entry, S = System Generated
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
            $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            $this->data['fields']->JournalDate = date('Y-m-d',strtotime($this->data['fields']->JournalDate));

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
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);   
        $this->data['dd_branch'] = (array) $dd->branch($this->data['user_id']);
        $this->data['dd_coa_flag'] = (array) $dd->coa_flag();
        $this->data['dd_debet_credit'] = (array) $dd->debet_credit();   
        $this->data['dd_currency'] = (array) $dd->currency();
        $this->data['dd_journal_type'] = (array) $dd->journal_type_entry();             

        // URL
        $this->data['url_save_header'] = url('/ac-journal/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_JournalHeader'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('dbo.USP_GL_JournalDetail_List',$param,'list','sqlsrv');            
        }
       
        // VIEW                      
        $this->data['view'] = 'accounting/journal_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_JournalHeader_Create]';
        $this->sp_update = '[dbo].[USP_GL_JournalHeader_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-journal/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_JournalType' => 'required',
            'JournalDate' => 'required',
            'RemarkHeader' => 'required',
            'IDX_M_Partner' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update'){
                $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];    
            } 
            
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_JournalType'] = $data['IDX_M_JournalType'];
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['ApplicationID'] = isset($data['ApplicationID']) ? $data['ApplicationID'] : '0';
            $param['IDX_ReferenceNo'] = $data['IDX_ReferenceNo'];
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['VoucherNo'] = $data['VoucherNo'];
            $param['JournalDate'] = $data['JournalDate'];
            $param['RemarkHeader'] = $data['RemarkHeader'];
            $param['PartnerDesc'] = $data['PartnerDesc'];
            $param['PostingStatus'] = $data['PostingStatus'];
            // $param['PostingDate'] = isset($data['PostingDate']) ? $data['PostingDate'] : '';
            // $param['PostedBy'] = isset($data['PostedBy']) ? $data['PostedBy'] : '';
            $param['DebetAmount'] = isset($data['DebetAmount']) ? (double)str_replace(',','',$data['DebetAmount']) : 0;
            $param['CreditAmount'] = isset($data['CreditAmount']) ? (double)str_replace(',','',$data['CreditAmount']) : 0;
            $param['JournalSource'] = $data['JournalSource'];           
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
   
    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function posting(Request $request)
    {
        $this->data['form_id'] = 'AC-JOURNAL-POSTING';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Posting Journal';
        $this->data['form_sub_title'] = 'Posting';        
        $this->data['form_desc'] = 'Posting Journal';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_JournalHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->PostingNotes = '';           
            $this->data['fields']->PostingDate = date('Y-m-d',strtotime($this->data['fields']->JournalDate));
            $this->data['fields']->PostedBy = $this->data['user_id']; 

            // DROPDOWN
            //$dd = new DropdownController;  
            //$this->data['dd_receiving_status'] = (array)$dd->receiving_item_status($this->data['fields']->ReceivingStatus);

            // URL
            $this->data['url_save_modal'] = url('/ac-journal/save-posting');            

            // VIEW                          
            $this->data['view'] = 'accounting/journal_posting_form';
            $this->data['submit_title'] = 'Approve';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_posting(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_JournalHeader' => 'required' ,      
            'PostingDate' => 'required',
            'PostingNotes' => 'required'                      
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_JournalHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_GL_Journal_Posting]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/ac-journal/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];
            $param['PostingDate'] = date('Y-m-d',strtotime($data['PostingDate']));
            $param['PostingNotes'] = $data['PostingNotes'];
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function unposting(Request $request)
    {
        $this->data['form_id'] = 'AC-JOURNAL-UNPOSTING';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');         
       
        $this->data['form_title'] = 'Unposting Journal';
        $this->data['form_sub_title'] = 'Unposting';        
        $this->data['form_desc'] = 'Unposting Journal';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_JournalHeader)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->PostingNotes = '';           
            $this->data['fields']->PostingDate = date('Y-m-d',strtotime($this->data['fields']->JournalDate));
            $this->data['fields']->PostedBy = $this->data['user_id']; 

            // DROPDOWN
            //$dd = new DropdownController;  
            //$this->data['dd_receiving_status'] = (array)$dd->receiving_item_status($this->data['fields']->ReceivingStatus);

            // URL
            $this->data['url_save_modal'] = url('/ac-journal/save-unposting');            

            // VIEW                          
            $this->data['view'] = 'accounting/journal_unposting_form';
            $this->data['submit_title'] = 'Unposting';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_unposting(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_JournalHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_JournalHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_GL_Journal_Unposting]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/ac-journal/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];
            $param['PostingDate'] = date('Y-m-d',strtotime($data['PostingDate']));
            $param['PostingNotes'] = $data['PostingNotes'];
            $param['UserID'] = 'XXX'.$this->data['user_id'];  

            return $this->store($state,$param);
        }   
    }

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_JournalHeader'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_JournalHeader'])[0];
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];
        $data['records_detail'] = $this->exec_sp('dbo.USP_GL_JournalDetail_List',$param,'list','sqlsrv');              

        $pdf = PDF::loadView('accounting/journal_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }

        if ($return_type == 'download')
        {            
            return $pdf->download($data['fields']->VoucherNo.'.pdf');   
        }

        if ($return_type == 'email')
        {
            \Storage::put('public/temp/purchase_order-'.$data['fields']->VoucherNo.'.pdf', $pdf->output());
            
            //echo storage_path().'/app/public/temp/invoice.pdf';

            return storage_path().'/app/public/temp/purchase_order-'.$data['fields']->VoucherNo.'.pdf'; 
        }
    }

    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'AC-JOURNAL-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Journal';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Journal';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_GL_JournalHeader_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_JournalHeader)[0];         
            
            // DROPDOWN
            //$dd = new DropdownController;  
            //$this->data['dd_receiving_status'] = (array)$dd->receiving_item_status($this->data['fields']->ReceivingStatus);
                  
            // RECORDS
            $param['IDX_T_JournalHeader'] = $request->IDX_T_JournalHeader;   
            $this->data['records_detail'] = $this->exec_sp('dbo.USP_GL_JournalDetail_List',$param,'list','sqlsrv');          

            // URL
            $this->data['url_save_modal'] = url('/ac-journal/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'accounting/journal_duplicate_form';
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
            'IDX_T_JournalHeader' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_JournalHeader'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_GL_Journal_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/ac-journal/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_JournalHeader'] = $data['IDX_T_JournalHeader'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }
}