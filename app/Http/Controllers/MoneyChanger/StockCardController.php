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

class StockCardController extends MyController
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
        $this->data['form_title'] = 'Purchase Order';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // BREADCRUMB
        $this->data['breads'] = array('Pembelian','Purchase Order'); 

        // URL
        $this->data['url_create'] = url('mc-stock-card/create');
        $this->data['url_search'] = url('mc-stock-card-list');           
        $this->data['url_update'] = url('mc-stock-card/update/'); 
        $this->data['url_cancel'] = url('mc-stock-card'); 

        parent::__construct($request);
    }

    public function sop(Request $request)
    { 
        // VIEW
        $this->data['view'] = 'money_changer/sop';  
        return view($this->data['view']);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {       
        $this->data['form_id'] = 'FM-PI-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');
        
        // $access = TRUE;
        
        $this->data['form_sub_title'] = 'Daftar Purchase Order';
        $this->data['form_remark'] = 'Daftar PO pembelian valuta asing untuk persediaan dan untuk dijual kembali';        
        
        // BREADCRUMB
        array_push($this->data['breads'],'List');       

        if ($access == TRUE)
        {       
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No','IDX_M_Valas','Kode Lokasi','Nama Lokasi','Valas SKU',
                'Valas Name','Qty Beli','Nilai','Qty Jual','Nilai',
                'Total Qty','Total Nilai','Action');         

            $this->data['table_footer'] = array('RowNumber','IDX_M_Valas','BranchID','BranchName','ValasSKU',
                'ValasName','StockInQty','StockInForeignAmount','StockOutQty','StockOutForeignAmount',
                'BalanceQty','BalanceForeignAmount','Action');

            $this->data['array_filter'] = array('BranchName','ValasSKU','ValasName');

            // VIEW
            $this->data['view'] = 'money_changer/stock_card_list';  
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
        $array_filter['BranchName'] = $request->input('BranchName'); 
        $array_filter['ValasSKU'] = $request->input('ValasSKU');
        $array_filter['ValasName'] = $request->input('ValasName');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_MC_StockCardSummary_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Valas','BranchID','BranchName','ValasSKU',
            'ValasName','StockInQty','StockInForeignAmount','StockOutQty','StockOutForeignAmount',
            'BalanceQty','BalanceForeignAmount');

        return $this->get_datatables($request); 
    }

}