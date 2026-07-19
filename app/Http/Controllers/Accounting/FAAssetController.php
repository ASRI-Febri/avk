<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class FAAssetController extends MyController
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
        $this->data['form_title'] = 'Aset Tetap';
        $this->data['form_remark'] = 'Register aset tetap (PSAK 16)';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Fixed Asset','Aset Tetap');

        // URL
        $this->data['url_create'] = url('ac-fa-asset/create');
        $this->data['url_search'] = url('ac-fa-asset-list');
        $this->data['url_update'] = url('ac-fa-asset/update/');
        $this->data['url_cancel'] = url('ac-fa-asset');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Daftar Aset Tetap';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_Asset','IDX_M_Company','IDX_M_Branch','Cabang',
            'IDX_M_AssetCategory','Kategori','Kode Aset','Nama Aset','Tgl Perolehan','Harga Perolehan',
            'Akum. Penyusutan','Nilai Buku','AssetStatus','Status','Action');

        $this->data['table_footer'] = array('','','IDX_M_Company','IDX_M_Branch','BranchName',
            'IDX_M_AssetCategory','CategoryName','AssetCode','AssetName','AcquisitionDate','',
            '','','','AssetStatusDesc','Action');

        $this->data['array_filter'] = array('IDX_M_Company','IDX_M_Branch','SearchText','IDX_M_AssetCategory','AssetStatus');

        // DROPDOWN FILTER
        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();
        $this->data['dd_branch'] = (array) $dd->branch();
        $this->data['dd_asset_category'] = (array) $dd->asset_category();
        $this->data['dd_asset_status'] = (array) $dd->asset_status();

        // VIEW
        $this->data['view'] = 'accounting/fa_asset_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['IDX_M_Company'] = $request->input('IDX_M_Company');
        $array_filter['IDX_M_Branch'] = $request->input('IDX_M_Branch');
        $array_filter['SearchText'] = $request->input('SearchText');
        $array_filter['IDX_M_AssetCategory'] = $request->input('IDX_M_AssetCategory');
        $array_filter['AssetStatus'] = $request->input('AssetStatus');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_FA_Asset_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_Asset','IDX_M_Company','IDX_M_Branch','BranchName',
            'IDX_M_AssetCategory','CategoryName','AssetCode','AssetName','AcquisitionDate','AcquisitionCost',
            'AccumDepr','BookValue','AssetStatus','AssetStatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Aset Tetap';
        $this->data['form_sub_title'] = 'Input Aset';
        $this->data['form_desc'] = 'Input Aset Tetap';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_FA_Asset_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_Asset = '0';
            $this->data['fields']->IDX_M_Company = '';
            $this->data['fields']->IDX_M_Branch = '';
            $this->data['fields']->IDX_M_Department = '';
            $this->data['fields']->IDX_M_AssetCategory = '';
            $this->data['fields']->AssetCode = '';
            $this->data['fields']->AcquisitionDate = date('Y-m-d');
            $this->data['fields']->UsageStartDate = date('Y-m-d');
            $this->data['fields']->AcquisitionCost = '0';
            $this->data['fields']->ResidualValue = '0';
            $this->data['fields']->OpeningAccumDepr = '0';
            $this->data['fields']->DeprMethod = 'SL';
            $this->data['fields']->FiscalGroup = '';
            $this->data['fields']->FiscalDeprMethod = 'SL';
            $this->data['fields']->AssetStatus = 'D';
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        } else {

            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $access = TRUE;

        $this->data['form_title'] = 'Aset Tetap';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Aset Tetap';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_FA_Asset_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            return $this->show_form($id, 'update');
        }
        else
        {
            return $this->show_no_access();
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_company'] = (array) $dd->company();
        $this->data['dd_branch'] = (array) $dd->branch();
        $this->data['dd_department'] = (array) $dd->department();
        $this->data['dd_asset_category'] = (array) $dd->asset_category();
        $this->data['dd_depr_method'] = (array) $dd->depr_method();
        $this->data['dd_fiscal_group'] = (array) $dd->fiscal_group();
        $this->data['dd_asset_status'] = (array) $dd->asset_status();

        // URL
        $this->data['url_save_header'] = url('/ac-fa-asset/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW
        $this->data['view'] = 'accounting/fa_asset_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_FA_Asset_Create]';
        $this->sp_update = '[dbo].[USP_FA_Asset_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-fa-asset/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-fa-asset/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_Asset' => 'required',
            'IDX_M_Company' => 'required',
            'IDX_M_Branch' => 'required',
            'IDX_M_AssetCategory' => 'required',
            'AssetName' => 'required',
            'AcquisitionDate' => 'required|date',
            'UsageStartDate' => 'required|date',
            'AcquisitionCost' => 'required|numeric|min:0.01',
            'ResidualValue' => 'required|numeric|min:0',
            'UsefulLifeMonth' => 'required|numeric|min:1',
            'DeprMethod' => 'required',
            'AssetStatus' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_Asset'] = $data['IDX_M_Asset'];
            }

            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['IDX_M_Branch'] = $data['IDX_M_Branch'];
            $param['IDX_M_Department'] = ($data['IDX_M_Department'] != '') ? $data['IDX_M_Department'] : 0;
            $param['IDX_M_AssetCategory'] = $data['IDX_M_AssetCategory'];
            $param['AssetCode'] = 'XXX'.$data['AssetCode'];
            $param['AssetName'] = $data['AssetName'];
            $param['AssetDesc'] = $data['AssetDesc'];
            $param['AcquisitionDate'] = $data['AcquisitionDate'];
            $param['UsageStartDate'] = $data['UsageStartDate'];
            $param['AcquisitionCost'] = str_replace(',', '', $data['AcquisitionCost']);
            $param['ResidualValue'] = str_replace(',', '', $data['ResidualValue']);
            $param['UsefulLifeMonth'] = $data['UsefulLifeMonth'];
            $param['DeprMethod'] = $data['DeprMethod'];
            $param['FiscalGroup'] = $data['FiscalGroup'];
            $param['FiscalDeprMethod'] = $data['FiscalDeprMethod'];
            $param['IDX_T_PurchaseInvoice'] = 0;
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['AssetStatus'] = $data['AssetStatus'];
            $param['OpeningAccumDepr'] = str_replace(',', '', $data['OpeningAccumDepr']);

            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }
}
