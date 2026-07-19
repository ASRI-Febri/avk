<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class RptFACardController extends MyController
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
        $this->data['form_title'] = 'Kartu Aset';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Report','Kartu Aset');

        parent::__construct($request);
    }

    public function period()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Kartu Aset';
        $this->data['form_sub_title'] = 'Per Aset';
        $this->data['form_desc'] = 'Laporan Kartu Aset';
        $this->data['form_remark'] = 'Riwayat kronologis satu aset: perolehan, penyusutan per periode, mutasi, dan pelepasan';

        // BREADCRUMB
        array_push($this->data['breads'],'By Asset');

        $this->data['state'] = 'update';

        if($access == TRUE)
        {
            // DROPDOWN (semua aset, termasuk yang sudah dilepas)
            $dd = new DropdownController;
            $this->data['dd_asset'] = (array) $this->all_assets();

            // DEFAULT PARAMETER
            $this->data['IDX_M_Asset'] = '';

            // URL SAVE
            $this->data['url_show_repoprt'] = url('ac-rpt-fa-card');

            return view('accounting/rpt_fa_card_form', $this->data);
        }
        else
        {
            return $this->show_no_access();
        }
    }

    public function period_report(Request $request)
    {
        $validator = Validator::make($request->all(),[
            'IDX_M_Asset' => 'required',
        ]);

        if($validator->fails())
        {
            return $this->validation_fails($validator->errors(),$request->input('IDX_M_Asset'));
        }
        else
        {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'Laporan Kartu Aset';
            $this->data['title'] = 'Laporan Kartu Aset';
            $this->data['form_title'] = 'Laporan Kartu Aset';

            // INFO ASET
            $this->sp_getdata = '[dbo].[USP_FA_Asset_Info]';
            $info = $this->get_detail_by_id($this->data['fields']['IDX_M_Asset']);
            $this->data['asset_info'] = !empty($info) ? $info[0] : null;

            // RIWAYAT (KARTU)
            $param['IDX_M_Asset'] = $this->data['fields']['IDX_M_Asset'];
            $this->data['records'] = $this->exec_sp('USP_FA_R_AssetCard',$param,'list','sqlsrv');

            // VIEW
            $this->data['view'] = 'accounting/rpt_fa_card_report';
            return view($this->data['view'], $this->data);
        }
    }

    // =========================================================================================
    // HELPERS
    // =========================================================================================
    private function all_assets()
    {
        $sql = "SELECT IDX_M_Asset, AssetCode, AssetName
                FROM FA_M_Asset WITH(NOLOCK)
                WHERE RecordStatus = 'A'
                ORDER BY AssetCode";

        $result = DB::connection('sqlsrv')->select($sql);

        $value[''] = '--SELECT--';
        foreach ($result as $row){
            $value[trim($row->IDX_M_Asset)] = trim($row->AssetCode . ' - ' . $row->AssetName);
        }
        return $value;
    }
}
