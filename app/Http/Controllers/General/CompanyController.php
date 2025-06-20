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

class CompanyController extends MyController
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
        $this->data['form_title'] = 'Company';
        $this->data['form_remark'] = 'Master company';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // BREADCRUMB
        $this->data['breads'] = array('General','Setting','Company'); 

        // URL
        $this->data['url_create'] = url('gn-company/create');  
        $this->data['url_search'] = url('gn-company-list');           
        $this->data['url_update'] = url('gn-company/update/'); 
        $this->data['url_cancel'] = url('gn-company'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Company List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Company','Company ID','Company Name','Alias','RecordStatus','Status','Action');         

        $this->data['table_footer'] = array('','','CompanyID','CompanyName','CompanyAlias','','','Action');

        $this->data['array_filter'] = array('CompanyID','CompanyName','CompanyAlias');

        // VIEW
        $this->data['view'] = 'general/company_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['CompanyID'] = $request->input('CompanyID');
        $array_filter['CompanyName'] = $request->input('CompanyName');  
        $array_filter['CompanyAlias'] = $request->input('CompanyAlias'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_Company_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Company','CompanyID','CompanyName','CompanyAlias','RecordStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Company';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Company';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_Company_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Company = '0'; 
            $this->data['fields']->IDX_M_Currency = '0';                       
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

        $this->data['form_title'] = 'Company';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Company';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_Company_Info]';
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
        $this->data['dd_currency'] = (array) $dd->currency(); 
        $this->data['dd_yes_no'] = (array) $dd->yes_no();        
        
        // URL
        $this->data['url_save_header'] = url('/gn-company/save');

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';
        
        // VIEW                      
        //$this->data['view'] = 'layouts/form_master';
        $this->data['view'] = 'general/company_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_Company_Save]';
        $this->sp_update = '[dbo].[USP_GN_Company_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-company/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/gn-company/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => 'required',           
            'IDX_M_Currency' => 'required',
            'CompanyID' => 'required',
            'CompanyName' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
                     
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Parent'] = $data['IDX_M_Parent'];
            $param['IDX_M_Currency'] = $data['IDX_M_Currency'];            
            $param['CompanyID'] = $data['CompanyID'];
            $param['CompanyName'] = $data['CompanyName'];
            $param['CompanyAlias'] = $data['CompanyAlias'];
            $param['SIUP'] = $data['SIUP'];
            $param['NPWP'] = $data['NPWP'];
            $param['PKPIdentityNumber'] = '0';
            $param['PKPDate'] = isset($data['PKPDate']) ? $data['PKPDate'] : '1900-01-01';;
            $param['Phone'] = $data['Phone'];
            $param['Fax'] = '';
            $param['Email'] = $data['Email'];
            $param['LegalAddress'] = $data['LegalAddress'];
            $param['Country'] = isset($data['Country']) ? $data['Country'] : 'Indonesia';
            $param['Province'] = $data['Province'];              
            $param['City'] = $data['City'];
            $param['Subdistrict'] = $data['Subdistrict'];
            $param['District'] = $data['District'];
            $param['Zip'] = $data['Zip'];  
            $param['Logo'] = isset($data['Country']) ? $data['Country'] : '';
            $param['Website'] = $data['Website'];
            $param['Remarks'] = $data['Remarks'];  
            
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}