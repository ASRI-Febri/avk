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

class PartnerController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/general.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Procurement';
        $this->data['form_title'] = 'Business Partner';
        $this->data['form_remark'] = 'Business Partner atau supplier adalah penjual barang dan jasa kepada perusahaan';  

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // BREADCRUMB
        $this->data['breads'] = array('Setting & Configuration','Business Partner'); 

        // URL
        $this->data['url_create'] = url('gn-partner/create');
        $this->data['url_search'] = url('gn-partner-list');           
        $this->data['url_update'] = url('gn-partner/update/'); 
        $this->data['url_cancel'] = url('gn-partner'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_sub_title'] = 'Daftar Business Partner';
        $this->data['form_desc'] = 'Daftar Business Partner';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'BarcodeMember', 'Kode Partner', 'Nama Partner', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'No KTP',
            'NPWP', 'No HP', 'Keterangan', 'Alamat', 'ActiveDesc','Status','Action');         

        $this->data['table_footer'] = array('', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','','Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','BarcodeMember','SingleIdentityNumber','PartnerType','Street');

        // VIEW
        $this->data['view'] = 'general/partner_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['PartnerID'] = $request->input('PartnerID');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['BarcodeMember'] = $request->input('BarcodeMember');  
        $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber'); 
        $array_filter['PartnerType'] = ''; // SUPPLIER
        $array_filter['Street'] = $request->input('Street');          
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GN_Partner_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Input Business Partner';
        $this->data['form_desc'] = 'Input Business Partner';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GN_Partner_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Partner = '0';    
            $this->data['fields']->ActiveStatus = 'A';        
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

        $this->data['form_title'] = 'Business Partner';
        $this->data['form_sub_title'] = 'Update Business Partner';
        $this->data['form_desc'] = 'Update Business Partner';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GN_Partner_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            //$this->data['fields']->PODate = date('Y-m-d', strtotime($this->data['fields']->PODate));
            //$this->data['fields']->POExpectedDate = date('Y-m-d', strtotime($this->data['fields']->POExpectedDate));
            //$this->data['fields']->MeterStart = number_format($this->data['fields']->MeterStart,2,'.',',');
           

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
        $this->data['dd_gender'] = (array) $dd->gender(); 
        $this->data['dd_active_status'] = (array) $dd->active_status();                
                       

        // RECORDS
        if($state !== 'create')
        {
            $param['IDX_M_Partner'] = $this->data['fields']->IDX_M_Partner;
            $this->data['records_address'] = $this->exec_sp('USP_GN_PartnerAddress_List',$param,'list','sqlsrv');   
            $this->data['records_bank'] = $this->exec_sp('USP_GN_PartnerBank_List',$param,'list','sqlsrv');             
        }

        // URL
        $this->data['url_save_header'] = url('/gn-partner/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW  
        $this->data['view'] = 'general/partner_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GN_Partner_Save]';
        $this->sp_update = '[dbo].[USP_GN_Partner_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/gn-partner/update');

        $validator = Validator::make($request->all(), [
            'IDX_M_Partner' => 'required',
            'Phone1' => 'required',
            'PartnerName' => 'required',
            'SingleIdentityNumber' => 'required',
            'Email' => 'required|email:rfc,dns',
            'MobilePhone' => 'required',
        ],[
            'IDX_M_Partner.required' => 'Index vendor is required',
            'Phone1.required' => 'No telp belum diisi!',
            'PartnerName.required' => 'Nama belum diisi!',
            'SingleIdentityNumber.required' => 'No KTP belum diisi',
            'Email.required' => 'Alamat email belum diisi!',
            'MobilePhone.required' => 'No HP belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['PartnerID'] = $data['PartnerID'];
            $param['BarcodeMember'] = $data['BarcodeMember'];
            $param['Prefix'] = $data['Prefix'];
            $param['PartnerName'] = $data['PartnerName'];
            $param['PartnerAlias'] = $data['PartnerAlias'];
            $param['Gender'] = $data['Gender'];
            $param['SingleIdentityNumber'] = 'XXX'.$data['SingleIdentityNumber'];
            $param['TaxIdentityNumber'] = 'XXX'.$data['TaxIdentityNumber'];
            $param['DateOfBirth'] = $data['DateOfBirth'];
            $param['PlaceOfBirth'] = $data['PlaceOfBirth'];
            $param['Email'] = $data['Email'];
            $param['Phone1'] = $data['Phone1'];
            $param['Phone2'] = $data['Phone2'];
            $param['FaxNo'] = $data['FaxNo'];
            $param['MobilePhone'] = $data['MobilePhone'];
            $param['Remarks'] = $data['Remarks'];

            $param['IsSupplier'] = isset($_POST['IsSupplier']) ? 'Y' : 'N'; 
            $param['IsCustomer'] = isset($_POST['IsCustomer']) ? 'Y' : 'N'; 
            $param['IsCompany'] = isset($_POST['IsCompany']) ? 'Y' : 'N'; 
            $param['IsMember'] = isset($_POST['IsMember']) ? 'Y' : 'N'; 

            $param['StartDate'] = isset($_POST['StartDate']) ? $_POST['StartDate'] : '';
            $param['EndDate'] = isset($_POST['StartDate']) ? $_POST['StartDate'] : '';
            $param['ARAccount'] = $data['ARAccount'];
            $param['APAccount'] = $data['APAccount'];
            $param['ActiveStatus'] = $data['ActiveStatus'];
            $param['CreditLimit'] = (double)str_replace(',','',$data['CreditLimit']);
            $param['DiscountMember'] = '0.00'; //(double)str_replace(',','',$data['DiscountMember']);
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // LOOKUP & SELECT VENDOR
    // =========================================================================================
    public function show_lookup(Request $request)
    {
        $this->data['form_title'] = 'Vendor';
        $this->data['form_sub_title'] = 'Select Vendor';
        $this->data['form_desc'] = 'Select Vendor';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/gn-partner-list');        

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'BarcodeMember', 'Vendor ID', 'Vendor Name', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','Status','Action');         

        $this->data['table_footer'] = array('', 'IDX_M_Partner', 'BarcodeMember', 'PartnerID', 'PartnerName', 
            'IsCustomer', 'IsMember', 'IsSupplier', 'SingleIdentityNumber',
            'TaxIdentityNumber', 'MobilePhone', 'Remarks', 'Street', 'ActiveDesc','','Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','BarcodeMember','SingleIdentityNumber','PartnerType','Street');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        return view('general/m_select_partner_list', $this->data);
    }
}