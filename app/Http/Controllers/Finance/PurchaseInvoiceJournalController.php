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

class PurchaseInvoiceJournalController extends MyController
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
        $this->data['form_title'] = 'Purchase Invoice Journal Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Purchase Invoice Journal'); 

        // URL
        $this->data['url_create'] = url('fm-purchase-invoice-journal/create');
        $this->data['url_search'] = url('fm-purchase-invoice-journal-list');           
        $this->data['url_update'] = url('fm-purchase-invoice-journal/update/'); 
        $this->data['url_cancel'] = url('fm-purchase-invoice-journal'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        //dd($id);
        $param['IDX_T_PurchaseInvoiceHeader'] = $id;
          
        $this->data['journal_detail'] = $this->exec_sp('USP_CM_PurchaseInvoice_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/purchase_invoice_journal_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_T_PurchaseInvoiceHeader'] = $request->input('IDX_T_PurchaseInvoiceHeader');

        // // SET STORED PROCEDURE
        // $this->sp_getinquiry = 'dbo.[usp_CM_PurchaseInvoiceDetail_List]';

        // // ARRAY COLUMN AND FILTER FOR DATATABLES
        // $this->array_filter = $array_filter;

        // $this->array_column = array(
        //     'RowNumber','IDX_T_PurchaseInvoiceDetail','ItemSKU','ItemAlias','ItemDesc'
        //         ,'UOMID','UOMDesc','BrandAlias','BrandDesc','CurrencyDesc','IDX_M_Partner'
        //         ,'InvoiceStatus','StatusDesc','COAID','COADesc','IDX_M_COA');

        // return $this->get_datatables($request);

        $this->data['journal_detail'] = $this->exec_sp('USP_CM_PurchaseInvoice_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/purchase_invoice_journal_list', $this->data);
    }
    
    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        //$access = $this->check_permission($this->data['user_id'], '', 'U');

        $access = TRUE;

        $this->data['form_title'] = 'Membership Receipt';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Input Membership Receipt';
        $this->data['breads'] = array('Membership','Transaction','Membership Receipt', 'Create');
        
        $this->data['state'] = 'create';

        if ($access == TRUE) {
            $id = 0;

            // if($request->ReceiptCategory == 'Membership'){

            $this->sp_getdata = '[MembershipDB].dbo.[usp_T_ReceiptMembershipDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id($id);

            $this->data['fields']->IDX_T_ReceiptMembershipHeader = $request->IDX_T_ReceiptMembershipHeader;
            $this->data['fields']->IDX_T_ReceiptMembershipDetail = 0;
            $this->data['fields']->IDX_T_InvoiceMembership = 0;
            $this->data['fields']->RecordStatus = 'A';

            $custid = $request->IDX_M_CustomerMembershipHeader;
            
            //dd($this->data['fields']->IDX_M_CustomerMembershipHeader);
            return $this->show_form($id, 'create', $custid);
            // }   
            // else{
            //     $this->sp_getdata = '[MembershipDB].dbo.[usp_T_ReceiptMembershipDetail_InfoOther]';
            //     $this->data['fields'] = (object) $this->get_detail_by_id($id);

            //     $this->data['fields']->IDX_T_ReceiptMembershipHeader = $request->IDX_T_ReceiptMembershipHeader;
            //     $this->data['fields']->IDX_T_ReceiptMembershipDetail = 0;
            //     $this->data['fields']->IDX_T_InvoiceMembership = 0;
            //     $this->data['fields']->RecordStatus = 'A';

            //     $custid = $request->IDX_M_Customer;

            //     //dd($custid);
            //     return $this->show_other_form($id, 'create', $custid);
            //}
            
        } else {

            return $this->show_no_access_modal();
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update(Request $request)
    {
        //$access = $this->check_permission($this->data['user_id'], '', 'U');

        $access = TRUE;

        $this->data['form_title'] = 'Membership Receipt';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Membership Receipt';
        $this->data['breads'] = array('Membership','Transaction','Membership Receipt', 'Update');        
        $this->data['state'] = 'update';

        if ($access == TRUE) {
            $id = $request->IDX_T_ReceiptMembershipDetail;

            // if($request->ReceiptCategory == 'Membership'){
            $this->sp_getdata = '[MembershipDB].dbo.[usp_T_ReceiptMembershipDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            $this->data['fields']->InvoiceAmount = number_format($this->data['fields']->InvoiceAmount,0,',','.');
            $this->data['fields']->OutstandingAmount = number_format($this->data['fields']->OutstandingAmount,0,',','.');
            $this->data['fields']->ReceiveAmount = number_format($this->data['fields']->ReceiveAmount,0,',','.');

            return $this->show_form($id, 'update', $this->data['fields']->IDX_M_CustomerMembershipHeader);
            // } else {
            //     $this->sp_getdata = '[MembershipDB].dbo.[usp_T_ReceiptMembershipDetail_InfoOther]';
            //     $this->data['fields'] = $this->get_detail_by_id($id)[0];

            //     return $this->show_other_form($id, 'update', $this->data['fields']->IDX_M_Customer);
            // }
            
        } else {

            return $this->show_no_access_modal();
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state, $custid)
    {
        $id = $custid;
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_payment_type'] = (array)$dd->payment_type();
        $this->data['dd_invoicemembership'] = (array)$dd->invoicemembership('sqlsrv', $state, $custid);
        
        // DEFAULT VALUE
        $this->data['show_action'] = TRUE;

        // URL
        $url = url('rct-membership-detail/save');	
        $this->data['js_modal_save'] = "saveDetail('" . $url . "','table-membershipreceipt')";  

        $this->data['url_save_header'] = url('/rct-membership-detail/save');
       
        // BUTTON SAVE
        $this->data['button_save_status'] = '';
       
        // VIEW        
        $this->data['view'] = 'membership/t_membership_receipt_detail_form';

        return view($this->data['view'], $this->data);
    }

    // function show_other_form($id, $state, $custid)
    // {
    //     // DROPDOWN
    //     $dd = new DropdownController;
    //     $this->data['dd_payment_type'] = (array)$dd->payment_type();
    //     $this->data['dd_invoicemembership'] = (array)$dd->otherinvoice('sqlsrv', $state, $custid);
        
    //     // DEFAULT VALUE
    //     $this->data['show_action'] = TRUE;

    //     // URL
    //     $url = url('rct-membership-detail/save');	
    //     $this->data['js_modal_save'] = "saveDetail('" . $url . "','table-membershipreceipt')";  

    //     $this->data['url_save_header'] = url('/rct-membership-detail/save');
       
    //     // BUTTON SAVE
    //     $this->data['button_save_status'] = '';
       
    //     // VIEW        
    //     $this->data['view'] = 'membership/t_membership_receipt_detail_form';

    //     return view($this->data['view'], $this->data);
    // }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[MembershipDB].[dbo].[usp_T_ReceiptMembershipDetail_Save]';
        $this->sp_update = '[MembershipDB].[dbo].[usp_T_ReceiptMembershipDetail_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/rct-membership-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_ReceiptMembershipDetail' => 'required',
            'IDX_T_ReceiptMembershipHeader' => 'required',
            'PaymentType' => 'in:Cash,Transfer,Giro,Credit,Debit',
            'ReceiveDate' => 'required',
            'ReceiveAmount' => 'required|min:0|not_in:0',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_ReceiptMembershipHeader'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            //print_r($data);

            //EXEC [MembershipDB].[dbo].[usp_T_ReceiptMembershipDetail_Save] 0,5,27,'None','2023-01-17','','','2301013','A'

            if ($state == 'create' || $state == 'update') {               

                $param['IDX_T_ReceiptMembershipDetail'] = $data['IDX_T_ReceiptMembershipDetail'];
                $param['IDX_T_ReceiptMembershipHeader'] = $data['IDX_T_ReceiptMembershipHeader'];
                $param['IDX_T_InvoiceMembership'] = $data['IDX_T_InvoiceMembership'];
                $param['PaymentType'] = $data['PaymentType'];
                $param['ReceiveDate'] = $data['ReceiveDate'];
                $param['ReceiptAmountDetail'] = filter_var($data['ReceiveAmount'], FILTER_SANITIZE_NUMBER_INT);
                $param['ReceiptNotes'] = $data['Notes']; 
                $param['UserID'] = 'XXX'.$this->data['user_id'];
                $param['RecordStatus'] = 'A';
            }

            return $this->store($state, $param);
        }
    }
      
    // =========================================================================================
    // DELETE
    // =========================================================================================
    public function delete(Request $request)
    {
        $this->data['form_desc'] = 'Delete Membership Receipt';

        $id = $request->IDX_T_ReceiptMembershipDetail; 

        $this->sp_getdata = '[MembershipDB].[dbo].[usp_T_ReceiptMembershipDetail_Info]';
        $this->data['fields'] = $this->get_detail_by_id($id)[0];

        $this->data['ReceiptNo'] = $request->ReceiptNo;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $url = url('rct-membership-detail/save-delete');	
        $this->data['js_modal_save'] = "saveDetail('" . $url . "','table-membershipreceipt')";  

        // $this->data['url_save_modal'] = url('fm-pdc-customer-detail/save-delete');

        // VIEW
        return view('membership/t_membership_delete_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $data = $request->all();		        
        
        $this->sp_delete = '[MembershipDB].dbo.[usp_T_ReceiptMembershipDetail_Delete]'; 
        $this->next_action = '';
        $this->next_url = url('/rct-membership-detail/reload');       
        
        $param['IDX_T_ReceiptMembershipDetail'] = $data['IDX_T_ReceiptMembershipDetail'];        
        $param['UserID'] = 'XXX'.$this->data['user_id'];
        $param['RecordStatus'] = 'A';       

        return $this->store('delete',$param);
    }

}
