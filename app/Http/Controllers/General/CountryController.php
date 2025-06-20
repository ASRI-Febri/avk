<?php

namespace App\Http\Controllers\General;

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


class CountryController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'General';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Negara';

        $this->data['form_remark'] = 'Daftar negara untuk digunakan dengan currency atau mata uang';  
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general';

        // BREADCRUMB
        $this->data['breads'] = array('Setting','Negara'); 

        // URL
        $this->data['url_create'] = url('gn-country/create');
        $this->data['url_search'] = url('gn-country-list');           
        $this->data['url_update'] = url('gn-country/update/');        
        $this->data['url_cancel'] = url('gn-country'); 

        
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
        
        $this->data['form_sub_title'] = 'Daftar Negara';
        $this->data['form_remark'] = 'Daftar negara untuk diintergrasikan dengan currency atau mata uang';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('gn-country-list');
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_Country','Country ID','Country Name','RecordStatus','Status','Action');         

            $this->data['table_footer'] = array('','','','CountryName','','','Action');

            $this->data['array_filter'] = array('CountryID','CountryName');

            // VIEW
            $this->data['view'] = 'general/country_list';  
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
        $array_filter['CountryID'] = $request->input('CountryID');
        $array_filter['CountryName'] = $request->input('CountryName');  
         

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_Country_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Country','CountryID','CountryName','RecordStatus','StatusDesc');

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

        $this->data['form_title'] = 'Negara';
        $this->data['form_sub_title'] = 'Input Negara';
        $this->data['form_desc'] = 'Input Negara';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_Country_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Country = 0;        
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

        $this->data['form_title'] = 'Negara';
        $this->data['form_sub_title'] = 'Update Negara';
        $this->data['form_desc'] = 'Update Negara';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_Country_Info]';
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
        $this->data['dd_country'] = (array) $dd->country();        

        // URL
        $this->data['url_save_header'] = url('/gn-country/save');       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW    
        $this->data['view'] = 'general/country_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_Country_Save]';
        $this->sp_update = '[dbo].[USP_GN_Country_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-country/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Country' => 'required',
            'CountryID' => 'required',
            'CountryName' => 'required',            
        ],[
            'CountryID.required' => 'Kode negara belum diisi!',
            'CountryName.required' => 'Nama negara belum diisi!',            
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_Country'));
        } 
        else 
        {
            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Country'] = $data['IDX_M_Country'];
            $param['CountryID'] = $data['CountryID'];
            $param['CountryName'] = $data['CountryName'];                      
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}