<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;

use Maatwebsite\Excel\Facades\Excel;
use Validator;
use PDF;
use App\File;
use Image;


class ValasController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Valas';
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Setting','Valas'); 

        // URL
        $this->data['url_create'] = url('mc-valas/create');
        $this->data['url_search'] = url('mc-valas-list');           
        $this->data['url_update'] = url('mc-valas/update/');  
        $this->data['url_duplicate'] = url('mc-valas/duplicate/');      
        $this->data['url_cancel'] = url('mc-valas'); 

        
        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request, $status = '')
    {       
        $this->data['form_id'] = 'CF-LO-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Valas';
        $this->data['form_remark'] = 'Daftar mata uang asing sesuai berdasarkan nilai dan pecahan. 
            Misalnya pecahan 1, 5, 10, 20 atau 100';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('mc-valas-list');
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_Valas','SKU','Tanggal','Kode Valas','Currency','Pecahan','Angka Pecahan','Nilai Beli','Nilai Jual','','Status','Action');         

            $this->data['table_footer'] = array('','','','','','CurrencyName','ValasChangeName','ValasChangeNumber','','','','','Action');

            $this->data['array_filter'] = array('CurrencyName','ValasChangeName','ValasChangeNumber',);

            // VIEW
            $this->data['view'] = 'money_changer/valas_list';  
            return view($this->data['view'], $this->data);
            
        } 
        else
        {
            return $this->show_no_access($this->data);
        }  
    }

    public function inquiry_data(Request $request, $status = '')
    { 
        // FILTER FOR STORED PROCEDURE
        $array_filter['CurrencyName'] = $request->input('CurrencyName');
        $array_filter['ValasChangeName'] = $request->input('ValasChangeName');  
        $array_filter['ValasChangeNumber'] = $request->input('ValasChangeNumber');   

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_Valas_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Valas','ValasSKU','EffectiveDate','CurrencyID','CurrencyName','ValasChangeName','ValasChangeNumber','BuyValue','SellValue','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-FA-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Valas';
        $this->data['form_sub_title'] = 'Input Valas';
        $this->data['form_desc'] = 'Create Valas';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_Valas_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Valas = 0;    
            $this->data['fields']->EffectiveDate = date('Y-m-d');
            $this->data['fields']->BuyValue = 0.00;
            $this->data['fields']->SellValue = 0.00;    
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

        $access = TRUE;

        $this->data['form_title'] = 'Valas';
        $this->data['form_sub_title'] = 'Update Valas';
        $this->data['form_desc'] = 'Update Valas';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_Valas_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];    
            
            $this->data['fields']->BuyValue = number_format($this->data['fields']->BuyValue,2,'.',',');
            $this->data['fields']->SellValue = number_format($this->data['fields']->SellValue,2,'.',',');

            return $this->show_form($id, 'update');
        } 
        else 
        {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate($id)
    {
        $this->data['form_id'] = 'FM-FA-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;

        $this->data['form_title'] = 'Valas';
        $this->data['form_sub_title'] = 'Duplicate Valas';
        $this->data['form_desc'] = 'Duplicate Valas';              
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_Valas_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];    
            
            $this->data['fields']->IDX_M_Valas = '0';
            $this->data['fields']->ValasSKU = '';

            $this->data['fields']->BuyValue = number_format($this->data['fields']->BuyValue,2,'.',',');
            $this->data['fields']->SellValue = number_format($this->data['fields']->SellValue,2,'.',',');

            return $this->show_form($id, 'create');
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
        $dd_finance = new DropdownFinanceController;                
        $this->data['dd_valas_change'] = (array) $dd_finance->valas_change();

        $dd = new DropdownController;  
        $this->data['dd_currency'] = (array) $dd->currency();
        

        // URL
        $this->data['url_save_header'] = url('/mc-valas/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Keterangan Valas';        
        $this->data['view'] = 'money_changer/valas_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_Valas_Save]';
        $this->sp_update = '[dbo].[USP_MC_Valas_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-valas/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Valas' => 'required',
            'IDX_M_Currency' => 'required',
            'IDX_M_ValasChange' => 'required',   
            'ValasName' => 'required',         
            'EffectiveDate' => 'required',
            'BuyValue' => 'required',
            'SellValue' => 'required',            
        ],[
            'ValasName.required' => 'Nama valas belum diisi!',
            'EffectiveDate.required' => 'Tanggal belum diisi!',
            'BuyValue.required' => 'Nama pecahan belum diisi!',
            'SellValue.required' => 'Nilai pecahan belum diisi!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_ValasChange'));
        } 
        else 
        {
            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Valas'] = $data['IDX_M_Valas'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_ValasChange'] = $data['IDX_M_ValasChange'];
            $param['ValasName'] = $data['ValasName'];
            $param['EffectiveDate'] = $data['EffectiveDate'];
            $param['BuyValue'] = (double)str_replace(',','',$data['BuyValue']);
            $param['SellValue'] = (double)str_replace(',','',$data['SellValue']);          
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}