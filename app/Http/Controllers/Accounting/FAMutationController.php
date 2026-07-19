<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class FAMutationController extends MyController
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
        $this->data['form_title'] = 'Mutasi Aset';
        $this->data['form_remark'] = 'Mutasi aset tetap antar cabang / departemen';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Fixed Asset','Mutasi Aset');

        // URL
        $this->data['url_create'] = url('ac-fa-mutation/create');
        $this->data['url_search'] = url('ac-fa-mutation-list');
        $this->data['url_cancel'] = url('ac-fa-mutation');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'Riwayat Mutasi';
        $this->data['form_desc'] = 'Riwayat mutasi aset tetap';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_T_AssetMutation','IDX_M_Asset','Kode Aset','Nama Aset',
            'Tgl Mutasi','Cabang Asal','Cabang Tujuan','Dept Asal','Dept Tujuan','Keterangan','User');

        $this->data['table_footer'] = array('','','','AssetCode','AssetName',
            '','','','','','','');

        $this->data['array_filter'] = array('SearchText');

        // VIEW
        $this->data['view'] = 'accounting/fa_mutation_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['SearchText'] = $request->input('SearchText');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_FA_AssetMutation_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_AssetMutation','IDX_M_Asset','AssetCode','AssetName',
            'MutationDate','BranchFrom','BranchTo','DeptFrom','DeptTo','MutationNotes','UCreate');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create($asset_id = 0)
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Input Mutasi';
        $this->data['form_desc'] = 'Input Mutasi Aset';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_asset'] = (array) $dd->asset_active();
            $this->data['dd_branch'] = (array) $dd->branch();
            $this->data['dd_department'] = (array) $dd->department();

            $this->data['fields'] = (object) [
                'IDX_M_Asset' => $asset_id > 0 ? (string) $asset_id : '',
                'MutationDate' => date('Y-m-d'),
                'IDX_M_Branch_To' => '',
                'IDX_M_Department_To' => '',
                'MutationNotes' => '',
                'RecordStatus' => 'A',
            ];

            $this->data['url_save_header'] = url('/ac-fa-mutation/save');

            $this->data['view'] = 'accounting/fa_mutation_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_FA_AssetMutation_Save]';
        $this->next_action = 'redirect';
        $this->next_url = url('/ac-fa-mutation');

        $validator = Validator::make($request->all(), [
            'IDX_M_Asset' => 'required',
            'MutationDate' => 'required|date',
            'IDX_M_Branch_To' => 'required',
        ], [
            'IDX_M_Asset.required' => 'Aset belum dipilih!',
            'MutationDate.required' => 'Tanggal mutasi belum diisi!',
            'IDX_M_Branch_To.required' => 'Cabang tujuan belum dipilih!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $param['IDX_M_Asset'] = $data['IDX_M_Asset'];
            $param['MutationDate'] = $data['MutationDate'];
            $param['IDX_M_Branch_To'] = $data['IDX_M_Branch_To'];
            $param['IDX_M_Department_To'] = ($data['IDX_M_Department_To'] != '') ? $data['IDX_M_Department_To'] : 0;
            $param['MutationNotes'] = $data['MutationNotes'];
            $param['UserID'] = $this->data['user_id'];

            return $this->store('create', $param, 'custom');
        }
    }
}
