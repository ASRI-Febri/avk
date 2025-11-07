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

class GroupUserController extends MyController
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
        $this->data['form_title'] = 'Group  User';
        $this->data['form_remark'] = 'Group  User untuk keperluan pengaturan akses aplikasi. 
            STA = Staff, SPV = Supervisor, MAN = Manager, GMA = General Manager, DIR = Direktur';    

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','User Management','Setting','Group User'); 

        // URL
        $this->data['url_create'] = url('sm-group-user/create');
        $this->data['url_search'] = url('sm-group-user-list');           
        $this->data['url_update'] = url('sm-group-user/update/'); 
        $this->data['url_cancel'] = url('sm-group-user'); 

        // FOR SPECIFIC USER 
        $this->data['UserID_Search'] = '';

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Group User List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Group','Group ID','Group Name','Notes','','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','IDX_M_Group','GroupID','GroupName','','','','','Action');

        $this->data['array_filter'] = array('GroupID','GroupName');

        // VIEW
        $this->data['view'] = 'user_management/group_user_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['GroupID'] = $request->input('GroupID');
        $array_filter['GroupName'] = $request->input('GroupName'); 
        $array_filter['UserID'] = $request->input('UserID');           
        
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_SM_Group_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Group','GroupID','GroupName','Notes','UserID','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    public function inquiry_data_by_user($UserID = '', Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['GroupID'] = $request->input('GroupID');
        $array_filter['GroupName'] = $request->input('GroupName'); 
        $array_filter['UserID'] = $UserID;           
        
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_SM_Group_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Group','GroupID','GroupName','Notes','UserID','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Group User';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Group User';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE){

            $this->sp_getdata = '[dbo].[USP_SM_Group_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);            

            //print_r($this->data['fields']);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Group = '0';            
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

        $this->data['form_title'] = 'Group User';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Group User';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_SM_Group_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];  
            
            //print_r($this->data['fields']);

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
        //$dd = new DropdownController;        
        //$this->data['dd_gender'] = (array) $dd->gender();                

        // URL
        $this->data['url_save_header'] = url('/sm-group-user/save');

        //RECORDS 
        //RECORDS 
        $param['IDX_M_Group'] = $id;        
        $this->data['records_form'] = $this->exec_sp('USP_SM_GroupForm_List', $param, 'list', 'sqlsrv');

        // $param['IDX_M_Application'] = $id;

        // if($state == 'create')
        // {
        //     $param['GroupID'] = 'New Group'; 
        // }
        // else 
        // {
        //     $param['GroupID'] = trim($this->data['fields']->GroupID);        
        // }


        // $this->data['records_form'] = $this->exec_sp('USP_SM_Form_CheckList_ByGroupID', $param, 'list', 'sqlsrv');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW                
        $this->data['view'] = 'user_management/group_user_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_Group_Create]';
        $this->sp_update = '[dbo].[USP_SM_Group_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-group-user/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/sm-group-user/create');
        }

        $validator = Validator::make($request->all(), [
            'GroupID' => 'required',
            'GroupName' => 'required',            
        ],[
            'GroupID.required' => 'Group ID is required!',
            'GroupName.required' => 'Group Name is required!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            //$array_chk_box = $data['chk_box'];	

            // $data['FormCheck'] = '';
			
			// foreach($array_chk_box as $value){		
			// 	$data['FormCheck'] .= $value.',';					
			// }

            if($state == 'update'){
                $param['IDX_M_Group'] = $data['IDX_M_Group'];
            }            
            
            $param['GroupID'] = $data['GroupID'];
            $param['GroupName'] = $data['GroupName'];
            $param['Notes'] = $data['Notes'];
            $param['FormCheck'] = isset($data['FormCheck']) ? $data['FormCheck'] : '';           
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // CREATE NEW GROUP ACCESS FORM
    // =========================================================================================
    public function create_form(Request $request)
    {
        $this->data['form_title'] = 'Group Access';
        $this->data['form_sub_title'] = 'Select Group Access';	
        $this->data['form_desc'] = 'Select Group Access for : ' . $request->GroupID . ' - ' . $request->GroupName;			
        $this->data['url_search'] = url('sm-form-specific-list'.'/'.$request->GroupID);	
        
        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Form','Application ID','Form ID','Form Name','Form URL',
            'FormDescription','GroupID','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','ApplicationName','FormID','FormName','FormURL','FormDescription',
            'GroupID','','','Action');

        $this->data['array_filter'] = array('ApplicationName','FormID','FormName','FormURL');
        
         // URL
         $this->data['url_save_modal'] = url('/sm-group-form/save');
        
        $this->data['IDX_M_Group'] = $request->IDX_M_Group;
        $this->data['GroupID'] = $request->GroupID;
        $this->data['GroupName'] = $request->GroupName;    		                

        return view('user_management/m_select_multiple_form_list', $this->data);
    }

    // =========================================================================================
    // SAVE DATA GROUP ACCESS FORM
    // =========================================================================================
    public function save_form(Request $request)
    {
        $this->sp_create = '[dbo].[USP_SM_Group_AddForm]';
        $this->sp_update = '[dbo].[]';
        $this->next_action = 'reload';
        $this->next_url = url('/sm-group-form/reload');

        $validator = Validator::make($request->all(), [
            'IDX_M_Group' => 'required',
                     
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_M_Group'));
        } else {

            $data = $request->all();
            
            $state = 'create';

            // LOOP FOR ARRAY CHECKBOX
            $array_chk_box = $data['chk_box'];	

            $data['FormList'] = '';			
        
            foreach($array_chk_box as $value){		
                $data['FormList'] .= $value.',';
            }
            
            $data['FormList'] = rtrim($data['FormList'],',');
            // ==========================================================
            
            $param['IDX_M_Group'] = $data['IDX_M_Group'];
            $param['FormList'] = 'XXX'.$data['FormList'];  
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

        $this->data['form_title'] = 'Group Access';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Delete Group Access';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_GroupForm'] = $request->IDX_M_GroupForm;
            $this->data['message'] = 'Delete Group Access ' .  $request->FormName . ' ?';

            $this->data['submit_title'] = 'Delete ?';
            $this->data['url_save_modal'] = url('sm-group-form/save-delete'); 

            return view('user_management/group_delete_form', $this->data);

        } else {
            
            return $this->show_no_access();

        }        
    }

    public function delete_form(Request $request)
    { 
        // $id = IDX_R_Sales
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Group Access';
        $this->data['form_sub_title'] = 'Delete';
        $this->data['form_desc'] = 'Delete Group Access';        
        $this->data['state'] = 'delete';    

        if($access == TRUE)
        {
            $this->data['IDX_M_GroupForm'] = $request->IDX_M_GroupForm;
            $this->data['message'] = 'Delete Group Access ' .  $request->FormName . ' ( Index: '. $request->IDX_M_GroupForm . ') ?';

            $this->data['submit_title'] = 'Delete ?';
            $this->data['url_save_modal'] = url('sm-group-form/save-delete'); 

            return view('user_management/group_delete_form', $this->data);

        } else {
            
            return $this->show_no_access();

        }        
    }

    public function save_delete_form(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = 'dbo.[USP_SM_Group_DeleteForm]'; 
        $this->next_action = 'reload';
        $this->next_url = url('sm-group-form/reload');        
        
        $param['IDX_M_GroupForm'] = $data['IDX_M_GroupForm'];        
        $param['UserID'] = $this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

    // =========================================================================================
    // RELOAD GROUP USER AFTER CREATE OR DELETE
    // =========================================================================================
    public function reload_form($id)
    {	
        $param['IDX_M_Group'] = $id;        
        $this->data['records_form'] = $this->exec_sp('USP_SM_GroupForm_List', $param, 'list', 'sqlsrv');

        return view('user_management/group_form_list', $this->data);
    }
}
