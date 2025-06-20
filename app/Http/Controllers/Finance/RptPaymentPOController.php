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

class RptPaymentPOController extends MyController
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
        $this->data['form_title'] = 'Payment PO Report';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';     
        $this->data['sidebar'] = 'navigation.sidebar_finance'; 

        // BREADCRUMB
        $this->data['breads'] = array('ASBS','Finance','Report'); 
         

        parent::__construct($request);
    }

    public function payment_po()
    { 
        $this->data['form_id'] = 'FM-RPT-Payment-PO';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        // $access = TRUE;
        
        $this->data['title'] = 'ASBS';
        $this->data['form_title'] = 'Laporan Payment PO';
        $this->data['form_sub_title'] = 'Laporan';
        $this->data['form_desc'] = 'Laporan Payment PO';

        $this->data['form_remark'] = 'Laporan Payment PO';

        // BREADCRUMB
        array_push($this->data['breads'],'Payment PO'); 

        $this->data['state'] = 'update';        

        if($access == TRUE)
        { 
                       
            // DEFAULT PARAMETER
            $this->data['start_date'] = date('Y-m-d');
            $this->data['end_date'] = date('Y-m-d');

            // DROPDOWN
            $dd = new DropdownController;           
            $this->data['dd_project'] = (array) $dd->project();

            // URL SAVE
            $this->data['url_show_repoprt'] = url('fm-rpt-payment-po');

            return view('finance/rpt_payment_po_form', $this->data);
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    public function payment_po_report(Request $request)
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
            $this->data['page_title'] = 'Laporan Payment PO';   
            $this->data['title'] = 'Laporan Payment PO';            
            $this->data['form_title'] = 'Laporan Payment PO';      

            $this->data['bulan'] = $this->indonesian_month($this->data['fields']['end_date']);

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = '1';
            $param['IDX_M_Branch'] = '1';
            $param['StartDate'] = $this->data['fields']['start_date'];
            $param['EndDate'] = $this->data['fields']['end_date'];
            $param['IDX_M_Partner'] = $this->data['fields']['IDX_M_Partner'];
            $param['IDX_M_Project'] = $this->data['fields']['IDX_M_Project'];	                     

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_CM_R_PaymentPO_Period',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'finance/rpt_payment_po_report'; 

            if($request->report_type == 'S')
            {
                $this->data['title'] = 'LAPORAN PAYMENT PO';   
                $this->data['view'] = 'finance/rpt_payment_po_report';                                 
            }
            
            return view($this->data['view'], $this->data);
        }
    }

    // =========================================================================================
    // LOOKUP & SELECT PARTNER
    // =========================================================================================
    public function inquiry_data_partner(Request $request)
    { 
        // FILTER FOR STORED PROCEDURE   
        $array_filter['PartnerID'] = $request->input('PartnerID');
        $array_filter['PartnerName'] = $request->input('PartnerName');
        $array_filter['BarcodeMember'] = $request->input('BarcodeMember');
        $array_filter['SingleIdentityNumber'] = $request->input('SingleIdentityNumber');
        $array_filter['PartnerType'] = 'A';
        $array_filter['Street'] = $request->input('Street');
                
        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_Partner_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_M_Partner', 'PartnerID', 'PartnerName', 'IsCustomer', 'IsSupplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'StatusDesc');

        // { data: 'RowNumber', name: 'DT_RowIndex' },
        // { data: "IDX_M_Partner", visible: false },
        // { data: "PartnerID", visible: true },
        // { data: "PartnerName", visible: true },
        // { data: "IsCustomer", visible: true },
        // { data: "IsSupplier", visible: true },
        // { data: "Remarks", visible: true },
        // { data: "BarcodeMember", visible: false },
        // { data: "SingleIdentityNumber", visible: false },
        // { data: "Street", visible: true },
        // { data: "PartnerType", visible: false },
        // { data: "StatusDesc", visible: true },

        return $this->get_datatables($request);
    }

    public function show_lookup_partner(Request $request)
    {
        $this->data['form_title'] = 'Partner';
        $this->data['form_sub_title'] = 'Select Partner';
        $this->data['form_desc'] = 'Select Partner';		
        
        // URL TO DATATABLES
        $this->data['url_search'] = url('/fm-select-partner-rpt');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No', 'IDX_M_Partner', 'Partner ID', 'Partner Name', 'Is Customer', 'Is Supplier',
         'Remarks', 'BarcodeMember', 'SingleIdentityNumber', 'Street', 'Status', 'Action');         

        $this->data['table_footer'] = array('', '',
            'PartnerID', 'PartnerName', '', '', '', 'Street', '', '');

        $this->data['array_filter'] = array('PartnerID','PartnerName','Street');

        $this->data['target_index'] = $request->target_index;
        $this->data['target_name'] = $request->target_name;

        

        return view('finance/m_select_partner_list', $this->data);
    }
}