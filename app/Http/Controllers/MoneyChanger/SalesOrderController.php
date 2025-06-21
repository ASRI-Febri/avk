<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;
use App\File;
use Image;

class SalesOrderController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/finance.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Sales Order';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Pembelian','Sales Order'); 

        // URL
        $this->data['url_create'] = url('mc-sales-order/create');
        $this->data['url_search'] = url('mc-sales-order-list');           
        $this->data['url_update'] = url('mc-sales-order/update/'); 
        $this->data['url_cancel'] = url('mc-sales-order'); 

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-PI-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        // $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Sales Order';
        $this->data['form_remark'] = 'Daftar transaksi jual beli valuta asing antara customer dengan money changer';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {       
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_T_SalesOrder','Perusahaan','Cabang','Nomor PO',
            'Tanggal PO','Business Partner', 'Catatan PO','POStatus','Status','Action');         

            $this->data['table_footer'] = array('','IDX_T_SalesOrder','CompanyName','BranchName','PONumber',
            '','PartnerName','PONotes','','','Action');

            $this->data['array_filter'] = array('CompanyName','BranchName','PONumber','PONotes','PartnerName');

            // VIEW
            $this->data['view'] = 'money_changer/sales_order_list';  
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
        $array_filter['CompanyName'] = $request->input('CompanyName');  
        $array_filter['BranchName'] = $request->input('BranchName'); 
        $array_filter['PONumber'] = $request->input('PONumber');
        $array_filter['PONotes'] = $request->input('PONotes');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id']; 

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_SalesOrder_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_SalesOrder','CompanyName','BranchName','PONumber',
            'PODate','PartnerName', 'PONotes','POStatus','StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_id'] = 'FM-PI-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Sales Order';
        $this->data['form_sub_title'] = 'Input Sales Order';
        $this->data['form_desc'] = 'Input Sales Order';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_SalesOrder = 0; 
            $this->data['fields']->IDX_M_Partner = 0;  
            $this->data['fields']->SOStatus = 'D';   
            $this->data['fields']->IDX_M_Company = 1; 
            $this->data['fields']->IDX_M_Branch = 1; 
            $this->data['fields']->PartnerDesc = '';
            $this->data['fields']->RecordStatus = 'A';
            $this->data['fields']->SODate = date('Y-m-d');

            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-PI-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Sales Order';
        $this->data['form_sub_title'] = 'Update Sales Order';
        $this->data['form_desc'] = 'Update Sales Order';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];           

            $this->data['fields']->PartnerDesc = $this->data['fields']->PartnerID . ' - ' . $this->data['fields']->PartnerName;
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
        $this->data['dd_branch'] = (array) $dd->branch($this->data['user_id']);
        $this->data['dd_currency'] = (array) $dd->currency();
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);

        // URL
        $this->data['url_save_header'] = url('/mc-sales-order/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW    
        $this->data['view'] = 'money_changer/sales_order_form';

        // RECORDS
        if($state !== 'create')
        {      
            // RECORDS
            $param['IDX_T_SalesOrder'] = $id;   
            $this->data['records_detail'] = $this->exec_sp('USP_MC_SalesOrderDetail_List',$param,'list','sqlsrv');
        }

        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // LOOKUP & SELECT VENDOR
    // =========================================================================================
    public function inquiry_data_partner(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE   
        $array_filter['PartnerID'] = $request->input('PartnerID');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['BarcodeMember'] = $request->input('BarcodeMember');
        $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber');
        $array_filter['PartnerType'] = 'S';
        $array_filter['Street'] = $request->input('Street');
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_Partner_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Partner', 'PartnerID', 'PartnerName', 'IsCustomer', 'IsSupplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'StatusDesc');

        // { data: 'RowNumber', name: 'DT_RowIndex' },
        // { data: "IDX_M_Partner", visible: false },
        // { data: "PartnerID", visible: true },
        // { data: "PartnerName", visible: true },
        // { data: "IsCustomer", visible: true },
        // { data: "IsSupplier", visible: true },
        // { data: "Remarks", visible: true },
        // { data: "BarcodeMember", visible: false },
        // { data: "SingleIdentityNumber", visible: false },
        // { data: "Street", visible: true },
        // { data: "PartnerType", visible: false },
        // { data: "StatusDesc", visible: true },

        return $this->get_datatables($request);
    }

    public function show_lookup_partner(Request $request)
    {
        $this->data['form_title'] = 'Partner';
        $this->data['form_sub_title'] = 'Select Partner';
        $this->data['form_desc'] = 'Select Partner';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/mc-partner-list-pi');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'Partner ID', 'Partner Name', 'Is Customer', 'Is Supplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'Status', 'Action');         

        $this->data['table_footer'] = array('', '',
            'PartnerID', 'PartnerName', '', '', '', '', '', 'Street', '', 'Action');

        $this->data['array_filter'] = array('PartnerID','PartnerName','Street');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        

        return view('money_changer/m_select_partner_list', $this->data);
    }

    // =========================================================================================
    // AJAX REQUEST
    // =========================================================================================
    public function search_po_no(Request $request)
    {
        $search_value = $request->input('q','');          

        $param['SearchValue'] = $search_value;
        $records = $this->exec_sp('USP_MC_SalesOrderSearchByValue_List',$param,'list','sqlsrv');

        $items = array();
        $row_array = array();

        foreach ($records as $row){
        
            $row_array['label'] = $row->PONumber;				
            
            // $row_array['IDX_T_SalesOrder'] = $row->IDX_T_SalesOrder;
            
            array_push($items, $row_array);	            
        }

        $result["rows"] = $items;
			
        echo json_encode($items);

    }

    // // Fetch records
    // public function getInvoiceInfo($id=0){

    //     $sql = "SELECT SUM((UntaxedAmount * Quantity) + DiscountAmount - TaxAmount) - SUM(PaymentAmount)
    //     FROM CM_T_SalesOrderHeader PIH
    //     JOIN CM_T_SalesOrderDetail PID ON PIH.IDX_T_SalesOrder = PID.IDX_T_SalesOrder
    //     LEFT JOIN CM_T_FinancialPaymentDetail FPD ON PIH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
    //     WHERE PIH.IDX_T_SalesOrder = ". $id;

    //     $result['data'] =  DB::connection('sqlsrv')->select($sql);

    //     return response()->json($result);
    
    // }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_SalesOrder_Save]';
        $this->sp_update = '[dbo].[USP_MC_SalesOrder_Save]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-sales-order/update');

        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',            
            'IDX_M_Partner' => 'required',
            'SODate' => 'required',   
            'SONotes' => 'required',          
        ],[
            'IDX_T_SalesOrder.required' => 'Index PO is required',
            'IDX_M_Company.required' => 'Perusahaan belum diisi!',
            'IDX_M_Branch.required' => 'Cabang belum diisi!',
            'IDX_M_Partner.required' => 'Supplier belum diisi',
            'SODate.required' => 'Tgl sales order belum diisi!',
            'SONotes.required' => 'Keterangan belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesOrder'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];

            // SET PARAMETER            
            $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];                
            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];           
            $param['IDX_M_Partner'] = $data['IDX_M_Partner'];            
            $param['SONumber'] = $data['SONumber'];            
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['FundSource'] = $data['FundSource'];
            $param['TransactionPurpose'] = $data['TransactionPurpose'];
            $param['SODate'] = $data['SODate'];            
            $param['SONotes'] = $data['SONotes'];
            $param['SOStatus'] = $data['SOStatus'];                        
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
            $param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // APPROVE
    // =========================================================================================
    public function approve(Request $request)
    {
        $this->data['form_id'] = 'FM-PI-A';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Approval Sales Order';
        $this->data['form_sub_title'] = 'Approval';        
        $this->data['form_desc'] = 'Approval Sales Order';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesOrder)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->PODate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/mc-sales-order/save-approve');            

            // VIEW                          
            $this->data['view'] = 'money_changer/sales_order_approval_form';
            $this->data['submit_title'] = 'Approve';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_approve(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesOrder'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_MC_SalesOrder_Approve]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/mc-sales-order/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];
            $param['ApprovalDate'] = date('Y-m-d',strtotime($data['ApprovalDate']));
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            
            return $this->store($state,$param);
        }   
    }

    // =========================================================================================
    // REVERSE
    // =========================================================================================
    public function reverse(Request $request)
    {
        $this->data['form_id'] = 'FM-PI-Reverse';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
       
        $this->data['form_title'] = 'Reverse Sales Order';
        $this->data['form_sub_title'] = 'Reverse';        
        $this->data['form_desc'] = 'Reverse Sales Order';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesOrder)[0];         

            // DEFAULT VALUE                                  
            $this->data['fields']->ApprovalRemark = '';           
            $this->data['fields']->ApprovalDate = date('Y-m-d',strtotime($this->data['fields']->InvoiceDate));
            $this->data['fields']->ApprovalBy = $this->data['user_id'];

            // URL
            $this->data['url_save_modal'] = url('/mc-sales-order/save-reverse');            

            // VIEW                          
            $this->data['view'] = 'money_changer/sales_order_reverse_form';
            $this->data['submit_title'] = 'Reverse';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_reverse(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesOrder'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_MC_SalesOrder_ReverseValidate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/mc-sales-order/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];
            $param['ApprovalRemark'] = $data['ApprovalRemark'];
            $param['ApprovalBy'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

    // DOWNLOAD PDF 
    public function download_pdf($id,Request $request)
    {
        $data = $request->all();
        
        $data['IDX_T_SalesOrder'] = $id;        

        return $this->generate_pdf($data,'stream');
    }
    
    public function generate_pdf($data = array(), $return_type = 'stream')
    {
        $data['img_logo_w'] = '142';
        $data['img_logo_h'] = '60';
        $data['img_logo'] = url('public/logo-quality.jpeg');

        $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
        $data['fields'] = $this->get_detail_by_id($data['IDX_T_SalesOrder'])[0];
        
        $data['show_action'] = FALSE;

        // GET NUP RECORDS        
        $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];
        $data['records_detail'] = $this->exec_sp('USP_MC_SalesOrderDetail_List',$param,'list','sqlsrv');              

        $pdf = PDF::loadView('money_changer/sales_order_pdf', $data);

        //return $pdf->download('test.pdf');        

        if ($return_type == 'stream')
        {
            return $pdf->stream();
        }

        if ($return_type == 'download')
        {            
            return $pdf->download($data['fields']->SONumber.'.pdf');   
        }

        if ($return_type == 'email')
        {
            \Storage::put('public/temp/sales_order-'.$data['fields']->SONumber.'.pdf', $pdf->output());
            
            //echo storage_path().'/app/public/temp/invoice.pdf';

            return storage_path().'/app/public/temp/sales_order-'.$data['fields']->SONumber.'.pdf'; 
        }
    }


    // =========================================================================================
    // DUPLICATE
    // =========================================================================================
    public function duplicate(Request $request)
    {
        $this->data['form_id'] = 'FM-PI-DUPLICATE';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');        
       
        $this->data['form_title'] = 'Duplicate Purcase Invoice';
        $this->data['form_sub_title'] = 'Duplicate';        
        $this->data['form_desc'] = 'Duplicate Purcase Invoice';
        
        $this->data['state'] = 'approve';

        if ($access == TRUE)
        {
            // GET DATA
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = $this->get_detail_by_id($request->IDX_T_SalesOrder)[0];        
                  
            // RECORDS
            $param['IDX_T_SalesOrder'] = $request->IDX_T_SalesOrder;   
            $this->data['records_detail'] = $this->exec_sp('USP_MC_SalesOrderDetail_List',$param,'list','sqlsrv');       

            // URL
            $this->data['url_save_modal'] = url('/mc-sales-order/save-duplicate');            

            // VIEW                          
            $this->data['view'] = 'money_changer/SalesOrder_duplicate_form';
            $this->data['submit_title'] = 'Duplicate';

            return view($this->data['view'], $this->data);
        } 
        else 
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_duplicate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required'                                  
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesOrder'));
        } 
        else
        {
            $this->sp_approval = '[dbo].[USP_MC_SalesOrder_Duplicate]'; 
            $this->next_action = 'reload';
            $this->next_url = url("/mc-sales-order/update");

            $state = 'approve';
            
            $data = $request->all();
            
            $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];            
            $param['UserID'] = 'XXX'.$this->data['user_id']; 

            return $this->store($state,$param);
        }   
    }

}