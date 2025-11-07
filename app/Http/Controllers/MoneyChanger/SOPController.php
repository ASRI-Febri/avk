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

class SOPController extends MyController
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
        $this->data['form_title'] = 'SOP';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer','SOP'); 

        // URL
        $this->data['url_create'] = url('mc-purchase-order/create');
        $this->data['url_search'] = url('mc-purchase-order-list');           
        $this->data['url_update'] = url('mc-purchase-order/update/'); 
        $this->data['url_cancel'] = url('mc-purchase-order'); 

        parent::__construct($request);
    }

    public function sop(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop';  
        return view($this->data['view']);
    }

    public function sop_risk_management(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop_risk_management';  
        return view($this->data['view']);
    }

    public function sop_money_laundry(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop_money_laundry';  
        return view($this->data['view']);
    }

    public function sop_penetapan_kurs(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop_penetapan_kurs';  
        return view($this->data['view']);
    }

    public function sop_perlindungan_konsumen(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop_perlindungan_konsumen';  
        return view($this->data['view']);
    }

}