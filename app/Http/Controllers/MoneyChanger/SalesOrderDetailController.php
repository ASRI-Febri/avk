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

class SalesOrderDetailController extends MyController
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
        $this->data['form_title'] = 'Sales Order Detail Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_procurement';     
        $this->data['sidebar'] = 'navigation.sidebar_procurement'; 

        // BREADCRUMB
        $this->data['breads'] = array('Transaction','Sales Order Detail'); 

        // URL
        $this->data['url_create'] = url('mc-sales-order-detail/create');
        $this->data['url_search'] = url('mc-sales-order-detail-list');           
        $this->data['url_update'] = url('mc-sales-order-detail/update/'); 
        $this->data['url_cancel'] = url('mc-sales-order-detail'); 

        parent::__construct($request);
    }

    public function reload($IDX_T_SalesOrder,Request $request)
    {   
        $param['IDX_T_SalesOrder'] = $IDX_T_SalesOrder;
        $this->data['records_detail'] = $this->exec_sp('USP_MC_SalesOrderDetail_List',$param,'list','sqlsrv');        
        
        return view('money_changer/sales_order_detail_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {   
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Sales Order Detail List';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_T_SalesOrder', 'IDX_M_Company', 'IDX_M_Branch', 'IDX_M_Partner', 
            'PO Number', 'CompanyName', 'Branch Name', 'Vendor',
            'Reference No', 'PO Date', 'PO Description', 'POStatus', 'Status','Action');         

        $this->data['table_footer'] = array('', '', '', '', '', 
            'PONumber', 'CompanyName', 'BranchName', 'PartnerName',
            'ReferenceNo', 'PODate', 'PODescription', '', 'StatusDesc','Action');

        $this->data['array_filter'] = array('PONumber','CompanyName','BranchName','PartnerName','ReferenceNo','PODate','PODescription');

        // VIEW
        $this->data['view'] = 'money_changer/sales_order_list';  
        return view($this->data['view'], $this->data);        
    }

    public function inquiry_data(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE       
        $array_filter['POStatus'] = $request->input('POStatus');
        $array_filter['PONumber'] = $request->input('PONumber');
        $array_filter['CompanyName'] = $request->input('CompanyName');  
        $array_filter['BranchName'] = $request->input('BranchName'); 
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['ReferenceNo'] = $request->input('ReferenceNo');  
        $array_filter['PODate'] = $request->input('PODate'); 
        $array_filter['PODescription'] = $request->input('PODescription'); 
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_SalesOrderItem_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_SalesOrder', 'IDX_M_Company', 'IDX_M_Branch', 'IDX_M_Partner', 
            'PONumber', 'CompanyName', 'BranchName', 'PartnerName',
            'ReferenceNo', 'PODate', 'PODescription', 'POStatus', 'StatusDesc');

        return $this->get_datatables($request); 
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'PR-PO-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        //$access = TRUE;

        $this->data['form_title'] = 'Sales Order Detail';
        $this->data['form_sub_title'] = 'Create Sales Order Detail';
        $this->data['form_desc'] = 'Create Sales Order Detail';       
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');  

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_MC_SalesOrderDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_SalesOrderDetail = '0';
            $this->data['fields']->IDX_T_SalesOrder = $request->IDX_T_SalesOrder;  
            $this->data['fields']->ForeignAmount = '0.00';
            $this->data['fields']->Quantity = '0.00';            
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
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
        $this->data['form_id'] = 'PR-PO-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Sales Order Detail';
        $this->data['form_sub_title'] = 'Update Sales Order Detail';
        $this->data['form_desc'] = 'Update Sales Order Detail';              
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');  

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrderDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            //$this->data['fields']->ItemLabel = $this->data['fields']->ItemSKU . ' - ' . $this->data['fields']->ItemName; 
            //$this->data['fields']->PODate = date('Y-m-d', strtotime($this->data['fields']->PODate));
            //$this->data['fields']->POExpectedDate = date('Y-m-d', strtotime($this->data['fields']->POExpectedDate));
            $this->data['fields']->ExchangeRate = number_format($this->data['fields']->ExchangeRate,2,'.',',');
            $this->data['fields']->Quantity = number_format($this->data['fields']->Quantity,2,'.',',');
            //$this->data['fields']->UnitPrice = number_format($this->data['fields']->UnitPrice,2,'.',',');
           

            return $this->show_form($id, 'update');
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
        $ddf = new DropdownFinanceController; 
        $this->data['dd_valas'] = (array) $ddf->valas(); 
        $this->data['dd_transaction_type'] = (array) $ddf->transaction_type(); 

        // RECORDS
        if($state !== 'create')
        {
            //$param['IDX_T_SalesOrder'] = $this->data['fields']->IDX_T_SalesOrder;
            //$this->data['records_detail'] = $this->exec_sp('USP_MC_SalesOrderDetailDetail_List',$param,'list','sqlsrv');             
        }

        // URL
        $this->data['url_save_modal'] = url('/mc-sales-order-detail/save');
       

        // BUTTON SAVE
        //$this->data['label'] = 'danger';
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';      

        // VIEW        
        $this->data['form_remark'] = 'Pilih jenis transaksi jual atau beli dan jumlah valas';        
        $this->data['view'] = 'money_changer/sales_order_detail_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_MC_SalesOrderDetail_Save]';
        $this->sp_update = '[dbo].[USP_MC_SalesOrderDetail_Save]';
        $this->next_action = '';
        $this->next_url = url('/mc-sales-order-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required',
            'IDX_M_Valas' => 'required',
            'IDX_M_TransactionType' => 'required',
            'ForeignAmount' => 'required',
            'ExchangeRate' => 'required',
            'IDX_T_SalesOrderDetail' => 'required',
        ],[
            'IDX_T_SalesOrder.required' => 'Index PO is required',
            'IDX_M_Valas.required' => 'Valas belum diisi!',
            'IDX_M_TransactionType.required' => 'Jenis transaksi belum diisi!',
            'ForeignAmount.required' => 'Jumlah Valas belum diisi',
            'ExchangeRate.required' => 'Nilai tukar belum diisi!',
            'IDX_T_SalesOrderDetail.required' => 'Index transaksi belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();
            
            $state = $data['state'];
            
            $param['IDX_T_SalesOrderDetail'] = $data['IDX_T_SalesOrderDetail'];
            $param['IDX_T_SalesOrder'] = $data['IDX_T_SalesOrder'];
            $param['IDX_M_Valas'] = $data['IDX_M_Valas'];
            $param['IDX_M_Tax'] = 0;     
            $param['IDX_M_TransactionType'] = $data['IDX_M_TransactionType'];
            $param['Quantity'] = (double)str_replace(',','',$data['Quantity']);       
            $param['ForeignAmount'] = (double)str_replace(',','',$data['ForeignAmount']);
            $param['ExchangeRate'] = (double)str_replace(',','',$data['ExchangeRate']);            
            $param['DetailNotes'] = $data['DetailNotes'];           
            
            $param['UserID'] = 'XXX'.$this->data['user_id'];
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

        $this->data['item_index'] = $request->IDX_T_SalesOrderDetail;
        $this->data['item_description'] = $request->ItemDesc;

        $this->data['state'] = 'delete'; 

        // URL SAVE
        $this->data['url_save_modal'] = url('mc-sales-order-detail/save-delete');

        return view('general/delete_detail_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_MC_SalesOrderDetail_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/mc-sales-order-detail/reload');

        $validator = Validator::make($request->all(),[            
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();
            
            $state = 'delete';
            
            $param['IDX_T_SalesOrderDetail'] = $data['item_index'];            
            
            //$param['UserID'] = $this->data['user_id'];
            //$param['RecordStatus'] = 'A';            

            return $this->store($state, $param);
        }
    }

}