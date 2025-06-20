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

class SalesInvoicePaymentController extends MyController
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
        $this->data['form_title'] = 'Sales Invoice Payment Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Sales Invoice Payment'); 

        // URL
        $this->data['url_create'] = url('fm-sales-invoice-payment/create');
        $this->data['url_search'] = url('fm-sales-invoice-payment-list');           
        $this->data['url_update'] = url('fm-sales-invoice-payment/update/'); 
        $this->data['url_cancel'] = url('fm-sales-invoice-payment'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        //dd($id);
        $param['IDX_T_SalesInvoiceHeader'] = $id;
          
        $this->data['payment_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Payment_List',$param,'list','sqlsrv');
        
        return view('finance/sales_invoice_payment_list', $this->data);
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

        $this->data['payment_detail'] = $this->exec_sp('USP_CM_SalesInvoice_Payment_List',$param,'list','sqlsrv');
        
        return view('finance/sales_invoice_payment_list', $this->data);
    }
    
    /// =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'FM-SIP-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;

        $this->data['form_title'] = 'Sales Invoice Payment';
        $this->data['form_sub_title'] = 'Create Sales Invoice Payment';
        $this->data['form_desc'] = 'Create Sales Invoice Payment';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_SalesInvoice_Payment_List]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0); 

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_SalesInvoiceHeader = $request->IDX_T_SalesInvoiceHeader;
            $this->data['fields']->IDX_M_COA = 0;

            // $this->data['fields']->RecordStatus = 'A';

            // return $this->show_form(0, 'create');
            return $this->show_form($this->data['fields']->IDX_T_SalesInvoiceHeader, 'create');
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;   
        $this->data['dd_payment_method'] = (array) $dd->payment_method();
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);
        $this->data['dd_coa_transactionsi'] = (array) $dd->coa_transactionsi($id);

        // URL
        $this->data['url_save_modal'] = url('/fm-sales-invoice-payment/save');
       

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Sales Invoice Detail adalah invoice pemesanan barang atau jasa kepada supplier';        
        $this->data['view'] = 'finance/sales_invoice_detail_payment';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_SalesInvoice_Payment]';
        $this->next_action = 'redirect';
        $this->next_url = url('/fm-financial-receive/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_SalesInvoiceHeader' => 'required',
        ]);

        if ($validator->fails()) {
            // return $this->validation_fails($validator->errors(), $request->input('FormID'));
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesInvoiceHeader'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            $param['IDX_T_SalesInvoiceHeader'] = $data['IDX_T_SalesInvoiceHeader'];
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['IDX_M_FinancialAccount'] = $data['IDX_M_FinancialAccount'];
            $param['IDX_M_PaymentType'] = $data['IDX_M_PaymentType'];
            $param['ReceiveAmount'] = (double)str_replace(',','',$data['ReceiveAmount']);
            $param['RemarkDetail'] = $data['RemarkDetail'];
            
            $param['UserID'] = $this->data['user_id'];
            // $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }
}
