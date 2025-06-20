<?php

namespace App\Http\Controllers\Accounting;

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

class RptGLController extends MyController
{   
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {        
        $this->data['img_logo']  = url('public/images/logo/accounting.png');    
        $this->table_name = '';    
        
        // FORM TITLE
        $this->data['module_name'] = 'ACCOUNTING';
        $this->data['form_title'] = 'General Ledger';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';     
        $this->data['sidebar'] = 'navigation.sidebar_accounting'; 

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','General Ledger'); 

        // URL
        $this->data['url_create'] = url('ac-rpt-tb/create');
        $this->data['url_search'] = url('ac-rpt-tb-list');           
        $this->data['url_update'] = url('ac-rpt-tb/update/'); 
        $this->data['url_cancel'] = url('ac-rpt-tb'); 

        parent::__construct($request);
    }

    public function period()
    { 
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;
        
        $this->data['title'] = 'ASBS';
        $this->data['form_title'] = 'Laporan General Ledger';
        $this->data['form_sub_title'] = 'Berdasarkan Periode';
        $this->data['form_desc'] = 'Laporan General Ledger';

        $this->data['form_remark'] = 'Laporan General Ledger berdasarkan periode tanggal awal dan tanggal akhir';

        // BREADCRUMB
        array_push($this->data['breads'],'By Period'); 

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
            $this->data['url_show_repoprt'] = url('ac-rpt-gl');

            return view('accounting/rpt_gl_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function period_report(Request $request)
    {
        $validator = Validator::make($request->all(),[   
            'IDX_M_Company' => 'required',
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
            $this->data['page_title'] = 'Laporan General Ledger';   
            $this->data['title'] = 'Laporan General Ledger';            
            $this->data['form_title'] = 'Laporan General Ledger';      

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];	
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];	
            $param['StartDate'] = $this->data['fields']['start_date'];
            $param['EndDate'] = $this->data['fields']['end_date'];
            $param['COA'] = substr($request->coa,0,strlen($request->coa) - 1);	                              

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_GL_R_GeneralLedger',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_gl_report';                                 
            return view($this->data['view'], $this->data);
        }
    }

}
