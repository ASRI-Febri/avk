# Modul Money Changer (MC)

> Sumber analisis: 104 SP `USP_MC_*` hasil ekstrak DB lokal (`scratchpad/sp/*.sql`), metadata (`meta/`), controller `app/Http/Controllers/MoneyChanger/*`, `routes/web/moneychanger.php`, view `resources/views/money_changer/*`, dan `MyController`.
> Bagian yang tidak bisa dipastikan dari kode (mis. DEFAULT constraint, isi master `GN_M_DocumentType`) diberi tanda **[VERIFIKASI]**. Database tidak di-query.

---

## 0. Konvensi teknis yang berlaku di seluruh modul

### 0.1 Kontrak pemanggilan SP (MyController)

- `exec_sp($sp, $params)` merangkai `EXEC sp v1,v2,...` **posisional**, urutan = urutan key array PHP (nama key tidak berpengaruh).
  - `is_numeric($v)` → dikirim tanpa kutip. Akibat: string angka seperti nomor nota `"001234"` dikirim sebagai `001234` → diterima SP `VARCHAR` sebagai `'1234'` (**nol di depan hilang**). Prefiks `'XXX'` memaksa nilai jadi string (prefiks dibuang).
  - String **tidak di-escape** (kecuali beberapa controller yang melakukan `str_replace("'", "''")` sendiri) → rawan SQL injection / error kutip.
- `store($state, $param)` memilih SP via properti `sp_create / sp_update / sp_delete / sp_approval / sp_reverse_approval / ...`, lalu membaca result set: **hanya baris terakhir** yang menentukan `Result` (`success`/`error`) dan `ID`; semua `LogDesc` digabung jadi pesan SweetAlert.
- Pola result set standar SP transaksi: tabel variabel `@TableLog(Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500))`; validasi menambah baris `error`, bila `COUNT(*)=0` baru proses, lalu tambah baris `('success', ID, 'Data Sudah Disimpan')`.

### 0.2 Pola error handling SP (penting untuk recode)

- Sebagian besar SP lama memakai `CATCH` dengan `CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())`. Ekspresi ini `INT + VARCHAR` → SQL Server mencoba konversi pesan ke INT → **error baru di dalam CATCH**, sehingga pesan asli tidak pernah sampai ke UI (muncul sebagai QueryException di PHP) dan blok `XACT_STATE` di bawahnya tidak dieksekusi. SP baru (NotaScan, CurrencyRate, KursBI) sudah memakai `CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE()` yang benar.
- Pada CATCH, bila `XACT_STATE() = 1` SP justru **COMMIT** (bukan rollback) → perubahan parsial bisa tersimpan.
- Pada Approve PO/SO: bila pembuatan jurnal gagal, SP menambah baris `error` **lalu tetap** menambah baris `success` dan **COMMIT** → `store()` membaca baris terakhir = `success`. Hasil: status Approved + kartu stok tercatat **tanpa jurnal** dan UI menampilkan sukses (dengan pesan "Create journal failed!" ikut tampil).
- Tidak ada trigger. Tidak ada FK kecuali `MC_T_NotaScanDetail.IDX_T_MC_NotaScan → MC_T_NotaScan`. Tidak ada pengecekan kunci periode GL (`GL_M_Period` dsb.) di SP MC mana pun → transaksi/approve/reverse bisa dilakukan pada periode yang sudah ditutup.

### 0.3 Kode status

| Objek | Kolom | Kode |
|---|---|---|
| Nota pembelian (PO) | `MC_T_PurchaseOrder.POStatus` | `D` Draft, `A` Approved, `V` Void, `C` Cancel, `F` Validate (label dari `USP_MC_*_List`; dalam praktik hanya `D`↔`A` yang dipakai) |
| Nota penjualan (SO) | `MC_T_SalesOrder.SOStatus` | sama dengan PO |
| Open/Close harian | `MC_T_OpenCloseDaily.TransactionStatus` | `O` Open, `C` Close (SP juga mengecek `A`,`F`) |
| Nota scan OCR | `MC_T_NotaScan.Status` | `D` Draft (satu-satunya yang dipakai) |
| LTKT / LTKM | `ReportStatus` | `O` (Open/belum dilaporkan) |
| Penerimaan/Pembayaran CM | `ReceiveStatus` / `PaymentStatus` | `A` Approved, `D` Draft |
| Record | `RecordStatus` | `A` aktif |
| Status bayar (computed di `*_Info`) | `ReceiveStatus`/`PaymentStatus` virtual | `P` Lunas bila total bayar ≥ total nota; `N` "Belum Lunas"/"Belum Dibayar" |

### 0.4 Jenis transaksi (`MC_M_TransactionType`, 5 baris)

Dari komentar SP: `1 BUY` (valas dibeli dari nasabah, baris dalam nota **penjualan**), `2 SELL` (valas dijual ke nasabah), `3 PO` (pembelian stok via nota **pembelian**), `4 ADJIN`, `5 ADJOUT` (tidak dipakai SP mana pun). Kode ini juga dipakai sebagai `MC_T_StockCardValas.IDX_M_TransactionType`.

### 0.5 Konstanta hardcoded (harus dipindah ke config saat recode)

| Konstanta | Nilai | Dipakai di |
|---|---|---|
| `IDX_M_Company` jurnal | `1` | semua SP jurnal MC, `COGSCalculationController`, `USP_MC_R_InventoryCalculation` |
| Mata uang dasar | `IDX 1 = IDR` (`BaseCurrency`, `IDX_M_Currency` payment) | Detail_Save, Payment |
| COA Piutang Usaha | `IDX_M_COA 5` (1115-001) | `USP_MC_SalesJournal_Create`, `USP_MC_SalesOrder_Payment` (COADetail) |
| COA Hutang Usaha | `IDX_M_COA 12` (2110-001) | `USP_MC_SalesJournal_Create` (baris BUY) |
| COA Rekening Antara | `IDX_M_COA 102` (9110-002) | `USP_MC_PurchaseJournal_Create`, `USP_MC_PurchaseOrder_Payment` |
| COA Persediaan / Kas / Pendapatan lain | `80`, `1`, `22`, `67` | dideklarasikan tapi **tidak dipakai** (akun persediaan riil diambil dari `MC_M_Currency.PurchaseAccount`) |
| JournalType | `2` Pembelian Valas, `5` Penjualan Valas, `8` HPP; `3` Financial Receive (CM) | SP jurnal |
| DocumentType | SO header `12`; Financial Receive `3`; Financial Payment `4`; PO header **tidak di-set SP** [VERIFIKASI DEFAULT constraint] | Save/Payment |
| Akun keuangan "CASH" | `IDX_M_FinancialAccount = 3` | LTKT, LTKM, `USP_MC_R_AR`, `USP_MC_R_AP` |
| Threshold LTKT | `500.000.000` | default param `USP_MC_LTKT_*` |
| User contoh | `'it_febry'` | `USP_MC_R_InventoryCalculation` memanggil `USP_MC_InventoryCalculation 1,@Period,'it_febry'` (laporan yang **menulis** data) |

---

## 1. Ringkasan fitur & alur bisnis end-to-end

Modul ini adalah KUPVA (penukaran valuta asing) dengan stok **per pecahan** (`MC_M_Valas` = mata uang × pecahan, mis. `USD-100`). Kuantitas selalu dalam **lembar/koin** (INT); nilai valas = lembar × nilai pecahan.

```
Master: Currency (kurs papan + akun GL) ── ValasChange (pecahan) ── Valas (SKU = CUR-pecahan)
                                │
 ┌──────────── Nota Pembelian (PO, beli stok dari supplier/bank) ───────────┐
 │ Save(DRAFT-n) → Detail* → Approve: nomor final, StockCard IN (type 3),   │
 │ Jurnal type 2 (Dr Persediaan / Cr Rek. Antara) → Payment (CM Payment,    │
 │ jurnal CM) → Reverse (hapus stok+jurnal; ditolak bila sudah dibayar)     │
 └──────────────────────────────────────────────────────────────────────────┘
 ┌──────────── Nota Penjualan (SO, transaksi kasir dengan nasabah) ─────────┐
 │ Baris SELL (2) & BUY (1) bisa dicampur dalam satu nota.                  │
 │ Save(DRAFT-n) → Detail* (cek stok) → Approve: cek stok per pecahan,      │
 │ nomor final, StockCard OUT (type 2) & IN (type 1), Jurnal type 5 →       │
 │ Receive (CM Receive + jurnal) → Reverse                                  │
 └──────────────────────────────────────────────────────────────────────────┘
 Input Cepat (Quick Sales/Purchase): header+detail+approve+pembayaran 1 layar
 Upload dokumen (KTP, bukti) per nota.  Nota Kasir/PDF.  Tab "Kartu Stok" (koreksi manual).
 Open/Close harian kasir (stok awal/akhir per pecahan).
 Bulanan: Hitung HPP rata-rata (COGSValasCalculation) → Generate Jurnal HPP (type 8)
 Kepatuhan: DTTOT (upload & screening nasabah), LTKT (tunai ≥ 500 jt/hari), LTKM (ditandai manual)
 Pelaporan BI: Kurs tengah BI (upload) → Laporan Bulanan BI (form B0001)
 Kurs papan: import paste Panin/BCA, update manual (dengan riwayat), display TV.
 Nota Scan OCR (Claude) → arsip nota kertas (tidak membuat SO/PO).
 Laporan & dashboard/analitik.
```

---

## 2. Proses per entitas

### 2.1 Master Mata Uang (`MC_M_Currency`)

| SP | Param penting | Controller / route |
|---|---|---|
| `USP_MC_Currency_List` | paging, `CurrencyName`, `CurrencyID`, `CountryName` (dynamic SQL) | `CurrencyController@inquiry_data` (`POST /mc-currency-list`), display kurs |
| `USP_MC_Currency_Info` | `@IDX_M_Currency` → + `SalesAccountDesc`, `PurchaseAccountDesc`, `COGSAccountDesc` (`COAID - COADesc`) | `@update`, `@duplicate` |
| `USP_MC_Currency_Save` | semua kolom master termasuk `BuyRate`, `SellRate`, `SalesAccount`, `PurchaseAccount`, `COGSAccount` | `POST /mc-currency/save` |
| `USP_MC_Currency_UpdateRate` | `@CurrencyID, @BuyRate, @SellRate, @UserID, @ChangeSource='IMPORT'` | import kurs Panin/BCA (`/mc-currency-import-kurs[-bca]/save`) |
| `USP_MC_CurrencyRate_Save` | `@IDX_M_Currency, @BuyRate, @SellRate, @ChangeSource='MANUAL', @UserID, @Silent, @ResultOut OUT` | `CurrencyRateController@save` (`POST /mc-currency-rate/save`) |
| `USP_MC_CurrencyRate_History_List` | `@IDX_M_Currency, @Row=50` | `/mc-currency-rate/history/{id}` |

Aturan:
- `Currency_Save`: error `'Currency ID already exists!'` bila `CurrencyID` dipakai currency lain. Insert/Update langsung, **termasuk BuyRate/SellRate tanpa mencatat riwayat** (jalur bypass history).
- `CurrencyRate_Save` (sumber kebenaran perubahan kurs):
  1. Currency tidak ada/tidak aktif → `notfound` `'Mata uang tidak ditemukan atau sudah tidak aktif.'`
  2. Rate < 0 → `error` `'Rate tidak boleh negatif.'`
  3. Rate sama persis → `nochange` `'Rate tidak berubah.'` (tidak menulis).
  4. Dalam 1 transaksi: insert `MC_T_CurrencyRateHistory` (BuyRate/SellRate **lama**, NewBuyRate/NewSellRate, `ChangeDate=GETDATE()`, `ChangeSource` default `'MANUAL'`), lalu update master.
  5. `@Silent=1` → tanpa result set, status via `@ResultOut`.
- `Currency_UpdateRate`: cari currency aktif by `UPPER(TRIM(CurrencyID))` (TOP 1 by IDX), hanya bila Buy>0 & Sell>0; memanggil `CurrencyRate_Save` silent; `success`/`nochange` → `Result='success'`, else `'notfound'`.
- Import kurs: teks tabel kurs disalin operator dari situs bank (situs diproteksi, tidak di-scrape); parsing di `app/Services/PaninKursParser.php` / `BcaKursParser.php` (BCA default kolom TT Counter). Alur paste → preview (tanpa tulis DB) → simpan (parse ulang).
- Kurs papan (`BuyRate/SellRate`) dipakai untuk **display kurs** (`/mc-display-kurs`, `/mc-display-kurs-tv`, `/display-kurs`, `/mc/kurs`) dan fallback kurs tengah BI Monthly. **Tidak** dipakai otomatis sebagai rate transaksi (rate diinput kasir per baris).
- `Rounding`, `Accuracy`, `IconFlag`, `SortPriority`: atribut tampilan; tidak dipakai dalam perhitungan SP.

### 2.2 Master Pecahan (`MC_M_ValasChange`) & Valas (`MC_M_Valas`)

| SP | Controller |
|---|---|
| `USP_MC_ValasChange_List/Info/Save` | `ValasChangeController` (`/mc-valas-change*`) |
| `USP_MC_Valas_List/Info/Save` | `ValasController` (`/mc-valas*`) |

- `ValasChange_Save`: `'Nama pecahan belum diisi!'`; `'Kode pecahan sudah ada!'` (case-insensitive, hanya jika ID tidak kosong). `ValasChangeNumber` kolom **INT** (param VARCHAR) → pecahan desimal (mis. koin 0.5) tidak didukung.
- `Valas_Save`: `'Nama mata uang belum diisi!'` (currency=0), `'Nama pecahan mata uang belum diisi!'`, `'Kode valas dengan nilai pecahan ini sudah ada!'` (unik `IDX_M_Currency + IDX_M_ValasChange`).
  - `ValasSKU = CurrencyID + '-' + ValasChangeNumber` **hanya saat insert**; update currency/pecahan tidak meng-generate ulang SKU (SKU bisa basi).
  - `BuyValue/SellValue/EffectiveDate` disimpan tapi tidak dipakai SP transaksi (ikut di dropdown `DropdownFinanceController::valas`).

### 2.3 Nota Pembelian Valas (PO) — `MC_T_PurchaseOrder`, `MC_T_PurchaseOrderDetail`

Controller: `PurchaseOrderController`, `PurchaseOrderDetailController`, `PurchaseOrderPaymentController`, `PurchaseQuickController`.

| SP | Param | Route |
|---|---|---|
| `USP_MC_PurchaseOrder_List` | paging + filter LIKE, `@UserID` (data scope cabang via `SM_M_UserBranch`), `@ReferenceNo` | `POST /mc-purchase-order-list` |
| `USP_MC_PurchaseOrder_Info` | `@IDX` → header + total & status bayar | update, payment, laporan |
| `USP_MC_PurchaseOrder_Save` | `@IDX_T_PurchaseOrder, @IDX_M_Company, @IDX_M_Branch, @IDX_M_Partner, @PONumber, @ReferenceNo, @PODate, @PONotes, @POStatus, @UserID, @RecordStatus, @FundSource=NULL, @TransactionPurpose=NULL` | `POST /mc-purchase-order/save`, `/mc-purchase-quick/save` |
| `USP_MC_PurchaseOrderDetail_Save` | `@IDX_T_PurchaseOrderDetail, @IDX_T_PurchaseOrder, @IDX_M_Valas, @IDX_M_Tax, @Quantity INT, @ForeignAmount, @ExchangeRate, @DetailNotes, @UserID, @RecordStatus` | `POST /mc-purchase-order-detail/save`, quick |
| `USP_MC_PurchaseOrderDetail_Delete` | `@IDX_T_PurchaseOrderDetail` | `/mc-purchase-order-detail/save-delete`, quick |
| `USP_MC_PurchaseOrderDetail_List/Info` | | tab detail |
| `USP_MC_PurchaseOrder_Approve` | `@IDX, @ApprovalDate VARCHAR(10), @ApprovalRemark, @UserID` | `POST /mc-purchase-order/save-approve`, quick (konfirmasi) |
| `USP_MC_PurchaseJournal_Create` | `@IDX, @UserID, @Result OUT` | dipanggil dari Approve |
| `USP_MC_PurchaseOrder_Reverse` | `@IDX, @ApprovalDate DATE, @ApprovalRemark, @UserID` | `POST /mc-purchase-order/save-reverse` |
| `USP_MC_PurchaseOrder_Payment` | `@IDX, @IDX_M_FinancialAccount, @PaymentAmount, @RemarkHeader, @PaymentDate, @UserID` | `POST /mc-purchase-order-payment/save` (state create), quick |
| `USP_MC_PurchaseOrderPayment_List` | `@IDX` | tab pembayaran |
| `USP_MC_PurchaseOrderUpload_Save/List` | lihat 2.6 | `POST /mc-purchase-order-upload` |
| `USP_MC_PurchaseOrder_NotaKasir` | `@IDX` → data cetak (perusahaan, cabang, nasabah, petugas) | `/mc-purchase-order/print-nota-kasir/{id}`, PDF |

**Save header** (`USP_MC_PurchaseOrder_Save`, tanpa transaksi):
- Validasi: `'Perusahaan uang belum diisi!'` (company=0), `'Cabang belum diisi!'`, `'Nomor nota belum diisi!'` (`ReferenceNo` kosong), `'Nomor nota sudah digunakan!'` (`ReferenceNo` unik global di seluruh PO, lintas cabang/status).
- Controller (form penuh) wajib: Company, Branch, Partner, PODate, PONotes; form penuh mengirim 11 parameter (tanpa FundSource/TransactionPurpose → tidak diubah). Quick: Partner `not_in:0` (`'Supplier belum diisi!'`), `ReferenceNo` (`'No nota belum diisi!'`), PODate, PONotes.
- Insert: `PONumber = 'DRAFT-' + IDX` (nomor sementara), `POStatus` dari form (`'D'`), `FundSource/TransactionPurpose = ISNULL(param,'')`. `IDX_M_DocumentType` **tidak diisi** [VERIFIKASI DEFAULT].
- Update: **tidak** mengubah `PONumber` dan `POStatus` (dikunci sistem); `FundSource/TransactionPurpose` hanya diubah jika param bukan NULL. Tidak ada cek status → header nota Approved masih bisa diedit (tanggal/partner/cabang berubah tanpa menyesuaikan stok & jurnal).

**Detail** (`USP_MC_PurchaseOrderDetail_Save`, dalam transaksi):
- `'Quantity pembelian harus lebih dari 0!'` (Qty=0), `'Exchange rate must be > 0!'`.
- Pecahan sama boleh berulang dalam satu nota (sengaja, mis. uang mulus vs rusak beda rate).
- Kalkulasi (input `@ForeignAmount` dari layar **diabaikan**):
  ```
  ForeignCurrency    = MC_M_Valas.IDX_M_Currency
  ForeignAmount      = ValasChangeNumber × Quantity
  BaseCurrency       = 1 (IDR)
  BaseCurrencyAmount = CONVERT(DECIMAL(18,2), ForeignAmount × ExchangeRate)   -- dibulatkan 2 desimal
  ```
- Pajak: lookup `GL_M_Tax` dilakukan tapi tidak dipakai (logika pajak dikomentari; `MC_T_PurchaseOrderTax` 0 baris).
- **Tidak ada cek status header** → detail nota Approved bisa diubah lewat SP (UI hanya menyembunyikan tombol jika `POStatus <> 'D'`); stok & jurnal tidak ikut berubah.
- `Detail_Delete`: ditolak `'Data sudah divalidasi, tidak bisa dihapus!'` bila `POStatus <> 'D'`; sukses `'Data Sudah Dihapus'`.

**Approve** (`USP_MC_PurchaseOrder_Approve`, satu transaksi):
1. Validasi: `'No Data in Detail Transaction'`; `'This order already approved!'` (status `A`/`F`); `'Approval Date must be greater than Order Date!'` bila `PODate > @ApprovalDate`.
2. Penomoran (lihat 2.5).
3. Update header: `POStatus='A'`, `POApprovalDate/By/Notes`; `PONumber` hanya diganti jika masih `DRAFT%` (re-approve setelah reverse memakai nomor lama).
4. Insert `MC_T_StockCardValas` per baris detail: `IDX_M_TransactionType=3`, `IDX_Transaction=IDX PO`, `TransactionNo=PONumber`, `TransactionDate=PODate` (**bukan** tanggal approval), `StockInQty=Quantity`, `ExchangeRateIn=ExchangeRate`, `StockInForeignAmount=Qty×Pecahan`, `StockInBaseAmount=Qty×Pecahan×Rate` (tanpa pembulatan), kolom Out = 0.
5. `EXEC USP_MC_PurchaseJournal_Create` → bila `@Result<>1` tambah `'Create journal failed!'` (tetap commit, lihat 0.2).

**Jurnal pembelian** (`USP_MC_PurchaseJournal_Create`, JournalType 2):
- Hapus jurnal lama `WHERE IDX_M_JournalType=2 AND IDX_ReferenceNo=@IDX` (tanpa nomor nota → idempoten).
- Header `GL_T_JournalHeader`: Company 1, Branch PO, Partner, `ReferenceNo=VoucherNo=PONumber`, `JournalDate=PostingDate=PODate`, `RemarkHeader='Transaksi pembelian valas'`, `PostingStatus='P'` (langsung posted), `JournalSource='S'`, `DebetAmount=CreditAmount=0` (tidak diisi), `UCreate/DCreate` = pembuat **nota** (bukan approver).
- Detail (hanya jika total > 0), semua dalam IDR (OriginalCurrency=1, rate=1):

| Sisi | Akun | Nilai | Granularitas |
|---|---|---|---|
| Debet | `MC_M_Currency.PurchaseAccount` (Persediaan Valas) | Σ BaseCurrencyAmount | 1 baris per valas (group currency+valas) |
| Kredit | COA `102` (9110-002 Rekening Antara) | Σ BaseCurrencyAmount | 1 baris total |

- Variabel `@_PaymentAmount` dihitung tapi tidak dipakai.

**Payment** (`USP_MC_PurchaseOrder_Payment`):
- Ditolak: `'Nota pembelian tidak ditemukan!'`; `'Nota pembelian <no> belum di-approve. Pembayaran hanya bisa diinput untuk nota yang sudah Approved.'` (rollback).
- **Tidak ada validasi jumlah** (boleh lebih/kurang dari sisa tagihan, boleh berulang).
- Insert `CM_T_FinancialPaymentHeader`: Company/Branch/Partner dari PO, `IDX_M_Currency=1`, `IDX_M_PaymentType=0`, `IDX_M_DocumentType=4`, `PaymentStatus='A'`, `PaymentAmount`, `ApprovalDate=PaymentDate`, `ApprovedBy=UserID`, `RemarkHeader` default `'Pembayaran pembelian valas'`.
- `PaymentID = DocumentTypeID(doc 4) + CONVERT(VARCHAR, IDX_M_Branch) + '-' + IDX_header` (memakai **IDX** cabang, bukan kode cabang).
- Detail `CM_T_FinancialPaymentDetail`: `IDX_M_DocumentType = PO.IDX_M_DocumentType`, `IDX_DocumentNo=IDX PO`, `DocumentNo=PONumber`, `COADetail=102`, `RemarkDetail='Pembayaran '+PONumber+' / '+ReferenceNo`.
- `EXEC USP_CM_FinancialPayment_CreateJournal` (detail jurnal di modul CM; secara pola: Dr `COADetail`=102 Rekening Antara / Cr COA akun keuangan) [VERIFIKASI di section CM].
- Edit pembayaran (`state=update`) memanggil `USP_MC_PurchaseOrderPayment_Save` yang **tidak ada di DB** → fitur edit rusak.

**Reverse** (`USP_MC_PurchaseOrder_Reverse`):
- Validasi: `'No Data in Detail Transaction'`; `'This order already draft!'`; `'Approval Date must be greater than Order Date!'`; `'TIdak bisa direverse, karena sudah ada pembayaran!'` bila ada payment `PaymentStatus='A'` yang terhubung lewat `IDX_DocumentNo` **dan** `IDX_M_DocumentType` (jika `PO.IDX_M_DocumentType` NULL, join gagal dan cek ini lolos — [VERIFIKASI]).
- Aksi: `POStatus='D'`, kosongkan approval (nomor final **dipertahankan**); hapus StockCard `IDX_Transaction=@IDX AND TransactionNo=PONumber AND type=3`; hapus jurnal type 2 by `IDX_ReferenceNo + ReferenceNo`.
- **Tidak** mengecek apakah stok pembelian ini sudah terjual → reverse bisa membuat saldo stok negatif.
- Controller mengirim `ApprovalDate` mentah dari form (tanpa `date()`).

### 2.4 Nota Penjualan Valas (SO) — `MC_T_SalesOrder`, `MC_T_SalesOrderDetail`

Controller: `SalesOrderController`, `SalesOrderDetailController`, `SalesOrderPaymentController`, `SalesQuickController`, `StockCardCheckController`.

SP: `USP_MC_SalesOrder_List/Info/Save/Approve/Reverse/Payment/NotaKasir`, `USP_MC_SalesOrderDetail_Save/Delete/List/Info`, `USP_MC_SalesOrderPayment_List`, `USP_MC_SalesOrderJournal_List`, `USP_MC_SalesOrderUpload_Save/List`, `USP_MC_SalesJournal_Create`, `USP_MC_ValasStock_List`. Route paralel dengan PO (`/mc-sales-order*`, `/mc-sales-quick/*`).

**Save header** (`USP_MC_SalesOrder_Save`): validasi identik PO (`'Perusahaan uang belum diisi!'`, `'Cabang belum diisi!'`, `'Nomor nota belum diisi!'`, `'Nomor nota sudah digunakan!'` — unik global `ReferenceNo` di SO). Insert `IDX_M_DocumentType=12`, `SONumber='DRAFT-'+IDX`. Update tidak menyentuh `SONumber/SOStatus`; `FundSource/TransactionPurpose` **ditimpa** (beda dengan PO yang ISNULL).

**Detail** (`USP_MC_SalesOrderDetail_Save`, transaksi):
- `'Quantity pembelian harus lebih dari 0!'`, `'Exchange rate must be > 0!'`, `'Jenis transaksi belum diisi!'` (`IDX_M_TransactionType=0`).
- Validasi stok (hanya untuk `IDX_M_TransactionType = 2`):
  ```
  CurrentStock  = Σ StockInQty − Σ StockOutQty  dari MC_T_StockCardValas
                  WHERE Branch = branch nota AND Valas = @Valas AND DATE(TransactionDate) <= SODate
                  (tanpa filter RecordStatus)
  QtyBarisLain  = Σ Quantity baris lain di nota ini (valas sama, type 2, RecordStatus 'A')  -- hanya jika SOStatus <> 'A'
  Error 'Tidak ada stok valas!'  bila (CurrentStock − QtyBarisLain) < @Quantity
  ```
  Catatan: untuk nota Approved, stok kartu sudah mengurangi baris itu sendiri, sehingga edit baris approved dinilai terlalu ketat (dan tetap tidak mengubah stok/jurnal).
- Kalkulasi sama dengan PO: `ForeignAmount = Pecahan × Qty`, `BaseCurrencyAmount = CONVERT(DECIMAL(18,2), ForeignAmount × Rate)`.
- Tidak ada cek status header (sama seperti PO). `Detail_Delete` ditolak jika `SOStatus <> 'D'`.

**Approve** (`USP_MC_SalesOrder_Approve`, transaksi) — commit terbaru `2fa87c3`:
1. `'No Data in Detail Transaction'`, `'This order already approved!'` (A/F), `'Approval Date must be greater than Order Date!'`.
2. Validasi stok per pecahan (baris type 2), memperhitungkan nota mundur tanggal:
   ```
   Req(valas)      = Σ Qty baris SELL di nota
   Daily(valas,d)  = Σ (In − Out) StockCard aktif (RecordStatus='A') cabang nota, per tanggal
   Running(valas,d)= kumulatif Daily s/d d
   Available       = MIN( Σ Daily s/d SODate ,  Running(d) untuk semua d > SODate )
   Error per valas : 'Stok <ValasSKU> tidak cukup: diminta <Qty> lembar, tersedia <max(Available,0)> lembar'
                     bila Req > Available   (format angka '0.##')
   ```
   (tidak mempertimbangkan baris BUY di nota yang sama sebagai sumber stok).
3. Penomoran (2.5), update `SOStatus='A'` dst.
4. StockCard: baris type 2 → `StockOutQty=Qty`, `ExchangeRateOut=Rate`, `StockOutForeignAmount=Qty×Pecahan`, `StockOutBaseAmount=Qty×Pecahan×Rate` (nilai **jual**, bukan HPP); baris type 1 → sisi In. `TransactionDate=SODate`, `IDX_M_TransactionType` = type baris.
5. `EXEC USP_MC_SalesJournal_Create` (pola error sama dengan PO).

**Jurnal penjualan** (`USP_MC_SalesJournal_Create`, JournalType 5, header `'Transaksi jual beli'`, posted `'P'`, tanggal = SODate; hapus-dulu by type+IDX):

| Kondisi | Debet | Kredit |
|---|---|---|
| Σ Base baris BUY (type 1) > 0 | `Currency.PurchaseAccount` per valas ('Persediaan Valas') | COA `12` 2110-001 Hutang Usaha, total ('Hutang pembelian Valas') |
| Σ Base baris SELL (type 2) > 0 | COA `5` 1115-001 Piutang Usaha, per valas ('Piutang penjualan valas') | `Currency.SalesAccount` per valas ('Penjualan valas') |

HPP **tidak** dijurnal saat approve; dijurnal bulanan (2.9).

**Receive / pembayaran nasabah** (`USP_MC_SalesOrder_Payment`): identik PO kecuali: `CM_T_FinancialReceiveHeader/Detail`, `IDX_M_DocumentType=3`, `ReceiveID = DocTypeID(3)+IDX_M_Branch+'-'+IDX`, `COADetail=5` (Piutang), remark default `'Penerimaan pembayaran penjualan valas'`, pesan `'Nota penjualan ... belum di-approve...'`, jurnal via `USP_CM_FinancialReceive_CreateJournal` (Dr COA akun keuangan / Cr `COADetail` Piutang; JournalType 3). Tidak ada validasi jumlah. Edit memanggil `USP_MC_SalesOrderPayment_Save` (**tidak ada di DB**).

**Reverse** (`USP_MC_SalesOrder_Reverse`):
- Validasi hanya: `'No Data in Detail Transaction'`, `'This order already draft!'` (validasi tanggal dikomentari; **tidak ada cek pembayaran**, beda dengan PO).
- Aksi: `SOStatus='D'`, kosongkan approval; hapus StockCard **hanya type 2** (`IDX_Transaction + TransactionNo + type=2`); hapus jurnal type 5.
- **Bug**: baris StockCard type 1 (BUY) **tidak dihapus** → re-approve menggandakan stok masuk (ini sebab adanya kolom `DupCount` di tab Kartu Stok). Jurnal HPP (type 8) yang sudah digenerate juga tidak dihapus. Penerimaan kas tetap ada.
- **Bug parameter**: `SalesOrderController@save_reverse` mengirim `[IDX, ApprovalRemark, ApprovalBy, UserID]` → `@ApprovalDate DATE` menerima teks remark (konversi gagal bila remark bukan tanggal/kosong), `@ApprovalRemark` = user id. [VERIFIKASI di UI]

**Status bayar & total** (`USP_MC_SalesOrder_Info`): `TotalSalesAmount = Σ BaseCurrencyAmount semua baris` (BUY+SELL dijumlah, bukan netto), `TotalReceiveAmount = Σ ReceiveAmount` (receive `A`, record `A`, match `IDX_M_DocumentType + IDX + SONumber`). `P/'Lunas'` jika receive ≥ total; `N/'Belum Lunas'` jika 0 < receive < total; default `N/'Belum Dibayar'`. PO identik (Payment).

**Nota kasir/PDF** (`SalesOrderController::nota_data`): `total_valas = Σ ForeignAmount`, `total_beli = Σ Base type 1`, `total_jual = Σ Base type≠1`, `total_net = total_jual − total_beli` (netto, **berbeda** dari TotalSalesAmount di Info/Quick). PDF A5 landscape.

### 2.5 Penomoran dokumen

| Dokumen | Format | Counter |
|---|---|---|
| Draft PO/SO | `DRAFT-<IDX>` | identity |
| PO/SO final (saat approve pertama) | `<DocumentTypeID>-<BranchID>-<YY><MM>-<NNNN>` | `MAX(CAST(RIGHT(no,4) AS INT)) + 1` atas nota cabang sama, `YEAR(tgl nota) = YEAR(ApprovalDate)`, bukan `DRAFT-%` |
| Financial Payment (PO) | `<DocTypeID doc 4><IDX_M_Branch>-<IDX header>` | identity |
| Financial Receive (SO) | `<DocTypeID doc 3><IDX_M_Branch>-<IDX header>` | identity |
| Voucher jurnal HPP | `HP-<SONumber>` | — |

- `YY`,`MM` dari **ApprovalDate**; reset counter **per tahun per cabang** (tahun tanggal nota). `DocumentTypeID` dari `GN_M_DocumentType` (SO = 12; PO dari kolom header [VERIFIKASI]).
- Risiko: tanpa lock (race → nomor ganda); `RIGHT(...,4)` membuat nomor ke-10000 menjadi `0000`; nota bertanggal Desember yang di-approve Januari memakai counter tahun lama tapi prefix YYMM tahun baru; nomor tidak pernah dikembalikan ke DRAFT saat reverse.

### 2.6 Upload dokumen (`OrderUploadTrait`)

- Route: `POST /mc-{purchase|sales}-order-upload`, `GET /mc-…-download/{id}`, `GET /mc-…-view-file/{id}`.
- Permission form: `FM-PI-U` (PO maupun SO); validasi: parent ID ≥1 & ada di tabel nota, `UploadCategory` wajib (`'Kategori dokumen belum dipilih!'`), file `jpg,jpeg,png,pdf` (plus `jfif` pada whitelist ekstensi), max 10 MB.
- File: `storage/app/public/upload-po|upload-so/<IDX>/<12hex>_<nama-bersih>.<ext>`; `FileDescription = '<Pembelian|Penjualan> Valas - <nomor nota>'`.
- SP `USP_MC_PurchaseOrderUpload_Save` / `USP_MC_SalesOrderUpload_Save`: insert baris (`RecordStatus 'A'`) lalu langsung mengembalikan list upload nota. Tidak ada SP delete. Download hanya via ID baris, dengan `realpath` guard (commit `cbc82c5`).

### 2.7 Input Cepat (Quick Sales / Quick Purchase)

Orkestrasi di **PHP** (bukan SP), tidak atomik:
1. Validasi Laravel (lihat 2.3/2.4); detail dari `detail_json` disaring: `foreign_amount>0 && exchange_rate>0 && idx_m_valas>0`; kosong → `'Minimal 1 baris detail valas harus diisi (valas, jumlah, nilai tukar).'`.
2. **Sales saja**: `periksa_stok` — dilewati jika nota sudah Approved; jumlahkan Qty per valas untuk type 2, bandingkan dengan `USP_MC_ValasStock_List(branch, SODate)` (`Sisa = ΣIn − ΣOut` s/d tanggal, semua status record, valas aktif). Pesan: `'Stok valas tidak mencukupi:<br><SKU>: diminta X lembar, sisa stok Y lembar'`. Endpoint `GET /mc-sales-quick/stok?branch&date` untuk layar.
3. `*_Save` header → bila update, hapus detail di `deleted_ids_json` via `*Detail_Delete` → `*Detail_Save` per baris (`IDX_M_Tax=0`, type default 2 untuk sales). Error per baris dikumpulkan `'Baris n: ...'` (header & baris lain sudah tersimpan).
4. Jika `confirm=1` (`konfirmasi_dan_bayar`):
   - `total_transaksi = Σ BaseCurrencyAmount` dari DB (bukan dari layar; BUY+SELL dijumlah).
   - `payment_json` disaring `amount>0`; wajib ≥1 baris (`'Pembayaran belum diisi...'`), tiap baris wajib akun (`'Cara bayar belum dipilih...'`), `|Σbayar − total| ≤ 0.01` (`'Total pembayaran X tidak sama dengan nilai transaksi Y.'`), nota belum punya pembayaran (`'Nota ini sudah punya pembayaran...'`).
   - Approve jika status ≠ A (`ApprovalDate = SODate/PODate`, remark `'Konfirmasi dari input cepat'`), lalu satu `*_Payment` per baris bayar (`ReceiveDate/PaymentDate = tanggal nota`).
   - Akun default layar: CASH = akun aktif pertama `FinancialAccountID LIKE 'CASH%' OR Desc LIKE '%Kas%'`; TRANSFER = utamakan `LIKE 'MAN%'` (Mandiri), lalu `BCA%`/`Bank%`.
5. JS layar (`sales_quick_form.blade.php`): total baris = `foreign × rate`, Qty integer, tombol konfirmasi menahan jika stok kurang / selisih bayar > 0.01.

### 2.8 Kartu Stok Valas (`MC_T_StockCardValas`)

- Ditulis **hanya** oleh `USP_MC_PurchaseOrder_Approve` (IN, type 3), `USP_MC_SalesOrder_Approve` (OUT type 2 / IN type 1), dihapus oleh Reverse, dan diedit/dihapus manual oleh `StockCardCheckController` (raw SQL, **tanpa cek permission & tanpa audit selain UModified**):
  - `GET /mc-stock-card-check/reload/{type}/{idx}` list baris + `DupCount` (duplikat per transaksi+no+valas).
  - `save`: set `StockInQty/StockOutQty`, `*ForeignAmount = qty × pecahan`, `*BaseAmount = qty × pecahan × ExchangeRateIn/Out`.
  - `save_delete`: hapus 1 baris by PK.
- Saldo stok (semua pemakai): `Σ StockInQty − Σ StockOutQty` per `(Branch, Valas)` s/d tanggal. Inkonsistensi filter `RecordStatus`: Approve SO & dashboard memfilter `'A'`, Detail_Save / ValasStock_List / R_StockCard tidak.
- `USP_MC_StockCardSummary_List`: ringkasan per cabang × valas (dynamic SQL): `BalanceQty`, `BalanceForeignAmount` (`/mc-stock-card`).
- `CheckStockCardController` (`/mc-check-stock-card`): rekonsiliasi raw SQL kartu stok vs detail nota (type 2: ΣStockOut vs ΣQty detail SO — **tanpa** filter type pada detail, sehingga nota campuran tampak selisih; type 3: ΣStockIn vs ΣQty detail PO).

### 2.9 HPP / COGS (rata-rata tertimbang bulanan per pecahan)

Controller `COGSCalculationController`: `POST /mc-cogs-calculation/save` → `USP_MC_COGSValasCalculation(1, YYYYMM, user)` (hasil SP **tidak diperiksa**); `POST /mc-cogs-calculation/save-generate-journal` → `USP_MC_GenerateJournalCOGSValas`. Validasi controller: periode `^\d{6}$`, bulan 01–12.

**`USP_MC_COGSValasCalculation`** (transaksi; `@IDX_M_Company` diabaikan; seluruh cabang digabung):
```
P = periode, Prev = P − 1 bulan
1. DELETE MC_T_COGSValasCalculation WHERE COGSPeriod = P
2. INSERT 1 baris per MC_M_Valas (semua, termasuk non-aktif), ValasChangeNumber dari pecahan, nilai 0
3. BB_ForeignAmount/BB_BaseAmount/BB_Qty = EB_* periode Prev (join Currency+Valas)
4. IN_* = Σ detail PO Approved (YEAR/MONTH PODate = P, ForeignAmount>0, Base>0):
         IN_Foreign = Σ ForeignAmount, IN_Base = Σ BaseCurrencyAmount, IN_Qty = Σ Quantity
5. AverageAmount = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign)        -- IDR per 1 unit valas
                   (hanya jika penyebut ≠ 0, selain itu tetap 0)
6. Sold_* = Σ detail SO Approved bulan P (ForeignAmount>0, Base>0) — SEMUA type (BUY ikut terhitung "terjual")
7. COGSAmount        = Sold_Qty × AverageAmount × ValasChangeNumber
8. GrossProfitAmount = Sold_BaseAmount − COGSAmount
9. EB_Qty     = BB_Qty + IN_Qty − Sold_Qty
   EB_Foreign = EB_Qty × ValasChangeNumber
   EB_Base    = EB_Qty × AverageAmount × ValasChangeNumber
```
Catatan bisnis [VERIFIKASI ke user]: baris BUY dari nasabah (type 1) **tidak** masuk IN tetapi **masuk** Sold → saldo HPP berbeda dari kartu stok. Perhitungan ulang periode lama tidak otomatis memperbarui periode sesudahnya (harus dijalankan berurutan). Tidak ada kunci periode.

**`USP_MC_GenerateJournalCOGSValas`** (satu transaksi untuk seluruh periode, cursor):
- `'Belum ada perhitungan COGS!'` jika tidak ada baris periode.
- Untuk tiap SO `SOStatus='A'` di bulan P → `USP_MC_COGSValasJournal_Create`. Gagal → `'Gagal membuat jurnal HPP untuk nota <SONumber> (IDX n). Cek apakah valas pada nota ini punya baris perhitungan HPP periode P.'`. Ada satu error → **ROLLBACK semua**. Sukses → `'Jurnal HPP periode P selesai dibuat untuk N nota penjualan.'` + `' M nota dilewati karena tidak ada penjualan valas.'`.

**`USP_MC_COGSValasJournal_Create`** (JournalType 8):
- Hapus jurnal type 8 lama by `IDX_ReferenceNo`.
- Hanya jika Σ Base baris SELL > 0: header `VoucherNo='HP-'+SONumber`, `RemarkHeader='Perhitungan HPP'`, tanggal = SODate, posted `'P'`.
- Detail per valas (join `MC_T_COGSValasCalculation` periode P; **semua baris nota, tanpa filter type**):
  - Dr `Currency.COGSAccount` = `ROUND(Σ Qty × AverageAmount × ValasChangeNumber, 2)` ('HPP Valas')
  - Cr `Currency.PurchaseAccount` = nilai sama ('HPP Persediaan valas')
- Jika tidak ada detail terbentuk → hapus header, `@Result=0`.

**Legacy (tidak dipakai kode)**: `USP_MC_COGSCalculation` (per mata uang, tabel `MC_T_COGSCalculation`, BB = pembelian bulan **sebelumnya** saja — rumus berbeda), `USP_MC_GenerateJournalCOGS` + `USP_MC_COGSJournal_Create` (tanpa ROUND, filter `IDX_T_SalesOrder > 2`).

**Inventory calculation** (`USP_MC_InventoryCalculation`, dipanggil oleh laporan `USP_MC_R_InventoryCalculation`):
```
Opening(Qty,Value) = Closing/InventoryValue periode sebelumnya (MC_T_InventoryCalculation)
In  = Σ Qty, Σ Base detail PO bulan P  -- TANPA filter POStatus (draft ikut!)
Out = Σ Qty, Σ Base detail SO type 2, SOStatus 'A', WHERE IDX_M_Branch = @IDX_M_Company (=1)
Closing  = Opening + In − Out
Average  = (OpeningValue + InValue) / (OpeningQty + InQty)          -- per lembar
COGS     = OutQty × Average ;  InventoryValue = ClosingQty × Average
DELETE + INSERT MC_T_InventoryCalculation periode P
```
Laporan `/mc-rpt-inventory-calculation` dengan demikian **menulis ulang data** setiap kali dibuka.

### 2.10 Open/Close harian kasir (`MC_T_OpenCloseDaily`, `…Detail`)

| SP | Route |
|---|---|
| `USP_MC_OpenCloseDaily_List/Info/Save` | `/mc-open-close*` |
| `USP_MC_OpenCloseDaily_Closing` | `POST /mc-open-close/save-closing` (param `IDX, TransactionDate, Notes, UserID`) |
| `USP_MC_OpenCloseDaily_Calculate` | `POST /mc-open-close/save-calculate` — **SP tidak ada di DB** |
| `USP_MC_OpenCloseDailyDetail_List/Info/Save` | `/mc-open-close-detail*` |
| `USP_MC_OpenCloseDailyItem_List`, `…Detail_Delete` | dipanggil controller, **tidak ada di DB** |

- `Save`: `'Teller belum diisi!'`, `'Status belum diisi!'`; insert baru ditolak `'Data transaksi hari ini sudah ada!'` (sudah ada record **tanggal sama**, global, bukan per cabang/teller) dan `'Masih ada transaksi perhitungan yang belum diselesaikan!'` (ada record tanggal lain yang `TransactionStatus <> 'C'`). Insert header (status awal `'O'` dari controller) + otomatis 1 detail per valas aktif (`OpenQty/InQty/OutQty/DiffQty = 0`, notes `'Persiapan harian dd Mon yyyy'`). `IDX_M_Company/IDX_M_Branch` NOT NULL tapi tidak diisi SP [VERIFIKASI DEFAULT].
- `DetailSave`: `'Data valas ini sudah ada!'` (insert duplikat valas). Qty Open/Close/Diff diinput manual (DiffQty hidden field, tidak dihitung server); insert mengabaikan `CloseQty`.
- `Closing` (transaksi): `'No Data in Detail Transaction'`; `'Transaksi sudah ditutup!'` (status A/F/C); `'Approval Date must be greater than Order Date!'`; `'Masih ada transaksi penjualan yang tertunda! <SONumber>'` / `'…pembelian yang tertunda! <PONumber>'` (ada nota Draft bertanggal = @TransactionDate, semua cabang); `'Data ini sudah pernah diproses!'` jika **ada record mana pun** berstatus `C` (global — kemungkinan bug yang memblokir closing hari-hari berikutnya [VERIFIKASI]). Proses: status `'C'`; `OutQty` = Σ Qty SO Approved type 2 pada tanggal header; `InQty` = Σ Qty SO Approved type 1 (PO **tidak** dihitung sebagai masuk). `OpenQty/CloseQty/DiffQty` tidak dihitung. Pesan sukses `'Data Sudah Diproses!'`.
- `USP_MC_OpenCloseDaily_Approve` (tidak dipakai): seperti Closing tetapi cek Draft **tanpa** filter tanggal.
- Laporan harian `USP_MC_R_DailyCalculation(@Branch, @Type, @Date, ...)`: baris = detail open/close tanggal itu LEFT JOIN detail SO approved tanggal itu (cabang); `BuyQuantity/BuyRate` (type 1), `SellQuantity/SellRate` (type 2), `ClosingQuantity = Opening + Buy − Sell`, `DiffQuantity = ClosingQuantity − CloseQty(manual)`.

### 2.11 Nota Scan OCR (`MC_T_NotaScan`, `MC_T_NotaScanDetail`)

- Upload foto nota → `app/Services/OcrService.php` (Anthropic Claude) → form review → simpan. Arsip saja; **tidak** membuat SO/PO/stok/jurnal. Tabel 0 baris.
- `USP_MC_NotaScan_Save`: `'Tipe transaksi tidak valid! Gunakan J (Jual) atau B (Beli).'`, `'Tanggal nota belum diisi!'`, `'No kwitansi <NoNota> sudah pernah disimpan!'` (unik `NoNota` aktif). Insert `Status='D'`.
- Update detail: controller memanggil `USP_MC_NotaScanDetail_DeleteAll` lalu `USP_MC_NotaScanDetail_Save` per baris (keduanya mensyaratkan header `Status='D'` dan aktif: `'Header nota scan tidak ditemukan atau sudah bukan Draft!'`). Validasi detail: `'Referensi header nota scan tidak valid!'`, `'Keterangan valuta asing belum diisi!'`, `'Nilai valuta asing harus lebih dari 0!'`, `'Nilai tukar (rate) harus lebih dari 0!'`. `TotalNilai = NilaiValas × NilaiTukar` **hanya jika** dikirim 0.
- `USP_MC_NotaScanDetail_Delete` disebut di komentar controller tapi tidak ada di DB (tidak dipanggil).

### 2.12 Kepatuhan APU-PPT

**DTTOT** (`DTTOTController`, SP `USP_GN_DTTOT_*`, `USP_GN_Partner_SetDTTOT` — modul GN):
- Upload Excel resmi → preview → `USP_GN_DTTOT_Clear` (hapus semua) → `USP_GN_DTTOT_Save` per baris (full replace).
- `USP_GN_DTTOT_Screening`: pecah `FullName` per segmen `' ALIAS '` (cursor), cocokkan ke `GN_M_Partner.PartnerName` aktif (UPPER/TRIM): `EXACT` bila sama; `PARTIAL` bila salah satu mengandung yang lain dan sisi yang dicari ≥ 5 karakter. Satu hasil per (partner, DTTOT), EXACT diprioritaskan.
- Admin menandai → `USP_GN_Partner_SetDTTOT` set `IsDTTOT 'Y'/'N'`. Flag juga bisa diubah di form partner.
- **Tidak ada blokir transaksi** untuk nasabah `IsDTTOT='Y'` di SO/PO (hanya informasi di LTKM).

**LTKT** (`LTKTController`, `/mc-ltkt*`, `/mc-rpt-ltkt`):
- Kandidat (`USP_MC_LTKT_Preview(@Period, @CashThreshold=500000000)` / `_Process`): SO Approved dalam bulan; `TotalSalesAmount = Σ Base semua baris aktif`; `PaymentCashAmount = Σ ReceiveAmount` receive `A` dengan `IDX_M_FinancialAccount = 3` (CASH); `DailyCashAmount = Σ PaymentCash per (Partner, Tanggal)`; ambil baris dengan `DailyCashAmount ≥ threshold`. Alamat = alamat partner default (`IsDefault='Y'`) atau pertama.
- `Process`: `ReportDueDate` = **hari kerja ke-14** (Senin–Jumat, tanpa kalender libur) setelah tanggal transaksi; `DELETE` periode lalu `INSERT` (`ReportStatus='O'`). Controller tidak mengirim threshold (pakai default). Hanya penjualan (SO) yang dinilai; pembelian tunai dari nasabah via PO tidak.

**LTKM** (`LTKMController`, `/mc-ltkm*`, `/mc-rpt-ltkm`):
- `USP_MC_LTKM_Preview`: semua SO Approved periode + `IsDTTOT`, `PaymentCashAmount`, `DailyCashAmount`, status TKM tersimpan (`InLTKM`, `TKMDate`, `TKMIndicator`).
- Proses: controller `USP_MC_LTKM_Clear(period)` lalu `USP_MC_LTKM_Save(period, IDX_SO, TKMDate, Indicator, user)` per baris dicentang. Save menghapus dulu baris dengan IDX SO sama (lintas periode), snapshot data nasabah & nominal, `ReportDueDate = TKMDate + 3 hari kalender`, `ReportStatus='O'`.

### 2.13 Kurs BI & Laporan Bulanan BI

**Kurs tengah BI** (`BIMiddleRateController`, `/mc-bi-middle-rate*`): upload file Kurs Transaksi BI → preview (disimpan di session) → `USP_MC_BIMiddleRate_Clear(RateDate)` → `USP_MC_BIMiddleRate_Save(RateDate, CurrencyID, RateUnit, SellRate, BuyRate, FileName, User)` dengan `MiddleRate = (SellRate + BuyRate)/2` (per kuotasi file, mis. JPY per 100; `RateUnit` disimpan tapi tidak dipakai membagi).

**Laporan Bulanan BI form B0001** (`BIMonthlyController`, `/mc-bi-monthly*`):
- `USP_MC_BIMonthly_Preview(@ReportPeriod)` per currency aktif ≠ IDR:
  - **Kurs tengah**, prioritas: (1) `BI` = `MC_T_BIMiddleRate` pada **tanggal akhir bulan**; (2) `RIIL` = kurs riil transaksi Approved: `KursBeli = ΣBase PO / ΣForeign PO`, `KursJual = ΣBase SO / ΣForeign SO`, `KursTengah = (Beli+Jual)/2` atau satu sisi yang ada; periode laporan, jika tidak ada pakai periode terakhir ≤ P; JPY dikali 100; (3) `MASTER` = `(Currency.BuyRate + SellRate)/2`.
  - **Mutasi**: jika HPP periode sudah dihitung (`HasCOGS`) → Opening/Buy/Sell dari `MC_T_COGSValasCalculation` (BB/IN/Sold, dijumlah per currency); jika belum → Opening = EB HPP periode lalu, Buy = PO Approved bulan P, Sell = **semua** detail SO Approved bulan P.
  - **Saldo awal** di-override: (a) `SAVED` = `ClosingForeign/ClosingIDR` laporan BI periode lalu yang tersimpan; else (b) `HITUNG` = `EB_Foreign` HPP periode lalu × kurs tengah BI akhir bulan lalu (fallback kurs master), JPY ÷100; else (c) `NIHIL` = 0.
  - Output hanya valuta dengan nilai ≠ 0: `ClosingForeign = Opening + Buy − Sell`; `ClosingIDR = ClosingForeign × MiddleRate` (JPY ÷ 100); `ProductType='1'`.
- Simpan: controller `USP_MC_BIMonthly_Clear(period)` lalu `USP_MC_BIMonthly_Save` per baris dicentang (CurrencyID dipaksa 3 huruf A–Z). SP menghitung ulang `ClosingForeign/ClosingIDR` dengan rumus sama (pembulatan DECIMAL(18,2)). Download Excel via `@download`.

**Kurs BI otomatis** (`USP_MC_KursBI_Save` upsert per tanggal+currency, `USP_MC_KursBI_Latest` dengan `MidPerUnit = ((Beli+Jual)/2)/Nilai`): direferensikan ke `App\Services\BIKursService` yang **tidak ada** di repo; tabel `MC_T_KursBI` 0 baris → fitur mati.

### 2.14 Laporan & Dashboard

| SP | Route/Controller | Inti logika |
|---|---|---|
| `USP_MC_R_Transaction(@Branch,@Type,@Start,@End,@Valas,@Currency,@Partner,@GroupBy='VALAS'|'NOTA'|'PARTNER')` | `/mc-rpt-so`, `/mc-rpt-po` (`RptTransactionController`) | Transaksi approved per cabang; `AverageAmount = AverageValue × Pecahan × Qty` dengan AverageValue: jika HPP periode lalu ada → `(BB_Base + IN_Base bulan berjalan)/(BB_Foreign + IN_Foreign)`, else kumulatif semua PO ≤ EndDate |
| `USP_MC_R_DailyCalculation` | `/mc-rpt-daily-calculation` | lihat 2.10 |
| `USP_MC_R_Customer(@Start,@End)` | `/mc-rpt-customer` | partner aktif berdasar `DCreate` + alamat default |
| `USP_MC_R_StockCard(@Branch,@Start,@End,@Valas,@Currency)` | `/mc-rpt-inventory` (`RptInventoryController`) | baris 'SALDO AWAL' (saldo < Start) + mutasi; ReferenceNo diisi dari nota approved; running balance dihitung di view |
| `USP_MC_R_StockMutationRecap(@Period)` | `/mc-rpt-mutation-recap` | agregat `MC_T_COGSValasCalculation` per currency; `EB_AverageRate = EB_Base/EB_Foreign` |
| `USP_MC_R_InventoryCalculation(@Period)` | `/mc-rpt-inventory-calculation` | **menjalankan** `USP_MC_InventoryCalculation` lalu SELECT |
| `USP_MC_R_COGSCalculation(@Period)` | `/mc-rpt-cogs-calculation` | SELECT `MC_T_COGSValasCalculation` |
| `USP_MC_R_AR` / `USP_MC_R_AP` | `/mc-rpt-ar`, `/mc-rpt-ap` | nota approved periode; `PaymentCash` (akun 3) & `PaymentTransfer` (akun ≠3); `Outstanding = Total − Cash − Transfer` |
| `USP_MC_R_DashboardSales`, `_Dashboard_Average/_Stock/_SalesValas/_PurchaseValas` | `HomeController` (dashboard MC, `/mc-dashboard-valas-pdf`) | volume jual/beli; stok (`StockCard` aktif ≤ AsOfDate) × average (logika sama dengan R_Transaction) |
| `USP_MC_A_*` (7 SP) | `AnalyticController` `/mc-analytic-*` | GL-based: Kas&Bank (COA 1110,1111), Persediaan (1117), Revenue 4100/4200/7110, COGS 5110/5113, OpEx 6110–6113/8110/8111, likuiditas (aset 1110/1111/1115/1117/1119/1120/1121; liab 2110/2115/2119/2120); posisi valas `Σ(In−Out)×Pecahan × AvgRate(ΣBase PO/ΣForeign PO)`; margin `AvgSellRate − AvgBuyRate` (spread dihitung di view) |
| `USP_MC_R_TransactionCustomer` | — (tidak dipakai) | |

---

## 3. Tabel `MC_*`

Relasi semuanya implisit (tanpa FK) kecuali NotaScanDetail.

| Tabel | Rows | Tujuan | Kolom kunci & relasi |
|---|---|---|---|
| `MC_M_Currency` | 26 | Mata uang, kurs papan, akun GL | `IDX_M_Currency`, `CurrencyID`, `BuyRate/SellRate`, `SalesAccount/PurchaseAccount/COGSAccount` → `GL_M_COA.IDX_M_COA`, `IDX_M_Country` → `GN_M_Country` |
| `MC_M_ValasChange` | 19 | Pecahan | `ValasChangeNumber INT` |
| `MC_M_Valas` | 143 | SKU valas = currency × pecahan | `IDX_M_Currency`, `IDX_M_ValasChange`, `ValasSKU` |
| `MC_M_TransactionType` | 5 | 1 BUY, 2 SELL, 3 PO, 4 ADJIN, 5 ADJOUT | |
| `MC_T_PurchaseOrder` | 2.349 | Header nota pembelian | `PONumber`, `ReferenceNo` (no nota manual, unik), `POStatus`, `IDX_M_Branch/Partner/Company/DocumentType`, `FundSource`, `TransactionPurpose` |
| `MC_T_PurchaseOrderDetail` | 4.739 | Baris pembelian | `IDX_T_PurchaseOrder`, `IDX_M_Valas`, `Quantity INT`, `ForeignAmount`, `ExchangeRate`, `BaseCurrencyAmount` |
| `MC_T_PurchaseOrderTax` | 0 | Pajak (tidak dipakai) | |
| `MC_T_PurchaseOrderUpload` | 4.527 | Dokumen nota pembelian | `IDX_T_PurchaseOrder`, `UploadCategory`, `FilePath`, `FileName` (kolom typo `DModifed`) |
| `MC_T_SalesOrder` | 1.855 | Header nota penjualan (jual+beli nasabah) | sama dengan PO, `SONumber`, `SOStatus`, `IDX_M_DocumentType=12` |
| `MC_T_SalesOrderDetail` | 4.215 | Baris jual/beli | + `IDX_M_TransactionType` (1/2) |
| `MC_T_SalesOrderUpload` | 4.448 | Dokumen nota penjualan | |
| `MC_T_StockCardValas` | 8.944 | Kartu stok per cabang × valas | `IDX_M_Branch`, `IDX_M_Valas`, `IDX_M_TransactionType`, `IDX_Transaction` (IDX PO/SO), `TransactionNo`, `TransactionDate`, `StockIn/OutQty`, `ExchangeRateIn/Out`, `*ForeignAmount`, `*BaseAmount` |
| `MC_T_COGSValasCalculation` | 995 | HPP bulanan per valas | `COGSPeriod` (YYYYMM), `IDX_M_Currency`, `IDX_M_Valas`, BB/IN/Sold/EB (Foreign, Qty, Base), `AverageAmount`, `COGSAmount`, `GrossProfitAmount` |
| `MC_T_COGSCalculation` | 16 | HPP per currency (legacy) | |
| `MC_T_InventoryCalculation` | 321 | Persediaan bulanan (dari laporan) | `CalculationPeriod`, `IDX_M_Valas`, Opening/In/Out/Closing, Average, COGS, InventoryValue |
| `MC_T_OpenCloseDaily` | 1 | Header buka/tutup kasir | `TransactionDate`, `TransactionStatus`, `TellerID`, `IDX_M_Company/Branch` |
| `MC_T_OpenCloseDailyDetail` | 130 | Qty per valas | `OpenQty, InQty, OutQty, CloseQty, DiffQty` |
| `MC_T_CurrencyRateHistory` | 0 | Riwayat perubahan kurs papan | old/new rate, `ChangeSource` |
| `MC_T_BIMiddleRate` | 182 | Kurs transaksi BI harian | `RateDate`, `CurrencyID`, `RateUnit`, `Buy/Sell/MiddleRate` |
| `MC_T_BIMonthly` | 154 | Laporan bulanan BI B0001 tersimpan | `ReportPeriod`, `CurrencyID`, Opening/Buy/Sell/Closing (Foreign & IDR), `MiddleRate` |
| `MC_T_KursBI` | 0 | Kurs BI otomatis (fitur mati) | |
| `MC_T_LTKT` | 0 | Kandidat LTKT | `LTKTPeriod`, snapshot nasabah, `DailyCashAmount`, `ReportDueDate`, `ReportStatus` |
| `MC_T_LTKM` | 0 | TKM yang ditetapkan | + `TKMDate`, `TKMIndicator`, `IsDTTOT` |
| `MC_T_NotaScan` / `…Detail` | 0 / 0 | Arsip OCR nota | FK detail → header |
| `MC_T_POSValas` / `…Detail` | 0 / 0 | POS valas — tidak dipakai SP/kode | |

---

## 4. Kesenjangan SP vs kode

### 4.1 SP di DB yang tidak dipanggil kode secara langsung

| SP | Status |
|---|---|
| `USP_MC_PurchaseJournal_Create`, `USP_MC_SalesJournal_Create` | dipakai **tidak langsung** (dari Approve) |
| `USP_MC_COGSValasJournal_Create` | tidak langsung (dari `GenerateJournalCOGSValas`) |
| `USP_MC_InventoryCalculation` | tidak langsung (dari `R_InventoryCalculation`) |
| `USP_MC_COGSCalculation`, `USP_MC_GenerateJournalCOGS`, `USP_MC_COGSJournal_Create` | legacy, mati |
| `USP_MC_OpenCloseDaily_Approve` | mati (digantikan Closing) |
| `USP_MC_KursBI_Save`, `USP_MC_KursBI_Latest` | mati (service tidak ada) |
| `USP_MC_R_TransactionCustomer` | mati |

### 4.2 SP yang dipanggil kode tapi tidak ada di DB (akan error bila jalur dipakai)

`USP_MC_PurchaseOrderPayment_Save`, `USP_MC_SalesOrderPayment_Save` (edit pembayaran), `USP_MC_PurchaseOrder_Duplicate`, `USP_MC_SalesOrder_Duplicate` (route `/mc-*-order/save-duplicate`; view duplicate form juga tidak ada di `resources/views/money_changer`), `USP_MC_PurchaseOrderSearchByValue_List`, `USP_MC_SalesOrderSearchByValue_List`, `USP_MC_PurchaseOrderItem_List`, `USP_MC_SalesOrderItem_List`, `USP_MC_OpenCloseDailyItem_List`, `USP_MC_OpenCloseDailyDetail_Delete`, `USP_MC_OpenCloseDaily_Calculate` (route `/mc-open-close/save-calculate`).
Hanya di komentar (aman): `USP_MC_NotaScanDetail_Delete`, `USP_MC_PurchaseOrderDetailDetail_List`, `USP_MC_SalesOrderDetailDetail_List`, `USP_MC_OpenCloseDailyDetailDetail_List`, `USP_MC_R_Dashboard_SalesPartner`.

---

## 5. Catatan untuk recode

### 5.1 Risiko & logika tersembunyi (prioritas)

1. **Atomicity Approve**: jurnal gagal tetap commit + UI sukses. Recode: satu `DB::transaction()` untuk status + nomor + stok + jurnal; lempar exception bila jurnal gagal.
2. **Reverse SO** tidak menghapus stok BUY (type 1), tidak cek pembayaran, tidak menghapus jurnal HPP; parameter dari controller salah urut. **Reverse PO** tidak cek stok sudah terjual. Perlu keputusan bisnis sebelum disalin.
3. **Edit nota Approved** dimungkinkan di SP (header & detail) tanpa sinkron stok/jurnal; hanya UI yang membatasi. Recode: guard di service (`status === 'D'`).
4. **HPP**: baris BUY di SO dihitung sebagai "Sold" dan ikut dijurnal HPP, tetapi tidak sebagai IN → kemungkinan salah secara akuntansi [VERIFIKASI ke akuntan]. Jurnal BUY di SO kredit Hutang Usaha (2110-001) sementara penerimaan kas nota mengkredit Piutang (5) → akun hutang tidak pernah terselesaikan oleh alur MC.
5. **Penomoran** tanpa lock & limit 9999 per tahun per cabang; gunakan tabel sequence + `lockForUpdate`.
6. **exec_sp**: string angka kehilangan nol depan (ReferenceNo), tanpa escaping. Recode wajib parameter binding; putuskan apakah normalisasi nol-depan dipertahankan untuk data lama (cek duplikat `ReferenceNo`).
7. **CATCH rusak** (`INT + VARCHAR`) — perilaku error saat ini tidak bisa diandalkan sebagai spesifikasi.
8. **Stok**: inkonsistensi filter `RecordStatus`; koreksi manual kartu stok tanpa permission/audit; tidak ada mekanisme ADJIN/ADJOUT resmi (type 4/5) — koreksi seharusnya lewat dokumen adjustment.
9. **Tidak ada kunci periode** pada approve/reverse/payment/HPP; HPP harus dihitung berurutan per bulan (EB→BB).
10. **Hardcoded**: COA 5/12/102, FinancialAccount 3 (CASH), DocumentType 3/4/12, JournalType 2/5/8, Company 1, threshold LTKT, hari kerja tanpa libur nasional.
11. **Open/Close**: unik per tanggal global, closing diblokir jika ada record `C` mana pun, PO tidak dihitung sebagai `InQty`, SP `Calculate` tidak ada.
12. **Dynamic SQL** di semua `*_List` (concat LIKE & ORDER BY dari input) → injection; sort `PartnerName` memakai alias `GMP` yang tidak ada di FROM SO List (bug).
13. Laporan yang **menulis** data (`R_InventoryCalculation`); `InventoryCalculation` memasukkan PO Draft dan memakai `Branch = @IDX_M_Company`.
14. DTTOT tidak memblokir transaksi; LTKT hanya menilai SO (bukan PO) dan akun kas hardcoded.
15. Total nota tidak konsisten: Info/Quick/LTKT memakai Σ semua baris (gross), Nota Kasir memakai netto (jual − beli).

### 5.2 Pemetaan ke service class Laravel (usulan)

| Service | Tanggung jawab | Menggantikan |
|---|---|---|
| `Mc\CurrencyService` / `CurrencyRateService` | master, update kurs + history (satu-satunya jalur ubah rate), import parser | `Currency_*`, `CurrencyRate_*`, `Currency_UpdateRate` |
| `Mc\ValasService` | pecahan & SKU | `Valas_*`, `ValasChange_*` |
| `Mc\DocumentNumberService` | nomor final & ID pembayaran (lock) | blok penomoran di Approve/Payment |
| `Mc\StockLedgerService` | posting/unposting kartu stok, saldo per tanggal, `availableQty(branch, valas, date)` dengan aturan "minimum running balance" | StockCard insert/delete, `ValasStock_List`, cek stok Detail/Approve/Quick |
| `Mc\PurchaseOrderService` / `SalesOrderService` | save, detail (rumus amount), approve, reverse, guard status | `*_Save`, `*Detail_*`, `*_Approve`, `*_Reverse` |
| `Mc\McJournalService` (pakai `GlJournalService` umum) | jurnal type 2/5/8, mapping akun dari config | `*Journal_Create` |
| `Mc\McPaymentService` (memakai service CM) | receive/payment + jurnal CM, validasi jumlah (baru) | `*_Payment` |
| `Mc\QuickTransactionService` | orkestrasi quick dalam satu transaksi DB | `SalesQuickController`/`PurchaseQuickController::save` |
| `Mc\CogsService` | hitung HPP bulanan + generate jurnal HPP | `COGSValasCalculation`, `GenerateJournalCOGSValas` |
| `Mc\DailyCashierService` | open/close | `OpenCloseDaily_*` |
| `Mc\Compliance\{DttotService, LtktService, LtkmService}` | screening, kandidat, due date (kalender kerja) | `USP_GN_DTTOT_*`, `LTKT_*`, `LTKM_*` |
| `Mc\BiReportService` | kurs tengah & B0001 | `BIMiddleRate_*`, `BIMonthly_*` |
| `Mc\Reports\*` (query objects read-only) | laporan/dashboard | `USP_MC_R_*`, `USP_MC_A_*` |

Config usulan `config/money_changer.php`: `company_id`, `base_currency_id`, `coa.{receivable,payable,interim}`, `journal_type.{purchase,sales,cogs}`, `document_type.{so,po,receive,payment}`, `cash_financial_account_ids`, `ltkt.threshold`, `ltkt.workdays`, `ltkm.due_days`.

### 5.3 Urutan migrasi yang aman

1. **Read-only dulu**: laporan, dashboard, analitik, list/info (ganti dynamic SQL dengan query builder). Bandingkan output lama vs baru (snapshot test).
2. Master (Currency/Rate/Valas/ValasChange) + `CurrencyRateService` (tutup bypass history di Currency_Save).
3. `StockLedgerService` (fungsi saldo & cek stok) — pakai di UI/validasi sambil SP lama masih menulis.
4. Save header/detail PO & SO (dengan guard status baru) dan upload.
5. Approve/Reverse/Payment + jurnal dalam satu transaksi; perbaiki bug reverse SO; jalankan paralel (shadow) dan rekonsiliasi `MC_T_StockCardValas` + `GL_T_Journal*` per nota.
6. Quick transaction (atomik).
7. HPP & jurnal HPP (setelah keputusan bisnis soal baris BUY), lalu BI Monthly yang bergantung pada HPP.
8. Kepatuhan (DTTOT/LTKT/LTKM), Open/Close (redesign), Nota Scan.
9. Bersihkan SP/route mati (4.1, 4.2) dan data duplikat kartu stok (lihat `DupCount`).

### 5.4 Test case penting

- Detail: `ForeignAmount` selalu = pecahan × qty (input layar diabaikan); `BaseCurrencyAmount` dibulatkan 2 desimal; qty 0 / rate 0 ditolak.
- Stok: jual melebihi saldo s/d tanggal nota → ditolak; dua baris pecahan sama dijumlahkan; nota mundur tanggal yang membuat saldo masa depan negatif → ditolak di approve (pesan per SKU); baris BUY tidak divalidasi stok.
- Approve: nomor `DOC-BRANCH-YYMM-0001` pertama tahun, increment per cabang, reset tahun baru, re-approve setelah reverse mempertahankan nomor; `ApprovalDate < tanggal nota` ditolak; status A ditolak.
- Jurnal: PO → Dr PurchaseAccount per valas / Cr 102 total, balance; SO campuran → dua pasang (persediaan/hutang & piutang/penjualan); approve ulang tidak menggandakan jurnal.
- Payment: ditolak pada Draft; ID pembayaran; jurnal CM terbentuk; status Lunas/Belum Lunas di Info.
- Reverse: PO dengan pembayaran approved ditolak; stok & jurnal terhapus; (perilaku baru) SO reverse menghapus type 1 juga.
- Quick: selisih bayar > 0.01 ditolak; nota sudah dibayar ditolak; kegagalan di tengah tidak meninggalkan data parsial (perilaku baru).
- HPP: contoh numerik BB+IN → Average; COGS = SoldQty × Avg × pecahan; EB periode N = BB periode N+1; jurnal HPP di-ROUND 2 desimal & balance; satu nota gagal → seluruh periode rollback.
- LTKT: agregasi tunai per nasabah per hari ≥ 500 jt; due date hari kerja ke-14 melewati akhir pekan; proses ulang mengganti data periode.
- LTKM: due date +3 hari; simpan ulang menghapus baris SO yang sama.
- BI Monthly: prioritas kurs BI → RIIL → MASTER; JPY ÷100 / ×100; saldo awal dari laporan tersimpan bulan lalu.
- Kurs: rate sama → `nochange` tanpa history; rate negatif ditolak; history menyimpan nilai lama.
- DTTOT screening: alias split `' ALIAS '`, EXACT vs PARTIAL (minimal 5 karakter).
