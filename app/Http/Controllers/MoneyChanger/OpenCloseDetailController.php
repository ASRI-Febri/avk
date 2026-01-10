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

class OpenCloseDetailController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/procurement.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Transaction Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Transaction','Transaction Detail'); 

        // URL
        $this->data['url_create'] = url('mc-open-close-detail/create');
        $this->data['url_search'] = url('mc-open-close-detail-list');           
        $this->data['url_update'] = url('mc-open-close-detail/update/'); 
        $this->data['url_cancel'] = url('mc-open-close-detail'); 

        parent::__construct($request);
    }

    public function reload($IDX_T_OpenCloseDaily,Request $request)
    {   
        $param['IDX_T_OpenCloseDaily'] = $IDX_T_OpenCloseDaily;
        $this->data['records_detail'] = $this->exec_sp('USP_MC_OpenCloseDailyDetail_List',$param,'list','sqlsrv');        
        
        return view('money_changer/open_close_detail_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {   
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Transaksi Valuta Asing';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_T_OpenCloseDaily', 'IDX_M_Company', 'IDX_M_Branch', 'IDX_M_Partner', 
            'PO Number', 'CompanyName', 'Branch Name', 'Vendor',
            'Reference No', 'PO Date', 'PO Description', 'POStatus', 'Status','Action');         

        $this->data['table_footer'] = array('', '', '', '', '', 
            'PONumber', 'CompanyName', 'BranchName', 'PartnerName',
            'ReferenceNo', 'PODate', 'PODescription', '', 'StatusDesc','Action');

        $this->data['array_filter'] = array('PONumber','CompanyName','BranchName','PartnerName','ReferenceNo','PODate','PODescription');

        // VIEW
        $this->data['view'] = 'money_changer/sales_order_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['POStatus'] = $request->input('POStatus');
        $array_filter['PONumber'] = $request->input('PONumber');
        $array_filter['CompanyName'] = $request->input('CompanyName');  
        $array_filter['BranchName'] = $request->input('BranchName'); 
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['ReferenceNo'] = $request->input('ReferenceNo');  
        $array_filter['PODate'] = $request->input('PODate'); 
        $array_filter['PODescription'] = $request->input('PODescription'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_OpenCloseDailyItem_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_OpenCloseDaily', 'IDX_M_Company', 'IDX_M_Branch', 'IDX_M_Partner', 
            'PONumber', 'CompanyName', 'BranchName', 'PartnerName',
            'ReferenceNo', 'PODate', 'PODescription', 'POStatus', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'PR-PO-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        //$access = TRUE;

        $this->data['form_title'] = 'Transaction Detail';
        $this->data['form_sub_title'] = 'Create Transaction Detail';
        $this->data['form_desc'] = 'Input Transaksi';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDailyDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_OpenCloseDailyDetail = '0';
            $this->data['fields']->IDX_T_OpenCloseDaily = $request->IDX_T_OpenCloseDaily;  
            $this->data['fields']->ForeignAmount = '0.00';
            $this->data['fields']->Quantity = '0.00';            
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

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Transaction Detail';
        $this->data['form_sub_title'] = 'Update Transaction Detail';
        $this->data['form_desc'] = 'Ubah Transaksi';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_OpenCloseDailyDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->OpenQty = number_format($this->data['fields']->OpenQty,2,'.',',');
            $this->data['fields']->CloseQty = number_format($this->data['fields']->CloseQty,2,'.',',');

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
        $ddf = new DropdownFinanceController; 
        $this->data['dd_valas'] = (array) $ddf->valas(); 
        //$this->data['dd_transaction_type'] = (array) $ddf->transaction_type(); 

        // RECORDS
        if($state !== 'create')
        {
            //$param['IDX_T_OpenCloseDaily'] = $this->data['fields']->IDX_T_OpenCloseDaily;
            //$this->data['records_detail'] = $this->exec_sp('USP_MC_OpenCloseDailyDetailDetail_List',$param,'list','sqlsrv');             
        }

        // URL
        $this->data['url_save_modal'] = url('/mc-open-close-detail/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Pilih valas dan edit jumlah quantity';        
        $this->data['view'] = 'money_changer/open_close_daily_detail_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_OpenCloseDailyDetail_Save]';
        $this->sp_update = '[dbo].[USP_MC_OpenCloseDailyDetail_Save]';
        $this->next_action = '';
        $this->next_url = url('/mc-open-close-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_OpenCloseDaily' => 'required',
            'IDX_M_Valas' => 'required',
            'IDX_T_OpenCloseDailyDetail' => 'required',
            'OpenQty' => 'required',
            'CloseQty' => 'required',            
        ],[
            'IDX_T_OpenCloseDaily.required' => 'Index header is required',
            'IDX_M_Valas.required' => 'Valas belum diisi!',            
            'OpenQty.required' => 'Opening qty belum diisi',
            'CloseQty.required' => 'Closing qty belum diisi!',
            'IDX_T_OpenCloseDailyDetail.required' => 'Index transaksi belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_T_OpenCloseDailyDetail'] = $data['IDX_T_OpenCloseDailyDetail'];
            $param['IDX_T_OpenCloseDaily'] = $data['IDX_T_OpenCloseDaily'];
            $param['IDX_M_Valas'] = $data['IDX_M_Valas'];                          
            $param['OpenQty'] = (double)str_replace(',','',$data['OpenQty']);       
            $param['InQty'] = (double)str_replace(',','',$data['InQty']);
            $param['OutQty'] = (double)str_replace(',','',$data['OutQty']);  
            $param['CloseQty'] = (double)str_replace(',','',$data['CloseQty']);  
            $param['DiffQty'] = (double)str_replace(',','',$data['DiffQty']);   
            $param['DetailNotes'] = $data['DetailNotes'];           
            
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

        $this->data['item_index'] = $request->IDX_T_OpenCloseDailyDetail;
        $this->data['item_description'] = $request->ItemDesc;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $this->data['url_save_modal'] = url('mc-open-close-detail/save-delete');

        return view('general/delete_detail_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_MC_OpenCloseDailyDetail_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-open-close-detail/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_T_OpenCloseDailyDetail'] = $data['item_index'];            
            
            //$param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}