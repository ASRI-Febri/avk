<?php

namespace App\Http\Controllers\Accounting;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class JournalTypeController extends MyController
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
        $this->data['form_title'] = 'Journal Type';
        $this->data['form_remark'] = 'Jenis jurnal untuk pengelompokan transaksi di General Ledger';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_accounting';
        $this->data['sidebar'] = 'navigation.sidebar_accounting';

        // BREADCRUMB
        $this->data['breads'] = array('Accounting','Setting','Journal Type');

        // URL
        $this->data['url_create'] = url('ac-journal-type/create');
        $this->data['url_search'] = url('ac-journal-type-list');
        $this->data['url_update'] = url('ac-journal-type/update/');
        $this->data['url_cancel'] = url('ac-journal-type');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Journal Type List';

        // BREADCRUMB
        array_push($this->data['breads'],'List');

        // TABLE HEADER & FOOTER
        $this->data['table_header'] = array('No','IDX_M_JournalType','Journal Type ID','Description',
            'AllowJournalEntry','Allow Journal Entry','Label','RecordStatus','Status','Action');

        $this->data['table_footer'] = array('','','JournalTypeID','JournalTypeDesc',
            '','','','','','Action');

        $this->data['array_filter'] = array('JournalTypeID','JournalTypeDesc');

        // VIEW
        $this->data['view'] = 'accounting/journal_type_list';
        return view($this->data['view'], $this->data);
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['JournalTypeID'] = $request->input('JournalTypeID');
        $array_filter['JournalTypeDesc'] = $request->input('JournalTypeDesc');

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_GL_JournalType_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber','IDX_M_JournalType','JournalTypeID','JournalTypeDesc',
            'AllowJournalEntry','AllowJournalEntryDesc','JournalLabel','RecordStatus','StatusDesc');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $access = TRUE;

        $this->data['form_title'] = 'Journal Type';
        $this->data['form_sub_title'] = 'Create';
        $this->data['form_desc'] = 'Create Journal Type';
        $this->data['state'] = 'create';

        // BREADCRUMB
        array_push($this->data['breads'], 'Create');

        if ($access == TRUE) {

            $this->sp_getdata = '[dbo].[USP_GL_JournalType_Info]';
            $this->data['fields'] = (object) $this->get_detail_by_id(0);

            // SET DEFAULT VALUE
            $this->data['fields']->IDX_M_JournalType = '0';
            $this->data['fields']->AllowJournalEntry = 'N';
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

        $this->data['form_title'] = 'Journal Type';
        $this->data['form_sub_title'] = 'Update';
        $this->data['form_desc'] = 'Update Journal Type';
        $this->data['state'] = 'update';

        // BREADCRUMB
        array_push($this->data['breads'], 'Update');

        if ($access == TRUE)
        {
            $this->sp_getdata = '[dbo].[USP_GL_JournalType_Info]';
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
        $this->data['dd_yes_no'] = (array) $dd->yes_no();

        // URL
        $this->data['url_save_header'] = url('/ac-journal-type/save');

        // BUTTON SAVE
        $this->data['button_save_status'] = '';
        $this->data['button_change_status'] = '';

        // VIEW
        $this->data['view'] = 'accounting/journal_type_form';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE DATA
    // =========================================================================================
    public function save(Request $request)
    {
        $this->sp_create = '[dbo].[USP_GL_JournalType_Create]';
        $this->sp_update = '[dbo].[USP_GL_JournalType_Update]';
        $this->next_action = 'reload';
        $this->next_url = url('/ac-journal-type/update');

        if(isset($_POST['add-new-after-save']))
        {
            $this->next_url = url('/ac-journal-type/create');
        }

        $validator = Validator::make($request->all(), [
            'IDX_M_JournalType' => 'required',
            'JournalTypeID' => 'required',
            'JournalTypeDesc' => 'required',
            'AllowJournalEntry' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('FormID'));
        } else {

            $data = $request->all();

            $state = $data['state'];

            if($state == 'update')
            {
                $param['IDX_M_JournalType'] = $data['IDX_M_JournalType'];
            }

            $param['JournalTypeID'] = 'XXX'.$data['JournalTypeID'];
            $param['JournalTypeDesc'] = $data['JournalTypeDesc'];
            $param['AllowJournalEntry'] = $data['AllowJournalEntry'];
            $param['JournalLabel'] = $data['JournalLabel'];

            $param['UserID'] = $this->data['user_id'];
            $param['RecordStatus'] = 'A';

            return $this->store($state, $param);
        }
    }
}
