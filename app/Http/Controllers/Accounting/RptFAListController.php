<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptFAListController extends MyController
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
        $this->data['form_title'] = 'Daftar Aset Tetap';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','Daftar Aset Tetap');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Daftar Aset Tetap';
        $this->data['form_sub_title'] = 'Per Tanggal Cut-Off';
        $this->data['form_desc'] = 'Laporan Daftar Aset Tetap';
        $this->data['form_remark'] = 'Daftar aset tetap dengan harga perolehan, akumulasi penyusutan, dan nilai buku per tanggal cut-off';

        // BREADCRUMB
        array_push($this->data['breads'],'By Cut-Off');

        $this->data['state'] = 'update';

        if($access == TRUE)
        {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();
            $this->data['dd_branch'] = (array) $dd->branch('');
            $this->data['dd_asset_category'] = (array) $dd->asset_category();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['IDX_M_Branch'] = '0';
            $this->data['IDX_M_AssetCategory'] = '0';
            $this->data['cutoff_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-fa-list');

            return view('accounting/rpt_fa_list_form', $this->data);
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
            'cutoff_date' => 'required|date',
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('cutoff_date'));
        }
        else
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Daftar Aset Tetap';
            $this->data['title'] = 'Laporan Daftar Aset Tetap';
            $this->data['form_title'] = 'Laporan Daftar Aset Tetap';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['IDX_M_Branch'] = ($this->data['fields']['IDX_M_Branch'] != '') ? $this->data['fields']['IDX_M_Branch'] : 0;
            $param['CutOffDate'] = $this->data['fields']['cutoff_date'];
            $param['IDX_M_AssetCategory'] = ($this->data['fields']['IDX_M_AssetCategory'] != '') ? $this->data['fields']['IDX_M_AssetCategory'] : 0;

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_FA_R_AssetList',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_fa_list_report';
            return view($this->data['view'], $this->data);
        }
    }
}
