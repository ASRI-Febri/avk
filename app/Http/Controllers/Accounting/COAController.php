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

class COAController extends MyController
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
        $this->data['form_title'] = 'Chart of Account';
        $this->data['form_remark'] = 'Chart of account untuk pencatatan journal accounting';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Setting','Chart of Account'); 

        // URL
        $this->data['url_create'] = url('ac-coa/create');
        $this->data['url_search'] = url('ac-coa-list');           
        $this->data['url_update'] = url('ac-coa/update/'); 
        $this->data['url_cancel'] = url('ac-coa'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'Daftar Chart of Account';
        $this->data['form_desc'] = 'Chart of Account List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_COA','COA ID','COA Desc','COA Desc2','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','COAID','COADesc','COADesc2','','','Action');

        $this->data['array_filter'] = array('COAID','COADesc','COADesc2');

        // VIEW
        $this->data['view'] = 'accounting/coa_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['COAID'] = $request->input('COAID');
        $array_filter['COADesc'] = $request->input('COADesc');  
        $array_filter['COADesc2'] = $request->input('COADesc2'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_COA_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_COA','COAID','COADesc','COADesc2','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Chart of Account';
        $this->data['form_sub_title'] = 'Input Chart of Account';
        $this->data['form_desc'] = 'Input data baru untuk Chart of Account';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_COA_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_COA = '0'; 
            $this->data['fields']->IDX_M_COAType = '0';           
            $this->data['fields']->ParentID = '';            
            $this->data['fields']->ParentDesc = '';
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

        $this->data['form_title'] = 'Chart of Account';
        $this->data['form_sub_title'] = 'Update Chart of Account';
        $this->data['form_desc'] = 'Update Chart of Account';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_COA_Info]';
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
        $this->data['dd_coa_type'] = (array) $dd->coa_type(); 
        $this->data['dd_coa_category'] = (array) $dd->coa_category(); 
        $this->data['dd_coa_flag'] = (array) $dd->coa_flag();
        $this->data['dd_debet_credit'] = (array) $dd->debet_credit();
        $this->data['dd_yes_no'] = (array) $dd->yes_no();         
        $this->data['dd_coa_group1'] = (array) $dd->coa_group1($this->data['fields']->IDX_M_COAType);
        $this->data['dd_coa_group2'] = (array) $dd->coa_group2($this->data['fields']->COAGroup1);
        $this->data['dd_coa_group3'] = (array) $dd->coa_group3($this->data['fields']->COAGroup2);                

        // URL
        $this->data['url_save_header'] = url('/ac-coa/save');
       

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
        $this->data['view'] = 'accounting/coa_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_COA_Create]';
        $this->sp_update = '[dbo].[USP_GL_COA_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-coa/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-coa/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_COA' => 'required',
            'IDX_M_COACategory' => 'required',
            'IDX_M_COAType' => 'required',
            'COAID' => 'required',
            'COADesc' => 'required',
            'COADesc2' => 'required',
        ],[
            'IDX_M_COA.required' => 'Index account belum diisi!',
            'IDX_M_COACategory.required' => 'Kategori account belum diisi!',
            'IDX_M_COAType.required' => 'Tipe accout belum diisi!',
            'COAID.required' => 'Kode CoA belum diisi!',
            'COADesc.required' => 'Nama CoA belum diisi!',
            'COADesc2.required' => 'Nama CoA 2 belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('COAID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_COA'] = $data['IDX_M_COA'];
            }            
            
            $param['IDX_M_COACategory'] = $data['IDX_M_COACategory'];
            $param['IDX_M_COAType'] = $data['IDX_M_COAType'];            
            $param['COAFlag'] = $data['COAFlag'];
            $param['COAID'] = $data['COAID'];
            $param['COADesc'] = $data['COADesc'];
            $param['COADesc2'] = $data['COADesc2'];
            $param['ParentID'] = $data['ParentID'];
            $param['IDX_M_CashflowIn'] = '0';
            $param['IDX_M_CashflowOut'] = '0';
            $param['AllowJournalEntry'] = $data['AllowJournalEntry'];
            $param['IsReconcile'] = $data['IsReconcile'];
            $param['COAStatus'] = $data['COAStatus'];
            $param['COAGroup1'] = $data['COAGroup1'];
            $param['COAGroup2'] = $data['COAGroup2'];
            $param['COAGroup3'] = $data['COAGroup3'];            
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // LOOKUP & SELECT ITEM
    // =========================================================================================
    public function show_lookup(Request $request)
    {
        $this->data['form_title'] = 'Chart of Account';
        $this->data['form_sub_title'] = 'Select Chart of Account';
        $this->data['form_desc'] = 'Select Chart of Account';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/ac-coa-list');        

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_COA','COA ID','COA Desc','COA Desc2','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','COAID','COADesc','COADesc2','','','Action');

        $this->data['array_filter'] = array('COAID','COADesc','COADesc2');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        return view('accounting/m_select_coa_list', $this->data);
    }

    public function show_multiple_lookup(Request $request)
    {
        $this->data['form_title'] = 'Chart of Account';
        $this->data['form_sub_title'] = 'Select Chart of Account';
        $this->data['form_desc'] = 'Select Chart of Account';			
        $this->data['url_search'] = url('/ac-coa-list');
        $this->data['url_update'] = url('/ac-coa/update');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','ID','CoA ID','CoA Name','CoA Name 2','Action'); 
        $this->data['table_footer'] = array('','','COAID','COADesc','COADesc2','Action');
        $this->data['array_filter'] = array('COAID','COADesc','COADesc2');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        return view('accounting/m_select_multiple_coa_list', $this->data);
    }

    // =========================================================================================
    // AJAX REQUEST
    // =========================================================================================
    public function search_coa(Request $request)
    {
        $search_value = $request->input('q','');          

        $param['SearchValue'] = $search_value;
        $records = $this->exec_sp('USP_GL_COASearch_List',$param,'list','sqlsrv');

        $items = array();
        $row_array = array();

        foreach ($records as $row){
        
            $row_array['label'] = $row->COAID . ' - ' . $row->COADesc;				
            
            $row_array['IDX_M_COA'] = $row->IDX_M_COA;           
            $row_array['COAID'] = $row->COAID; 
            $row_array['COADesc'] = $row->COADesc;            
            
            array_push($items, $row_array);	            
        }

        $result["rows"] = $items;
			
        echo json_encode($items);

    }

    // ============================================ AJAX FUNCTION - CHAINED DROPDOWN ==============================================
    function select_group1(Request $request)
    {
        $IDX_M_COAType = $request->IDX_M_COAType;			
			
        $data['IDX_GL_M_COAType'] = $IDX_M_COAType;	
        $data['COAGroup1'] = '';
        $data['COAGroup2'] = '';
        $data['COAGroup3'] = '';				
        
        $dd = new DropdownController;
        $data['dd_coa_group1'] = (array) $dd->coa_group1($IDX_M_COAType);
        
        $data['dd_coa_group2'] = array('' => 'Select...');
        $data['dd_coa_group3'] = array('' => 'Select...');
                
        return view('ajax/ddl_coa_group1', $data);
    }

    function select_group2(Request $request)
    {
        $COAGroup1 = $request->COAGroup1;			
		
        $data['COAGroup1'] = $COAGroup1;
        $data['COAGroup2'] = '';
        $data['COAGroup3'] = '';				
        
        $dd = new DropdownController;
        $data['dd_coa_group2'] = (array) $dd->coa_group2($COAGroup1);  
        
        $data['dd_coa_group3'] = array('' => 'Select...');
                
        return view('ajax/ddl_coa_group2', $data);
    }

    function select_group3(Request $request)
    {
        $COAGroup2 = $request->COAGroup2;			
		
        $data['COAGroup2'] = $COAGroup2;        
        $data['COAGroup3'] = '';				
        
        $dd = new DropdownController;
        $data['dd_coa_group3'] = (array) $dd->coa_group3($COAGroup2);        
                                
        return view('ajax/ddl_coa_group3', $data);
    }
}