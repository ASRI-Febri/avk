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

class UserController extends MyController
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
        $this->data['form_title'] = 'User ID';
        $this->data['form_remark'] = 'User ID untuk keperluan akses aplikasi';    

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // BREADCRUMB
        $this->data['breads'] = array('User Management'); 

        // URL
        $this->data['url_create'] = url('sm-user/create');
        $this->data['url_search'] = url('sm-user-list');           
        $this->data['url_update'] = url('sm-user/update/'); 
        $this->data['url_cancel'] = url('sm-user'); 
        $this->data['url_reset'] = url('sm-user/reset');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'SM-USER-R';

        $access = $this->check_permission($this->data['user_id'], 'SM-USER-R', 'R');

        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'User List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_User','User ID','User Name','Alias','RecordStatus','Status','Action');         

            $this->data['table_footer'] = array('','IDX_M_User','LoginID','UserName','','','','Action');

            $this->data['array_filter'] = array('LoginID','UserName');

            // VIEW
            $this->data['view'] = 'user_management/user_list';  
            return view($this->data['view'], $this->data);   
        } 
        else 
        {
            return $this->show_no_access($this->data);
        }     
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['LoginID'] = $request->input('LoginID');
        $array_filter['UserName'] = $request->input('UserName');           
        
        // SET STORED PROCEDUREß
        $this->sp_getinquiry = 'AVKDB.dbo.[USP_SM_User_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_User','LoginID','UserName','UserAlias','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'SM-USER-C';

        $access = $this->check_permission($this->data['user_id'], 'SM-USER-C', 'R');

        //$access = TRUE;

        $this->data['form_title'] = 'User ID';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create User ID';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE)
        {
            $id = 0;

            $param['UserID'] = '';
            $param['IDX_M_User'] = $id;
            $this->data['fields'] = (object)$this->exec_sp('USP_SM_User_Info', $param, 'record', 'sqlsrv'); 

            //print_r($this->data['fields']);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_User = '0';            
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        } 
        else 
        {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'SM-USER-U';

        $access = $this->check_permission($this->data['user_id'], 'SM-USER-U', 'R');

        //$access = TRUE;

        $this->data['form_title'] = 'User ID';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update User ID';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $param['UserID'] = '';
            $param['IDX_M_User'] = $id;
            $this->data['fields'] = $this->exec_sp('USP_SM_User_Info', $param, 'record', 'sqlsrv')[0];   
            
            //print_r($this->data['fields']);

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
        $this->data['dd_gender'] = (array) $dd->gender();                

        // URL
        $this->data['url_save_header'] = url('/sm-user/save');

        //RECORDS 
        $param['IDX_M_User'] = $id;        
        $this->data['records_group'] = $this->exec_sp('USP_SM_UserGroup_List', $param, 'list', 'sqlsrv');
        $this->data['records_branch'] = $this->exec_sp('USP_SM_UserBranch_List', $param, 'list', 'sqlsrv');
        $this->data['records_project'] = $this->exec_sp('USP_SM_UserProject_List', $param, 'list', 'sqlsrv');
        $this->data['records_department'] = $this->exec_sp('USP_SM_UserDepartment_List', $param, 'list', 'sqlsrv');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW                
        $this->data['view'] = 'user_management/user_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_User_Create]';
        $this->sp_update = '[dbo].[USP_SM_User_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-user/update');

        $validator = Validator::make($request->all(), [            
            'IDX_M_Gender' => 'required',
            'LoginID' => 'required',
            'Name' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_User'] = $data['IDX_M_User'];
            }            
            
            $param['IDX_M_Gender'] = $data['IDX_M_Gender'];
            $param['LoginID'] = $data['LoginID'];
            $param['Name'] = $data['Name'];
            $param['Alias'] = $data['Alias'];
            $param['Email'] = $data['Email'];

            if($state == 'create')
            {
                $param['Password2'] = $data['Password2'];
                $param['Password2Confirm'] = $data['Password2Confirm'];
            }   
            else 
            {
                $param['Password2'] = '';
                $param['Password2Confirm'] = '';
            }         
            
            $param['Notes'] = $data['Notes'];  
            $param['CompanyCheck'] = '';  
            $param['BranchCheck'] = '';  
            $param['GroupCheck'] = '';            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // CREATE NEW GROUP ROLE
    // =========================================================================================
    public function create_group(Request $request)
    {
        $this->data['form_title'] = 'Group User';
        $this->data['form_sub_title'] = 'Select Group User';	
        $this->data['form_desc'] = 'Select Group User for : ' . $request->UserID . ' - ' . $request->UserName;			
        $this->data['url_search'] = url('sm-group-user-specific-list'.'/'.$request->UserID);	
        
        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Group','Group ID','Group Name','Notes','User ID','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','GroupID','GroupName','','','','','Action');

        $this->data['array_filter'] = array('GroupID','GroupName');
        
         // URL
         $this->data['url_save_modal'] = url('/sm-user-group/save');
        
        $this->data['IDX_M_User'] = $request->IDX_M_User;
        $this->data['UserID'] = $request->UserID;
        $this->data['UserName'] = $request->UserName;    		                

        return view('user_management/m_select_multiple_group_list', $this->data);
    }

    // =========================================================================================
    // SAVE DATA GROUP ROLE
    // =========================================================================================
    public function save_group(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_User_AddGroup]';
        $this->sp_update = '[dbo].[]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-user-group/reload');

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

            $data['GroupList'] = '';			
        
            foreach($array_chk_box as $value){		
                $data['GroupList'] .= $value.',';
            }
            
            $data['GroupList'] = rtrim($data['GroupList'],',');
            // ==========================================================
            
            $param['IDX_M_User'] = $data['IDX_M_User'];
            $param['GroupList'] = $data['GroupList'];  
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    public function delete_group(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Group User';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Delete Group User';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserGroup'] = $request->IDX_M_UserGroup;
            $this->data['message'] = 'Delete Group User ' .  $request->GroupName . ' ?';

            $this->data['submit_title'] = 'Delete ?';
            $this->data['url_save_modal'] = url('sm-user-group/save-delete'); 

            return view('user_management/user_delete_group_form', $this->data);

        } else {
            
            return $this->show_no_access();

        }        
    }

    public function save_delete_group(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = 'dbo.[USP_SM_User_DeleteGroup]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-group/reload');        
        
        $param['IDX_M_UserGroup'] = $data['IDX_M_UserGroup'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

    public function activate_group(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Group User';
        $this->data['form_sub_title'] = 'Activate';
        $this->data['form_desc'] = 'Activate Group User';        
        $this->data['state'] = 'update';    

        if($access == TRUE)
        {
            $this->data['IDX_M_UserGroup'] = $request->IDX_M_UserGroup;
            $this->data['message'] = 'Activate Group User ' .  $request->GroupName . ' ?';

            $this->data['submit_title'] = 'Activate ?';
            $this->data['url_save_modal'] = url('sm-user-group/save-activate'); 

            return view('user_management/user_delete_group_form', $this->data);

        } else {
            
            return $this->show_no_access();

        }        
    }

    public function save_activate_group(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_update = 'dbo.[USP_SM_User_ActivateGroup]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user-group/reload');        
        
        $param['IDX_M_UserGroup'] = $data['IDX_M_UserGroup'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('update',$param);
    }

    // =========================================================================================
    // RELOAD GROUP USER AFTER CREATE OR DELETE
    // =========================================================================================
    public function reload_group($id)
    {	
        $param['IDX_M_User'] = $id;        
        $this->data['records_group'] = $this->exec_sp('USP_SM_UserGroup_List', $param, 'list', 'sqlsrv');

        return view('user_management/user_role_list', $this->data);
    }
    
    // =========================================================================================
    // CHANGE PASSWORD
    // =========================================================================================
    public function change_password($id)
    { 
        $access = TRUE;

        $this->data['form_title'] = 'User ID';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Change Password';              
        $this->data['state'] = 'update';
        $this->data['form_remark'] = 'Change password. Type old password and new password';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_portal';     
        $this->data['sidebar'] = 'navigation.sidebar_portal'; 

        // BREADCRUMB
        array_push($this->data['breads'], 'Change Password');  

        if ($access == TRUE)
        {
            $param['UserID'] = '';
            $param['IDX_M_User'] = $id;
            $this->data['fields'] = $this->exec_sp('USP_SM_User_Info', $param, 'record', 'sqlsrv')[0];   
            
            // URL
            $this->data['url_save_header'] = url('/sm-user/save-change-password');

            // VIEW                
            $this->data['view'] = 'user_management/change_password_form';
            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access($this->data);
        }
    }

    public function save_change_password(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_User_ChangePassword]';
        $this->sp_update = '[dbo].[USP_SM_User_ChangePassword]';
        $this->next_action = 'reload';
        $this->next_url = url('/home');

        $validator = Validator::make($request->all(), [            
            'IDX_M_User' => 'required',
            'PrevPassword' => 'required',
            'NewPassword' => 'required|min:5',
            'NewPasswordConfirm' => 'required|min:5',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];                      
            
            $param['IDX_M_User'] = $data['IDX_M_User'];
            $param['PrevPassword'] = $data['PrevPassword'];
            $param['NewPassword'] = $data['NewPassword'];
            $param['NewPasswordConfirm'] = $data['NewPasswordConfirm'];   
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            
            $param['IsReset'] = 'N';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // RESET PASSWORD
    // =========================================================================================
    public function reset_password(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Reset Password';
        $this->data['form_sub_title'] = 'Reset Password';
        $this->data['form_desc'] = 'Reset Password';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_User'] = $request->IDX_M_User;
            $this->data['UserID'] = $request->UserID;
            $this->data['message'] = 'Reset Password ' .  $request->UserID . ' ?';

            $this->data['submit_title'] = 'Reset Password ?';
            $this->data['url_save_modal'] = url('sm-user/save-reset-password'); 

            return view('user_management/reset_password', $this->data);

        } else {
            
            return $this->show_no_access_modal($this->data);

        }        
    }

    public function save_reset_password(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = 'dbo.[USP_SM_User_ResetPassword]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-user/update');        
        
        $param['IDX_M_User'] = $data['IDX_M_User'];        
        $param['UserID'] = 'XXX'.$data['UserID'];  
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

}