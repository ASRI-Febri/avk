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

class COAGroup3Controller extends MyController
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
        $this->data['form_title'] = 'COA Group 3';
        $this->data['form_remark'] = 'COA Group 3 atau level 2 untuk pembentukan laporan neraca';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Setting','COA Group 3'); 

        // URL
        $this->data['url_create'] = url('ac-coa-group3/create');
        $this->data['url_search'] = url('ac-coa-group3-list');           
        $this->data['url_update'] = url('ac-coa-group3/update/'); 
        $this->data['url_cancel'] = url('ac-coa-group3'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'Account group level 2';
        $this->data['form_desc'] = 'COA Group 3 List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_COAGroup3','IDX_M_COAGroup1','Group 2','Group 3 ID',
            'Group 3 Name','COAGroup3Name2','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','','COAGroup1Name1','COAGroup3ID',
            'COAGroup3Name1','COAGroup3Name2','','','Action');

        $this->data['array_filter'] = array('COAGroup2Name1','COAGroup3ID','COAGroup3Name1','COAGroup3Name2');

        // VIEW
        $this->data['view'] = 'accounting/coa_group3_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['COAGroup2Name1'] = $request->input('COAGroup2Name1');
        $array_filter['COAGroup3ID'] = $request->input('COAGroup3ID'); 
        $array_filter['COAGroup3Name1'] = $request->input('COAGroup3Name1');
        $array_filter['COAGroup3Name2'] = $request->input('COAGroup3Name2'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_COAGroup3_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_COAGroup3','IDX_M_COAGroup2','COAGroup2Name1','COAGroup3ID',
            'COAGroup3Name1','COAGroup3Name2','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'COA Group 3';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create COA Group 3';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_COAGroup3_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_COAGroup2 = '0';
            $this->data['fields']->IDX_M_COAGroup3 = '0';             
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

        $this->data['form_title'] = 'COA Group 3';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update COA Group 3';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_COAGroup3_Info]';
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
        $this->data['dd_coa_group2'] = (array) $dd->coa_group2(''); 

        // URL
        $this->data['url_save_header'] = url('/ac-coa-group3/save');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';       

        // VIEW                      
        //$this->data['view'] = 'layouts/form_master';
        $this->data['view'] = 'accounting/coa_group3_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_COAGroup3_Create]';
        $this->sp_update = '[dbo].[USP_GL_COAGroup3_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-coa-group2/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-coa-group2/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_COAGroup1' => 'required',            
            'IDX_M_COAGroup3' => 'required',
            'COAGroup3ID' => 'required',
            'COAGroup3Name1' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_COAGroup3'] = $data['IDX_M_COAGroup3'];
            } 
           
            $param['IDX_M_COAGroup1'] = $data['IDX_M_COAGroup1'];            
            $param['COAGroup3ID'] = $data['COAGroup3ID'];
            $param['COAGroup3Name1'] = $data['COAGroup3Name1'];
            $param['COAGroup3Name2'] = $data['COAGroup3Name2'];                       
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}