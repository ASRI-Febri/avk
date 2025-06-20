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

class FinancialReceivePaymentController extends MyController
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
        $this->data['form_title'] = 'Financial Receive Journal Payment Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Transaction','Financial Receive Journal Payment'); 

        // URL
        $this->data['url_create'] = url('fm-financial-receive-payment/create');
        $this->data['url_search'] = url('fm-financial-receive-payment-list');           
        $this->data['url_update'] = url('fm-financial-receive-payment/update/'); 
        $this->data['url_cancel'] = url('fm-financial-receive-payment'); 

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        $param['IDX_T_FinancialReceiveHeader'] = $id;
          
        $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialReceive_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/financial_receive_payment_list', $this->data);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry_data(Request $request)
    {
        $param['IDX_T_FinancialReceiveHeader'] = $id;
          
        $this->data['payment_detail'] = $this->exec_sp('USP_CM_FinancialReceive_Journal_List',$param,'list','sqlsrv');
        
        return view('finance/financial_receive_payment_list', $this->data);
    }
}
