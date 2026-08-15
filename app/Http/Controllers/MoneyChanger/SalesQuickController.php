<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Validator;

/**
 * SalesQuickController
 *
 * Form input cepat transaksi penjualan valuta asing (header + detail dalam 1 form).
 * Header disimpan lewat USP_MC_SalesOrder_Save, tiap baris detail lewat
 * USP_MC_SalesOrderDetail_Save.
 */
class SalesQuickController extends MyController
{
    public function __construct(Request $request)
    {
        $this->data['module_name']  = 'Money Changer';
        $this->data['form_title']   = 'Input Cepat Penjualan Valas';
        $this->data['navbar']       = 'navigation.navbar_money_changer';
        $this->data['sidebar']      = 'navigation.sidebar_money_changer';
        $this->data['breads']       = ['Transaksi', 'Valuta Asing', 'Input Cepat'];

        $this->data['url_create']   = url('mc-sales-quick/create');
        $this->data['url_cancel']   = url('mc-sales-order');

        parent::__construct($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_sub_title'] = 'Input Penjualan Valas';
        $this->data['form_desc']      = 'Input penjualan valuta asing secara cepat (header + detail)';
        $this->data['state']          = 'create';

        $fields = (object)[
            'IDX_T_SalesOrder'   => 0,
            'IDX_M_Company'      => 1,
            'IDX_M_Branch'       => 1,
            'IDX_M_Partner'      => 0,
            'SONumber'           => '',
            'ReferenceNo'        => '',
            'SODate'             => date('Y-m-d'),
            'SONotes'            => '',
            'FundSource'         => '',
            'TransactionPurpose' => '',
            'PartnerDesc'        => '',
            'SOStatus'           => 'D',
            'RecordStatus'       => 'A',
        ];

        $this->data['fields']            = $fields;
        $this->data['records_detail']    = [];
        $this->data['records_payment']   = [];

        return $this->show_form();
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_sub_title'] = 'Edit Penjualan Valas';
        $this->data['form_desc']      = 'Edit penjualan valuta asing';
        $this->data['state']          = 'update';

        $param['IDX'] = $id;
        $records = $this->exec_sp('[dbo].[USP_MC_SalesOrder_Info]', $param, 'list');

        if (empty($records)) {
            return redirect(url('mc-sales-order'));
        }

        $fields = $records[0];
        $fields->PartnerDesc = trim(($fields->PartnerID ?? '') . ' - ' . ($fields->PartnerName ?? ''));

        $param_detail['IDX_T_SalesOrder'] = $id;
        $records_detail = $this->exec_sp('USP_MC_SalesOrderDetail_List', $param_detail, 'list', 'sqlsrv');

        $this->data['fields']          = $fields;
        $this->data['records_detail']  = $records_detail;
        $this->data['records_payment'] = $this->pembayaran_tersimpan($id);

        return $this->show_form();
    }

    // =========================================================================================
    // SHOW FORM
    // =========================================================================================
    protected function show_form()
    {
        $dd  = new DropdownController;
        $ddf = new DropdownFinanceController;

        $this->data['dd_valas']   = (array) $ddf->valas();
        $this->data['dd_company'] = (array) $dd->company($this->data['user_id']);
        $this->data['dd_branch']  = (array) $dd->branch($this->data['user_id']);

        // CARA BAYAR: dipakai baris pembayaran. Baris pertama diarahkan ke akun
        // kas dan baris kedua ke akun bank, sesuai permintaan "CASH dan TRANSFER".
        $this->data['dd_financial_account'] = (array) $dd->financial_account($this->data['user_id']);
        $this->data['akun_cash']            = $this->akun_bawaan('CASH');
        $this->data['akun_transfer']        = $this->akun_bawaan('TRANSFER');

        $this->data['url_save_header'] = url('mc-sales-quick/save');
        $this->data['view']            = 'money_changer.sales_quick_form';

        return view($this->data['view'], $this->data);
    }

    /**
     * Akun bawaan untuk baris pembayaran. CASH memakai akun kas, TRANSFER
     * memakai akun bank pertama. Kalau tidak ketemu, dikembalikan kosong supaya
     * kasir memilih sendiri di dropdown.
     */
    private function akun_bawaan($jenis)
    {
        $sql = "SELECT TOP 1 IDX_M_FinancialAccount
                FROM CM_M_FinancialAccount WITH(NOLOCK)
                WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'
                    AND " . ($jenis === 'CASH'
                        ? "(FinancialAccountID LIKE 'CASH%' OR FinancialAccountDesc LIKE '%Kas%')"
                        : "(FinancialAccountID LIKE 'BCA%' OR FinancialAccountID LIKE 'MAN%'
                            OR FinancialAccountDesc LIKE 'Bank%')") . "
                ORDER BY IDX_M_FinancialAccount";

        $rows = DB::connection('sqlsrv')->select($sql);

        return $rows ? (int) $rows[0]->IDX_M_FinancialAccount : 0;
    }

    /** Pembayaran yang sudah tercatat untuk nota ini */
    private function pembayaran_tersimpan($id)
    {
        if ((int) $id === 0) {
            return [];
        }

        return $this->exec_sp('USP_MC_SalesOrderPayment_List',
            ['IDX_T_SalesOrder' => (int) $id], 'list', 'sqlsrv');
    }

    // =========================================================================================
    // SAVE (HEADER + DETAIL DALAM SATU REQUEST)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_SalesOrder' => 'required',
            'IDX_M_Company'    => 'required',
            'IDX_M_Branch'     => 'required',
            'IDX_M_Partner'    => 'required|not_in:0',
            'SODate'           => 'required|date',
            'SONotes'          => 'required',
        ], [
            'IDX_M_Partner.required' => 'Konsumen belum diisi!',
            'IDX_M_Partner.not_in'   => 'Konsumen belum diisi!',
            'SODate.required'        => 'Tanggal transaksi belum diisi!',
            'SONotes.required'       => 'Keterangan belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_SalesOrder', 0));
        }

        $details = json_decode($request->input('detail_json', '[]'), true) ?: [];
        $details = array_values(array_filter($details, function ($d) {
            return (float)($d['foreign_amount'] ?? 0) > 0
                && (float)($d['exchange_rate'] ?? 0) > 0
                && (int)($d['idx_m_valas'] ?? 0) > 0;
        }));

        if (count($details) === 0) {
            $obj = [
                'flag'    => 'error',
                'message' => '<span>Minimal 1 baris detail valas harus diisi (valas, jumlah, nilai tukar).</span>',
                'id'      => $request->input('IDX_T_SalesOrder', 0),
                'url'     => '',
            ];
            echo json_encode($obj);
            return;
        }

        $state  = $request->input('state', 'create');
        $userId = 'XXX' . $this->data['user_id'];

        // ---------- HEADER ----------
        $param_header = [
            'IDX_T_SalesOrder'   => $request->input('IDX_T_SalesOrder', 0),
            'IDX_M_Company'      => $request->input('IDX_M_Company', 1),
            'IDX_M_Branch'       => $request->input('IDX_M_Branch', 1),
            'IDX_M_Partner'      => $request->input('IDX_M_Partner'),
            'SONumber'           => $request->input('SONumber', ''),
            'ReferenceNo'        => $request->input('ReferenceNo', ''),
            'FundSource'         => $request->input('FundSource', ''),
            'TransactionPurpose' => $request->input('TransactionPurpose', ''),
            'SODate'             => $request->input('SODate'),
            'SONotes'            => $request->input('SONotes'),
            'SOStatus'           => $request->input('SOStatus', 'D'),
            'UserID'             => $userId,
            'RecordStatus'       => 'A',
        ];

        $result_header = $this->exec_sp('[dbo].[USP_MC_SalesOrder_Save]', $param_header, 'list');

        $flag    = '';
        $new_idx = 0;
        foreach ($result_header as $row) {
            $flag    = $row->Result ?? '';
            $new_idx = $row->ID ?? 0;
        }

        if (strtolower($flag) !== 'success') {
            $obj = [
                'flag'    => 'error',
                'message' => $this->sweet_alert_message($result_header),
                'id'      => $request->input('IDX_T_SalesOrder', 0),
                'url'     => '',
            ];
            echo json_encode($obj);
            return;
        }

        // ---------- HAPUS DETAIL YANG DIBUANG DI FORM (hanya mode update) ----------
        if ($state === 'update') {
            $deleted_ids = json_decode($request->input('deleted_ids_json', '[]'), true) ?: [];
            foreach ($deleted_ids as $del_id) {
                if ((int)$del_id > 0) {
                    $this->exec_sp('[dbo].[USP_MC_SalesOrderDetail_Delete]',
                        ['IDX_T_SalesOrderDetail' => (int)$del_id], 'list');
                }
            }
        }

        // ---------- DETAIL ----------
        $detail_errors = [];
        foreach ($details as $i => $d) {
            $foreign_amount = (float) ($d['foreign_amount'] ?? 0);
            $exchange_rate  = (float) ($d['exchange_rate'] ?? 0);
            $quantity       = (float) ($d['quantity'] ?? 0);

            $param_detail = [
                'IDX_T_SalesOrderDetail' => (int) ($d['idx_t_salesorderdetail'] ?? 0),
                'IDX_T_SalesOrder'       => $new_idx,
                'IDX_M_Valas'            => (int) $d['idx_m_valas'],
                'IDX_M_Tax'              => 0,
                'IDX_M_TransactionType'  => (int) ($d['idx_m_transactiontype'] ?? 2),
                'Quantity'               => $quantity,
                'ForeignAmount'          => $foreign_amount,
                'ExchangeRate'           => $exchange_rate,
                'DetailNotes'            => $d['detail_notes'] ?? '',
                'UserID'                 => $userId,
                'RecordStatus'           => 'A',
            ];

            $result_detail = $this->exec_sp('[dbo].[USP_MC_SalesOrderDetail_Save]', $param_detail, 'list');

            $flag_detail = '';
            foreach ($result_detail as $row) {
                $flag_detail = $row->Result ?? '';
            }

            if (strtolower($flag_detail) !== 'success') {
                $detail_errors[] = 'Baris ' . ($i + 1) . ': ' . $this->sweet_alert_message($result_detail);
            }
        }

        if (!empty($detail_errors)) {
            $obj = [
                'flag'    => 'error',
                'message' => implode('<br>', $detail_errors),
                'id'      => $new_idx,
                'url'     => url('mc-sales-quick/update') . '/' . $new_idx,
            ];
            echo json_encode($obj);
            return;
        }

        // ---------- KONFIRMASI + PEMBAYARAN ----------
        // Nota harus Approved dulu sebelum pembayaran boleh dicatat, jadi
        // urutannya: approve nota, baru posting tiap baris pembayaran lewat
        // stored procedure yang sama dengan menu penjualan penuh.
        if ((int) $request->input('confirm', 0) === 1) {
            $hasil = $this->konfirmasi_dan_bayar($request, $new_idx, $details, $userId);

            if ($hasil !== true) {
                $obj = [
                    'flag'    => 'error',
                    'message' => $hasil,
                    'id'      => $new_idx,
                    'url'     => url('mc-sales-quick/update') . '/' . $new_idx,
                ];
                echo json_encode($obj);
                return;
            }

            $obj = [
                'flag'        => 'success',
                'message'     => '<span>Transaksi dikonfirmasi dan pembayaran tercatat.</span>',
                'id'          => $new_idx,
                'next_action' => 'reload',
                'url'         => url('mc-sales-quick/update') . '/' . $new_idx,
            ];

            echo json_encode($obj);
            return;
        }

        $obj = [
            'flag'        => 'success',
            'message'     => '<span>Transaksi penjualan valas berhasil disimpan.</span>',
            'id'          => $new_idx,
            'next_action' => 'reload',
            'url'         => url('mc-sales-quick/update') . '/' . $new_idx,
        ];

        echo json_encode($obj);
    }

    /**
     * Approve nota lalu catat pembayarannya.
     *
     * Mengembalikan TRUE bila berhasil, atau pesan kesalahan siap tampil.
     */
    private function konfirmasi_dan_bayar(Request $request, $idx_so, $details, $userId)
    {
        // Nilai transaksi dihitung dari detail yang baru saja disimpan, bukan
        // dari angka yang dikirim layar, supaya tidak bisa dimanipulasi.
        $total_transaksi = 0;
        foreach ($details as $d) {
            $total_transaksi += (float) $d['foreign_amount'] * (float) $d['exchange_rate'];
        }

        $payments = json_decode($request->input('payment_json', '[]'), true) ?: [];
        $payments = array_values(array_filter($payments, function ($p) {
            return (float) ($p['amount'] ?? 0) > 0;
        }));

        if (count($payments) === 0) {
            return '<span>Pembayaran belum diisi. Isi minimal satu cara bayar dengan nominalnya.</span>';
        }

        $total_bayar = 0;
        foreach ($payments as $p) {
            if ((int) ($p['idx_m_financialaccount'] ?? 0) === 0) {
                return '<span>Cara bayar belum dipilih pada salah satu baris pembayaran.</span>';
            }

            $total_bayar += (float) $p['amount'];
        }

        if (abs($total_bayar - $total_transaksi) > 0.01) {
            return '<span>Total pembayaran <b>' . number_format($total_bayar, 2, '.', ',')
                . '</b> tidak sama dengan nilai transaksi <b>' . number_format($total_transaksi, 2, '.', ',')
                . '</b>.</span>';
        }

        // Jangan mencatat pembayaran dua kali untuk nota yang sama
        if (count($this->pembayaran_tersimpan($idx_so)) > 0) {
            return '<span>Nota ini sudah punya pembayaran. Buka menu penjualan untuk mengubahnya.</span>';
        }

        $tanggal = $request->input('SODate', date('Y-m-d'));

        // 1. APPROVE, hanya bila notanya memang belum approved
        $info = $this->exec_sp('[dbo].[USP_MC_SalesOrder_Info]', ['IDX' => $idx_so], 'list');
        $status = $info ? trim($info[0]->SOStatus ?? '') : '';

        if ($status !== 'A') {
            $hasil_approve = $this->exec_sp('[dbo].[USP_MC_SalesOrder_Approve]', [
                    'IDX_T_SalesOrder' => $idx_so,
                    'ApprovalDate'     => 'XXX' . $tanggal,
                    'ApprovalRemark'   => 'XXX' . 'Konfirmasi dari input cepat',
                    'UserID'           => $userId,
                ], 'list');

            $flag = '';
            foreach ($hasil_approve as $row) {
                $flag = $row->Result ?? '';
            }

            if (strtolower($flag) !== 'success') {
                return $this->sweet_alert_message($hasil_approve);
            }
        }

        // 2. PEMBAYARAN, satu baris satu penerimaan
        $keterangan = trim($request->input('SONotes', '')) !== ''
            ? trim($request->input('SONotes'))
            : 'Penerimaan pembayaran penjualan valas';

        $gagal = [];

        foreach ($payments as $i => $p) {
            $hasil_bayar = $this->exec_sp('[dbo].[USP_MC_SalesOrder_Payment]', [
                'IDX_T_SalesOrder'       => $idx_so,
                'IDX_M_FinancialAccount' => (int) $p['idx_m_financialaccount'],
                'ReceiveAmount'          => (float) $p['amount'],
                'RemarkHeader'           => 'XXX' . $keterangan,
                'ReceiveDate'            => 'XXX' . $tanggal,
                'UserID'                 => $userId,
            ], 'list');

            $flag = '';
            foreach ($hasil_bayar as $row) {
                $flag = $row->Result ?? '';
            }

            if (strtolower($flag) !== 'success') {
                $gagal[] = 'Pembayaran baris ' . ($i + 1) . ': ' . $this->sweet_alert_message($hasil_bayar);
            }
        }

        return empty($gagal) ? true : implode('<br>', $gagal);
    }
}
