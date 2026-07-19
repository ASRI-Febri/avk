<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class FADisposalController extends MyController
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
        $this->data['form_title'] = 'Pelepasan Aset';
        $this->data['form_remark'] = 'Pelepasan aset tetap: dijual, hapus buku, atau hibah (PSAK 16)';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Fixed Asset','Pelepasan Aset');

        // URL
        $this->data['url_create'] = url('ac-fa-disposal/create');
        $this->data['url_search'] = url('ac-fa-disposal-list');
        $this->data['url_cancel'] = url('ac-fa-disposal');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'Daftar Pelepasan';
        $this->data['form_desc'] = 'Daftar pelepasan aset tetap';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_T_AssetDisposal','IDX_M_Asset','Kode Aset','Nama Aset',
            'Tgl Pelepasan','DisposalType','Tipe','Harga Jual','Akum. Penyusutan','Nilai Buku','Laba/(Rugi)','No Jurnal');

        $this->data['table_footer'] = array('','','','AssetCode','AssetName',
            '','','','','','','','');

        $this->data['array_filter'] = array('SearchText','DisposalType');

        // DROPDOWN FILTER
        $dd = new DropdownController;
        $this->data['dd_disposal_type'] = (array) $dd->disposal_type();

        // VIEW
        $this->data['view'] = 'accounting/fa_disposal_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['SearchText'] = $request->input('SearchText');
        $array_filter['DisposalType'] = $request->input('DisposalType');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_FA_AssetDisposal_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_T_AssetDisposal','IDX_M_Asset','AssetCode','AssetName',
            'DisposalDate','DisposalType','DisposalTypeDesc','DisposalProceed','AccumDeprAtDisposal',
            'BookValueAtDisposal','GainLossAmount','JournalRef');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create($asset_id = 0)
    {
        $access = TRUE;

        $this->data['form_sub_title'] = 'Input Pelepasan';
        $this->data['form_desc'] = 'Input Pelepasan Aset';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_asset'] = (array) $dd->asset_active();
            $this->data['dd_disposal_type'] = (array) $dd->disposal_type();
            $this->data['dd_coa'] = (array) $dd->coa();

            // INFO ASET (bila dipanggil dari daftar aset)
            $this->data['asset_info'] = null;
            if ($asset_id > 0) {
                $this->sp_getdata = '[dbo].[USP_FA_Asset_Info]';
                $info = $this->get_detail_by_id($asset_id);
                if (!empty($info)) {
                    $this->data['asset_info'] = $info[0];
                }
            }

            $this->data['fields'] = (object) [
                'IDX_M_Asset' => $asset_id > 0 ? (string) $asset_id : '',
                'DisposalDate' => date('Y-m-d'),
                'DisposalType' => '',
                'DisposalProceed' => '0',
                'IDX_M_COA_Proceed' => '',
                'DisposalNotes' => '',
                'RecordStatus' => 'A',
            ];

            $this->data['url_save_header'] = url('/ac-fa-disposal/save');

            $this->data['view'] = 'accounting/fa_disposal_form';
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
        $this->sp_create = '[dbo].[USP_FA_AssetDisposal_Save]';
        $this->next_action = 'redirect';
        $this->next_url = url('/ac-fa-disposal');

        $validator = Validator::make($request->all(), [
            'IDX_M_Asset' => 'required',
            'DisposalDate' => 'required|date',
            'DisposalType' => 'required|in:S,W,H',
            'DisposalProceed' => 'required_if:DisposalType,S',
            'IDX_M_COA_Proceed' => 'required_if:DisposalType,S',
        ], [
            'IDX_M_Asset.required' => 'Aset belum dipilih!',
            'DisposalDate.required' => 'Tanggal pelepasan belum diisi!',
            'DisposalType.required' => 'Tipe pelepasan belum dipilih!',
            'DisposalProceed.required_if' => 'Harga jual belum diisi!',
            'IDX_M_COA_Proceed.required_if' => 'Akun penerima hasil penjualan belum dipilih!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $param['IDX_M_Asset'] = $data['IDX_M_Asset'];
            $param['DisposalDate'] = $data['DisposalDate'];
            $param['DisposalType'] = $data['DisposalType'];
            $param['DisposalProceed'] = str_replace(',', '', $data['DisposalProceed'] != '' ? $data['DisposalProceed'] : '0');
            $param['IDX_M_COA_Proceed'] = ($data['IDX_M_COA_Proceed'] != '') ? $data['IDX_M_COA_Proceed'] : 0;
            $param['DisposalNotes'] = $data['DisposalNotes'];
            $param['UserID'] = $this->data['user_id'];

            return $this->store('create', $param, 'custom');
        }
    }
}
