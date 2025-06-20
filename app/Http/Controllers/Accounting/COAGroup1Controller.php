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

class COAGroup1Controller extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/wuser.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'ACCOUNTING';
        $this->data['form_title'] = 'COA Group 1';
        $this->data['form_remark'] = 'COA group 1 atau level 1 untuk pembentukan laporan neraca';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Setting','COA Group 1'); 

        // URL
        $this->data['url_create'] = url('ac-coa-group1/create');
        $this->data['url_search'] = url('ac-coa-group1-list');           
        $this->data['url_update'] = url('ac-coa-group1/update/'); 
        $this->data['url_cancel'] = url('ac-coa-group1'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'Account group level 1';
        $this->data['form_desc'] = 'COA Group 1 List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_COAGroup1','IDX_M_COAType','COA Type','Group 1 ID',
            'Group 1 Name','COAGroup1Name2','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','','COATypeDesc','COAGroup1ID',
            'COAGroup1Name1','COAGroup1Name2','','','Action');

        $this->data['array_filter'] = array('COATypeDesc','COAGroup1ID','COAGroup1Name1','COAGroup1Name2');

        // VIEW
        $this->data['view'] = 'accounting/coa_group1_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['COATypeDesc'] = $request->input('COATypeDesc');
        $array_filter['COAGroup1ID'] = $request->input('COAGroup1ID');  
        $array_filter['COAGroup1Name1'] = $request->input('COAGroup1Name1');
        $array_filter['COAGroup1Name2'] = $request->input('COAGroup1Name2'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_COAGroup1_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_COAGroup1','IDX_M_COAType','COATypeDesc','COAGroup1ID',
            'COAGroup1Name1','COAGroup1Name2','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'COA Group 1';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create COA Group 1';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_COAGroup1_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_COAGroup1 = '0'; 
            $this->data['fields']->IDX_M_COAType = '0';  
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

        $this->data['form_title'] = 'COA Group 1';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update COA Group 1';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_COAGroup1_Info]';
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
        $this->data['dd_coa_type'] = (array) $dd->coa_type(); 

        // URL
        $this->data['url_save_header'] = url('/ac-coa-group1/save');
       

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

        // $this->data['array_hidden_field'] = array(
        //     array('field' => 'IDX_M_COA','type' => 'textbox','label' => 'IDX_M_COA','value' => $this->data['fields']->IDX_M_COA,'class' => 'required')            
        // );

        // Nama Field, DOM Type, Label, Css Class
        // $this->data['array_field'] = array(      
        //     array('field' => 'COAFlag','type' => 'dropdown','label' => 'COA Flag','value' => $this->data['fields']->COAFlag,'class' => 'select2 form-control required','dd_array' => $this->data['dd_coa_flag']),
        //     array('field' => 'COAID','type' => 'textbox','label' => 'COA ID','value' => $this->data['fields']->COAID,'class' => 'form-control required'),
        //     array('field' => 'COADesc','type' => 'textbox','label' => 'COA Name','value' => $this->data['fields']->COADesc,'class' => 'form-control required'),
        //     array('field' => 'COADesc2','type' => 'textbox','label' => 'COA Name 2','value' => $this->data['fields']->COADesc2,'class' => 'form-control required'),              
        //     array('field' => 'DefaultBalance','type' => 'dropdown','label' => 'Default Balance','value' => $this->data['fields']->DefaultBalance,'class' => 'select2 form-control required','dd_array' => $this->data['dd_debet_credit']),
        // );

        //print_r($this->data['array_hidden_fields']);
        //print_r($this->data['array_fields']);

        // VIEW                      
        //$this->data['view'] = 'layouts/form_master';
        $this->data['view'] = 'accounting/coa_group1_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_COAGroup1_Create]';
        $this->sp_update = '[dbo].[USP_GL_COAGroup1_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-coa-group1/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-coa-group1/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_COAGroup1' => 'required',            
            'IDX_M_COAType' => 'required',
            'COAGroup1ID' => 'required',
            'COAGroup1Name1' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_COAGroup1'] = $data['IDX_M_COAGroup1'];
            } 
           
            $param['IDX_M_COAType'] = $data['IDX_M_COAType'];            
            $param['COAGroup1ID'] = $data['COAGroup1ID'];
            $param['COAGroup1Name1'] = $data['COAGroup1Name1'];
            $param['COAGroup1Name2'] = $data['COAGroup1Name2'];                       
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}