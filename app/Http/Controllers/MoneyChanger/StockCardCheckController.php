<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class StockCardCheckController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo'] = url('public/images/logo/finance.png');
        $this->table_name = '';

        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Kartu Stok';

        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        $this->data['breads'] = array('Money Changer', 'Kartu Stok');

        parent::__construct($request);
    }

    // =========================================================================================
    // LIST (rendered into the "Kartu Stok" tab of the SO / PO update page)
    //   $type = 2 (Penjualan / Sales Order) | 3 (Pembelian / Purchase Order)
    //   $idx  = IDX_Transaction (IDX_T_SalesOrder atau IDX_T_PurchaseOrder)
    // =========================================================================================
    public function reload($type, $idx, Request $request)
    {
        $this->data['records_stockcard'] = $this->get_rows((int) $idx, (int) $type);
        $this->data['IDX_Transaction'] = (int) $idx;
        $this->data['IDX_M_TransactionType'] = (int) $type;

        return view('money_changer/stock_card_check_list', $this->data);
    }

    private function get_rows($idx, $type)
    {
        $sql = "
            SELECT
                sc.IDX_T_StockCardValas,
                sc.IDX_M_Branch,
                sc.IDX_M_Valas,
                sc.IDX_M_TransactionType,
                sc.IDX_Transaction,
                sc.TransactionNo,
                sc.TransactionDate,
                CAST(ISNULL(sc.StockInQty, 0) AS DECIMAL(18,4))  AS StockInQty,
                CAST(ISNULL(sc.StockOutQty, 0) AS DECIMAL(18,4)) AS StockOutQty,
                CAST(ISNULL(sc.StockInForeignAmount, 0) AS DECIMAL(18,4))  AS StockInForeignAmount,
                CAST(ISNULL(sc.StockOutForeignAmount, 0) AS DECIMAL(18,4)) AS StockOutForeignAmount,
                val.ValasSKU,
                val.ValasName,
                dup.DupCount
            FROM MC_T_StockCardValas sc
            LEFT JOIN MC_M_Valas val ON val.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN (
                SELECT IDX_Transaction, IDX_M_TransactionType, TransactionNo, IDX_M_Valas, COUNT(*) AS DupCount
                FROM MC_T_StockCardValas
                WHERE RecordStatus = 'A'
                GROUP BY IDX_Transaction, IDX_M_TransactionType, TransactionNo, IDX_M_Valas
            ) dup
                ON dup.IDX_Transaction = sc.IDX_Transaction
               AND dup.IDX_M_TransactionType = sc.IDX_M_TransactionType
               AND dup.TransactionNo = sc.TransactionNo
               AND dup.IDX_M_Valas = sc.IDX_M_Valas
            WHERE sc.IDX_Transaction = ?
              AND sc.IDX_M_TransactionType = ?
              AND sc.RecordStatus = 'A'
            ORDER BY sc.IDX_M_Valas, sc.IDX_T_StockCardValas";

        return DB::connection('sqlsrv')->select($sql, [$idx, $type]);
    }

    // =========================================================================================
    // EDIT MODAL
    // =========================================================================================
    public function update(Request $request, $id)
    {
        $row = DB::connection('sqlsrv')->select("
            SELECT sc.IDX_T_StockCardValas, sc.IDX_Transaction, sc.IDX_M_TransactionType,
                   sc.TransactionNo, sc.IDX_M_Valas,
                   CAST(ISNULL(sc.StockInQty, 0) AS DECIMAL(18,4))  AS StockInQty,
                   CAST(ISNULL(sc.StockOutQty, 0) AS DECIMAL(18,4)) AS StockOutQty,
                   val.ValasSKU, val.ValasName
            FROM MC_T_StockCardValas sc
            LEFT JOIN MC_M_Valas val ON val.IDX_M_Valas = sc.IDX_M_Valas
            WHERE sc.IDX_T_StockCardValas = ?
        ", [$id]);

        if (empty($row)) {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['fields'] = $row[0];
        $this->data['fields']->RecordStatus = 'A';
        $this->data['state'] = 'update';

        $this->data['form_desc'] = 'Edit Kartu Stok';
        $this->data['url_save_modal'] = url('mc-stock-card-check/save');

        return view('money_changer/stock_card_check_form', $this->data);
    }

    // =========================================================================================
    // SAVE (UPDATE QUANTITY)
    // =========================================================================================
    public function save(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_StockCardValas'  => 'required',
            'IDX_Transaction'       => 'required',
            'IDX_M_TransactionType' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $idStockCard = (int) $request->input('IDX_T_StockCardValas');
        $idx         = (int) $request->input('IDX_Transaction');
        $type        = (int) $request->input('IDX_M_TransactionType');
        $stockIn     = (double) str_replace(',', '', $request->input('StockInQty', 0));
        $stockOut    = (double) str_replace(',', '', $request->input('StockOutQty', 0));

        // Recompute nilai valas mengikuti logika USP_MC_SalesOrderDetail_Save:
        //   ForeignAmount = ValasChangeNumber (denominasi) x Quantity
        //   BaseAmount    = ForeignAmount x ExchangeRate (rate per baris kartu stok)
        DB::connection('sqlsrv')->update("
            UPDATE sc
            SET sc.StockInQty            = ?,
                sc.StockOutQty           = ?,
                sc.StockInForeignAmount  = ? * ISNULL(vc.ValasChangeNumber, 0),
                sc.StockOutForeignAmount = ? * ISNULL(vc.ValasChangeNumber, 0),
                sc.StockInBaseAmount     = (? * ISNULL(vc.ValasChangeNumber, 0)) * ISNULL(sc.ExchangeRateIn, 0),
                sc.StockOutBaseAmount    = (? * ISNULL(vc.ValasChangeNumber, 0)) * ISNULL(sc.ExchangeRateOut, 0),
                sc.UModified             = ?,
                sc.DModified             = GETDATE()
            FROM MC_T_StockCardValas sc
            LEFT JOIN MC_M_Valas v ON v.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN MC_M_ValasChange vc ON vc.IDX_M_ValasChange = v.IDX_M_ValasChange
            WHERE sc.IDX_T_StockCardValas = ?
        ", [$stockIn, $stockOut, $stockIn, $stockOut, $stockIn, $stockOut, $this->data['user_id'], $idStockCard]);

        return $this->reload_response($type, $idx, 'Kuantitas & nilai valas kartu stok berhasil diperbarui.');
    }

    // =========================================================================================
    // DELETE MODAL
    // =========================================================================================
    public function delete(Request $request)
    {
        $row = DB::connection('sqlsrv')->select("
            SELECT sc.IDX_T_StockCardValas, sc.IDX_Transaction, sc.IDX_M_TransactionType,
                   sc.TransactionNo, val.ValasSKU, val.ValasName
            FROM MC_T_StockCardValas sc
            LEFT JOIN MC_M_Valas val ON val.IDX_M_Valas = sc.IDX_M_Valas
            WHERE sc.IDX_T_StockCardValas = ?
        ", [$request->input('IDX_T_StockCardValas')]);

        if (empty($row)) {
            return $this->show_no_access_modal($this->data);
        }

        $this->data['fields'] = $row[0];
        $this->data['state'] = 'delete';
        $this->data['form_desc'] = 'Hapus Kartu Stok';
        $this->data['url_save_modal'] = url('mc-stock-card-check/save-delete');

        return view('money_changer/stock_card_check_delete_form', $this->data);
    }

    public function save_delete(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'IDX_T_StockCardValas'  => 'required',
            'IDX_Transaction'       => 'required',
            'IDX_M_TransactionType' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), '');
        }

        $idStockCard = (int) $request->input('IDX_T_StockCardValas');
        $idx         = (int) $request->input('IDX_Transaction');
        $type        = (int) $request->input('IDX_M_TransactionType');

        // Hapus HANYA 1 baris berdasarkan PRIMARY KEY (IDX_T_StockCardValas yang unik/IDENTITY).
        // JANGAN pakai IDX_Transaction / TransactionNo di WHERE, karena baris duplikat berbagi
        // nilai itu sehingga akan ikut terhapus. $idx & $type hanya dipakai untuk reload tab.
        DB::connection('sqlsrv')->delete("
            DELETE FROM MC_T_StockCardValas WHERE IDX_T_StockCardValas = ?
        ", [$idStockCard]);

        return $this->reload_response($type, $idx, 'Baris kartu stok berhasil dihapus.');
    }

    // =========================================================================================
    // RESPONSE FOR saveDetail() JS: reloads the #table-stock-card div via data['url'].
    // =========================================================================================
    private function reload_response($type, $idx, $message)
    {
        $obj = [
            'flag'        => 'success',
            'message'     => '<p>' . $message . '</p>',
            'id'          => $idx,
            'next_action' => 'reload',
            'url'         => url('mc-stock-card-check/reload/' . $type . '/' . $idx),
        ];

        echo json_encode($obj);
    }
}
