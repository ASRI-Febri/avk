<?php

namespace App\Http\Controllers\Finance;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Services\BankStatement\MandiriStatementParser;

use Validator;

class BankStatementController extends MyController
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
        $this->data['form_title'] = 'Rekening Koran';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_finance';
        $this->data['sidebar'] = 'navigation.sidebar_finance';

        // BREADCRUMB
        $this->data['breads'] = array('Finance', 'Transaction', 'Rekening Koran');

        // URL
        $this->data['url_create'] = url('fm-bank-statement/upload');
        $this->data['url_search'] = url('fm-bank-statement-list');
        $this->data['url_update'] = url('fm-bank-statement/update/');
        $this->data['url_cancel'] = url('fm-bank-statement');

        parent::__construct($request);
    }

    // =========================================================================================
    // DATATABLES
    // =========================================================================================
    public function inquiry(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-R';

        $access = $this->check_permission($this->data['user_id'], $this->data['form_id']);

        $this->data['form_sub_title'] = 'List';
        $this->data['form_desc'] = 'Daftar Rekening Koran';

        // BREADCRUMB
        array_push($this->data['breads'], 'List');

        if ($access == TRUE)
        {
            // TABLE HEADER & FOOTER
            $this->data['table_header'] = array('No', 'IDX_T_BankStatementHeader', 'No Rekening Koran', 'Financial Account', 'No Rekening',
                'Periode', 'Saldo Awal', 'Saldo Akhir', 'Sudah Dijurnal', 'Action');

            $this->data['table_footer'] = array('', '', 'StatementNo', 'FinancialAccount', 'AccountNo', 'PeriodStart', '', '', '', 'Action');

            $this->data['array_filter'] = array('StatementNo', 'FinancialAccount', 'AccountNo', 'Period');

            // VIEW
            $this->data['view'] = 'finance/bank_statement_list';
            return view($this->data['view'], $this->data);
        }
        else
        {
            return $this->show_no_access($this->data);
        }
    }

    public function inquiry_data(Request $request)
    {
        // FILTER FOR STORED PROCEDURE
        $array_filter['StatementNo'] = $request->input('StatementNo');
        $array_filter['FinancialAccount'] = $request->input('FinancialAccount');
        $array_filter['AccountNo'] = $request->input('AccountNo');
        $array_filter['Period'] = $request->input('Period');
        $array_filter['UserID'] = 'XXX'.$this->data['user_id'];

        // SET STORED PROCEDURE
        $this->sp_getinquiry = 'dbo.[USP_CM_BankStatement_List]';

        // ARRAY COLUMN AND FILTER FOR DATATABLES
        $this->array_filter = $array_filter;
        $this->array_column = array('RowNumber', 'IDX_T_BankStatementHeader', 'StatementNo', 'FinancialAccount', 'AccountNo',
            'PeriodStart', 'PeriodEnd', 'OpeningBalance', 'ClosingBalance', 'JournalCount', 'LineCount');

        return $this->get_datatables($request);
    }

    // =========================================================================================
    // UPLOAD & PREVIEW
    // =========================================================================================
    public function upload()
    {
        $this->data['form_id'] = 'FM-BS-C';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access($this->data);
        }

        return $this->show_upload_form('upload');
    }

    public function preview(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-C';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access($this->data);
        }

        $validator = Validator::make($request->all(), [
            'file_statement' => 'required|file|mimes:pdf|max:20480',
        ], [
            'file_statement.required' => 'File rekening koran belum dipilih!',
            'file_statement.mimes' => 'File rekening koran harus berformat PDF.',
        ]);

        if ($validator->fails())
        {
            $this->data['error'] = implode(' ', $validator->errors()->all());
            return $this->show_upload_form('upload');
        }

        $file = $request->file('file_statement');

        try
        {
            $statement = (new MandiriStatementParser())->parseFile($file->getRealPath());
        }
        catch (\Exception $e)
        {
            $this->data['error'] = 'PDF tidak dapat dibaca: ' . $e->getMessage();
            return $this->show_upload_form('upload');
        }

        // Simpan file asli sebagai arsip; dipindah ke nama unik supaya upload ulang tidak menimpa.
        $stored_name = date('YmdHis') . '_' . preg_replace('/[^A-Za-z0-9._-]/', '_', $file->getClientOriginalName());
        $file->move(storage_path('app/bank-statement'), $stored_name);

        $statement['file_name'] = $stored_name;
        session(['bank_statement_upload' => $statement]);

        // FINANCIAL ACCOUNT DENGAN NOMOR REKENING YANG SAMA DIPILIH OTOMATIS
        $account = DB::connection('sqlsrv')->select(
            "SELECT TOP 1 IDX_M_FinancialAccount FROM CM_M_FinancialAccount WITH(NOLOCK)
             WHERE RecordStatus = 'A' AND REPLACE(REPLACE(AccountNo, '-', ''), ' ', '') = ?",
            [preg_replace('/\D/', '', $statement['header']['account_no'])]
        );
        $this->data['IDX_M_FinancialAccount'] = $account ? $account[0]->IDX_M_FinancialAccount : '';
        $this->data['statement'] = $statement;

        return $this->show_upload_form('preview');
    }

    function show_upload_form($state)
    {
        $this->data['form_sub_title'] = 'Upload Rekening Koran';
        $this->data['form_desc'] = 'Upload Rekening Koran';
        $this->data['form_remark'] = 'Upload PDF rekening koran bank';
        $this->data['upload_info'] = 'Upload PDF Account Statement dari Kopra by Mandiri. Sistem menampilkan isi rekening koran'
            . ' untuk diperiksa sebelum disimpan. Baris biaya admin ditandai otomatis dan masih bisa dikoreksi.';
        $this->data['state'] = $state;

        array_push($this->data['breads'], 'Upload');

        $dd = new DropdownController;
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);

        $this->data['view'] = 'finance/bank_statement_upload';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE UPLOAD
    // =========================================================================================
    public function save(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-C';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access($this->data);
        }

        $statement = session('bank_statement_upload');

        $validator = Validator::make($request->all(), [
            'IDX_M_FinancialAccount' => 'required',
        ], [
            'IDX_M_FinancialAccount.required' => 'Financial Account belum dipilih!',
        ]);

        if (!$statement || $validator->fails())
        {
            $this->data['error'] = $statement ? implode(' ', $validator->errors()->all()) : 'Data upload sudah kedaluwarsa, silakan upload ulang.';
            if ($statement)
            {
                $this->data['statement'] = $statement;
                $this->data['IDX_M_FinancialAccount'] = '';
                return $this->show_upload_form('preview');
            }
            return $this->show_upload_form('upload');
        }

        $admin_fee = array_flip((array) $request->input('admin_fee', []));

        $xml = '<rows>';
        foreach ($statement['rows'] as $row)
        {
            $xml .= sprintf('<r s="%d" d="%s" m="%s" f="%s" db="%s" cr="%s" b="%s" a="%d"/>',
                $row['seq'],
                str_replace(' ', 'T', $row['posting_date']),
                $this->xml_attr($row['remark']),
                $this->xml_attr($row['reference_no']),
                $row['debit'],
                $row['credit'],
                $row['balance'],
                isset($admin_fee[$row['seq']]) && $row['debit'] > 0 ? 1 : 0);
        }
        $xml .= '</rows>';

        $header = $statement['header'];

        $param['IDX_M_FinancialAccount'] = $request->input('IDX_M_FinancialAccount');
        $param['BankName'] = 'XXXMandiri';
        $param['AccountNo'] = 'XXX'.$this->esc($header['account_no']);
        $param['AccountName'] = 'XXX'.$this->esc($header['account_name']);
        $param['CurrencyID'] = 'XXX'.$this->esc($header['currency']);
        $param['PeriodStart'] = $header['period_start'];
        $param['PeriodEnd'] = $header['period_end'];
        $param['OpeningBalance'] = $header['opening_balance'];
        $param['ClosingBalance'] = $header['closing_balance'];
        $param['TotalDebit'] = $header['total_debit'];
        $param['TotalCredit'] = $header['total_credit'];
        $param['FileName'] = 'XXX'.$this->esc($statement['file_name']);
        $param['Notes'] = 'XXX'.$this->esc((string) $request->input('Notes'));
        $param['DetailXml'] = 'XXX'.$xml;
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_CM_BankStatement_Save', $param, 'list', 'sqlsrv');
        $result = $result ? end($result) : null;

        if ($result && strtolower($result->Result) == 'success')
        {
            session()->forget('bank_statement_upload');
            session()->flash('bank_statement_message', $result->LogDesc);

            return redirect(url('fm-bank-statement/update/'.$result->ID));
        }

        $this->data['error'] = $result ? $result->LogDesc : 'Rekening koran gagal disimpan.';
        $this->data['statement'] = $statement;
        $this->data['IDX_M_FinancialAccount'] = $request->input('IDX_M_FinancialAccount');

        return $this->show_upload_form('preview');
    }

    // =========================================================================================
    // DETAIL
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_id'] = 'FM-BS-R';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access($this->data);
        }

        $this->data['form_sub_title'] = 'Detail Rekening Koran';
        $this->data['form_desc'] = 'Detail Rekening Koran';
        $this->data['form_remark'] = 'Buat jurnal dari baris rekening koran';
        array_push($this->data['breads'], 'Detail');

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($id);
        if (!$fields || $fields[0]->RecordStatus != 'A')
        {
            return redirect($this->data['url_cancel']);
        }
        $this->data['fields'] = $fields[0];

        $param['IDX_T_BankStatementHeader'] = $id;
        $this->data['records_detail'] = $this->exec_sp('USP_CM_BankStatementDetail_List', $param, 'list', 'sqlsrv');

        $this->data['can_journal'] = $this->check_permission($this->data['user_id'], 'FM-BS-J');
        $this->data['can_delete'] = $this->check_permission($this->data['user_id'], 'FM-BS-D');
        $this->data['message'] = session('bank_statement_message');

        $this->data['view'] = 'finance/bank_statement_form';
        return view($this->data['view'], $this->data);
    }

    public function download($id)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-R'))
        {
            return $this->show_no_access($this->data);
        }

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($id);
        $path = $fields ? storage_path('app/bank-statement/'.basename($fields[0]->FileName)) : '';

        if (!$path || !is_file($path))
        {
            abort(404);
        }

        return response()->file($path);
    }

    // =========================================================================================
    // JURNAL PER BARIS
    // =========================================================================================
    public function journal(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-J';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['form_desc'] = 'Buat Jurnal dari Rekening Koran';
        $this->data['state'] = 'approve';

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $this->data['fields'] = $this->get_detail_by_id($request->input('IDX_T_BankStatementHeader'))[0];

        $selected = array_flip((array) $request->input('IDX_T_BankStatementDetail', []));
        $param['IDX_T_BankStatementHeader'] = $request->input('IDX_T_BankStatementHeader');
        $this->data['records_detail'] = array_values(array_filter(
            $this->exec_sp('USP_CM_BankStatementDetail_List', $param, 'list', 'sqlsrv'),
            function ($row) use ($selected) {
                return isset($selected[$row->IDX_T_BankStatementDetail]) && !$row->IDX_T_JournalHeader;
            }
        ));

        $this->data['url_save_modal'] = url('fm-bank-statement/save-journal');
        $this->data['submit_title'] = 'Buat Jurnal';
        $this->data['show_save'] = count($this->data['records_detail']) > 0;

        $this->data['view'] = 'finance/bank_statement_journal_form';
        return view($this->data['view'], $this->data);
    }

    public function save_journal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_BankStatementHeader' => 'required',
            'rows' => 'required|array',
        ], [
            'rows.required' => 'Pilih minimal satu baris rekening koran.',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_BankStatementHeader'));
        }

        $xml = '<rows>';
        foreach ($request->input('rows') as $detail_id => $row)
        {
            $xml .= sprintf('<r id="%d" coa="%d" m="%s"/>', $detail_id, $row['coa'] ?? 0, $this->xml_attr($row['remark'] ?? ''));
        }
        $xml .= '</rows>';

        $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateJournal]';
        $this->next_action = 'reload';
        $this->next_url = url('fm-bank-statement/update');

        $param['IDX_T_BankStatementHeader'] = $request->input('IDX_T_BankStatementHeader');
        $param['RowsXml'] = 'XXX'.$xml;
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        return $this->store('approve', $param);
    }

    // =========================================================================================
    // JURNAL GABUNGAN BIAYA ADMIN
    // =========================================================================================
    public function admin_fee(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-J';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['form_desc'] = 'Jurnal Biaya Admin Bank';
        $this->data['state'] = 'approve';

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($request->input('IDX_T_BankStatementHeader'))[0];

        // DEFAULT: COA "Biaya Admin Bank", TANGGAL AKHIR PERIODE
        $coa = DB::connection('sqlsrv')->select(
            "SELECT TOP 1 IDX_M_COA, RTRIM(COAID) + ' - ' + RTRIM(COADesc) AS COAName FROM GL_M_COA WITH(NOLOCK)
             WHERE RecordStatus = 'A' AND AllowJournalEntry = 'Y' AND COADesc LIKE '%Biaya Admin%Bank%'
             ORDER BY COAID"
        );
        $fields->IDX_M_COA = $coa ? $coa[0]->IDX_M_COA : '';
        $fields->COAName = $coa ? $coa[0]->COAName : '';
        $fields->JournalDate = $fields->PeriodEnd;
        $fields->JournalRemark = 'Biaya admin bank ' . $fields->FinancialAccount . ' periode '
            . date('d/m/Y', strtotime($fields->PeriodStart)) . ' - ' . date('d/m/Y', strtotime($fields->PeriodEnd));

        $this->data['fields'] = $fields;
        $this->data['url_save_modal'] = url('fm-bank-statement/save-admin-fee');
        $this->data['show_save'] = $fields->AdminFeeCount > 0;

        $this->data['view'] = 'finance/bank_statement_admin_fee_form';
        return view($this->data['view'], $this->data);
    }

    public function save_admin_fee(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_BankStatementHeader' => 'required',
            'IDX_M_COA' => 'required',
            'JournalDate' => 'required|date',
            'JournalRemark' => 'required',
        ], [
            'IDX_M_COA.required' => 'Chart of Account belum dipilih!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_BankStatementHeader'));
        }

        $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateAdminFeeJournal]';
        $this->next_action = 'reload';
        $this->next_url = url('fm-bank-statement/update');

        $param['IDX_T_BankStatementHeader'] = $request->input('IDX_T_BankStatementHeader');
        $param['IDX_M_COA'] = $request->input('IDX_M_COA');
        $param['JournalDate'] = date('Y-m-d', strtotime($request->input('JournalDate')));
        $param['JournalRemark'] = 'XXX'.$this->esc($request->input('JournalRemark'));
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        return $this->store('approve', $param);
    }

    // =========================================================================================
    // TANDA BIAYA ADMIN & HAPUS
    // =========================================================================================
    public function set_admin_fee(Request $request)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-J'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $param['IDX_T_BankStatementDetail'] = (int) $request->input('IDX_T_BankStatementDetail');
        $param['IsAdminFee'] = $request->input('IsAdminFee') ? 1 : 0;
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_CM_BankStatementDetail_SetAdminFee', $param, 'list', 'sqlsrv');
        $result = end($result);

        return response()->json(['flag' => $result->Result, 'message' => $result->LogDesc]);
    }

    public function delete(Request $request)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-D'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $param['IDX_T_BankStatementHeader'] = (int) $request->input('IDX_T_BankStatementHeader');
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_CM_BankStatement_Delete', $param, 'list', 'sqlsrv');
        $result = end($result);

        return response()->json(['flag' => $result->Result, 'message' => $result->LogDesc, 'url' => $this->data['url_cancel']]);
    }

    // exec_sp menyusun EXEC dengan literal string tanpa escape.
    private function esc($value)
    {
        return str_replace("'", "''", $value);
    }

    // ENT_QUOTES mengubah ' menjadi &apos; sehingga hasilnya aman sebagai literal SQL.
    private function xml_attr($value)
    {
        return htmlspecialchars($value, ENT_QUOTES | ENT_XML1, 'UTF-8');
    }
}
