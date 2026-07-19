<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptFAFiscalController extends MyController
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
        $this->data['form_title'] = 'Penyusutan Fiskal';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','Penyusutan Fiskal');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Penyusutan Fiskal';
        $this->data['form_sub_title'] = 'Per Tahun Pajak';
        $this->data['form_desc'] = 'Laporan Penyusutan Fiskal';
        $this->data['form_remark'] = 'Daftar penyusutan fiskal per tahun pajak (format Lampiran Khusus 1A SPT Tahunan PPh Badan)';

        // BREADCRUMB
        array_push($this->data['breads'],'By Tax Year');

        $this->data['state'] = 'update';

        if($access == TRUE)
        {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['TaxYear'] = date('Y');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-fa-fiscal');

            return view('accounting/rpt_fa_fiscal_form', $this->data);
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
            'TaxYear' => ['required', 'regex:/^\d{4}$/'],
        ], [
            'TaxYear.regex' => 'Tahun pajak harus 4 angka!',
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('TaxYear'));
        }
        else
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Penyusutan Fiskal';
            $this->data['title'] = 'Laporan Penyusutan Fiskal';
            $this->data['form_title'] = 'Laporan Penyusutan Fiskal';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['TaxYear'] = 'XXX' . $this->data['fields']['TaxYear'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_FA_R_FiscalDepreciation',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_fa_fiscal_report';
            return view($this->data['view'], $this->data);
        }
    }
}
