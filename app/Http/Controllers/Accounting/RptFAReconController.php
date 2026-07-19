<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptFAReconController extends MyController
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
        $this->data['form_title'] = 'Rekonsiliasi Aset vs GL';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','Rekonsiliasi Aset vs GL');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Rekonsiliasi Aset Tetap vs GL';
        $this->data['form_sub_title'] = 'Per Tanggal Cut-Off';
        $this->data['form_desc'] = 'Rekonsiliasi Aset Tetap vs GL';
        $this->data['form_remark'] = 'Bandingkan total register aset (harga perolehan & akumulasi penyusutan) '
            . 'dengan saldo akun GL per kategori. Selisih harus 0 sebelum go-live.';

        // BREADCRUMB
        array_push($this->data['breads'],'By Cut-Off');

        $this->data['state'] = 'update';

        if($access == TRUE)
        {
            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_company'] = (array) $dd->company();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Company'] = '1';
            $this->data['cutoff_date'] = date('Y-m-d');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-fa-recon');

            return view('accounting/rpt_fa_recon_form', $this->data);
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
            $this->data['page_title'] = 'Rekonsiliasi Aset Tetap vs GL';
            $this->data['title'] = 'Rekonsiliasi Aset Tetap vs GL';
            $this->data['form_title'] = 'Rekonsiliasi Aset Tetap vs GL';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['IDX_M_Company'] = $this->data['fields']['IDX_M_Company'];
            $param['CutOffDate'] = $this->data['fields']['cutoff_date'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_FA_R_Reconciliation',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_fa_recon_report';
            return view($this->data['view'], $this->data);
        }
    }
}
