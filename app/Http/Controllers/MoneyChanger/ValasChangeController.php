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


class ValasChangeController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Money Changer';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = 'Pecahan Valas';
        
        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Setting','Pecahan Valas'); 

        // URL
        $this->data['url_create'] = url('mc-valas-change/create');
        $this->data['url_search'] = url('mc-valas-change-list');           
        $this->data['url_update'] = url('mc-valas-change/update/');        
        $this->data['url_cancel'] = url('mc-valas-change'); 

        
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
        
        $this->data['form_sub_title'] = 'Daftar Pecahan Valas';
        $this->data['form_remark'] = 'Daftar pecahan mata uang asing sesuai berdasarkan nilai. 
            Misalnya pecahan 1, 5, 10, 20 atau 100';    
        
        if($status !== '')
        {
            $this->data['url_search'] = url('mc-valas-change-list');
        }        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_ValasChange','Kode','Nama Pecahan','Nilai Pecahan','RecordStatus','Status','Action');         

            $this->data['table_footer'] = array('','IDX_M_ValasChange','ValasChangeID','ValasChangeName','ValasChangeNumber','','','Action');

            $this->data['array_filter'] = array('ValasChangeID','ValasChangeName','ValasChangeNumber',);

            // VIEW
            $this->data['view'] = 'money_changer/valas_change_list';  
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
        $array_filter['ValasChangeID'] = $request->input('ValasChangeID');
        $array_filter['ValasChangeName'] = $request->input('ValasChangeName');  
        $array_filter['ValasChangeNumber'] = $request->input('ValasChangeNumber');   

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_ValasChange_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_ValasChange','ValasChangeID','ValasChangeName','ValasChangeNumber','RecordStatus','StatusDesc');

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

        $this->data['form_title'] = 'Pecahan Valas';
        $this->data['form_sub_title'] = 'Input Pecahan Valas';
        $this->data['form_desc'] = 'Create Pecahan Valas';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_ValasChange_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_ValasChange = 0;        
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

        $this->data['form_title'] = 'Pecahan Valas';
        $this->data['form_sub_title'] = 'Update Pecahan Valas';
        $this->data['form_desc'] = 'Update Pecahan Valas';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_ValasChange_Info]';
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
        $this->data['url_save_header'] = url('/mc-valas-change/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Keterangan Pecahan Valas';        
        $this->data['view'] = 'money_changer/valas_change_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_ValasChange_Save]';
        $this->sp_update = '[dbo].[USP_MC_ValasChange_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-valas-change/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_ValasChange' => 'required',
            'ValasChangeID' => 'required',
            'ValasChangeName' => 'required',
            'ValasChangeNumber' => 'required',            
        ],[
            'ValasChangeID.required' => 'Kode pecahan belum diisi!',
            'ValasChangeName.required' => 'Nama pecahan belum diisi!',
            'ValasChangeNumber.required' => 'Nilai pecahan belum diisi!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_ValasChange'));
        } 
        else 
        {
            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_ValasChange'] = $data['IDX_M_ValasChange'];
            $param['ValasChangeID'] = $data['ValasChangeID'];
            $param['ValasChangeName'] = $data['ValasChangeName'];
            $param['ValasChangeNumber'] = $data['ValasChangeNumber'];            
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}