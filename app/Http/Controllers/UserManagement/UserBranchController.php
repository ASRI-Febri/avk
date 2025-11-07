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

class UserBranchController extends MyController
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
        $this->data['form_title'] = 'User ID - Branch';
        $this->data['form_remark'] = 'User ID & Branch mapping untuk keperluan akses aplikasi';    

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // BREADCRUMB
        $this->data['breads'] = array('User Management','User ID - Branch'); 

        // URL
        $this->data['url_create'] = url('sm-user-branch/create');
        $this->data['url_search'] = url('sm-user-branch-list');           
        $this->data['url_update'] = url('sm-user-branch/update/'); 
        $this->data['url_cancel'] = url('sm-user-branch'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // CREATE 
    // =========================================================================================
    public function create_branch(Request $request)
    {
        $this->data['form_title'] = 'Branch';
        $this->data['form_sub_title'] = 'Select Branch for User';	
        $this->data['form_desc'] = 'Select Branch User for : ' . $request->UserID . ' - ' . $request->UserName;			
        $this->data['url_search'] = url('gn-branch-user-specific-list'.'/'.$request->UserID);	
        
        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Branch','Branch ID','Branch Name','Alias','Remark','COASales','COA ID','COA Desc','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','BranchID','BranchName','BranchAlias','','','','','','','Action');

        $this->data['array_filter'] = array('BranchID','BranchName','BranchAlias');
        
         // URL
         $this->data['url_save_modal'] = url('/sm-user-branch/save');
        
        $this->data['IDX_M_User'] = $request->IDX_M_User;
        $this->data['UserID'] = $request->UserID;
        $this->data['UserName'] = $request->UserName;    		                

        return view('general/m_select_multiple_branch_list', $this->data);
    }

    // =========================================================================================
    // SAVE DATA GROUP ROLE
    // =========================================================================================
    public function save_branch(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_User_AddBranch]';
        $this->sp_update = '[dbo].[]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-user-branch/reload');

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

            $data['BranchList'] = '';			
        
            foreach($array_chk_box as $value){		
                $data['BranchList'] .= $value.',';
            }
            
            $data['BranchList'] = rtrim($data['BranchList'],',');
            // ==========================================================
            
            $param['IDX_M_User'] = $data['IDX_M_User'];
            $param['BranchList'] = $data['BranchList'];  
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // ACTIVATE BRANCH
    // =========================================================================================
    public function activate_branch(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Branch';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Update Branch';        
        $this->data['state'] = 'update';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserBranch'] = $request->IDX_M_UserBranch;
            $this->data['message'] = 'Activate Branch ' .  $request->BranchName . ' ?';
           
            $this->data['submit_title'] = 'Activate ?';
            $this->data['url_save_modal'] = url('sm-user-branch/save-activate'); 

            return view('user_management/user_activate_branch_form', $this->data);

        } else {
            
            return $this->show_no_access_modal($this->data);

        }        
    }

    public function save_activate_branch(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_update = 'dbo.[USP_SM_User_ActivateBranch]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-branch/reload');        
        
        $param['IDX_M_UserBranch'] = $data['IDX_M_UserBranch'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('update',$param);
    }

    // =========================================================================================
    // DELETE BRANCH
    // =========================================================================================
    public function delete_branch(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Branch';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Delete Branch';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserBranch'] = $request->IDX_M_UserBranch;
            $this->data['message'] = 'Delete Branch ' .  $request->BranchName . ' ?';

            $this->data['submit_title'] = 'Delete ?';
            $this->data['url_save_modal'] = url('sm-user-branch/save-delete'); 

            return view('user_management/user_delete_branch_form', $this->data);

        } else {
            
            return $this->show_no_access_modal($this->data);

        }        
    }

    public function save_delete_branch(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = 'dbo.[USP_SM_User_DeleteBranch]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-branch/reload');        
        
        $param['IDX_M_UserBranch'] = $data['IDX_M_UserBranch'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

    // =========================================================================================
    // RELOAD GROUP USER AFTER CREATE OR DELETE
    // =========================================================================================
    public function reload_branch($id)
    {	
        $param['IDX_M_User'] = $id;        
        $this->data['records_branch'] = $this->exec_sp('USP_SM_UserBranch_List', $param, 'list', 'sqlsrv');

        return view('user_management/user_branch_list', $this->data);
    }

}