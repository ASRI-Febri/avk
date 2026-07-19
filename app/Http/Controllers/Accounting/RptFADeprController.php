<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptFADeprController extends MyController
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
        $this->data['form_title'] = 'Rekap Penyusutan';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','Rekap Penyusutan');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Rekap Penyusutan';
        $this->data['form_sub_title'] = 'Per Periode';
        $this->data['form_desc'] = 'Laporan Rekap Penyusutan';
        $this->data['form_remark'] = 'Rekap penyusutan komersial & fiskal per aset untuk satu periode (YYYYMM)';

        // BREADCRUMB
        array_push($this->data['breads'],'By Period');

        $this->data['state'] = 'update';

        if($access == TRUE)
        {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['Period'] = date('Ym');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-fa-depr');

            return view('accounting/rpt_fa_depr_form', $this->data);
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
            'Period' => ['required', 'regex:/^\d{6}$/'],
        ], [
            'Period.regex' => 'Periode harus 6 angka dengan format YYYYMM!',
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('Period'));
        }
        else
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Rekap Penyusutan';
            $this->data['title'] = 'Laporan Rekap Penyusutan';
            $this->data['form_title'] = 'Laporan Rekap Penyusutan';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['DeprPeriod'] = 'XXX' . $this->data['fields']['Period'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_FA_R_DepreciationSchedule',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_fa_depr_report';
            return view($this->data['view'], $this->data);
        }
    }
}
