<?php

namespace App\Http\Controllers\MoneyChanger;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;
use App\Http\Controllers\DropdownController;
use App\Http\Controllers\DropdownFinanceController;
use Symfony\Component\HttpFoundation\Response;

use Validator;

class CheckStockCardController extends MyController
{
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {
        $this->data['img_logo'] = url('public/images/logo/finance.png');
        $this->table_name = '';

        // FORM TITLE
        $this->data['module_name'] = 'Money Changer';
        $this->data['form_title'] = 'Cek Selisih Kartu Stok';

        // NAVIGATION
        $this->data['navbar'] = 'navigation.navbar_money_changer';
        $this->data['sidebar'] = 'navigation.sidebar_money_changer';

        // BREADCRUMB
        $this->data['breads'] = array('Money Changer', 'Cek Selisih Kartu Stok');

        parent::__construct($request);
    }

    // =========================================================================================
    // FILTER FORM
    // =========================================================================================
    public function inquiry()
    {
        $access = TRUE;

        $this->data['title'] = 'AVK';
        $this->data['form_title'] = 'Cek Selisih Kartu Stok';
        $this->data['form_sub_title'] = 'Rekonsiliasi Kartu Stok vs Transaksi';
        $this->data['form_desc'] = 'Cek Selisih Kartu Stok';
        $this->data['form_remark'] = 'Bandingkan kuantitas per valas pada kartu stok (MC_T_StockCardValas) dengan transaksi
            penjualan & pembelian untuk memastikan data sudah sesuai (reconcile). Pilih periode tanggal transaksi.';

        $this->data['state'] = 'update';

        if ($access == TRUE) {
            $this->data['fields'] = (object) ['RecordStatus' => 'A'];

            // DROPDOWN
            $dd = new DropdownController;
            $this->data['dd_branch'] = (array) $dd->branch('');

            $ddf = new DropdownFinanceController;
            $this->data['dd_valas'] = (array) $ddf->valas();

            // RECONCILE SCOPE: 0 = semua, 2 = penjualan saja, 3 = pembelian saja
            $this->data['dd_recon_scope'] = [
                '0' => 'Semua (Penjualan & Pembelian)',
                '2' => 'Penjualan Saja',
                '3' => 'Pembelian Saja',
            ];

            // DATA SCOPE: 0 = semua data, 1 = hanya selisih, 2 = hanya tidak ditemukan
            $this->data['dd_data_scope'] = [
                '0' => 'Semua Data',
                '1' => 'Data yang Selisih',
                '2' => 'Data yang Tidak Ditemukan',
            ];

            // DEFAULT PARAMETER
            $this->data['IDX_M_Branch'] = 1;
            $this->data['IDX_M_Valas'] = 0;
            $this->data['ReconScope'] = 0;
            $this->data['DataScope'] = 0;
            $this->data['start_date'] = date('Y-m-01');
            $this->data['end_date'] = date('Y-m-d');

            // URL
            $this->data['url_show_repoprt'] = url('mc-check-stock-card-report');

            $this->data['view'] = 'money_changer/check_stock_card_form';
            return view($this->data['view'], $this->data);
        } else {
            return $this->show_no_access($this->data);
        }
    }

    // =========================================================================================
    // RECONCILE REPORT
    // =========================================================================================
    public function report(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required',
            'end_date'   => 'required',
        ], [
            'start_date.required' => 'Tanggal Awal belum diisi!',
            'end_date.required'   => 'Tanggal Akhir belum diisi!',
        ]);

        if ($validator->fails()) {
            return $this->validation_fails($validator->errors(), $request->input('start_date'));
        }

        $this->data['fields'] = $request->all();

        // REPORT INFORMATION
        $this->data['page_title'] = 'CEK SELISIH KARTU STOK';
        $this->data['title']      = 'Cek Selisih Kartu Stok';
        $this->data['form_title'] = 'Cek Selisih Kartu Stok';

        $this->data['BranchName'] = $request->input('BranchName') ?: 'Semua Cabang';
        $this->data['ValasName']  = $request->input('ValasName') ?: 'Semua Valas';

        // FILTER PARAMETER
        $branch    = (int) $request->input('IDX_M_Branch', 0);
        $valas     = (int) $request->input('IDX_M_Valas', 0);
        $scope     = (int) $request->input('ReconScope', 0); // 0 = semua, 2 = penjualan, 3 = pembelian
        $dataScope = (int) $request->input('DataScope', 0);  // 0 = semua, 1 = selisih, 2 = tidak ditemukan
        $start     = $request->input('start_date');
        $end       = $request->input('end_date');

        $scope_name = [2 => 'Penjualan Saja', 3 => 'Pembelian Saja'];
        $this->data['ScopeName'] = $scope_name[$scope] ?? 'Semua (Penjualan & Pembelian)';

        $data_scope_name = [1 => 'Data yang Selisih', 2 => 'Data yang Tidak Ditemukan'];
        $this->data['DataScopeName'] = $data_scope_name[$dataScope] ?? 'Semua Data';

        $records = $this->reconcile($branch, $valas, $start, $end, $scope);
        $this->data['records'] = $this->filter_data_scope($records, $dataScope);

        $this->data['view'] = 'money_changer/check_stock_card_report';
        return view($this->data['view'], $this->data);
    }

    // =========================================================================================
    // FILTER BY RECONCILIATION STATUS
    //   1 = hanya baris selisih (qty tidak sama, transaksi ditemukan)
    //   2 = hanya baris tidak ditemukan (header / detail transaksi tidak ada)
    // =========================================================================================
    private function filter_data_scope($records, $dataScope)
    {
        if ($dataScope != 1 && $dataScope != 2) {
            return $records;
        }

        $filtered = array_filter($records, function ($r) use ($dataScope) {
            $missing = (($r->IsMissingDetail ?? 0) == 1 || ($r->IsMissingHeader ?? 0) == 1);

            if ($dataScope == 2) {
                return $missing;
            }
            // $dataScope == 1
            return !$missing && round($r->DiffQty, 4) != 0;
        });

        return array_values($filtered);
    }

    // =========================================================================================
    // RECONCILE QUERY
    //
    // Compare quantity per IDX_M_Valas between the stock card (MC_T_StockCardValas) and the
    // matching sales / purchase transaction detail. Both sides are summed first so the
    // comparison is done on aggregated quantities per transaction & valas:
    //   - Stock card : SUM(StockOutQty/StockInQty) GROUP BY IDX_Transaction, TransactionNo, IDX_M_Valas
    //   - Sales detail   : SUM(Quantity) GROUP BY IDX_T_SalesOrder, IDX_M_Valas
    //   - Purchase detail: SUM(Quantity) GROUP BY IDX_T_PurchaseOrder, IDX_M_Valas
    //
    //   IDX_M_TransactionType = 2 (Penjualan) -> SUM(StockOutQty) vs SUM(SalesOrderDetail.Quantity)
    //   IDX_M_TransactionType = 3 (Pembelian) -> SUM(StockInQty)  vs SUM(PurchaseOrderDetail.Quantity)
    // =========================================================================================
    private function reconcile($branch, $valas, $start, $end, $scope = 0)
    {
        // Common filter for the stock card aggregation (applied identically to each UNION half).
        $filter  = " AND RecordStatus = 'A' AND TransactionDate BETWEEN ? AND ? ";
        $binding = [$start, $end];
        if ($branch > 0) {
            $filter .= " AND IDX_M_Branch = ? ";
            $binding[] = $branch;
        }
        if ($valas > 0) {
            $filter .= " AND IDX_M_Valas = ? ";
            $binding[] = $valas;
        }

        // -------- SALES (IDX_M_TransactionType = 2) --------
        $sql_sales = "
            SELECT
                sc.IDX_M_Branch,
                b.BranchName,
                sc.IDX_M_Valas,
                val.ValasSKU,
                val.ValasName,
                cur.CurrencyID,
                cur.CurrencyName,
                sc.IDX_M_TransactionType,
                'Penjualan' AS TransactionTypeDesc,
                sc.IDX_Transaction,
                sc.TransactionNo,
                sc.TransactionDate,
                CAST(sc.StockCardQty AS DECIMAL(18,4))        AS StockCardQty,
                CAST(ISNULL(sod.TrxQty, 0) AS DECIMAL(18,4))  AS TransactionQty,
                CAST(sc.StockCardQty - ISNULL(sod.TrxQty, 0) AS DECIMAL(18,4)) AS DiffQty,
                CASE WHEN so.IDX_T_SalesOrder IS NULL THEN 1 ELSE 0 END AS IsMissingHeader,
                CASE WHEN sod.TrxQty IS NULL THEN 1 ELSE 0 END AS IsMissingDetail
            FROM (
                SELECT
                    IDX_M_Branch,
                    IDX_M_Valas,
                    IDX_M_TransactionType,
                    IDX_Transaction,
                    TransactionNo,
                    SUM(ISNULL(StockOutQty, 0)) AS StockCardQty,
                    MAX(TransactionDate) AS TransactionDate
                FROM MC_T_StockCardValas
                WHERE IDX_M_TransactionType = 2 " . $filter . "
                GROUP BY IDX_M_Branch, IDX_M_Valas, IDX_M_TransactionType, IDX_Transaction, TransactionNo
            ) sc
            LEFT JOIN MC_T_SalesOrder so
                ON so.IDX_T_SalesOrder = sc.IDX_Transaction
               AND so.SONumber = sc.TransactionNo
            LEFT JOIN (
                SELECT IDX_T_SalesOrder, IDX_M_Valas, SUM(Quantity) AS TrxQty
                FROM MC_T_SalesOrderDetail
                WHERE RecordStatus = 'A'
                GROUP BY IDX_T_SalesOrder, IDX_M_Valas
            ) sod
                ON sod.IDX_T_SalesOrder = sc.IDX_Transaction
               AND sod.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN MC_M_Valas val ON val.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN MC_M_Currency cur ON cur.IDX_M_Currency = val.IDX_M_Currency
            LEFT JOIN GN_M_Branch b ON b.IDX_M_Branch = sc.IDX_M_Branch";

        // -------- PURCHASE (IDX_M_TransactionType = 3) --------
        $sql_purchase = "
            SELECT
                sc.IDX_M_Branch,
                b.BranchName,
                sc.IDX_M_Valas,
                val.ValasSKU,
                val.ValasName,
                cur.CurrencyID,
                cur.CurrencyName,
                sc.IDX_M_TransactionType,
                'Pembelian' AS TransactionTypeDesc,
                sc.IDX_Transaction,
                sc.TransactionNo,
                sc.TransactionDate,
                CAST(sc.StockCardQty AS DECIMAL(18,4))        AS StockCardQty,
                CAST(ISNULL(pod.TrxQty, 0) AS DECIMAL(18,4))  AS TransactionQty,
                CAST(sc.StockCardQty - ISNULL(pod.TrxQty, 0) AS DECIMAL(18,4)) AS DiffQty,
                CASE WHEN po.IDX_T_PurchaseOrder IS NULL THEN 1 ELSE 0 END AS IsMissingHeader,
                CASE WHEN pod.TrxQty IS NULL THEN 1 ELSE 0 END AS IsMissingDetail
            FROM (
                SELECT
                    IDX_M_Branch,
                    IDX_M_Valas,
                    IDX_M_TransactionType,
                    IDX_Transaction,
                    TransactionNo,
                    SUM(ISNULL(StockInQty, 0)) AS StockCardQty,
                    MAX(TransactionDate) AS TransactionDate
                FROM MC_T_StockCardValas
                WHERE IDX_M_TransactionType = 3 " . $filter . "
                GROUP BY IDX_M_Branch, IDX_M_Valas, IDX_M_TransactionType, IDX_Transaction, TransactionNo
            ) sc
            LEFT JOIN MC_T_PurchaseOrder po
                ON po.IDX_T_PurchaseOrder = sc.IDX_Transaction
               AND po.PONumber = sc.TransactionNo
            LEFT JOIN (
                SELECT IDX_T_PurchaseOrder, IDX_M_Valas, SUM(Quantity) AS TrxQty
                FROM MC_T_PurchaseOrderDetail
                WHERE RecordStatus = 'A'
                GROUP BY IDX_T_PurchaseOrder, IDX_M_Valas
            ) pod
                ON pod.IDX_T_PurchaseOrder = sc.IDX_Transaction
               AND pod.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN MC_M_Valas val ON val.IDX_M_Valas = sc.IDX_M_Valas
            LEFT JOIN MC_M_Currency cur ON cur.IDX_M_Currency = val.IDX_M_Currency
            LEFT JOIN GN_M_Branch b ON b.IDX_M_Branch = sc.IDX_M_Branch";

        // Assemble only the halves requested by the scope (0 = both, 2 = sales, 3 = purchase).
        // Bindings appear once per included half, in order.
        if ($scope == 2) {
            $body = $sql_sales;
            $bindings = $binding;
        } elseif ($scope == 3) {
            $body = $sql_purchase;
            $bindings = $binding;
        } else {
            $body = $sql_sales . " UNION ALL " . $sql_purchase;
            $bindings = array_merge($binding, $binding);
        }

        $sql = $body . " ORDER BY IDX_M_TransactionType, ValasName, TransactionDate, TransactionNo";

        return DB::connection('sqlsrv')->select($sql, $bindings);
    }
}
