<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptEQController extends MyController
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
        $this->data['form_title'] = 'Statement of Changes in Equity';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting', 'Report', 'Statement of Changes in Equity');

        // URL
        $this->data['url_cancel'] = url('ac-rpt-eq');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'ASEQ';
        $this->data['form_title'] = 'Laporan Perubahan Ekuitas';
        $this->data['form_sub_title'] = 'Berdasarkan Periode';
        $this->data['form_desc'] = 'Laporan Perubahan Ekuitas';

        $this->data['form_remark'] = 'Laporan Perubahan Ekuitas (Statement of Changes in Equity) berdasarkan periode (YYYYMM). Saldo awal & akhir diambil dari Trial Balance sehingga konsisten dengan Neraca.';

        // BREADCRUMB
        array_push($this->data['breads'], 'By Period');

        $this->data['state'] = 'update';

        if ($access == TRUE) {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();
            $this->data['dd_branch'] = (array) $dd->branch('');

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['IDX_M_Branch'] = '1';
            $this->data['Period'] = date('Ym');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-eq');

            return view('accounting/rpt_eq_form', $this->data);
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
            $this->data['page_title'] = 'Laporan Perubahan Ekuitas';
            $this->data['title'] = 'Laporan Perubahan Ekuitas';
            $this->data['form_title'] = 'Laporan Perubahan Ekuitas';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['Period'] = $this->data['fields']['Period'];
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['IDX_M_Branch'] = $this->data['fields']['IDX_M_Branch'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_GL_R_StatementOfChangesInEquity', $param, 'list', 'sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_eq_report';
            return view($this->data['view'], $this->data);
        }
    }
}
