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

class RptFinancialPaymentController extends MyController
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
        $this->data['form_title'] = 'Financial Payment Report';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Report'); 
         

        parent::__construct($request);
    }

    public function financial_payment()
    { 
        $this->data['form_id'] = 'FM-RPT-Financial-Payment';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;
        
        $this->data['title'] = 'ASBS';
        $this->data['form_title'] = 'Laporan Financial Payment';
        $this->data['form_sub_title'] = 'Laporan';
        $this->data['form_desc'] = 'Laporan Financial Payment';

        $this->data['form_remark'] = 'Laporan Financial Payment';

        // BREADCRUMB
        array_push($this->data['breads'],'Financial Payment'); 

        $this->data['state'] = 'update';        

        if($access == TRUE)
        { 
            // DROPDOWN
            $dd = new DropdownController;           
            $this->data['dd_company'] = (array) $dd->company();                
            $this->data['dd_branch'] = (array) $dd->branch('');        
            
            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '0';
            $this->data['IDX_M_Branch'] = '0';
            $this->data['start_date'] = date('Y-m-d');
            $this->data['end_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('fm-rpt-financial-payment');

            return view('finance/rpt_financial_payment_form', $this->data);
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    public function financial_payment_report(Request $request)
    {
        $validator = Validator::make($request->all(),[   
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
            $this->data['page_title'] = 'Laporan Financial Payment';   
            $this->data['title'] = 'Laporan Financial Payment';            
            $this->data['form_title'] = 'Laporan Financial Payment';      

            $this->data['bulan'] = $this->indonesian_month($this->data['fields']['end_date']);

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];
            $param['StartDate'] = $this->data['fields']['start_date'];
            $param['EndDate'] = $this->data['fields']['end_date'];	                     

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_CM_R_FinancialPayment_Period',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'finance/rpt_financial_payment_report'; 

            if($request->report_type == 'S')
            {
                $this->data['title'] = 'LAPORAN FINANCIAL PAYMENT';   
                $this->data['view'] = 'finance/rpt_financial_payment_report';                                 
            }
            
            return view($this->data['view'], $this->data);
        }
    }
}