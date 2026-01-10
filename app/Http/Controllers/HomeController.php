<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;

use App\XSalesSummary;
use App\Imports\XSalesMemberImport;
use App\Imports\XSalesSummaryImport;
use App\Imports\XMemberSummaryImport;

use App\TestUpload;
use App\Imports\TestUploadImport;

use Maatwebsite\Excel\Facades\Excel;


class HomeController extends MyController
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['logo'] = 'Portal';
        $this->data['title'] = 'Dashboard';        

        $this->data['form_title'] = '';
        $this->data['form_sub_title'] = '';
        $this->data['breads'] = array();         
        
        parent::__construct($request);
    }

    // =========================================================================================
    // PORTAL
    // =========================================================================================
    public function portal(Request $request)
    {           
        $this->data['module_name'] = 'PORTAL';
        $this->data['form_title'] = 'Portal Application';
        $this->data['form_sub_title'] = 'Modules';
        $this->data['form_desc'] = 'Portal Application';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Application','Modules'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_portal';     
        $this->data['sidebar'] = 'navigation.sidebar_portal'; 

        // URL
        $this->data['url_save_header'] = '#';     

        // VIEW
        return view('portal', $this->data);
    } 

    // =========================================================================================
    // MONEY CHANGER
    // =========================================================================================
    public function money_changer(Request $request)
    {           
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Money Changer';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Money Changer Dashboard';    
        $this->data['form_remark'] = 'Dashboard money changer';

        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Money Changer','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';     
        $this->data['sidebar'] = 'navigation.sidebar_money_changer'; 

        // // RECORDS
        $param['AsOfDate'] = date('Y-m-d');   
        $this->data['records_stock'] = $this->exec_sp('USP_MC_R_Dashboard_Stock',$param,'list','sqlsrv');
        //$this->data['records_sales_by_valas'] = $this->exec_sp('USP_MC_R_Dashboard_SalesValas',$param,'list','sqlsrv');
        //$this->data['records_sales_by_partner'] = $this->exec_sp('USP_MC_R_Dashboard_SalesPartner',$param,'list','sqlsrv');

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('money_changer.dashboard', $this->data);
    }

    // =========================================================================================
    // PAWN (GADAI)
    // =========================================================================================
    public function pawn(Request $request)
    {           
        $this->data['module_name'] = 'Pawn';
        $this->data['form_title'] = 'Pawn';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Pawn Dashboard';    
        $this->data['form_remark'] = 'Dashboard Pawn';

        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Pawn','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_pawn';     
        $this->data['sidebar'] = 'navigation.sidebar_pawn'; 

        // // RECORDS
        // $sql_po = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        //             FROM PR_T_PurchaseOrder PO
        //             LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        //             WHERE PO.IDX_M_DocumentType = 8
        //             ORDER BY IDX_T_PurchaseOrder DESC';

        // $sql_spk = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        // FROM PR_T_PurchaseOrder PO
        // LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        // WHERE PO.IDX_M_DocumentType = 9
        // ORDER BY IDX_T_PurchaseOrder DESC';

        // $this->data['records_po'] = $this->exec_sql($sql_po, 'list', 'sqlsrv'); 
        // $this->data['records_spk'] = $this->exec_sql($sql_spk, 'list', 'sqlsrv');

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('pawn.dashboard', $this->data);
    }

    // =========================================================================================
    // LOAN (PINJAMAN)
    // =========================================================================================
    public function loan(Request $request)
    {           
        $this->data['module_name'] = 'Loan';
        $this->data['form_title'] = 'Loan';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Loan Dashboard';    
        $this->data['form_remark'] = 'Dashboard Loan';

        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Loan','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_loan';     
        $this->data['sidebar'] = 'navigation.sidebar_loan'; 

        // // RECORDS
        // $sql_po = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        //             FROM PR_T_PurchaseOrder PO
        //             LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        //             WHERE PO.IDX_M_DocumentType = 8
        //             ORDER BY IDX_T_PurchaseOrder DESC';

        // $sql_spk = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        // FROM PR_T_PurchaseOrder PO
        // LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        // WHERE PO.IDX_M_DocumentType = 9
        // ORDER BY IDX_T_PurchaseOrder DESC';

        // $this->data['records_po'] = $this->exec_sql($sql_po, 'list', 'sqlsrv'); 
        // $this->data['records_spk'] = $this->exec_sql($sql_spk, 'list', 'sqlsrv');

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('loan.dashboard', $this->data);
    }

    // =========================================================================================
    // PROCUREMENT
    // =========================================================================================
    public function procurement(Request $request)
    {           
        $this->data['module_name'] = 'Procurement';
        $this->data['form_title'] = 'Procurement';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Procurement Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Procurement','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_procurement';     
        $this->data['sidebar'] = 'navigation.sidebar_procurement'; 

        // RECORDS
        $sql_po = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
                    FROM PR_T_PurchaseOrder PO
                    LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
                    WHERE PO.IDX_M_DocumentType = 8
                    ORDER BY IDX_T_PurchaseOrder DESC';

        $sql_spk = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        FROM PR_T_PurchaseOrder PO
        LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        WHERE PO.IDX_M_DocumentType = 9
        ORDER BY IDX_T_PurchaseOrder DESC';

        $this->data['records_po'] = $this->exec_sql($sql_po, 'list', 'sqlsrv'); 
        $this->data['records_spk'] = $this->exec_sql($sql_spk, 'list', 'sqlsrv');

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('procurement.dashboard', $this->data);
    }

    // =========================================================================================
    // FINANCE
    // =========================================================================================
    public function finance(Request $request)
    {           
        $this->data['module_name'] = 'Finance';
        $this->data['form_title'] = 'Finance';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Finance Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Finance','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('finance.dashboard', $this->data);
    }

    // =========================================================================================
    // ACCOUNTING
    // =========================================================================================
    public function accounting(Request $request)
    {           
        $this->data['module_name'] = 'Accounting';
        $this->data['form_title'] = 'Accounting';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Accounting Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Accounting','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('accounting.dashboard', $this->data);
    }

    // =========================================================================================
    // USER MANAGEMENT
    // =========================================================================================
    public function user_management(Request $request)
    {           
        $this->data['module_name'] = 'User Management';
        $this->data['form_title'] = 'User Management';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'User Management Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'User Management','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_user_management';     
        $this->data['sidebar'] = 'navigation.sidebar_user_management'; 

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        $param['NIK'] = (string)trim($this->data['user_id']);
        $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('user_management.dashboard', $this->data);
    } 

    // =========================================================================================
    // SETTING CONFIGURATION
    // =========================================================================================
    public function general(Request $request)
    {           
        $this->data['module_name'] = 'Master';
        $this->data['form_title'] = 'General Setting';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'General Setting Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'General Setting','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_general';     
        $this->data['sidebar'] = 'navigation.sidebar_general'; 

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('general.dashboard', $this->data);
    }
    // =========================================================================================
    // DASHBOARD
    // =========================================================================================
    public function dashboard(Request $request)
    {   
        $this->data['module_name'] = 'PORTAL';
        $this->data['form_title'] = '';
        $this->data['form_sub_title'] = '';
        $this->data['form_desc'] = 'Application Portal';
        $this->data['breads'] = array('Portal - Application'); 
        $this->data['state'] = 'read';

        // URL
        $this->data['url_save_header'] = '#';        

        // VIEW
        return view('home', $this->data);
    } 

    // =========================================================================================
    // INVENTORY
    // =========================================================================================
    public function inventory(Request $request)
    {           
        $this->data['module_name'] = 'Inventory';
        $this->data['form_title'] = 'Inventory';
        $this->data['form_sub_title'] = 'Dashboard';
        $this->data['form_desc'] = 'Procurement Dashboard';        
        $this->data['state'] = 'read';

        // BREADCRUMB
        array_push($this->data['breads'], 'Inventory','Dashboard'); 

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_inventory';     
        $this->data['sidebar'] = 'navigation.sidebar_inventory'; 

        // RECORDS
        $sql_po = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
                    FROM PR_T_PurchaseOrder PO
                    LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
                    WHERE PO.IDX_M_DocumentType = 8
                    ORDER BY IDX_T_PurchaseOrder DESC';

        $sql_spk = ' SELECT TOP 10 IDX_T_PurchaseOrder, PONumber, MP.PartnerName, PODate, PODescription
        FROM PR_T_PurchaseOrder PO
        LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PO.IDX_M_Partner
        WHERE PO.IDX_M_DocumentType = 9
        ORDER BY IDX_T_PurchaseOrder DESC';

        $this->data['records_po'] = $this->exec_sql($sql_po, 'list', 'sqlsrv'); 
        $this->data['records_spk'] = $this->exec_sql($sql_spk, 'list', 'sqlsrv');

        // URL
        $this->data['url_save_header'] = '#';       
        
        // GET FORM LIST
        // $param['NIK'] = (string)trim($this->data['user_id']);
        // $this->data['records_form'] = $this->exec_sp('USP_SM_FormByUser_List',$param,'list','sqlsrv');

        // VIEW
        return view('inventory.dashboard', $this->data);
    }
    
}