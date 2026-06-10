<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptCFController extends MyController
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
        $this->data['form_title'] = 'Cashflow Statement';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting', 'Report', 'Cashflow Statement');

        // URL
        $this->data['url_cancel'] = url('ac-rpt-cf');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'ASBS';
        $this->data['form_title'] = 'Laporan Arus Kas';
        $this->data['form_sub_title'] = 'Berdasarkan Periode';
        $this->data['form_desc'] = 'Laporan Arus Kas';

        $this->data['form_remark'] = 'Laporan Arus Kas (Cashflow Statement) berdasarkan periode (YYYYMM), disusun dengan metode tidak langsung sesuai PSAK 2.';

        // BREADCRUMB
        array_push($this->data['breads'], 'By Period');

        $this->data['state'] = 'update';

        if ($access == TRUE) {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();
            $this->data['dd_branch'] = (array) $dd->branch('');
            $this->data['dd_project'] = (array) $dd->project();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['IDX_M_Branch'] = '1';
            $this->data['IDX_M_Project'] = '0';
            $this->data['Period'] = date('Ym');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-cf');

            return view('accounting/rpt_cf_form', $this->data);
        } else {
            return $this->show_no_access();
        }
    }

    public function period_report(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'Period' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('start_date'));
        } else {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Arus Kas';
            $this->data['title'] = 'Laporan Arus Kas';
            $this->data['form_title'] = 'Laporan Arus Kas';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['Period'] = $this->data['fields']['Period'];
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];
            $param['IDX_M_Project'] = $this->data['fields']['IDX_M_Project'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_GL_R_CashflowStatement', $param, 'list', 'sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_cf_report';
            return view($this->data['view'], $this->data);
        }
    }
}
