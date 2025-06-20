<?php

namespace App\Http\Controllers\Finance;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

// DATATABLES
use DataTables;

// BASE CONTROLLER
use App\Http\Controllers\MyController;

// MODEL


// PLUGIN
use Validator;
use PDF;
use Mail;

class RptBankTransferController extends MyController
{ 
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/wuser.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'Finance';
        $this->data['form_title'] = 'Bank Transfer Report';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Report'); 
         

        parent::__construct($request);
    }

    public function bank_transfer()
    { 
        $this->data['form_id'] = 'FM-RPT-Financial-Payment';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;
        
        $this->data['title'] = 'ASBS';
        $this->data['form_title'] = 'Laporan Mutasi Bank';
        $this->data['form_sub_title'] = 'Laporan';
        $this->data['form_desc'] = 'Laporan Mutasi Bank';

        $this->data['form_remark'] = 'Laporan Mutasi Bank';

        // BREADCRUMB
        array_push($this->data['breads'],'Financial Payment'); 

        $this->data['state'] = 'update';        

        if($access == TRUE)
        { 
            // DROPDOWN
            $dd = new DropdownController;           
            $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);       
            
            // DEFAULT PARAMETER
            $this->data['start_date'] = date('Y-m-d');
            $this->data['end_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('fm-rpt-bank-transfer');

            return view('finance/rpt_bank_transfer_form', $this->data);
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    public function bank_transfer_report(Request $request)
    {
        $this->data['fields'] = $request->all();

        // REPORT INFORMATION
        $this->data['page_title'] = 'Laporan Mutasi Bank';   
        $this->data['title'] = 'Laporan Mutasi Bank';            
        $this->data['form_title'] = 'Laporan Mutasi Bank';      

        // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
        $param['IDX_M_FinancialAccount'] = $this->data['fields']['IDX_M_FinancialAccount'];
        $param['StartDate'] = $this->data['fields']['start_date'];
        $param['EndDate'] = $this->data['fields']['end_date'];	                     

        // RECORDS
        $this->data['records'] = $this->exec_sp('USP_CM_R_BankTransfer_Period',$param,'list','sqlsrv');

        // VIEW
        $this->data['title'] = 'LAPORAN MUTASI BANK';   
        $this->data['view'] = 'finance/rpt_bank_transfer_report';                                 

        return view($this->data['view'], $this->data);
        
    }
}