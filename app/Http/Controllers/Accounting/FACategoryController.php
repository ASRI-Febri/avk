<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class FACategoryController extends MyController
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
        $this->data['form_title'] = 'Kategori Aset';
        $this->data['form_remark'] = 'Kategori aset tetap dan mapping akun (PSAK 16)';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Setting','Kategori Aset');

        // URL
        $this->data['url_create'] = url('ac-fa-category/create');
        $this->data['url_search'] = url('ac-fa-category-list');
        $this->data['url_update'] = url('ac-fa-category/update/');
        $this->data['url_cancel'] = url('ac-fa-category');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Kategori Aset List';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_AssetCategory','Kode','Nama Kategori','Akun Aset',
            'Akun Akumulasi','Akun Beban','Umur (Bulan)','Metode','Kelompok Fiskal','RecordStatus','Status','Action');

        $this->data['table_footer'] = array('','','CategoryCode','CategoryName','COAAsset',
            'COAAccumDepr','COADeprExpense','','','','','','Action');

        $this->data['array_filter'] = array('CategoryCode','CategoryName');

        // VIEW
        $this->data['view'] = 'accounting/fa_category_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['CategoryCode'] = $request->input('CategoryCode');
        $array_filter['CategoryName'] = $request->input('CategoryName');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_FA_AssetCategory_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_AssetCategory','CategoryCode','CategoryName','COAAsset',
            'COAAccumDepr','COADeprExpense','DefaultUsefulLifeMonth','DeprMethodDesc','FiscalGroupDesc','RecordStatus','StatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Kategori Aset';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Kategori Aset';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_FA_AssetCategory_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_AssetCategory = '0';
            $this->data['fields']->IDX_M_Company = '';
            $this->data['fields']->IDX_M_COA_Asset = '';
            $this->data['fields']->IDX_M_COA_AccumDepr = '';
            $this->data['fields']->IDX_M_COA_DeprExpense = '';
            $this->data['fields']->IDX_M_COA_GainDisposal = '';
            $this->data['fields']->IDX_M_COA_LossDisposal = '';
            $this->data['fields']->DefaultDeprMethod = 'SL';
            $this->data['fields']->FiscalGroup = '';
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

        $this->data['form_title'] = 'Kategori Aset';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Kategori Aset';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_FA_AssetCategory_Info]';
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
        $this->data['dd_coa'] = (array) $dd->coa();
        $this->data['dd_depr_method'] = (array) $dd->depr_method();
        $this->data['dd_fiscal_group'] = (array) $dd->fiscal_group();

        // URL
        $this->data['url_save_header'] = url('/ac-fa-category/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW
        $this->data['view'] = 'accounting/fa_category_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_FA_AssetCategory_Create]';
        $this->sp_update = '[dbo].[USP_FA_AssetCategory_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-fa-category/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-fa-category/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_AssetCategory' => 'required',
            'IDX_M_Company' => 'required',
            'CategoryCode' => 'required',
            'CategoryName' => 'required',
            'IDX_M_COA_Asset' => 'required',
            'IDX_M_COA_AccumDepr' => 'required',
            'IDX_M_COA_DeprExpense' => 'required',
            'DefaultUsefulLifeMonth' => 'required|numeric|min:1',
            'DefaultDeprMethod' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_AssetCategory'] = $data['IDX_M_AssetCategory'];
            }

            $param['IDX_M_Company'] = $data['IDX_M_Company'];
            $param['CategoryCode'] = $data['CategoryCode'];
            $param['CategoryName'] = $data['CategoryName'];
            $param['IDX_M_COA_Asset'] = $data['IDX_M_COA_Asset'];
            $param['IDX_M_COA_AccumDepr'] = $data['IDX_M_COA_AccumDepr'];
            $param['IDX_M_COA_DeprExpense'] = $data['IDX_M_COA_DeprExpense'];
            $param['IDX_M_COA_GainDisposal'] = ($data['IDX_M_COA_GainDisposal'] != '') ? $data['IDX_M_COA_GainDisposal'] : 0;
            $param['IDX_M_COA_LossDisposal'] = ($data['IDX_M_COA_LossDisposal'] != '') ? $data['IDX_M_COA_LossDisposal'] : 0;
            $param['DefaultUsefulLifeMonth'] = $data['DefaultUsefulLifeMonth'];
            $param['DefaultDeprMethod'] = $data['DefaultDeprMethod'];
            $param['FiscalGroup'] = $data['FiscalGroup'];

            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }
}
