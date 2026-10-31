<?php

namespace App\Http\Controllers\Finance;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Services\BankStatement\LedgerReconciler;
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
        $this->data['month_end_count'] = count($this->exec_sp('USP_CM_BankStatement_MonthEndRows', $param, 'list', 'sqlsrv'));

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
    // REKONSILIASI DENGAN LEDGER BANK
    // =========================================================================================
    public function reconcile($id)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-R'))
        {
            return $this->show_no_access($this->data);
        }

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($id);
        if (!$fields || $fields[0]->RecordStatus != 'A')
        {
            return redirect($this->data['url_cancel']);
        }

        $param['IDX_T_BankStatementHeader'] = $id;

        $bank = array_map(function ($row) {
            return [
                'id'         => $row->IDX_T_BankStatementDetail,
                'seq'        => $row->SeqNo,
                'date'       => substr($row->PostingDate, 0, 10),
                'datetime'   => $row->PostingDate,
                'remark'     => $row->Remark,
                'in'         => (float) $row->CreditAmount,
                'out'        => (float) $row->DebitAmount,
                'journal_id' => $row->IDX_T_JournalHeader,
            ];
        }, $this->exec_sp('USP_CM_BankStatementDetail_List', $param, 'list', 'sqlsrv'));

        $ledger = array_map(function ($row) {
            return [
                'id'         => $row->IDX_T_JournalDetail,
                'journal_id' => $row->IDX_T_JournalHeader,
                'voucher'    => $row->VoucherNo,
                'date'       => $row->JournalDate,
                'remark'     => $row->Remark,
                'partner'    => $row->PartnerDesc,
                'in'         => (float) $row->BDebetAmount,
                'out'        => (float) $row->BCreditAmount,
                'posted'     => $row->PostingStatus == 'P',
                'in_period'  => (bool) $row->InPeriod,
            ];
        }, $this->exec_sp('USP_CM_BankStatement_LedgerLines', $param, 'list', 'sqlsrv'));

        $balance = $this->exec_sp('USP_CM_BankStatement_LedgerBalance', $param, 'list', 'sqlsrv');

        $adjustments = [];
        foreach ($this->exec_sp('USP_CM_BankStatement_AdjustmentLinks', $param, 'list', 'sqlsrv') as $link)
        {
            $adjustments[$link->IDX_T_JournalHeader][$link->SourceType == 'B' ? 'bank' : 'ledger'][] = $link->SourceID;
        }

        $matches = [];
        foreach ($this->exec_sp('USP_CM_BankStatement_MatchLinks', $param, 'list', 'sqlsrv') as $link)
        {
            $matches[$link->IDX_T_BankStatementMatch][$link->SourceType == 'B' ? 'bank' : 'ledger'][] = $link->SourceID;
        }

        $this->data['fields'] = $fields[0];
        $this->data['balance'] = $balance[0];
        $this->data['result'] = (new LedgerReconciler())->reconcile($bank, $ledger, $adjustments, $matches);
        $this->data['can_journal'] = $this->check_permission($this->data['user_id'], 'FM-BS-J');
        $this->data['form_title'] = 'Rekonsiliasi ' . $fields[0]->StatementNo;

        $this->data['view'] = 'finance/bank_statement_reconcile';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // JURNAL PENYESUAIAN DARI REKONSILIASI
    // =========================================================================================
    public function adjustment(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-J';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['form_desc'] = 'Jurnal Penyesuaian Rekonsiliasi';
        $this->data['state'] = 'approve';

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($request->input('IDX_T_BankStatementHeader'))[0];

        $param['IDX_T_BankStatementHeader'] = $fields->IDX_T_BankStatementHeader;
        $bank_ids = array_flip((array) $request->input('bank', []));
        $ledger_ids = array_flip((array) $request->input('ledger', []));

        $this->data['records_bank'] = array_values(array_filter(
            $this->exec_sp('USP_CM_BankStatementDetail_List', $param, 'list', 'sqlsrv'),
            function ($row) use ($bank_ids) { return isset($bank_ids[$row->IDX_T_BankStatementDetail]); }
        ));
        $this->data['records_ledger'] = array_values(array_filter(
            $this->exec_sp('USP_CM_BankStatement_LedgerLines', $param, 'list', 'sqlsrv'),
            function ($row) use ($ledger_ids) { return isset($ledger_ids[$row->IDX_T_JournalDetail]); }
        ));

        // SELISIH = MUTASI BANK - MUTASI LEDGER; POSITIF BERARTI BANK PERLU DIDEBIT
        $difference = 0;
        $dates = [];
        $remarks = [];
        foreach ($this->data['records_bank'] as $row)
        {
            $difference += $row->CreditAmount - $row->DebitAmount;
            $dates[] = substr($row->PostingDate, 0, 10);
            $remarks[] = $row->Remark;
        }
        foreach ($this->data['records_ledger'] as $row)
        {
            $difference -= $row->BDebetAmount - $row->BCreditAmount;
            $dates[] = $row->JournalDate;
            $remarks[] = $row->VoucherNo;
        }

        $fields->Difference = round($difference, 2);
        $fields->JournalDate = $dates ? max($dates) : $fields->PeriodEnd;
        $fields->JournalRemark = 'Penyesuaian rekonsiliasi ' . implode(' / ', array_unique(array_filter($remarks)));

        $this->data['fields'] = $fields;
        $this->data['url_save_modal'] = url('fm-bank-statement/save-adjustment');
        $this->data['show_save'] = count($this->data['records_bank']) + count($this->data['records_ledger']) > 0;

        $this->data['view'] = 'finance/bank_statement_adjustment_form';
        return view($this->data['view'], $this->data);
    }

    public function save_adjustment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_BankStatementHeader' => 'required',
            'JournalDate' => 'required|date',
            'JournalRemark' => 'required',
            'lines' => 'required|array',
            'lines.*.coa' => 'required',
            'lines.*.amount' => 'required',
            'lines.*.side' => 'required|in:D,C',
        ], [
            'lines.required' => 'Isi minimal satu baris jurnal.',
            'lines.*.coa.required' => 'Chart of Account belum dipilih!',
            'lines.*.amount.required' => 'Nilai baris jurnal belum diisi!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_BankStatementHeader'));
        }

        $sources = '<rows>';
        foreach ((array) $request->input('bank', []) as $id)
        {
            $sources .= sprintf('<r t="B" id="%d"/>', $id);
        }
        foreach ((array) $request->input('ledger', []) as $id)
        {
            $sources .= sprintf('<r t="L" id="%d"/>', $id);
        }
        $sources .= '</rows>';

        $lines = '<lines>';
        foreach ($request->input('lines') as $line)
        {
            $amount = round((float) str_replace(',', '', $line['amount']), 2);
            $lines .= sprintf('<l coa="%d" d="%.2f" c="%.2f" m="%s"/>', $line['coa'],
                $line['side'] == 'D' ? $amount : 0, $line['side'] == 'C' ? $amount : 0, $this->xml_attr($line['remark'] ?? ''));
        }
        $lines .= '</lines>';

        $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateAdjustmentJournal]';
        $this->next_action = 'reload';
        $this->next_url = url('fm-bank-statement/reconcile');

        $param['IDX_T_BankStatementHeader'] = (int) $request->input('IDX_T_BankStatementHeader');
        $param['SourceXml'] = 'XXX'.$sources;
        $param['LinesXml'] = 'XXX'.$lines;
        $param['JournalDate'] = date('Y-m-d', strtotime($request->input('JournalDate')));
        $param['JournalRemark'] = 'XXX'.$this->esc($request->input('JournalRemark'));
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        return $this->store('approve', $param);
    }

    // =========================================================================================
    // TANDA COCOK MANUAL DARI REKONSILIASI
    // =========================================================================================
    public function match(Request $request)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-J'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $sources = '<rows>';
        foreach ((array) $request->input('bank', []) as $id)
        {
            $sources .= sprintf('<r t="B" id="%d"/>', $id);
        }
        foreach ((array) $request->input('ledger', []) as $id)
        {
            $sources .= sprintf('<r t="L" id="%d"/>', $id);
        }
        $sources .= '</rows>';

        $param['IDX_T_BankStatementHeader'] = (int) $request->input('IDX_T_BankStatementHeader');
        $param['SourceXml'] = 'XXX'.$sources;
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_CM_BankStatement_Match_Save', $param, 'list', 'sqlsrv');
        $result = end($result);

        return response()->json(['flag' => $result->Result, 'message' => $result->LogDesc]);
    }

    public function unmatch(Request $request)
    {
        if (!$this->check_permission($this->data['user_id'], 'FM-BS-J'))
        {
            return response()->json(['flag' => 'error', 'message' => 'Anda tidak memiliki akses.']);
        }

        $param['IDX_T_BankStatementMatch'] = (int) $request->input('IDX_T_BankStatementMatch');
        $param['UserID'] = 'XXX'.$this->data['user_id'];

        $result = $this->exec_sp('USP_CM_BankStatement_Match_Delete', $param, 'list', 'sqlsrv');
        $result = end($result);

        return response()->json(['flag' => $result->Result, 'message' => $result->LogDesc]);
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

        $merge = $request->input('JournalMode') == 'merge';
        if ($merge)
        {
            $validator->addRules([
                'MergeCOA' => 'required',
                'MergeDate' => 'required|date',
                'MergeRemark' => 'required',
            ]);
            $validator->setCustomMessages(['MergeCOA.required' => 'Chart of Account belum dipilih!']);
        }

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

        $this->next_action = 'reload';
        $this->next_url = url('fm-bank-statement/update');

        $param['IDX_T_BankStatementHeader'] = $request->input('IDX_T_BankStatementHeader');
        $param['RowsXml'] = 'XXX'.$xml;

        if ($merge)
        {
            $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateMergedJournal]';
            $param['IDX_M_COA'] = (int) $request->input('MergeCOA');
            $param['JournalDate'] = date('Y-m-d', strtotime($request->input('MergeDate')));
            $param['JournalRemark'] = 'XXX'.$this->esc($request->input('MergeRemark'));
        }
        else
        {
            $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateJournal]';
        }

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
        $coa = $this->default_coa('%Biaya Admin%Bank%');
        $fields->IDX_M_COA = $coa ? $coa->IDX_M_COA : '';
        $fields->COAName = $coa ? $coa->COAName : '';
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
    // JURNAL AKHIR BULAN (BIAYA ADMIN, BUNGA, PAJAK)
    // =========================================================================================
    public function month_end(Request $request)
    {
        $this->data['form_id'] = 'FM-BS-J';

        if (!$this->check_permission($this->data['user_id'], $this->data['form_id']))
        {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['form_desc'] = 'Jurnal Akhir Bulan';
        $this->data['state'] = 'approve';

        $this->sp_getdata = '[dbo].[USP_CM_BankStatement_Info]';
        $fields = $this->get_detail_by_id($request->input('IDX_T_BankStatementHeader'))[0];

        $param['IDX_T_BankStatementHeader'] = $fields->IDX_T_BankStatementHeader;
        $this->data['records_detail'] = $this->exec_sp('USP_CM_BankStatement_MonthEndRows', $param, 'list', 'sqlsrv');

        // KATEGORI YANG ADA PADA REKENING KORAN INI, BESERTA COA DEFAULT SESUAI JURNAL MANUAL SELAMA INI
        $categories = [
            'ADMIN'    => ['label' => 'Biaya Admin Bank', 'field' => 'COAAdmin', 'coa' => '%Biaya Admin%Bank%'],
            'INTEREST' => ['label' => 'Bunga Bank', 'field' => 'COAInterest', 'coa' => '%Pendapatan Bunga%'],
            'TAX'      => ['label' => 'Pajak Bunga', 'field' => 'COATax', 'coa' => '%Biaya Bunga%'],
        ];
        $present = array_unique(array_column($this->data['records_detail'], 'Category'));
        foreach ($categories as $key => $category)
        {
            if (!in_array($key, $present))
            {
                unset($categories[$key]);
                continue;
            }
            $categories[$key]['default'] = $this->default_coa($category['coa']);
        }
        $this->data['categories'] = $categories;

        $months = [1 => 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        $period = strtotime($fields->PeriodEnd);
        $fields->JournalDate = $fields->PeriodEnd;
        $fields->ReferenceNo = 'Journal Biaya Bank ' . date('Y-m', $period);
        $fields->JournalRemark = 'Rekening bank bulan ' . $months[(int) date('n', $period)] . ' ' . date('Y', $period);

        $this->data['fields'] = $fields;
        $this->data['url_save_modal'] = url('fm-bank-statement/save-month-end');
        $this->data['show_save'] = count($this->data['records_detail']) > 0;

        $this->data['view'] = 'finance/bank_statement_month_end_form';
        return view($this->data['view'], $this->data);
    }

    public function save_month_end(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_BankStatementHeader' => 'required',
            'JournalDate' => 'required|date',
            'ReferenceNo' => 'required|max:32',
            'JournalRemark' => 'required',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_BankStatementHeader'));
        }

        $this->sp_approval = '[dbo].[USP_CM_BankStatement_CreateMonthEndJournal]';
        $this->next_action = 'reload';
        $this->next_url = url('fm-bank-statement/update');

        $param['IDX_T_BankStatementHeader'] = $request->input('IDX_T_BankStatementHeader');
        $param['COAAdmin'] = (int) $request->input('COAAdmin');
        $param['COAInterest'] = (int) $request->input('COAInterest');
        $param['COATax'] = (int) $request->input('COATax');
        $param['JournalDate'] = date('Y-m-d', strtotime($request->input('JournalDate')));
        $param['ReferenceNo'] = 'XXX'.$this->esc($request->input('ReferenceNo'));
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

    // COA aktif yang boleh dijurnal, dicari dari nama (pola LIKE), untuk nilai default modal.
    private function default_coa($pattern)
    {
        $coa = DB::connection('sqlsrv')->select(
            "SELECT TOP 1 IDX_M_COA, RTRIM(COAID) + ' - ' + RTRIM(COADesc) AS COAName FROM GL_M_COA WITH(NOLOCK)
             WHERE RecordStatus = 'A' AND AllowJournalEntry = 'Y' AND COADesc LIKE ?
             ORDER BY COAID",
            [$pattern]
        );

        return $coa ? $coa[0] : null;
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
