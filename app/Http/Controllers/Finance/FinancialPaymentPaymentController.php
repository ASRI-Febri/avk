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

class FinancialPaymentPaymentController extends MyController
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
        $this->data['form_title'] = 'Financial Payment Journal Payment Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Financial Payment Journal Payment'); 

        // URL
        $this->data['url_create'] = url('fm-financial-payment-payment/create');
        $this->data['url_search'] = url('fm-financial-payment-payment-list');           
        $this->data['url_update'] = url('fm-financial-payment-payment/update/'); 
        $this->data['url_cancel'] = url('fm-financial-payment-payment'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        $param['IDX_T_FinancialPaymentHeader'] = $id;
          
        $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialPayment_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/financial_payment_payment_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry_data(Request $request)
    {
        $param['IDX_T_FinancialPaymentHeader'] = $id;
          
        $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialPayment_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/financial_payment_payment_list', $this->data);
    }
}
