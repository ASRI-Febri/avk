<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;
use App\File;
use Image;

class OpenCloseController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/finance.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Open Close Daily';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Transaksi','Opening & Closing'); 

        // URL
        $this->data['url_create'] = url('mc-open-close/create');
        $this->data['url_search'] = url('mc-open-close-list');           
        $this->data['url_update'] = url('mc-open-close/update/'); 
        $this->data['url_cancel'] = url('mc-open-close'); 

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
        
        $this->data['form_sub_title'] = 'Daftar Open Close Daily';
        $this->data['form_remark'] = 'Daftar perhitungan persiapan dan penutupan harian';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {       
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_T_OpenCloseDaily','Transaction Date','TransactionStatus',
                'Status','Teller ID','RecordStatus','Teller Name','Action');         

            $this->data['table_footer'] = array('','IDX_T_OpenCloseDaily','TransactionDate','',
                '','','','TellerName','Action');

            $this->data['array_filter'] = array('TransactionDate','TellerName');

            // VIEW
            $this->data['view'] = 'money_changer/open_close_daily_list';  
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
        $array_filter['TransactionDate'] = $request->input('TransactionDate');
        $array_filter['TellerName'] = $request->input('TellerName');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_OpenCloseDaily_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_OpenCloseDaily','TransactionDate','TransactionStatus',
            'StatusDesc','TellerID','RecordStatus','TellerName');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-PI-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Open Close Daily';
        $this->data['form_sub_title'] = 'Input Open Close Daily';
        $this->data['form_desc'] = 'Input Open Close Daily';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDaily_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_OpenCloseDaily = 0; 
            $this->data['fields']->TransactionDate = date('Y-m-d');  
            $this->data['fields']->TransactionStatus = 'O'; // O = Open, C = Close    
            $this->data['fields']->TellerID = $this->data['user_id'];         
            $this->data['fields']->TellerName = $this->data['user_name'];         
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

        $this->data['form_title'] = 'Update Open Close Daily';
        $this->data['form_sub_title'] = 'Update Open Close Daily';
        $this->data['form_desc'] = 'Update Open Close Daily';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDaily_Info]';
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
        $this->data['url_save_header'] = url('/mc-open-close/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW    
        $this->data['view'] = 'money_changer/open_close_daily_form';

        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_OpenCloseDaily'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_MC_OpenCloseDailyDetail_List',$param,'list','sqlsrv');
        }

        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_OpenCloseDaily_Save]';
        $this->sp_update = '[dbo].[USP_MC_OpenCloseDaily_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-open-close/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_OpenCloseDaily' => 'required',
            'TransactionDate' => 'required',
            'TransactionStatus' => 'required',            
            'TellerID' => 'required',          
        ],[
            'IDX_T_OpenCloseDaily.required' => 'Index transaction is required',
            'TransactionDate.required' => 'Tanggal transaksi belum diisi!',
            'TransactionStatus.required' => 'Status belum diisi!',
            'TellerID.required' => 'Teller belum diisi',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_OpenCloseDaily'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // SET PARAMETER            
            $param['IDX_T_OpenCloseDaily'] = $data['IDX_T_OpenCloseDaily'];                
            $param['TransactionDate'] = $data['TransactionDate'];
            $param['TransactionStatus'] = $data['TransactionStatus'];           
            $param['TellerID'] = $data['TellerID'];                                 
            
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
       
        $this->data['form_title'] = 'Approval Sales Order';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Sales Order';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDaily_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_OpenCloseDaily)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->SODate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/mc-sales-order/save-approve');            

            // VIEW                          
            $this->data['view'] = 'money_changer/sales_order_approval_form';
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
            'IDX_T_OpenCloseDaily' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_OpenCloseDaily'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_MC_OpenCloseDaily_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/mc-sales-order/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_OpenCloseDaily'] = $data['IDX_T_OpenCloseDaily'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            
            return $this->store($state,$param);
        }   
    }

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_OpenCloseDaily'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDaily_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_OpenCloseDaily'])[0];
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_OpenCloseDaily'] = $data['IDX_T_OpenCloseDaily'];
        $data['records_detail'] = $this->exec_sp('USP_MC_OpenCloseDailyDetail_List',$param,'list','sqlsrv');              

        $pdf = PDF::loadView('money_changer/open_close_daily_pdf', $data);        
        $pdf->setPaper('A4','portrait');

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }

        if ($return_type == 'download')
        {            
            return $pdf->download($data['fields']->IDX_T_OpenCloseDaily.'.pdf');   
        }

        if ($return_type == 'email')
        {
            \Storage::put('public/temp/open_close-'.$data['fields']->IDX_T_OpenCloseDaily.'.pdf', $pdf->output());
            
            //echo storage_path().'/app/public/temp/invoice.pdf';

            return storage_path().'/app/public/temp/open_close-'.$data['fields']->IDX_T_OpenCloseDaily.'.pdf'; 
        }
    }
}