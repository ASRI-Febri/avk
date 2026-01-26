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

class RptTransactionController extends MyController
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
        $this->data['form_title'] = 'Report Transaction';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Report','Penjualan'); 

        // URL
        // $this->data['url_create'] = url('pr-purchase-order/create');
        // $this->data['url_search'] = url('pr-purchase-order-list');           
        // $this->data['url_update'] = url('pr-purchase-order/update/'); 
        // $this->data['url_cancel'] = url('pr-purchase-order'); 

        parent::__construct($request);
    }

    public function period_sales()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Penjualan Valas';
        $this->data['form_sub_title'] = 'Laporan Penjualan Valas';
        $this->data['form_desc'] = 'Laporan Penjualan Valas';

        $this->data['form_remark'] = 'Laporan Penjualan valas  
            berdasarkan periode tanggal awal dan tanggal akhir';

        // BREADCRUMB
        array_push($this->data['breads'],'Harian'); 

        $this->data['state'] = 'update';        

        if($access == TRUE)
        {            
            $this->sp_getdata = '[dbo].[USP_MC_SalesOrder_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);
            
            // DROPDOWN
            $dd = new DropdownController;  
            $this->data['dd_branch'] = (array) $dd->branch(''); 
            

            $ddf = new DropdownFinanceController; 
            $this->data['dd_valas'] = (array) $ddf->valas();
            $this->data['dd_transaction_type'] = (array) $ddf->transaction_type(); 
            $this->data['dd_currency'] = (array) $ddf->currency();
                       
            // DEFAULT PARAMETER
            $this->data['IDX_M_Currency'] = 0;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['IDX_M_Branch'] = 1;
            $this->data['IDX_M_Partner'] = 0;
            $this->data['PartnerDesc'] = '';
            $this->data['IDX_M_TransactionType'] = 2;
            $this->data['start_date'] = date('Y-m-01');
            $this->data['end_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-so');

            return view('money_changer/rpt_transaction_period_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function period_sales_report(Request $request)
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
            $this->data['page_title'] = 'Laporan Penjualan Valas';   
            $this->data['title'] = 'Laporan Penjualan Valas';            
            $this->data['form_title'] = 'Laporan Penjualan Valas';    
            
            if($request->PartnerDesc == ''){
                $this->data['PartnerName'] = 'Semua Konsumen';
            } else {
                $this->data['PartnerName'] = $request->PartnerDesc;
            }

            if($request->CurrencyName == ''){
                $this->data['CurrencyName'] = 'Semua Mata Uang';
            } else {
                $this->data['CurrencyName'] = $request->CurrencyName;
            }

            if($request->ValasName == ''){
                $this->data['ValasName'] = 'Semua Valas';
            } else {
                $this->data['ValasName'] = $request->ValasName;
            }

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];	
            $param['IDX_M_TransactionType'] = $this->data['fields']['IDX_M_TransactionType'];	
            $param['start_date'] = $this->data['fields']['start_date'];	
            $param['end_date'] = $this->data['fields']['end_date'];	
            $param['IDX_M_Valas'] = $this->data['fields']['IDX_M_Valas'];	   
            $param['IDX_M_Currency'] = $this->data['fields']['IDX_M_Currency'];	 
            $param['IDX_M_Partner'] = $this->data['fields']['IDX_M_Partner'];	                  

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_R_Transaction',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_transaction_period_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

    public function period_purchase()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Pembelian Valas';
        $this->data['form_sub_title'] = 'Laporan Pembelian Valas';
        $this->data['form_desc'] = 'Laporan Pembelian Valas';

        $this->data['form_remark'] = 'Laporan Pembelian valas 
            berdasarkan, periode tanggal awal dan tanggal akhir';

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
            

            $ddf = new DropdownFinanceController; 
            $this->data['dd_valas'] = (array) $ddf->valas();
            $this->data['dd_transaction_type'] = (array) $ddf->transaction_type(); 
            $this->data['dd_currency'] = (array) $ddf->currency();
                       
            // DEFAULT PARAMETER
            $this->data['IDX_M_Currency'] = 0;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['IDX_M_Branch'] = 1;
            $this->data['IDX_M_Partner'] = 0;
            $this->data['PartnerDesc'] = '';
            $this->data['IDX_M_TransactionType'] = 1;
            $this->data['start_date'] = date('Y-m-01');
            $this->data['end_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-transaction');

            return view('money_changer/rpt_transaction_period_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function period_purchase_report(Request $request)
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
            $this->data['page_title'] = 'Laporan Pembelian Valas';   
            $this->data['title'] = 'Laporan Pembelian Valas';            
            $this->data['form_title'] = 'Laporan Pembelian Valas';    
            
            if($request->PartnerDesc == ''){
                $this->data['PartnerName'] = 'Semua Konsumen';
            } else {
                $this->data['PartnerName'] = $request->PartnerDesc;
            }

            if($request->CurrencyName == ''){
                $this->data['CurrencyName'] = 'Semua Mata Uang';
            } else {
                $this->data['CurrencyName'] = $request->CurrencyName;
            }

            if($request->ValasName == ''){
                $this->data['ValasName'] = 'Semua Valas';
            } else {
                $this->data['ValasName'] = $request->ValasName;
            }

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];	
            $param['IDX_M_TransactionType'] = $this->data['fields']['IDX_M_TransactionType'];	
            $param['start_date'] = $this->data['fields']['start_date'];	
            $param['end_date'] = $this->data['fields']['end_date'];	
            $param['IDX_M_Valas'] = $this->data['fields']['IDX_M_Valas'];	   
            $param['IDX_M_Currency'] = $this->data['fields']['IDX_M_Currency'];	 
            $param['IDX_M_Partner'] = $this->data['fields']['IDX_M_Partner'];	                  

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_R_Transaction',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_transaction_period_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

    public function daily_calculation()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Perhitungan Harian';
        $this->data['form_sub_title'] = 'Laporan Perhitungan Harian';
        $this->data['form_desc'] = 'Laporan Perhitungan Harian';

        $this->data['form_remark'] = 'Laporan perhitungan harian untuk membandingkan saldo awal valas, mutasi jual beli
        harian dengan saldo akhir';

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
            

            $ddf = new DropdownFinanceController; 
            $this->data['dd_valas'] = (array) $ddf->valas();
            $this->data['dd_transaction_type'] = (array) $ddf->transaction_type(); 
            $this->data['dd_currency'] = (array) $ddf->currency();
                       
            // DEFAULT PARAMETER
            $this->data['IDX_M_Currency'] = 0;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['IDX_M_Branch'] = 1;
            $this->data['IDX_M_Partner'] = 0;
            $this->data['PartnerDesc'] = '';
            $this->data['IDX_M_TransactionType'] = 0;
            $this->data['TransactionDate'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-daily-calculation');

            return view('money_changer/rpt_daily_calculation_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function daily_calculation_report(Request $request)
    {
        $validator = Validator::make($request->all(),[   
            'IDX_M_Branch' => 'required',
            'TransactionDate' => 'required',
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('TransactionDate'));     
        } 
        else 
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Perhitungan Harian';   
            $this->data['title'] = 'Laporan Perhitungan Harian';            
            $this->data['form_title'] = 'Laporan Perhitungan Harian';    
            
            if($request->PartnerDesc == ''){
                $this->data['PartnerName'] = 'Semua Konsumen';
            } else {
                $this->data['PartnerName'] = $request->PartnerDesc;
            }

            if($request->CurrencyName == ''){
                $this->data['CurrencyName'] = 'Semua Mata Uang';
            } else {
                $this->data['CurrencyName'] = $request->CurrencyName;
            }

            if($request->ValasName == ''){
                $this->data['ValasName'] = 'Semua Valas';
            } else {
                $this->data['ValasName'] = $request->ValasName;
            }

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];	
            $param['IDX_M_TransactionType'] = $this->data['fields']['IDX_M_TransactionType'];	
            $param['TransactionDate'] = $this->data['fields']['TransactionDate'];	
            $param['IDX_M_Valas'] = $this->data['fields']['IDX_M_Valas'];	   
            $param['IDX_M_Currency'] = $this->data['fields']['IDX_M_Currency'];	 
            $param['IDX_M_Partner'] = $this->data['fields']['IDX_M_Partner'];	                  

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_R_DailyCalculation',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_daily_calculation_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

}
