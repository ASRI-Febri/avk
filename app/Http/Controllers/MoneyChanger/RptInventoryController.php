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
            

            $ddf = new DropdownFinanceController; 
            $this->data['dd_valas'] = (array) $ddf->valas(); 
            $this->data['dd_currency'] = (array) $ddf->currency();

            // MAP VALAS -> MATA UANG UNTUK CHAINED DROPDOWN
            $this->data['valas_currency_map'] = collect(DB::connection('sqlsrv')->select(
                    "SELECT IDX_M_Valas, IDX_M_Currency FROM MC_M_Valas WHERE RecordStatus = 'A'"
                ))->pluck('IDX_M_Currency', 'IDX_M_Valas');

            // DEFAULT PARAMETER
            $this->data['IDX_M_Currency'] = 0;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['IDX_M_Branch'] = 1;
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

    public function inventory_calculation()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Perhitungan Persediaan';
        $this->data['form_sub_title'] = 'Laporan Perhitungan Persediaan';
        $this->data['form_desc'] = 'Laporan Perhitungan Persediaan';

        $this->data['form_remark'] = 'Laporan perhitungan persediaan dengan metode rata-rata / average';

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
            $this->data['dd_currency'] = (array) $ddf->currency();
                       
            // DEFAULT PARAMETER
            $this->data['Period'] = date('Ym');
            

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-inventory-calculation');
            return view('money_changer/rpt_inventory_calculation_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function inventory_calculation_report(Request $request)
    {
        $validator = Validator::make($request->all(),[   
            'Period' => 'required',
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
            $this->data['page_title'] = 'Laporan Perhitungan Persediaan';   
            $this->data['title'] = 'Laporan Perhitungan Persediaan';            
            $this->data['form_title'] = 'Laporan Perhitungan Persediaan';    
            
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
            $param['Period'] = $this->data['fields']['Period'];	

            // RECORDS
            //$this->data['records'] = $this->exec_sp('USP_MC_R_InventoryCalculation',$param,'list','sqlsrv');

            $query = $this->exec_sp_multi('USP_MC_R_InventoryCalculation', $param);

            $result = $query;

            if($result)
            {
                // RECORDS
                //$this->data['records_summary'] = $result[0];
                //$this->data['records_detail'] = $result[1];
                $this->data['records'] = $result[1];
            }

            // VIEW
            $this->data['view'] = 'money_changer/rpt_inventory_calculation_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

    // =========================================================================================
    // REKAP KARTU MUTASI (dari hasil Perhitungan HPP per periode)
    // =========================================================================================
    public function mutation_recap()
    {
        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Rekap Kartu Mutasi';
        $this->data['form_sub_title'] = 'Rekap Kartu Mutasi';
        $this->data['form_desc'] = 'Rekap Kartu Mutasi';
        $this->data['form_remark'] = 'Rekap mutasi transaksi jual beli UKA per mata uang berdasarkan periode Perhitungan HPP';

        array_push($this->data['breads'], 'Rekap Kartu Mutasi');

        $this->data['state'] = 'update';
        $this->data['fields'] = (object) [];

        $periods = [];
        foreach (DB::connection('sqlsrv')->select(
            "SELECT DISTINCT COGSPeriod FROM MC_T_COGSValasCalculation WITH(NOLOCK) WHERE COGSPeriod IS NOT NULL ORDER BY COGSPeriod DESC"
        ) as $row)
        {
            $periods[$row->COGSPeriod] = date('F Y', strtotime($row->COGSPeriod . '01')) . ' (' . $row->COGSPeriod . ')';
        }
        $this->data['dd_period'] = $periods;
        $this->data['Period'] = $periods ? array_key_first($periods) : date('Ym');

        $this->data['url_show_repoprt'] = url('mc-rpt-mutation-recap');

        return view('money_changer/rpt_mutation_recap_form', $this->data);
    }

    public function mutation_recap_report(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Period' => 'required|digits:6',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('Period'));
        }

        $months = [1 => 'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI', 'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'];
        $period = $request->input('Period');

        $company = DB::connection('sqlsrv')->select(
            "SELECT TOP 1 RTRIM(CompanyName) AS CompanyName FROM GN_M_Company WITH(NOLOCK) WHERE RecordStatus = 'A' ORDER BY IDX_M_Company"
        );

        $this->data['title'] = 'Rekap Kartu Mutasi';
        $this->data['page_title'] = 'REKAP KARTU MUTASI';
        $this->data['period_desc'] = $months[(int) substr($period, 4, 2)] . ' ' . substr($period, 0, 4);
        $this->data['company_name'] = $company ? strtoupper($company[0]->CompanyName) : '';

        $param['Period'] = $period;
        $this->data['records'] = $this->exec_sp('USP_MC_R_StockMutationRecap', $param, 'list', 'sqlsrv');

        return view('money_changer/rpt_mutation_recap_report', $this->data);
    }
}
