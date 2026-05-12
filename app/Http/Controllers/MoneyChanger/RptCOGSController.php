<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;
use App\File;
use Image;

class RptCOGSController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo'] = url('public/images/logo/procurement.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Report COGS';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Report', 'Perhitungan HPP');

        parent::__construct($request);
    }

    public function cogs_calculation()
    {
        //$access = $this->check_permission($this->data['user_index'], 'sm-acct-002');

        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Laporan Perhitungan HPP';
        $this->data['form_sub_title'] = 'Laporan Perhitungan HPP';
        $this->data['form_desc'] = 'Laporan Perhitungan HPP';

        $this->data['form_remark'] = 'Laporan perhitungan HPP / COGS valas berdasarkan periode';

        $this->data['state'] = 'update';

        if ($access == TRUE) {
            $this->data['fields'] = (object) [];

            // DROPDOWN COGSPeriod (distinct dari MC_T_COGSValasCalculation)
            $rows = DB::connection('sqlsrv')->select("
                SELECT DISTINCT COGSPeriod
                FROM MC_T_COGSValasCalculation
                WHERE COGSPeriod IS NOT NULL
                ORDER BY COGSPeriod DESC
            ");

            $dd_cogs_period = [];
            foreach ($rows as $row) {
                $dd_cogs_period[$row->COGSPeriod] = $row->COGSPeriod;
            }
            $this->data['dd_cogs_period'] = $dd_cogs_period;

            // DEFAULT PARAMETER
            $this->data['COGSPeriod'] = count($dd_cogs_period) > 0 ? array_key_first($dd_cogs_period) : date('Ym');

            // URL SAVE
            $this->data['url_show_repoprt'] = url('mc-rpt-cogs-calculation');

            return view('money_changer/rpt_cogs_calculation_form', $this->data);
        } else {
            return $this->show_no_access();
        }
    }

    public function cogs_calculation_report(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'COGSPeriod' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('COGSPeriod'));
        } else {
            // GET POST VALUE
            $this->data['fields'] = $request->all();

            // REPORT INFORMATION
            $this->data['page_title'] = 'LAPORAN PERHITUNGAN HPP';
            $this->data['title'] = 'Laporan Perhitungan HPP';
            $this->data['form_title'] = 'Laporan Perhitungan HPP';

            // REPORT PARAMETER ** Param sequence must refer to param sequence in stored procedure **
            $param['COGSPeriod'] = $this->data['fields']['COGSPeriod'];

            // RECORDS
            $this->data['records'] = $this->exec_sp('USP_MC_R_COGSCalculation', $param, 'list', 'sqlsrv');

            // VIEW
            $this->data['view'] = 'money_changer/rpt_cogs_calculation_report';
            return view($this->data['view'], $this->data);
        }
    }
}
