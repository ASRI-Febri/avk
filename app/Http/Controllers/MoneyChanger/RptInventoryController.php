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

class RptInventoryController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/procurement.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Report Inventory';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Report','Inventory'); 

        // URL
        // $this->data['url_create'] = url('pr-purchase-order/create');
        // $this->data['url_search'] = url('pr-purchase-order-list');           
        // $this->data['url_update'] = url('pr-purchase-order/update/'); 
        // $this->data['url_cancel'] = url('pr-purchase-order'); 

        parent::__construct($request);
    }

    public function period()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Inventory Valas';
        $this->data['form_sub_title'] = 'Laporan Inventory Valas';
        $this->data['form_desc'] = 'Laporan Inventory Valas';

        $this->data['form_remark'] = 'Laporan inventory valas berdasarkan cabang, periode tanggal awal dan tanggal akhir';

        // BREADCRUMB
        array_push($this->data['breads'],'Inventory'); 

        $this->data['state'] = 'update';        

        if($access == TRUE)
        {            
            $this->sp_getdata = '[dbo].[USP_MC_PurchaseOrder_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);
            
            // DROPDOWN
            $dd = new DropdownController;  
            $this->data['dd_branch'] = (array) $dd->branch(''); 
            $this->data['dd_currency'] = (array) $dd->currency();

            $ddf = new DropdownFinanceController; 
            $this->data['dd_valas'] = (array) $ddf->valas(); 
                       
            // DEFAULT PARAMETER
            $this->data['IDX_M_Currency'] = 0;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['start_date'] = date('Y-m-01');
            $this->data['end_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-inventory');

            return view('money_changer/rpt_inventory_period_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function period_report(Request $request)
    {
        $validator = Validator::make($request->all(),[   
            'IDX_M_Branch' => 'required',
            'start_date' => 'required',
            'end_date' => 'required'
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('start_date'));     
        } 
        else 
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Inventory Valas';   
            $this->data['title'] = 'Laporan Inventory Valas';            
            $this->data['form_title'] = 'Laporan Inventory Valas';      

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];	
            $param['start_date'] = $this->data['fields']['start_date'];	
            $param['end_date'] = $this->data['fields']['end_date'];	
            $param['IDX_M_Valas'] = $this->data['fields']['IDX_M_Valas'];	   
            $param['IDX_M_Currency'] = $this->data['fields']['IDX_M_Currency'];	                  

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_R_StockCard',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_inventory_period_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

}
