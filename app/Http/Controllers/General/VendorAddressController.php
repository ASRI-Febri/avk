<?php

namespace App\Http\Controllers\Procurement;

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

class VendorAddressController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/procurement.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Procurement';
        $this->data['form_title'] = 'Vendor';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_procurement';     
        $this->data['sidebar'] = 'navigation.sidebar_procurement'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Procurement','Transaction','Vendor'); 

        // URL
        $this->data['url_create'] = url('pr-vendor-address/create');
        $this->data['url_search'] = url('pr-vendor-address-list');           
        $this->data['url_update'] = url('pr-vendor-address/update/'); 
        $this->data['url_cancel'] = url('pr-vendor-address'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($idx_header)
    {	
        // RECORDS        
        $param['IDX_M_Partner'] = $idx_header;
        $this->data['records_address'] = $this->exec_sp('USP_GN_PartnerAddress_List',$param,'list','sqlsrv'); 
        
        return view('procurement/vendor_address_list', $this->data);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        //$access = $this->check_permission($this->data['user_id'], 'AAA', 'I');

        $access = TRUE;

        $this->data['form_title'] = 'Vendor';
        $this->data['form_sub_title'] = 'Add Address';
        $this->data['form_desc'] = 'Add Vendor Address';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_PartnerAddress_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_PartnerAddress = '0';  
            $this->data['fields']->IDX_M_Partner = $request->IDX_M_Partner;                      
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

        $this->data['form_title'] = 'Vendor';
        $this->data['form_sub_title'] = 'Update Address';
        $this->data['form_desc'] = 'Update Vendor Address';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_PartnerAddress_Info]';
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
        $this->data['dd_address_type'] = (array)$dd->address_type();         

        // URL
        $this->data['url_save_modal'] = url('/pr-vendor-address/save');         

        // VIEW                
        $this->data['view'] = 'procurement/vendor_address_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_PartnerAddress_Create]';
        $this->sp_update = '[dbo].[USP_CM_PartnerAddress_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/pr-vendor-address/reload');

        $validator = Validator::make($request->all(), [
            'IDX_M_PartnerAddress' => 'required',
            'IDX_M_AddressType' => 'required',
            'IDX_M_PostalCode' => 'required',
            'Street' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('Street'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_PartnerAddress'] = $data['IDX_M_PartnerAddress'];
            }            
            
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];
            $param['IDX_M_AddressType'] = $data['IDX_M_AddressType'];
            $param['IDX_M_PostalCode'] = $data['IDX_M_PostalCode'];
            $param['Street'] = $data['Street'];
            $param['Zip'] = $data['Zip'];
            $param['Notes'] = $data['Notes'];            
            $param['IsDefault'] = isset($_POST['IsDefault']) ? 'Y' : 'N'; 
            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DELETE
    // =========================================================================================
    public function delete(Request $request)
    {
        $this->data['form_desc'] = 'Delete Data';        

        $this->data['item_index'] = $request->IDX_M_PartnerAddress;
        $this->data['item_description'] = $request->Address;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $this->data['url_save_modal'] = url('pr-vendor-address/save-delete');

        return view('procurement/vendor_address_delete_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_CM_PartnerAddress_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/pr-vendor-address/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_M_PartnerAddress'] = $data['item_index']; 
            $param['IDX_M_Partner'] = $data['item_index'];                        
            $param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}
