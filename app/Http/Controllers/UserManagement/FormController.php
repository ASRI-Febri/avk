<?php

namespace App\Http\Controllers\UserManagement;

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

class FormController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/wuser.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'User Management';
        $this->data['form_title'] = 'Form ID';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','User Management','Form'); 

        // URL
        $this->data['url_create'] = url('sm-form/create');
        $this->data['url_search'] = url('sm-form-list');           
        $this->data['url_update'] = url('sm-form/update/'); 
        $this->data['url_cancel'] = url('sm-form'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Form List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Form','Application ID','Form ID','Form Name','Form URL',
            'FormDescription','GroupID','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','ApplicationName','FormID','FormName','FormURL',
        'FormDescription','GroupID','','','Action');

        $this->data['array_filter'] = array('ApplicationName','FormID','FormName','FormURL');

        // VIEW
        $this->data['view'] = 'user_management/form_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['ApplicationName'] = $request->input('ApplicationName');
        $array_filter['FormID'] = $request->input('FormID');  
        $array_filter['FormName'] = $request->input('FormName');
        $array_filter['FormDescription'] = $request->input('FormDescription'); 
        $array_filter['FormURL'] = $request->input('FormURL'); 
        $array_filter['GroupID'] = $request->input('GroupID');  
        
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_SM_Form_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Form','ApplicationName','FormID','FormName','FormURL',
            'FormDescription','GroupID','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    public function inquiry_data_by_group($GroupID = '', Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['ApplicationName'] = $request->input('ApplicationName');
        $array_filter['FormID'] = $request->input('FormID');  
        $array_filter['FormName'] = $request->input('FormName'); 
        $array_filter['FormDescription'] = $request->input('FormDescription'); 
        $array_filter['FormURL'] = $request->input('FormURL');  
        $array_filter['GroupID'] = $GroupID;
        
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_SM_Form_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Form','ApplicationName','FormID','FormName','FormURL',
            'FormDescription','GroupID','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Form ID';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Form ID';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_SM_Form_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Form = '0';
            $this->data['fields']->IDX_M_Parent = '0';
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

        $this->data['form_title'] = 'Form ID';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Form ID';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_SM_Form_Info]';
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
        $this->data['dd_asbs_application'] = (array) $dd->asbs_application();  
        $this->data['dd_yes_no'] = (array) $dd->yes_no();                

        // URL
        $this->data['url_save_header'] = url('/sm-form/save');

        //RECORDS Location LIST
        //$param['IDX_M_LocationInventory'] = $id;
        //$param['LocationID'] = '';
        //$param['LocationName'] = '';
        //$this->data['inventory_location_list'] = $this->exec_sp('USP_IN_LocationInventory_List', $param, 'list', 'inventory');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        /* 
        field = Nama field di database table, 
        type = texbox atau dropdown atau lookup, 
        label = label, 
        class = Css class. Misalnya required auto atau lainnya
        dd_array = dropdown array untuk input type array
        */

        $this->data['array_hidden_field'] = array(
            array('field' => 'IDX_M_Form','type' => 'textbox','label' => 'IDX_M_Form','value' => $this->data['fields']->IDX_M_Form,'class' => 'required')            
        );

        // Nama Field, DOM Type, Label, Css Class
        $this->data['array_field'] = array(      
            array('field' => 'IDX_M_Application','type' => 'dropdown','label' => 'Application','value' => $this->data['fields']->IDX_M_Application,'class' => 'select2 form-control required','dd_array' => $this->data['dd_asbs_application']),
            array('field' => 'FormID','type' => 'textbox','label' => 'Form ID','value' => $this->data['fields']->FormID,'class' => 'form-control required'),
            array('field' => 'FormName','type' => 'textbox','label' => 'Form Name','value' => $this->data['fields']->FormName,'class' => 'form-control required'),
            array('field' => 'FormDescription','type' => 'textbox','label' => 'Form Description','value' => $this->data['fields']->FormDescription,'class' => 'form-control required'),  
            array('field' => 'FormURL','type' => 'textbox','label' => 'Form URL','value' => $this->data['fields']->FormURL,'class' => 'form-control required'),
            array('field' => 'IconClass1','type' => 'textbox','label' => 'Icon Class 1','value' => $this->data['fields']->IconClass1,'class' => 'form-control'),
            array('field' => 'IconClass2','type' => 'textbox','label' => 'Icon Class 2','value' => $this->data['fields']->IconClass2,'class' => 'form-control'),
            array('field' => 'IconClass3','type' => 'textbox','label' => 'Icon Class 3','value' => $this->data['fields']->IconClass3,'class' => 'form-control'),    
            array('field' => 'ShowInSidebar','type' => 'dropdown','label' => 'Show In Sidebar','value' => $this->data['fields']->ShowInSidebar,'class' => 'select2 form-control required','dd_array' => $this->data['dd_yes_no']),
            array('field' => 'add-new-after-save','type' => 'checkbox','label' => 'add new after save ?','value' => '', 'checked' => ''),
        );

        //print_r($this->data['array_hidden_fields']);
        //print_r($this->data['array_fields']);

        // VIEW        
        $this->data['form_remark'] = 'Form ID adalah kode akses untuk setiap menu yang ada didalam aplikasi';
        //$this->data['view'] = 'user_management/form_form';

        // GENERAL FORM MASTER
        $this->data['view'] = 'layouts/form_master';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_Form_Save]';
        $this->sp_update = '[dbo].[USP_SM_Form_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-form/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/sm-form/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_Form' => 'required',
            'IDX_M_Application' => 'required',
            'FormID' => 'required',
            'FormName' => 'required',
            'FormDescription' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Form'] = $data['IDX_M_Form'];
            $param['IDX_M_Application'] = $data['IDX_M_Application'];
            $param['IDX_M_Module'] = '0';
            $param['FormID'] = $data['FormID'];
            $param['FormName'] = $data['FormName'];
            $param['FormDescription'] = $data['FormDescription'];
            $param['FormURL'] = $data['FormURL'];
            $param['IconClass1'] = $data['IconClass1'];
            $param['IconClass2'] = $data['IconClass2'];
            $param['IconClass3'] = $data['IconClass3'];
            $param['ShowInSidebar'] = $data['ShowInSidebar'];
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}