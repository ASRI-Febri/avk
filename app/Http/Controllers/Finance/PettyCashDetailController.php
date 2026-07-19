<?php

namespace App\Http\Controllers\Finance;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;
use PDF;
use App\File;
use Image;

class PettyCashDetailController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo']  = url('public/images/logo/finance.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'Finance';
        $this->data['form_title'] = 'Petty Cash Detail';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';
        $this->data['sidebar'] = 'navigation.sidebar_finance';

        // BREADCRUMB
        $this->data['breads'] = array('Finance', 'Transaction', 'Petty Cash Detail');

        // URL
        $this->data['url_cancel'] = url('fm-petty-cash-detail');

        parent::__construct($request);
    }

    // RELOAD TABLE
    public function reload($id)
    {
        $param['IDX_T_PettyCashHeader'] = $id;

        $this->data['records_detail'] = $this->exec_sp('USP_CM_PettyCashDetail_List', $param, 'list', 'sqlsrv');

        return view('finance/petty_cash_detail_list', $this->data);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create(Request $request)
    {
        $this->data['form_id'] = 'FM-PCD-C';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Petty Cash Detail';
        $this->data['form_sub_title'] = 'Create Petty Cash Detail';
        $this->data['form_desc'] = 'Create Petty Cash Detail';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_CM_PettyCashDetail_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_T_PettyCashDetail = '0';
            $this->data['fields']->IDX_T_PettyCashHeader = $request->IDX_T_PettyCashHeader;
            $this->data['fields']->TransactionDate = date('Y-m-d');
            $this->data['fields']->RecordStatus = 'A';

            return $this->show_form(0, 'create');
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-PCD-U';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_title'] = 'Petty Cash Detail';
        $this->data['form_sub_title'] = 'Update Petty Cash Detail';
        $this->data['form_desc'] = 'Update Petty Cash Detail';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_CM_PettyCashDetail_Info]';
            $this->data['fields'] = $this->get_detail_by_id($id)[0];

            // DEFAULT VALUE & FORMAT
            $this->data['fields']->PettyCashAmount = number_format($this->data['fields']->PettyCashAmount, 0, '.', ',');

            return $this->show_form($id, 'update');
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    function show_form($id, $state)
    {
        // DROPDOWN
        $dd = new DropdownController;
        $this->data['dd_document_type'] = (array) $dd->document_type();

        // DEFAULT DOCUMENT TYPE ON CREATE (Petty Cash)
        if($state === 'create')
        {
            foreach($this->data['dd_document_type'] as $idx => $label)
            {
                if($idx !== '' && strcasecmp(trim($label), 'Petty Cash') === 0)
                {
                    $this->data['fields']->IDX_M_DocumentType = $idx;
                    break;
                }
            }
        }

        // URL
        $this->data['url_save_modal'] = url('/fm-petty-cash-detail/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW
        $this->data['form_remark'] = 'Petty Cash Detail';
        $this->data['view'] = 'finance/petty_cash_detail_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_CM_PettyCashDetail_Create]';
        $this->sp_update = '[dbo].[USP_CM_PettyCashDetail_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-petty-cash-detail/reload');

        $validator = Validator::make($request->all(), [
            'IDX_T_PettyCashDetail' => 'required',
            'IDX_T_PettyCashHeader' => 'required',
            'IDX_M_COA' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PettyCashDetail'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            if($state == 'update'){
                $param['IDX_T_PettyCashDetail'] = $data['IDX_T_PettyCashDetail'];
            }

            $param['IDX_T_PettyCashHeader'] = $data['IDX_T_PettyCashHeader'];
            $param['IDX_M_DocumentType'] = $data['IDX_M_DocumentType'];
            $param['IDX_M_COA'] = $data['IDX_M_COA'];
            $param['IDX_M_Partner'] = 0;
            $param['IDX_Reference'] = 0;
            $param['ReferenceNo'] = $data['ReferenceNo'];
            $param['TransactionDate'] = $data['TransactionDate'];
            $param['PartnerName'] = $data['PartnerName'];
            $param['DetailDesc'] = $data['DetailDesc'];

            $param['PettyCashAmount'] = (double) str_replace(',', '', $data['PettyCashAmount']);

            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }

    // =========================================================================================
    // DELETE
    // =========================================================================================
    public function delete(Request $request)
    {
        $this->data['form_id'] = 'FM-PCD-D';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id'], 'R');

        $this->data['form_desc'] = 'Delete Data';

        if ($access == TRUE)
        {
            $this->data['item_index'] = $request->IDX_T_PettyCashDetail;
            $this->data['item_description'] = $request->DetailDesc;

            $this->data['state'] = 'delete';

            // URL SAVE
            $this->data['url_save_modal'] = url('fm-petty-cash-detail/save-delete');

            return view('finance/petty_cash_detail_delete', $this->data);
        }
        else
        {
            return $this->show_no_access_modal($this->data);
        }
    }

    public function save_delete(Request $request)
    {
        $this->sp_delete = '[dbo].[USP_CM_PettyCashDetail_Delete]';
        $this->next_action = 'reload';
        $this->next_url = url('/fm-petty-cash-detail/reload');

        $validator = Validator::make($request->all(), [
            'item_index' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('item_index'));
        } else {

            $data = $request->all();

            $state = 'delete';

            $param['IDX_T_PettyCashDetail'] = $data['item_index'];

            return $this->store($state, $param);
        }
    }
}
