<?php

/*
* Controller untuk mapping antara User ID dengan Branch
*/

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

class UserProjectController extends MyController
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
        $this->data['form_title'] = 'User ID - Project';
        $this->data['form_remark'] = 'User ID & Project mapping untuk keperluan akses aplikasi';    

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // BREADCRUMB
        $this->data['breads'] = array('User Management','User ID - Project'); 

        // URL
        $this->data['url_create'] = url('sm-user-project/create');
        $this->data['url_search'] = url('sm-user-project-list');           
        $this->data['url_update'] = url('sm-user-project/update/'); 
        $this->data['url_cancel'] = url('sm-user-project'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // CREATE 
    // =========================================================================================
    public function create_project(Request $request)
    {
        $this->data['form_title'] = 'Project';
        $this->data['form_sub_title'] = 'Select Project for User';	
        $this->data['form_desc'] = 'Select Project User for : ' . $request->UserID . ' - ' . $request->UserName;			
        $this->data['url_search'] = url('gn-project-user-specific-list'.'/'.$request->UserID);	
        
        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Project', 'Project ID', 'Project Name', 'Project Description', 
            'Action');         

        $this->data['table_footer'] = array('', '', 'ProjectID', 'ProjectName', 'ProjectDesc', 
            'Action');

        $this->data['array_filter'] = array('ProjectID','ProjectName','ProjectDesc');
        
         // URL
         $this->data['url_save_modal'] = url('/sm-user-project/save');
        
        $this->data['IDX_M_User'] = $request->IDX_M_User;
        $this->data['UserID'] = $request->UserID;
        $this->data['UserName'] = $request->UserName;    		                

        return view('general/m_select_multiple_project_list', $this->data);
    }

    // =========================================================================================
    // SAVE DATA GROUP ROLE
    // =========================================================================================
    public function save_project(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_User_AddProject]';
        $this->sp_update = '[dbo].[]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-user-project/reload');

        $validator = Validator::make($request->all(), [
            'IDX_M_User' => 'required',
                     
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = 'create';

            // LOOP FOR ARRAY CHECKBOX
            $array_chk_box = $data['chk_box'];	

            $data['ProjectList'] = '';			
        
            foreach($array_chk_box as $value){		
                $data['ProjectList'] .= $value.',';
            }
            
            $data['ProjectList'] = rtrim($data['ProjectList'],',');
            // ==========================================================
            
            $param['IDX_M_User'] = $data['IDX_M_User'];
            $param['ProjectList'] = $data['ProjectList'];  
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // ACTIVATE BRANCH
    // =========================================================================================
    public function activate_project(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Project';
        $this->data['form_sub_title'] = 'Activate';
        $this->data['form_desc'] = 'Update Project';        
        $this->data['state'] = 'update';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserProject'] = $request->IDX_M_UserProject;
            $this->data['message'] = 'Activate Project ' .  $request->ProjectName . ' ?';
           
            $this->data['submit_title'] = 'Activate ?';
            $this->data['url_save_modal'] = url('sm-user-project/save-activate'); 

            return view('user_management/user_activate_project_form', $this->data);

        } else {
            
            return $this->show_no_access_modal($this->data);

        }        
    }

    public function save_activate_project(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_update = 'dbo.[USP_SM_User_ActivateProject]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-project/reload');        
        
        $param['IDX_M_UserProject'] = $data['IDX_M_UserProject'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('update',$param);
    }

    // =========================================================================================
    // DELETE BRANCH
    // =========================================================================================
    public function delete_project(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Project';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Delete Project';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserProject'] = $request->IDX_M_UserProject;
            $this->data['message'] = 'Delete Project ' .  $request->ProjectName . ' ?';

            $this->data['submit_title'] = 'Delete ?';
            $this->data['url_save_modal'] = url('sm-user-project/save-delete'); 

            return view('user_management/user_delete_project_form', $this->data);

        } else {
            
            return $this->show_no_access_modal($this->data);

        }        
    }

    public function save_delete_project(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = 'dbo.[USP_SM_User_DeleteProject]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-project/reload');        
        
        $param['IDX_M_UserProject'] = $data['IDX_M_UserProject'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

    // =========================================================================================
    // RELOAD GROUP USER AFTER CREATE OR DELETE
    // =========================================================================================
    public function reload_project($id)
    {	
        $param['IDX_M_User'] = $id;        
        $this->data['records_project'] = $this->exec_sp('USP_SM_UserProject_List', $param, 'list', 'sqlsrv');

        return view('user_management/user_project_list', $this->data);
    }

}