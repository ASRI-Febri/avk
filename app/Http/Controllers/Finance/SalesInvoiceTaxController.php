<?php

namespace App\Http\Controllers\Finance;

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

class SalesInvoiceTaxController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/finance.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Finance';
        $this->data['form_title'] = 'Sales Invoice Tax Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Sales Invoice Tax'); 

        // URL
        $this->data['url_create'] = url('fm-sales-invoice-tax/create');
        $this->data['url_search'] = url('fm-sales-invoice-tax-list');           
        $this->data['url_update'] = url('fm-sales-invoice-tax/update/'); 
        $this->data['url_cancel'] = url('fm-sales-invoice-tax'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        //dd($id);
        $param['IDX_T_SalesInvoiceHeader'] = $id;
          
        //$this->data['records_detail'] = $this->exec_sp('USP_CM_SalesInvoiceDetail_List',$param,'list','sqlsrv');
        $this->data['tax_detail'] = $this->exec_sp('USP_CM_SalesInvoiceTax_List',$param,'list','sqlsrv');
        
        return view('finance/sales_invoice_tax_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_T_SalesInvoiceHeader'] = $request->input('IDX_T_SalesInvoiceHeader');

        // // SET STORED PROCEDURE
        // $this->sp_getinquiry = 'dbo.[usp_CM_PurchaseInvoiceDetail_List]';

        // // ARRAY COLUMN AND FILTER FOR DATATABLES
        // $this->array_filter = $array_filter;

        // $this->array_column = array(
        //     'RowNumber','IDX_T_PurchaseInvoiceDetail','ItemSKU','ItemAlias','ItemDesc'
        //         ,'UOMID','UOMDesc','BrandAlias','BrandDesc','CurrencyDesc','IDX_M_Partner'
        //         ,'InvoiceStatus','StatusDesc','COAID','COADesc','IDX_M_COA');

        // return $this->get_datatables($request);

        $this->data['tax_detail'] = $this->exec_sp('USP_CM_SalesInvoiceTax_List',$param,'list','sqlsrv');
        
        return view('finance/sales_invoice_tax_list', $this->data);
    }
    
    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'FM-SIT-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Sales Invoice Tax';
        $this->data['form_sub_title'] = 'Create Sales Invoice Tax';
        $this->data['form_desc'] = 'Create Sales Invoice Tax';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoiceTax_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_SalesInvoiceTax = '0';
            $this->data['fields']->IDX_T_SalesInvoiceHeader = $request->IDX_T_SalesInvoiceHeader;
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, $request->IDX_T_SalesInvoiceHeader, 'create');
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-SIT-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Sales Invoice Tax';
        $this->data['form_sub_title'] = 'Update Sales Invoice Tax';
        $this->data['form_desc'] = 'Update Sales Invoice Tax';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoiceTax_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            //$this->data['fields']->ItemLabel = $this->data['fields']->ItemSKU . ' - ' . $this->data['fields']->ItemName;
           
            return $this->show_form($id, $this->data['fields']->IDX_T_SalesInvoiceHeader, 'update');
        }
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $headerid, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;   
        $this->data['dd_tax'] = (array) $dd->tax();
        $this->data['dd_item_tax'] = (array) $dd->item_tax_si('sqlsrv', $headerid);
        // dd($this->data['dd_item_tax']);

        // URL
        $this->data['url_save_modal'] = url('/fm-sales-invoice-tax/save');
       

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Sales Invoice Detail adalah invoice pemesanan barang atau jasa kepada supplier';        
        $this->data['view'] = 'finance/sales_invoice_detail_tax';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_SalesInvoiceTax_Create]';
        $this->sp_update = '[dbo].[USP_CM_SalesInvoiceTax_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-sales-invoice-tax/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_SalesInvoiceTax' => 'required',
        ]);

        if ($validator->fails()) {
            // return $this->validation_fails($validator->errors(), $request->input('FormID'));
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceTax'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // $sql = "SELECT PID.IDX_T_SalesInvoiceDetail
            // FROM CM_T_SalesInvoiceDetail PID WITH(NOLOCK)
            // WHERE PID.IDX_T_SalesInvoiceHeader = " . $data['IDX_T_SalesInvoiceHeader'] . " AND PID.IDX_M_Item = " . $data['ItemDetail'];

            // $result =  DB::connection('sqlsrv')->select($sql);

            // foreach ($result as $row){
            //     $data['IDX_T_SalesInvoiceDetail'] = trim($row->IDX_T_SalesInvoiceDetail);
            // }

            // dd($data);

            if($state == 'update'){
                $param['IDX_T_SalesInvoiceTax'] = $data['IDX_T_SalesInvoiceTax'];    
            }   

            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
            $param['IDX_T_SalesInvoiceDetail'] = $data['IDX_T_SalesInvoiceDetail'];
            $param['IDX_M_Tax'] = $data['IDX_M_Tax'];
            $param['TaxAmount'] = 0;
            $param['TaxCOA'] = $data['IDX_M_COA'];
            
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
        $this->data['form_id'] = 'FM-SIT-D';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        $this->data['form_desc'] = 'Delete Data';

        if ($access == TRUE)
        {                

            $this->data['item_index'] = $request->IDX_T_SalesInvoiceTax;
            $this->data['item_description'] = $request->ItemDesc;

            $this->data['state'] = 'delete'; 

            // URL SAVE
            $this->data['url_save_modal'] = url('fm-sales-invoice-tax/save-delete');

            return view('finance/sales_invoice_tax_delete', $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_CM_SalesInvoiceTax_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-sales-invoice-tax/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_T_SalesInvoiceTax'] = $data['item_index'];            
            
            //$param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}
