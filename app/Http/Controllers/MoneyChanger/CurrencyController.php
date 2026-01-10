<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownLoanController;

use Maatwebsite\Excel\Facades\Excel;
use Validator;
use PDF;
use App\File;
use Image;


class CurrencyController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Currency';
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Setting','Currency'); 

        // URL
        $this->data['url_create'] = url('mc-currency/create');
        $this->data['url_search'] = url('mc-currency-list');           
        $this->data['url_update'] = url('mc-currency/update/');        
        $this->data['url_cancel'] = url('mc-currency'); 

        
        parent::__construct($request);
    }

    public function display_kurs(Request $request)
    {
        $param['page'] = 1; 
        $param['row'] = 100; 
        $param['sort_by'] = 'SortPriority';
        $param['sort_dir'] = 'ASC';
        $param['return_type'] = 'R';
        $param['CurrencyName'] = '';
        $param['CurrencyID'] = '';
        $this->data['records'] = $this->exec_sp('USP_MC_Currency_List',$param,'list','sqlsrv');   

        $this->data['view'] = 'money_changer/display_kurs';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request, $status = '')
    {       
        $this->data['form_id'] = 'CF-LO-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Currency';
        $this->data['form_remark'] = 'Daftar mata uang yang digunakan untuk transaksi jual beli valuta asing';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('mc-currency-list');
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_Currency','Currency ID','Currency Name','Country ID',
                '','Country Name','Rate Beli','Rate Jual','RecordStatus','Status','Action');         

            $this->data['table_footer'] = array('','','CurrencyID','CurrencyName','',
                '','','','','','','Action');

            $this->data['array_filter'] = array('CurrencyName','CurrencyID');

            // VIEW
            $this->data['view'] = 'money_changer/currency_list';  
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
        $array_filter['CurrencyID'] = $request->input('CurrencyID');  
         

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_Currency_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Currency','CurrencyID','CurrencyName','CountryID',
            'IconFlag','CountryName','BuyRate','SellRate','RecordStatus','StatusDesc');

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

        $this->data['form_title'] = 'Currency';
        $this->data['form_sub_title'] = 'Input Currency';
        $this->data['form_desc'] = 'Create Currency';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_Currency_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Currency = 0;        
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

        $this->data['form_title'] = 'Currency';
        $this->data['form_sub_title'] = 'Update Currency';
        $this->data['form_desc'] = 'Update Currency';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_Currency_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];   
            
            $this->data['fields']->BuyRate = number_format($this->data['fields']->BuyRate, 2, '.',',');
            $this->data['fields']->SellRate = number_format($this->data['fields']->SellRate, 2, '.',',');

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
        $this->data['dd_country'] = (array) $dd->country();   
        $this->data['dd_record_status'] = (array) $dd->active_status();        

        // URL
        $this->data['url_save_header'] = url('/mc-currency/save');       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Keterangan Currency';        
        $this->data['view'] = 'money_changer/currency_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_Currency_Save]';
        $this->sp_update = '[dbo].[USP_MC_Currency_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-currency/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Currency' => 'required',
            'IDX_M_Country' => 'required',
            'CurrencyID' => 'required',
            'CurrencyName' => 'required',
            'Symbol' => 'required',       
            'BuyRate' => 'required',
            'SellRate' => 'required',     
        ],[
            'IDX_M_Country.required' => 'Kode negara belum diisi!',
            'CurrencyName.required' => 'Nama mata uang belum diisi!',
            'CurrencyID.required' => 'Kode mata uang belum diisi!',
            'Symbol.required' => 'Simbol mata uang belum diisi!',
            'BuyRate.required' => 'Rate beli belum diisi!',
            'SellRate.required' => 'Rate jual belum diisi!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_Currency'));
        } 
        else 
        {
            $data = $request->all();
            
            $state = $data['state'];

            $data['Rounding'] = '0.00';
            $data['Accuracy'] = '0';
            
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];
            $param['IDX_M_Country'] = $data['IDX_M_Country'];
            $param['CurrencyID'] = $data['CurrencyID'];
            $param['CurrencyName'] = $data['CurrencyName'];
            $param['Symbol'] = $data['Symbol'];
            $param['Remarks'] = '';
            $param['Rounding'] = (double)str_replace(',','',$data['Rounding']);
            $param['Accuracy'] = (double)str_replace(',','',$data['Accuracy']);
            $param['BuyRate'] = (double)str_replace(',','',$data['BuyRate']);
            $param['SellRate'] = (double)str_replace(',','',$data['SellRate']);
            $param['IconFlag'] = $data['IconFlag'];
            $param['SortPriority'] = (double)str_replace(',','',$data['SortPriority']);
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = $data['RecordStatus'];            

            return $this->store($state, $param);
        }
    }

}