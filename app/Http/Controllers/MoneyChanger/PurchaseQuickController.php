<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Http\Request;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Validator;

/**
 * PurchaseQuickController
 *
 * Form input cepat transaksi pembelian valuta asing (header + detail dalam 1 form).
 * Header disimpan lewat USP_MC_PurchaseOrder_Save, tiap baris detail lewat
 * USP_MC_PurchaseOrderDetail_Save.
 */
class PurchaseQuickController extends MyController
{
    public function __construct(Request $request)
    {
        $this->data['module_name']  = 'Money Changer';
        $this->data['form_title']   = 'Input Cepat Pembelian Valas';
        $this->data['navbar']       = 'navigation.navbar_money_changer';
        $this->data['sidebar']      = 'navigation.sidebar_money_changer';
        $this->data['breads']       = ['Transaksi', 'Valuta Asing', 'Input Cepat Pembelian'];

        $this->data['url_create']   = url('mc-purchase-quick/create');
        $this->data['url_cancel']   = url('mc-purchase-order');

        parent::__construct($request);
    }

    // =========================================================================================
    // CREATE
    // =========================================================================================
    public function create()
    {
        $this->data['form_sub_title'] = 'Input Pembelian Valas';
        $this->data['form_desc']      = 'Input pembelian valuta asing secara cepat (header + detail)';
        $this->data['state']          = 'create';

        $fields = (object)[
            'IDX_T_PurchaseOrder' => 0,
            'IDX_M_Company'       => 1,
            'IDX_M_Branch'        => 1,
            'IDX_M_Partner'       => 0,
            'PONumber'            => '',
            'ReferenceNo'         => '',
            'PODate'              => date('Y-m-d'),
            'PONotes'             => '',
            'PartnerDesc'         => '',
            'POStatus'            => 'D',
            'RecordStatus'        => 'A',
        ];

        $this->data['fields']         = $fields;
        $this->data['records_detail'] = [];

        return $this->show_form();
    }

    // =========================================================================================
    // UPDATE
    // =========================================================================================
    public function update($id)
    {
        $this->data['form_sub_title'] = 'Edit Pembelian Valas';
        $this->data['form_desc']      = 'Edit pembelian valuta asing';
        $this->data['state']          = 'update';

        $param['IDX'] = $id;
        $records = $this->exec_sp('[dbo].[USP_MC_PurchaseOrder_Info]', $param, 'list');

        if (empty($records)) {
            return redirect(url('mc-purchase-order'));
        }

        $fields = $records[0];
        $fields->PartnerDesc = trim(($fields->PartnerID ?? '') . ' - ' . ($fields->PartnerName ?? ''));

        $param_detail['IDX_T_PurchaseOrder'] = $id;
        $records_detail = $this->exec_sp('USP_MC_PurchaseOrderDetail_List', $param_detail, 'list', 'sqlsrv');

        $this->data['fields']         = $fields;
        $this->data['records_detail'] = $records_detail;

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

        $this->data['url_save_header'] = url('mc-purchase-quick/save');
        $this->data['view']            = 'money_changer.purchase_quick_form';

        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // SAVE (HEADER + DETAIL DALAM SATU REQUEST)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_PurchaseOrder' => 'required',
            'IDX_M_Company'       => 'required',
            'IDX_M_Branch'        => 'required',
            'IDX_M_Partner'       => 'required|not_in:0',
            'ReferenceNo'         => 'required',
            'PODate'              => 'required|date',
            'PONotes'             => 'required',
        ], [
            'IDX_M_Partner.required' => 'Supplier belum diisi!',
            'IDX_M_Partner.not_in'   => 'Supplier belum diisi!',
            'ReferenceNo.required'   => 'No nota belum diisi!',
            'PODate.required'        => 'Tanggal transaksi belum diisi!',
            'PONotes.required'       => 'Keterangan belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('IDX_T_PurchaseOrder', 0));
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
                'id'      => $request->input('IDX_T_PurchaseOrder', 0),
                'url'     => '',
            ];
            echo json_encode($obj);
            return;
        }

        $state  = $request->input('state', 'create');
        $userId = 'XXX' . $this->data['user_id'];

        // ---------- HEADER ----------
        $param_header = [
            'IDX_T_PurchaseOrder' => $request->input('IDX_T_PurchaseOrder', 0),
            'IDX_M_Company'       => $request->input('IDX_M_Company', 1),
            'IDX_M_Branch'        => $request->input('IDX_M_Branch', 1),
            'IDX_M_Partner'       => $request->input('IDX_M_Partner'),
            'PONumber'            => $request->input('PONumber', ''),
            'ReferenceNo'         => $request->input('ReferenceNo', ''),
            'PODate'              => $request->input('PODate'),
            'PONotes'             => $request->input('PONotes'),
            'POStatus'            => $request->input('POStatus', 'D'),
            'UserID'              => $userId,
            'RecordStatus'        => 'A',
        ];

        $result_header = $this->exec_sp('[dbo].[USP_MC_PurchaseOrder_Save]', $param_header, 'list');

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
                'id'      => $request->input('IDX_T_PurchaseOrder', 0),
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
                    $this->exec_sp('[dbo].[USP_MC_PurchaseOrderDetail_Delete]',
                        ['IDX_T_PurchaseOrderDetail' => (int)$del_id], 'list');
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
                'IDX_T_PurchaseOrderDetail' => (int) ($d['idx_t_purchaseorderdetail'] ?? 0),
                'IDX_T_PurchaseOrder'       => $new_idx,
                'IDX_M_Valas'               => (int) $d['idx_m_valas'],
                'IDX_M_Tax'                 => 0,
                'Quantity'                  => $quantity,
                'ForeignAmount'             => $foreign_amount,
                'ExchangeRate'              => $exchange_rate,
                'DetailNotes'               => $d['detail_notes'] ?? '',
                'UserID'                    => $userId,
                'RecordStatus'              => 'A',
            ];

            $result_detail = $this->exec_sp('[dbo].[USP_MC_PurchaseOrderDetail_Save]', $param_detail, 'list');

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
                'url'     => url('mc-purchase-quick/update') . '/' . $new_idx,
            ];
            echo json_encode($obj);
            return;
        }

        $obj = [
            'flag'        => 'success',
            'message'     => '<span>Transaksi pembelian valas berhasil disimpan.</span>',
            'id'          => $new_idx,
            'next_action' => 'reload',
            'url'         => url('mc-purchase-quick/update') . '/' . $new_idx,
        ];

        echo json_encode($obj);
    }
}
