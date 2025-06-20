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

class ProjectController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/general.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'GENERAL';
        $this->data['form_title'] = 'Project';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // BREADCRUMB
        $this->data['breads'] = array('General','Setting','Project'); 

        // URL
        $this->data['url_create'] = url('gn-project/create');
        $this->data['url_search'] = url('gn-project-list');           
        $this->data['url_update'] = url('gn-project/update/'); 
        $this->data['url_cancel'] = url('gn-project'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Project List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Project', 'Project ID', 'Project Name', 'Project Description', 
            'Action');         

        $this->data['table_footer'] = array('', '', 'ProjectID', 'ProjectName', 'ProjectDesc', 
            'Action');

        $this->data['array_filter'] = array('ProjectID','ProjectName','ProjectDesc');

        // VIEW
        $this->data['view'] = 'procurement/project_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['ProjectID'] = $request->input('ProjectID');
        $array_filter['ProjectName'] = $request->input('ProjectName');
        $array_filter['ProjectDesc'] = $request->input('ProjectDesc');
        $array_filter['UserID'] = $this->data['user_id'];        
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_Project_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Project', 'ProjectID', 'ProjectName', 'ProjectDesc');

        return $this->get_datatables($request); 
    }

    public function inquiry_data_by_user($UserID = '', Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['ProjectID'] = $request->input('ProjectID');
        $array_filter['ProjectName'] = $request->input('ProjectName');
        $array_filter['ProjectDesc'] = $request->input('ProjectDesc');
        $array_filter['UserID'] = $UserID;
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_Project_Selected_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Project', 'ProjectID', 'ProjectName', 'ProjectDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Project';
        $this->data['form_sub_title'] = 'Create Project';
        $this->data['form_desc'] = 'Create Project';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_Project_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Project = '0';            
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

        $this->data['form_title'] = 'Project';
        $this->data['form_sub_title'] = 'Update Project';
        $this->data['form_desc'] = 'Update Project';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_Project_Info]';
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
        // URL
        $this->data['url_save_header'] = url('/gn-project/save');
       
        // DROPDOWN
        $dd = new DropdownController;        
        $this->data['dd_active_status'] = (array) $dd->active_status(); 
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']); 
        $this->data['dd_branch'] = (array) $dd->branch($this->data['user_id']);
        $this->data['dd_yes_no_bit'] = (array) $dd->yes_no_bit(); 
        $this->data['dd_flag_system'] = (array) $dd->flag_system(); 

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Master Project';        
        $this->data['view'] = 'procurement/project_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_Project_Save]';
        $this->sp_update = '[dbo].[USP_CM_Project_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-project/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/gn-project/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_Project' => 'required',
            'ProjectID' => 'required',
            'ProjectName' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('ProjectName'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            // SET PARAMETER
            $param['IDX_M_Project'] = $data['IDX_M_Project'];
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['ProjectID'] = $data['ProjectID'];
            $param['ProjectName'] = $data['ProjectName'];
            $param['ProjectDesc'] = $data['ProjectDesc'];
            $param['ProjectAddress'] = $data['ProjectAddress'];
            $param['FlagSystem'] = $data['FlagSystem'];
            $param['IsProfitSharing'] = $data['IsProfitSharing'];
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}