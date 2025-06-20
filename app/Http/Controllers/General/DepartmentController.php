<?php

namespace App\Http\Controllers\General;

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

class DepartmentController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/wuser.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'GENERAL';
        $this->data['form_title'] = 'Department';
        $this->data['form_remark'] = 'Daftar Department sebagai cost center';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // BREADCRUMB
        $this->data['breads'] = array('General','Setting','Department'); 

        // URL
        $this->data['url_create'] = url('gn-department/create');
        $this->data['url_search'] = url('gn-department-list');           
        $this->data['url_update'] = url('gn-department/update/'); 
        $this->data['url_cancel'] = url('gn-department'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Department List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Department','Department ID','Department Name','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','DepartmentID','BranchName','','','Action');

        $this->data['array_filter'] = array('DepartmentID','DepartmentName');

        // VIEW
        $this->data['view'] = 'general/department_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['DepartmentID'] = $request->input('DepartmentID');
        $array_filter['DepartmentName'] = $request->input('DepartmentName');          
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_Department_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Department','DepartmentID','DepartmentName','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Department';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Department';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_Department_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Department = '0'; 
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

        $this->data['form_title'] = 'Department';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Department';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_Department_Info]';
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
        $this->data['dd_active_status'] = (array) $dd->active_status();               
        
        // URL
        $this->data['url_save_header'] = url('/gn-department/save');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // VIEW                      
        //$this->data['view'] = 'layouts/form_master';
        $this->data['view'] = 'general/department_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_Department_Save]';
        $this->sp_update = '[dbo].[USP_GN_Department_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-department/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/gn-department/create');
        }

        $validator = Validator::make($request->all(), [           
            'IDX_M_Department' => 'required',            
            'DepartmentID' => 'required',
            'DepartmentName' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Department'] = $data['IDX_M_Department'];                                  
            $param['DepartmentID'] = $data['DepartmentID'];
            $param['DepartmentName'] = $data['DepartmentName'];            
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}