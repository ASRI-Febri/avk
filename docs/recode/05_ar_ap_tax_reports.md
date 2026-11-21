# Modul Cash Management – Invoice, Refund, Pajak & Laporan (CM)

> Cakupan: `USP_CM_SalesInvoice*`, `USP_CM_PurchaseInvoice*`, `USP_CM_SalesRefund*`, `USP_CM_PurchaseRefund*`, `USP_CM_PaymentAllocation*`, `USP_CM_ReceiveAllocation*`, `USP_CM_FakturNumber*`, SP pajak (`*Tax*`) di CM, seluruh `USP_CM_R_*`, beserta tabel `CM_*` terkait.
> Treasury (Financial Payment/Receive, transfer, petty cash, bank statement) dibahas di bagian lain; di sini hanya titik interaksinya.
> Sumber: source SP hasil ekstrak dari AVKDB (read-only), metadata `meta/*`, controller `app/Http/Controllers/Finance/*`, `routes/web/finance.php`.

---

## 0. Temuan utama (baca dulu)

1. **Semua tabel transaksi modul ini kosong (0 row)**: `CM_T_SalesInvoice*`, `CM_T_PurchaseInvoice*`, `CM_T_SalesRefund*`, `CM_T_PurchaseRefund*`, `CM_T_ReceiveAllocation`, `CM_T_PaymentAllocation`, `CM_M_FakturNumber*`, `CM_T_FakturPajak`, `CM_T_TaxInvoice*`. Master pajak `GL_M_Tax` juga **0 row**, dan `GL_M_FiscalPeriod` **0 row**. Fitur AR/AP/pajak ini praktis **belum pernah dipakai di produksi**.
2. Kode SP berasal dari produk lain (komentar menyebut `PralonDB`, `CoreDB`, "ASBS", item `MAKITA`, "BIAYA CIBODAS") dan merujuk objek yang **tidak ditemukan di metadata AVKDB** (150 tabel yang diekstrak):
   `IN_M_Item`, `IN_M_UOM`, `IN_M_Brand`, `IN_M_LocationInventory`, `PR_T_PurchaseOrder`, `PR_T_PurchaseOrderDetail`, `PS_T_PosOrderLine`, `X_SalesSummary_Quality`, `X_MemberSummary_Quality`, view `View_PurchaseInvoiceOS`, fungsi `fn_GetSalesInvoicePayment`, SP `USP_CheckUserForm`.
   **Terverifikasi 2026-11-21:** `OBJECT_ID()` untuk `IN_M_Item`, `PR_T_PurchaseOrder`, `X_SalesSummary_Quality`, `fn_GetSalesInvoicePayment`, `USP_CheckUserForm` = NULL dan tidak ada synonym. Jadi SP berikut **pasti gagal** dengan error 208 "Invalid object name":
   - `USP_CM_SalesInvoiceHeader_Update` (selalu cek `X_MemberSummary_Quality`/`X_SalesSummary_Quality`).
   - `USP_CM_SalesInvoice_Approve` (selalu `LEFT JOIN X_SalesSummary_Quality`).
   - `USP_CM_SalesInvoiceDetail_Create/_Update` (baca `IN_M_Item` saat item ≠ 0), `USP_CM_SalesInvoiceDetail_List/_Info` (join `IN_M_Item`).
   - `USP_CM_PurchaseInvoiceHeader_Create/_Update` (cek `PR_T_PurchaseOrder`).
   - `USP_CM_SalesInvoice_Info` (join `fn_GetSalesInvoicePayment`).
   - `USP_CM_ReceiveAllocation_Create/_Update`, `USP_CM_PaymentAllocation_Create/_Update/_CreateMultiple` (`EXEC USP_CheckUserForm`, yang tidak ada; yang ada `USP_SM_CheckUserForm`).
   - Laporan `USP_CM_R_PaymentPO_Period`, `USP_CM_R_PaymentSPK_Period` (berbasis `PR_T_PurchaseOrder`).
   Ini konsisten dengan tabel yang kosong. **Saran: perlakukan recode modul ini sebagai implementasi baru berbasis spesifikasi di bawah, bukan porting 1:1.**
3. Pola error-handling semua SP cacat: `CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())` → int + varchar memicu error konversi kedua di dalam `CATCH`; selain itu `CATCH` melakukan **`COMMIT` bila `XACT_STATE() = 1`** (commit parsial). Beberapa validasi menulis `'New Invoice'` ke kolom `ID BIGINT` di `@TableLog` → error konversi. Pesan error asli praktis tidak pernah sampai ke UI.
4. Tidak ada kontrol status di SP detail/pajak: detail & pajak invoice yang sudah **Approved** tetap bisa diubah/dihapus di level SP (hanya UI yang membatasi, jika ada).

---

## 1. Ringkasan fitur & alur bisnis

```
            (Sales / AR)                                     (Purchase / AP)
 SalesInvoiceHeader_Create  (D, DRAFT-n)             PurchaseInvoiceHeader_Create (D, DRAFT-n)
        │ + Detail_Create (hitung DPP/PPN)                  │ + Detail_Create (PPN saja)
        │ + Tax_Create (PPh tambahan)                       │ + Tax_Create (PPh tambahan)
        ▼                                                    ▼
 SalesInvoice_Approve  (A, nomor final, jurnal SJ)   PurchaseInvoice_Approve (A, nomor final, jurnal PJ,
        │                                                    │   cek total ≤ PO/SPK)
        ├─ ReverseValidate → D (jurnal di-unpost)            ├─ ReverseValidate → D
        ├─ Void → V (jurnal balik, tipe 11)                  └─ (Void: SP ada tapi tidak dipakai)
        ├─ Duplicate → invoice baru D
        ▼                                                    ▼
 Pelunasan via Financial Receive (Treasury)          Pelunasan via Financial Payment (Treasury)
   ReceiveAllocation_Create (D) → _Approve (A,         PaymentAllocation_Create (D) → _Approve (A,
   jurnal tipe 8 jika COA alokasi ≠ COA detail)        jurnal tipe 9)
   (shortcut: SalesInvoice_Payment)                    (shortcut: PurchaseInvoice_Payment)
        ▼
 SalesRefundHeader_Create (copy detail+tax invoice) → SalesRefund_Approve (jurnal SR, tipe 3) → SalesRefund_Void
 PurchaseRefundHeader_Create → PurchaseRefund_Approve  (tidak lengkap, tidak dipakai)

 Faktur pajak: FakturNumber_Create (12 periode setahun) → FakturNumber_Line_Create (range nomor NSFP)
   → nomor dipilih di invoice (TaxInvoiceNo) → SalesInvoice_Approve menandai isUsed=1
   → SalesInvoice_FakturHeader_Export (baris "FK" CSV e-Faktur).
```

Konsep pajak:
- **PPN** (`GL_M_Tax.IsWithHoldingTax = 0`): dipilih langsung di baris detail (`IDX_M_Tax`, `IncludeTax`). Dihitung per **unit** dan disimpan di `CM_T_*InvoiceDetail.TaxAmount` serta baris otomatis di `CM_T_*InvoiceTax` (`AllowEdit='N'`).
- **PPh** (`IsWithHoldingTax = 1`): ditambahkan lewat "Additional Tax" (`*InvoiceTax_Create`, `AllowEdit='Y'`), per baris detail. Amount PPh berupa nilai **negatif** (indikasi: validasi approve "TaxAmount < 0 → gunakan PPh", jurnal memakai `ABS()`); diduga `GL_M_Tax.TaxRate` untuk PPh disimpan negatif — **tidak bisa diverifikasi** karena `GL_M_Tax` kosong.
- COA pajak: Sales memakai `GL_M_Tax.COAIn`, Purchase memakai `GL_M_Tax.COAOut`.

---

## 2. Konvensi umum SP & pemanggilan

- Dipanggil lewat `MyController::exec_sp()` (EXEC positional, parameter digabung string) dan `store($state,$param)` yang memilih `sp_create/sp_update/sp_delete/sp_approval`. Urutan `$param` **harus** sama dengan urutan parameter SP.
- Hasil SP: tabel `@TableLog(Result VARCHAR(20) 'success'|'error', ID BIGINT, LogDesc VARCHAR(500))`. Semua validasi dikumpulkan dulu; bila `COUNT(*)=0` baru menulis. Pesan sukses: `'Data Sudah Disimpan'`, `'Data Sudah Dihapus'`, `'Data Berhasil Di Update'`, `'Data Berhasil Duplikat ke DRAFT-n'`.
- `UserID` dari controller header/approve diberi prefix **`'XXX'`** (`'XXX'.$this->data['user_id']` atau `'XXX'.$data['ApprovalBy']` — `ApprovalBy` diambil dari request, bisa dipalsukan). Akibatnya `UCreate/ApproveBy` = `XXX1406069`, join ke `SM_M_User.LoginID` di `*_Info` tidak ketemu. Detail/tax/payment controller **tanpa** prefix.
- Kunci periode: dua cek berbeda, keduanya ke `GL_M_FiscalPeriod` (tabel kosong ⇒ cek selalu lolos):
  - `FiscalPeriod = LEFT(CONVERT(VARCHAR,@Tanggal,112),6) AND GLStatus = 1` → "Journal Period Already Closed!"
  - `@Tanggal BETWEEN StartDate AND EndDate AND GLStatus = 1` → "GL period is already closed!"
- Jurnal GL selalu: `GL_T_JournalHeader` (`ApplicationID=1`, `PostingStatus='P'`, `PostingDate=tanggal jurnal`, `JournalSource='S'`, `DebetAmount=CreditAmount=0`, `RecordStatus='A'`, `IDX_ReferenceNo` = ID dokumen, `ReferenceNo` = nomor dokumen) + `GL_T_JournalDetail` (`OriginalCurrencyID=1`, `ExchangeRate=1`, `BaseCurrencyID=1`, `JournalSeqNo=0`, `IDX_M_Department=0`, O* = B*). **Mata uang selalu IDR (1)** walaupun header punya `IDX_M_Currency`.
- Penomoran voucher jurnal: `SELECT TOP 1 RIGHT(VoucherNo,4)` dari `GL_T_JournalHeader` dengan bulan+tahun `JournalDate` sama, `PostingStatus='P'`, `IDX_M_JournalType` sama, (umumnya) branch sama, `ORDER BY VoucherNo DESC`, lalu +1, 4 digit. Tanpa lock ⇒ race condition; journal yang di-unpost (`U`) tidak dihitung ⇒ nomor bisa terpakai ulang.

| JournalType (IDX) | Prefix voucher | Dipakai oleh | Format |
|---|---|---|---|
| 1 | `SJ` (hardcode) | `USP_CM_SalesInvoice_Approve` | `SJ-{BranchID}-{MM}{YY}-{NNNN}` |
| 2 | `PJ` (hardcode) | `USP_CM_PurchaseInvoice_Approve` | `PJ-{BranchID}-{MM}{YY}-{NNNN}` |
| 3 | `SR` (hardcode) | `USP_CM_SalesRefund_Approve` | `SR-{BranchID}-{MM}{YY}-{NNNN}` |
| 8 | `GL_M_JournalType.JournalTypeID` | `USP_CM_ReceiveAllocation_Approve` | `{ID}-{BranchID}-{MM}{YY}-{NNNN}` |
| 9 | `JournalTypeID` | `USP_CM_PaymentAllocation_Approve` | `{ID}-{MM}{YY}-{NNNN}` (tanpa branch, seq lintas branch) |
| 11 | `JournalTypeID` | `USP_CM_SalesInvoice_Void`, `USP_CM_SalesRefund_Void` | `{ID}-{BranchID}-{MM}{YY}-{NNNN}` (seq berdasarkan bulan `PostingDate`) |

---

## 3. Sales Invoice (AR)

### 3.1 Controller, route & SP

| Aksi | Route | Controller@method | SP |
|---|---|---|---|
| Inquiry | `GET /fm-sales-invoice`, `POST /fm-sales-invoice-list` | `SalesInvoiceController@inquiry/inquiry_data` | `USP_CM_SalesInvoice_List` |
| Form | `GET /fm-sales-invoice/create`, `/update/{id}` | `@create/@update` → `show_form` | `USP_CM_SalesInvoice_Info`, `USP_CM_SalesInvoiceDetail_List`, `USP_CM_SalesInvoiceTax_List`, `USP_CM_SalesInvoice_Payment_List`, `USP_CM_SalesInvoice_Journal_List` |
| Simpan header | `POST /fm-sales-invoice/save` | `@save` | `USP_CM_SalesInvoiceHeader_Create` / `_Update` |
| Approve | `POST /fm-sales-invoice/save-approve` | `@save_approve` | `USP_CM_SalesInvoice_Approve` |
| Reverse | `POST /fm-sales-invoice/save-reverse` | `@save_reverse` | `USP_CM_SalesInvoice_ReverseValidate` |
| Void | `POST /fm-sales-invoice/save-void` | `@save_void` | `USP_CM_SalesInvoice_Void` |
| Duplicate | `POST /fm-sales-invoice/save-duplicate` | `@save_duplicate` | `USP_CM_SalesInvoice_Duplicate` |
| Audit notes | `POST /fm-sales-invoice/save-auditnotes` | `@save_auditnotes` | `USP_CM_SalesInvoice_UpdateAuditNotes` |
| PDF | `GET /fm-sales-invoice/download-pdf/{id}`, `downloadreceipt-pdf`, `daily-summary-pdf` | `@download_pdf` dll. | `_Info`, `Detail_List`, (`USP_QP_UploadSummary_Sales/_Member` — tidak ada di DB) |
| Detail | `/fm-sales-invoice-detail/*` | `SalesInvoiceDetailController` | `USP_CM_SalesInvoiceDetail_Create/_Update/_Delete/_Info/_List` |
| Pajak tambahan | `/fm-sales-invoice-tax/*` | `SalesInvoiceTaxController` | `USP_CM_SalesInvoiceTax_Create/_Update/_Delete/_Info/_List` |
| Pembayaran cepat | `/fm-sales-invoice-payment/*` | `SalesInvoicePaymentController` | `USP_CM_SalesInvoice_Payment`, `_Payment_List` |

Nilai hardcode controller saat simpan header: `IDX_M_LocationInventory=0`, `IDX_M_DocumentType=1`, `IDX_ReferenceNo=0`, `TaxInvoiceNo=''`, `InvoiceNo=''`, `InvoiceStatus='D'`, `RecordStatus='A'`, `COAHeader = request IDX_M_COA`. Validasi Laravel wajib: Company, Branch, Currency, Partner, SalesPerson, ReferenceNo, InvoiceDate, InvoiceDueDate, RemarkHeader, COAHeader. (Catatan: `TaxInvoiceNo` selalu dikirim kosong ⇒ integrasi nomor faktur tidak tersambung dari UI.)

### 3.2 State machine `CM_T_SalesInvoiceHeader.InvoiceStatus`

| Kode | Label (List/Info) | Masuk dari | Keluar ke |
|---|---|---|---|
| `D` | Draft | Create, Duplicate, ReverseValidate | `A` (Approve), `V` (Void) |
| `A` | Approved | Approve | `D` (ReverseValidate), `V` (Void) |
| `F` | Validate | (tidak ada SP yang men-set; diperlakukan sama dengan A di cek "already approved" dan laporan) | – |
| `V` | Void | Void | final |
| `C` | Cancel | (tidak di-set SP manapun) | – |

`RecordStatus`: list memfilter `<> 'N'`.

### 3.3 `USP_CM_SalesInvoiceHeader_Create`
Param: `@IDX_M_Company, @IDX_M_Branch, @IDX_M_Currency, @IDX_M_LocationInventory, @IDX_M_Partner, @IDX_M_DocumentType, @IDX_ReferenceNo, @IDX_M_SalesPerson, @ReferenceNo, @TaxInvoiceNo, @InvoiceNo, @InvoiceDate, @InvoiceDueDate, @RemarkHeader, @AuditNotes, @InvoiceStatus, @COAHeader, @UserID, @RecordStatus`.

Validasi:
- `@COAHeader = 0` → "Invalid Chart of Account"
- `GN_M_Branch.IDX_M_Company` dari branch ≠ `@IDX_M_Company` → "Selected Branch Not Under The Same Group Company!"
(keduanya menulis `'New Invoice'` ke kolom ID BIGINT → sebenarnya memicu error konversi.)

Proses: INSERT header; lalu `InvoiceNo = 'DRAFT-' + IDX`. Jika `@IDX_M_DocumentType = 700` dan belum ada detail → copy baris dari `PS_T_PosOrderLine` (POS; tidak relevan, controller kirim 1). Tidak ada cek duplikasi ReferenceNo.

### 3.4 `USP_CM_SalesInvoiceHeader_Update`
Param: `@IDX_T_SalesInvoiceHeader` + sama dengan Create (ReferenceNo VARCHAR(50)).
Validasi tambahan:
- Branch di detail (`SELECT DISTINCT IDX_M_Branch FROM detail`) ≠ `@IDX_M_Branch` → "Please Delete All Detail Transactions First Before Changing BranchID!" (jika detail >1 branch, subquery error).
- Jika ReferenceNo lama terdaftar di `X_MemberSummary_Quality.UploadID` / `X_SalesSummary_Quality.UploadID` dan diubah → "Not Allow Change Sales Order No Information From Uploaded Source Member/Sales Data Transaction!"
Update semua kolom header (termasuk `InvoiceStatus` dari parameter — controller selalu kirim `'D'` ⇒ menyimpan invoice Approved lewat form akan **mengembalikan status ke D tanpa membatalkan jurnal**; recode wajib menolak update non-Draft). Tidak ada cek status.

### 3.5 Detail: `USP_CM_SalesInvoiceDetail_Create` / `_Update`
Param Create: `@IDX_T_SalesInvoiceHeader, @IDX_M_Project, @IDX_M_Item, @IDX_M_UoM, @IDX_M_COA, @IDX_M_Tax INT, @IncludeTax BIT, @ItemDesc, @Quantity INT, @UnitPrice DEC(22,3), @UntaxedAmount DEC(22,3), @DiscountAmount DEC(18,3), @TaxAmount DEC(18,3), @RemarkDetail, @UserID, @RecordStatus`. Update menambah `@IDX_T_SalesInvoiceDetail` di depan.
Controller mengirim `UntaxedAmount = UnitPrice` dan **`TaxAmount = UnitPrice`** (lihat risiko di bawah). `Quantity` bertipe **INT** (pecahan terpotong).

Validasi (pesan persis):
- `@IDX_M_COA = 0` → "Invalid Chart of Account"
- `@IncludeTax = 1 AND @IDX_M_Tax = 0` → "Invalid Tax"
- `@IDX_M_Item = 0` → "Master Item Not Exists!"; jika ≠0, `ItemDesc = UPPER(IN_M_Item.ItemName)` (menimpa input).
- Branch project (`GN_M_Project.IDX_M_Branch`) ≠ branch header → "Selected Project Not Under The Same Group Company / Branch!"
- `LEN(header.ReferenceNo) = 13` (penanda data upload Excel) → "Cannot Modified Detail Information From Excel Uploaded Data Transaction!"

**Kalkulasi per unit** (rate = `GL_M_Tax.TaxRate` dari `@IDX_M_Tax`; Update: jika `@IDX_M_Tax=0` rate=0):
```
jika IncludeTax = 1:
    jika rate = 10:  Untaxed = ROUND( CAST((UnitPrice - Disc)/1.1  AS DEC(18,2)), 0 ); Tax = UnitPrice - Disc - Untaxed
    jika rate = 11:  Untaxed = ROUND( CAST((UnitPrice - Disc)/1.11 AS DEC(18,2)), 0 ); Tax = UnitPrice - Disc - Untaxed
    rate lain:       Untaxed & Tax = nilai parameter (dari controller = UnitPrice!)  ← BUG
jika IncludeTax = 0:
    Untaxed = UnitPrice
    raw = (Untaxed - Disc) * rate / 100
    Tax = raw > 0 ? FLOOR(raw) : -FLOOR(ABS(raw))      (truncate ke arah nol; rate NULL → 0)
```
Simpan: `IDX_M_Branch` = branch project. Jika `Tax <> 0` insert `CM_T_SalesInvoiceTax` (`IDX_M_Tax, TaxID, TaxDesc=TaxName, TaxRate, TaxAmount=Tax (per unit), TaxCOA=COAIn, AllowEdit='N'`).
Update: jika Tax=0 hapus baris pajak lama (`IDX_M_Tax = tax sebelumnya`); jika ≠0 hapus semua pajak detail tsb lalu insert ulang (⇒ **PPh tambahan pada baris itu ikut terhapus**).

`TotalSalesAmount` header hanya diperbarui jika sudah > 0 (hanya terisi dari upload): `Σ (Untaxed - Disc + Tax) * Qty`. Pada Update, perbandingan "nilai berubah" dilakukan **setelah** UPDATE sehingga tidak pernah true (recalc tidak pernah jalan).

> Catatan kalkulasi: pada IncludeTax=1, `Untaxed` sudah net diskon, tetapi semua rumus selanjutnya memakai `(Untaxed - Disc)` ⇒ **diskon terpotong dua kali**. Recode harus memutuskan definisi yang benar (rekomendasi: `UntaxedAmount` = harga per unit sebelum diskon, DPP = (Untaxed − Disc) × Qty).

### 3.6 `USP_CM_SalesInvoiceDetail_Delete(@IDX_T_SalesInvoiceDetail)`
Tanpa validasi status. Hapus detail + semua `CM_T_SalesInvoiceTax` detail tsb. Jika `TotalSalesAmount > 0` dan ≠ `Σ UnitPrice (UnitPrice>0, RecordStatus='A')` maka `TotalSalesAmount = Σ UnitPrice` (rumus berbeda dari Create — inkonsisten). Tanpa `BEGIN TRAN`.

### 3.7 Pajak tambahan: `USP_CM_SalesInvoiceTax_Create/_Update/_Delete`
Param Create: `@IDX_T_SalesInvoiceHeader, @IDX_T_SalesInvoiceDetail, @IDX_M_Tax, @TaxAmount, @TaxCOA, @UserID, @RecordStatus` (controller kirim TaxAmount=0, TaxCOA=IDX_M_COA; keduanya ditimpa SP). Update menambah `@IDX_T_SalesInvoiceTax` di depan. Delete: `@IDX_T_SalesInvoiceTax`.
- Tax bukan PPh (`IsWithHoldingTax = 0`) → "Please Select TAX PPN item Directly From Detail Item!"
- `TaxCOA = GL_M_Tax.COAIn`; jika 0 → "Invalid Chart of Account"
- Update/Delete: baris `AllowEdit = 'N'` → "Please Update From Detail Invoice Item!"
- `TaxAmount = trunc0( (detail.Untaxed − detail.Disc) × rate / 100 )` (per unit). Insert `AllowEdit='Y'`.
- Tidak ada cek duplikasi PPh per detail; tidak ada cek status invoice. Delete tanpa transaksi.

### 3.8 `USP_CM_SalesInvoice_Approve(@IDX_T_SalesInvoiceHeader, @ApprovalDate VARCHAR(10), @ApprovalRemark, @UserID)`

Validasi:
| Kondisi | Pesan |
|---|---|
| Periode `YYYYMM(@ApprovalDate)` closed | "Journal Period Already Closed!" |
| Tidak ada detail | "No Data in Detail Transaction" |
| Status sudah `A`/`F` | "This invoice already approved!" |
| `@ApprovalDate` dalam periode closed | "GL period is already closed!" |
| Ada detail `TaxAmount < 0` | "Please Input PPH Tax Type on Add Additional Tax Section!" |
| `InvoiceDate > @ApprovalDate` | "Approval date < Invoice Date !" |
| `ApprovedDate` lama tidak NULL dan `MONTH(ApprovedDate) <> MONTH(@ApprovalDate)` (re-approve setelah reverse) | "VoucherNo Already Exist, Cannot Change Month Approval. Please Void Transaction!" (hanya bulan, tahun diabaikan) |
| Ada detail `UnitPrice = 0 / NULL` | "Please Check Amount Unit Price On Detail Transaction!" |

Penomoran invoice (hanya jika `InvoiceNo` masih `DRAFT…`):
```
last = RIGHT(InvoiceNo,4) dari invoice branch yang sama, MONTH/YEAR(ApprovedDate) = bulan/tahun approval,
       InvoiceNo bukan DRAFT, ORDER BY RIGHT(InvoiceNo,9) DESC ; default 0
InvoiceNo = {GN_M_DocumentType.DocumentTypeID}-{GN_M_Branch.BranchID}-{YY}{MM}-{last+1 4 digit}
```
(contoh di komentar: `SI-FJP-2401-0353`). Jika sudah bernomor (re-approve) nomor dipertahankan.
`ERPNo` ("SPECIAL REQUEST"): jika `@ApprovalDate >= '2019-12-16'` → `'SAJ/' + YEAR(InvoiceDate) + '/' + (ISNULL(MAX(RIGHT(ERPNo,5)) tahun InvoiceDate, 10719) + 1)`, selain itu NULL. `USP_CM_SalesInvoice_Info` menampilkan ERPNo sebagai InvoiceNo untuk InvoiceDate 16–31 Des 2019. **Legacy — kemungkinan tidak relevan untuk AVK.**

Update header: `InvoiceStatus='A', ApprovedDate, ApproveBy, ApproveRemark, ERPNo`. Update `CM_M_FakturNumberLine SET isUsed=1, IDX_T_Transaction=@id WHERE FakturNumber = header.TaxInvoiceNo` (tanpa cek period faktur Open / belum terpakai).

Agregat (DECIMAL(22,2)):
- `Untaxed = Σ (UntaxedAmount − DiscountAmount) × Quantity` (semua baris, termasuk negatif)
- `PPN account/amount`: dari `CM_T_SalesInvoiceTax` (IsWithHoldingTax=0) `GROUP BY IDX_M_Tax, TaxCOA` → `Σ TaxAmount × detail.Quantity`. Jika ada >1 grup, variabel hanya menyimpan **baris terakhir** (bug).
- `PPh account/amount`: idem IsWithHoldingTax=1.
- `Project` = `TOP 1 DISTINCT IDX_M_Project` dari detail.

**Jurnal (JournalType 1, voucher `SJ-…`, JournalDate = PostingDate = ApprovalDate, ReferenceNo = InvoiceNo, RemarkHeader = UPPER(RemarkHeader), PartnerDesc = PartnerName):**

| # | Akun | D/K | Nilai | Catatan |
|---|---|---|---|---|
| 1 | `header.COAHeader` (Piutang) | D | `Untaxed + PPN − ABS(PPh)` | Project = project pertama. Jika ReferenceNo ada di `X_SalesSummary_Quality` (UploadStatus/RecordStatus 'A'): nilai = `TotalSalesAmount − DiffFactor` (DiffFactor = −Σ UnitPrice baris negatif, per project). |
| 2 | `detail.IDX_M_COA` (Pendapatan) per baris `UnitPrice > 0` | K | `(Untaxed − Disc) × Qty` | Project per baris, Remark = RemarkDetail |
| 3 | `detail.IDX_M_COA` per baris `UnitPrice < 0` (potongan) | D | `(ABS(Untaxed) − Disc) × Qty` | |
| 4 | PPN `TaxCOA` per baris pajak (hanya akun = akun PPN terpilih) | K | `TaxAmount × Qty` | jika PPN > 0. Remark = RemarkDetail + TaxInvoiceNo + ReferenceNo |
| 5 | PPh `TaxCOA` per baris pajak (akun = akun PPh terpilih) | D | `ABS(TaxAmount × Qty)` | jika ABS(PPh) > 0 |

Keseimbangan: D(1)+D(3)+D(5) = Untaxed + PPN − |PPh| + Σneg + |PPh| = Σpos + PPN = K(2)+K(4) — seimbang **hanya jika** satu jenis PPN & satu jenis PPh dan tanpa pembulatan berbeda. Tidak ada validasi D=K.

### 3.9 `USP_CM_SalesInvoice_ReverseValidate(@IDX_T_SalesInvoiceHeader, @ReverseRemark, @UserID)`
Validasi:
- Periode bulan `ApprovedDate` closed → "Cannot Reverse Because Journal Period Already Closed!"
- Ada `CM_T_ReceiveAllocation` (IDX_DocumentNo + DocumentNo = InvoiceNo, status apa pun) → "This invoice already exist at Financial Receive Allocation. Please un-allocate first!"
- Ada `CM_T_SalesRefundHeader` status `A` → "This invoice have approved refund transaction. Please void sales refund transaction first!"
Proses: `InvoiceStatus='D'`, `ApproveBy=NULL`, `ApproveRemark=NULL` (**ApprovedDate & InvoiceNo tetap**); `DELETE GL_T_JournalDetail` jurnal (dicari by `IDX_ReferenceNo` + `ReferenceNo=InvoiceNo`, tanpa filter tipe — jika ada >1 jurnal hanya satu yang diambil); header jurnal `RecordStatus='I'`, `PostingStatus='U'`; insert `GL_T_JournalHeaderLog(…, 'Unposting', GETDATE(), @ReverseRemark, …)`. Faktur line **tidak** dilepas (`isUsed` tetap 1). Tidak cek status awal (bisa reverse invoice Draft/Void).

### 3.10 `USP_CM_SalesInvoice_Void(@IDX_T_SalesInvoiceHeader, @VoidDate DATE, @VoidReason, @UserID)`
Validasi: periode closed ("Journal Period Already Closed!", "GL period is already closed!"); tanpa detail → "No data in detail transaction"; ada `CM_T_ReceiveAllocation.IDX_DocumentNo = id` (tanpa filter tipe dokumen!) → "This invoice already allocated on Financial Receive, please un-allocate first!"; status `V` → "This invoice already void!". Tidak cek refund approved, tidak cek status A (Draft bisa di-void → hanya header jurnal kosong).
Proses: status `V`, `VoidDate/VoidBy/VoidReason`. Jurnal JournalType 11: header `RemarkHeader='VOID TRANSACTION - '+UPPER(Remark)`, `PostingNotes=@VoidReason`, JournalDate=PostingDate=`@VoidDate`, ReferenceNo=InvoiceNo; detail = **salinan semua baris jurnal posted** dengan `IDX_ReferenceNo=id AND ReferenceNo=InvoiceNo`, **Debet↔Kredit ditukar**, Remark `'VOID JOURNAL - '+…`, UCreate/DCreate disalin dari jurnal asli. Faktur line tidak dilepas.

### 3.11 `USP_CM_SalesInvoice_Duplicate(@IDX_T_SalesInvoiceHeader, @UserID)`
Tolak jika ReferenceNo ada di `X_MemberSummary_Quality` ("Not Allow Duplicate Member Transaction From Uploaded Source Data!") atau `X_SalesSummary_Quality` ("Not Allow Duplicate Sales Transaction From Uploaded Source Data!"). Copy header → status `D`, InvoiceDate=DueDate=`GETDATE()`, approve/void dikosongkan, nomor `DRAFT-{newId}`. Copy detail dengan `IDX_Prev_T_SalesInvoiceDetail` = id lama (via `OUTPUT … INTO #TAMPUNG`), lalu copy baris pajak ke detail baru. Pesan "Data Berhasil Duplikat ke DRAFT-n".

### 3.12 `USP_CM_SalesInvoice_UpdateAuditNotes(@id, @AuditNotes, @UserID)` — update `AuditNotes` saja, tanpa validasi.

### 3.13 Inquiry & info (kalkulasi read-model)
- **`USP_CM_SalesInvoice_List`** (`@Page, @Row, @SortBy, @SortDir, @ReturnType 'R'|'C', @CompanyName, @ProjectID, @InvoiceNo, @RemarkHeader, @PartnerName, @InvoiceDate, @DueDate, @TotalInvoice, @UserID`) – **dynamic SQL** dengan concatenation (SQL injection: `@UserID` dan semua filter). Temp `#TempInvoice`: `Total = Σ((Untaxed−Disc)×Qty + Σtax_detail×Qty)`; `#TempReceive`: `Σ AllocationAmount` alokasi `A`. Kolom: RowNumber, Company, Branch, Project (INNER JOIN per project → invoice multi-project muncul berkali-kali), InvoiceNo, ReferenceNo, PartnerID/Name, tanggal format 106, RemarkHeader, `TotalInvoice = TotalSalesAmount>0 ? TotalSalesAmount : Total`, `ReceiveAmount`, `Outstanding = TotalInvoice − ReceiveAmount`, InvoiceStatus, StatusDesc. Hak akses branch: INNER JOIN `SM_M_UserBranch` (RecordStatus 'A') milik `LoginID = @UserID`. Paging OFFSET/FETCH.
- **`USP_CM_SalesInvoice_Info`**: header + company/branch/partner/user/COA + `DPPAmount = Σ(Untaxed−Disc)×Qty`, `TaxAmount = Σ tax.TaxAmount × Qty` (PPN + PPh), `TotalAmount = DPP + TaxAmount`, `PaymentAmount = Σ alokasi A`, `PKPFlag = 'NON PKP'` bila NPWP partner kosong/NULL/`00.000.000.0-000.000`, `PaymentStatus/PaymentCss` dari `fn_GetSalesInvoicePayment` (tidak ada di dump).
- **`USP_CM_SalesInvoiceDetail_List`**: per detail + PPN & PPh per detail (dipisah `IsWithHoldingTax`).
- **`USP_CM_SalesInvoiceTax_List`**: baris pajak, `TaxDesc + ' - Refer to Notes: ' + RemarkDetail`.
- **`USP_CM_SalesInvoice_Payment_List`**: alokasi penerimaan per invoice (status D/A/C → Draft/Approved/Void).
- **`USP_CM_SalesInvoice_Journal_List`**: UNION jurnal invoice (`JH.ReferenceNo = InvoiceNo`, posted) + jurnal Financial Receive yang detailnya menunjuk invoice (`FRD.IDX_DocumentNo`).
- Tidak dipakai: `USP_CM_SalesInvoice_OS_List(@IDX_M_Partner)` (outstanding = Σ Qty×(UnitPrice−Disc) − ReceiveAmount FRD, status A), `USP_CM_SalesInvoiceItem_List`, `USP_CM_SalesInvoice_List_bak`, `USP_CM_SalesInvoice_List_new`.

### 3.14 Shortcut pembayaran: `USP_CM_SalesInvoice_Payment`
Param: `@IDX_T_SalesInvoiceHeader, @IDX_M_COA, @IDX_M_FinancialAccount, @IDX_M_PaymentType, @ReceiveAmount, @RemarkDetail, @UserID`.
Cek akses `EXEC USP_SM_CheckUserForm @UserID,'CF-APPR-001'` → "You Dont Have Access!". Membuat (titik interaksi Treasury):
1. `CM_T_FinancialReceiveHeader`: company/branch/partner/currency dari invoice, `IDX_M_DocumentType=3`, financial account & COA header dari `CM_M_FinancialAccount.IDX_M_COA`, `ReceiveDate=GETDATE()`, status `D`, amount, `ReceiveID='DRAFT-'+id`.
2. `CM_T_FinancialReceiveDetail`: branch, project (jika detail invoice 1 project pakai itu; jika tidak, project branch dengan `ProjectName LIKE '%ho'`), `IDX_M_DocumentType`/`IDX_DocumentNo`/`DocumentNo` = invoice, COA = `@IDX_M_COA`, amount.
3. `CM_T_ReceiveAllocation`: status `D`, AllocationID = NULL (variabel tidak pernah diisi), COAAllocation = `@IDX_M_COA`, amount.
Tidak ada cek outstanding, status invoice, atau amount > 0.

---

## 4. Purchase Invoice (AP)

Struktur identik dengan Sales (route `/fm-purchase-invoice*`, `PurchaseInvoiceController`, `PurchaseInvoiceDetailController`, `PurchaseInvoiceTaxController`, `PurchaseInvoicePaymentController`, `PurchaseInvoiceJournalController`). Tidak ada route void/auditnotes. Controller: `IDX_M_DocumentType=2`, `UserID='XXX'+user`, field tambahan `SupplierDeliveryNo, VendorInvoiceNo, FakturPajak, IsTaxChecked`.

Perbedaan terhadap Sales:

**Header (`USP_CM_PurchaseInvoiceHeader_Create/_Update`)**: param tanpa SalesPerson/TaxInvoiceNo/AuditNotes; tambah `@SupplierDeliveryNo, @VendorInvoiceNo, @FakturPajak, @IsTaxChecked`; `ReferenceNo` disimpan `UPPER`. Link ke PO: jika `PR_T_PurchaseOrder.PONumber = TRIM(@ReferenceNo) AND POStatus <> 'D'` maka `IDX_ReferenceNo = IDX_T_PurchaseOrder`. Update: jika PO berstatus Draft tidak ditemukan → `IDX_ReferenceNo` dipertahankan, else di-set ulang dari PO non-draft (logika terbalik/membingungkan). Validasi COA & branch group sama; tanpa cek upload Excel.

**Detail (`USP_CM_PurchaseInvoiceDetail_Create/_Update`)**: tipe DECIMAL(22,2); tambahan validasi tax PPh pada detail → "Please Add PPH TAX Category on Additional Tax Section!"; `TaxCOA = COAOut`; rate NULL → 0; `TaxAmount` disimpan `ISNULL(…,0)`; tanpa update `TotalPurchaseAmount`; tanpa cek ReferenceNo 13 char.
**Detail_Delete**: tolak jika header `IsTaxChecked = '1'` → "Checlist Tax Status Already Checked!".
**Tax_Create/_Update**: sama, `COAOut`; Create tanpa cek COA=0.

**`USP_CM_PurchaseInvoice_Approve(@id, @ApprovalDate, @ApprovalRemark, @UserID)`** – validasi Sales (tanpa cek tanggal invoice & unit price) ditambah:
- Detail `IDX_M_COA = 0` → "Detail Item Must Have COA Information!"
- Jika `IDX_ReferenceNo` (PO) terisi: `AmountPO = FLOOR(Σ PO.Qty×(Untaxed−Disc) + Qty×Tax)`; `AmountPI = FLOOR(Σ PI approved untuk PO tsb) + FLOOR(Σ PI ini)` (rumus sama dari detail). Jika `AmountPI > AmountPO` → "Total Amount Invoice ({AmountPI}) > Total Amount PO/SPK ({AmountPO}) !"
Nomor: `{DocTypeID}-{BranchID}-{YY}{MM}-{NNNN}` (sama). Jurnal **JournalType 2**, voucher `PJ-{Branch}-{MMYY}-{NNNN}`, JournalDate = ApprovalDate:

| # | Akun | D/K | Nilai |
|---|---|---|---|
| 1 | `detail.IDX_M_COA` (Biaya/Persediaan) per baris | D bila `Untaxed > 0`, else K | `(Untaxed − Disc) × Qty` (K: dikali −1) |
| 2 | `CM_T_PurchaseInvoiceTax.TaxCOA` PPN, grup per tax/COA/project/remark | D bila >0 else K | `FLOOR(Σ TaxAmount × Qty)`; COADescription diambil dari `GL_M_Tax.COAOut` |
| 3 | `header.COAHeader` (Hutang) | K | `Σ Qty × (Untaxed + detail.TaxAmount − Disc) − ABS(PPh)` dengan `PPh = −FLOOR(Σ ABS(TaxAmount)×Qty)` |
| 4 | PPh `TaxCOA` per baris pajak | K | `FLOOR(ABS(TaxAmount × Qty))` |

Risiko imbalance: Hutang memakai `detail.TaxAmount` (tanpa FLOOR agregat) sedangkan PPN memakai `FLOOR(Σ tax row)`; PPh header memakai FLOOR agregat vs per baris.

**`USP_CM_PurchaseInvoice_ReverseValidate`**: cek `CM_T_PaymentAllocation` ("…exist at Financial Payment Allocation. Please un-allocate first!"), tanpa cek refund; tambahan `IsTaxChecked = 0`. Sisanya sama.
**`USP_CM_PurchaseInvoice_Duplicate`**: sama, tanpa cek upload.
**`USP_CM_PurchaseInvoice_Payment`** (`@id, @IDX_M_FinancialAccount, @IDX_M_PaymentType, @PaymentAmount, @RemarkDetail, @UserID`): membuat `CM_T_FinancialPaymentHeader` (`IDX_M_DocumentType=4`, `PaymentID='DRAFT-'+id`), detail (COA = `COAHeader` invoice = akun Hutang) dan `CM_T_PaymentAllocation` (COA = COAHeader). Cek akses `CF-APPR-001`.
**`USP_CM_PurchaseInvoice_Void`** (tidak dipakai): cek `View_PurchaseInvoiceOS.OutstandingAmount = 0` → "This invoice already paid!", status V, periode; jurnal baru (voucher `PJV-…`, tipe 2) yang membalik secara rumus (D Hutang = Untaxed+PPN−|PPh|, D PPh, K biaya, K PPN).
**List/Info**: `TotalInvoice = Σ Qty×(Untaxed − Disc + TaxAmount)` (TaxAmount detail = PPN saja), `PaymentAmount = Σ PaymentAllocation A`, `Outstanding = (DetailAmount − Payment < 1) ? 0 : Total − Payment` (toleransi < 1 rupiah). Filter TotalInvoice: jika diisi → `FLOOR(Total) = nilai`. Info: DPP/Tax/Total sama seperti Sales.
Tidak dipakai: `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoiceItem_List`, `USP_CM_PurchaseInvoice_Journal_Inquiry`.

---

## 5. Alokasi pelunasan (Receive/Payment Allocation)

Dipanggil dari `FinancialReceiveDetailController` / `FinancialPaymentDetailController` (route `/fm-financial-receive-detail/*-allocation`, `/fm-financial-payment-detail/*-allocation`). Controller: Create/Update kirim `IDX_M_DocumentType` (`'2'` untuk payment), `AllocationID='-'`, `AllocationStatus='D'`; Approve kirim `(id, ApprovalRemark, ApprovalDate, 'XXX'+ApprovalBy)` untuk Receive dan `(id, ApprovalRemark, 'XXX'+ApprovalBy)` untuk Payment.

Tabel `CM_T_ReceiveAllocation` / `CM_T_PaymentAllocation`: `IDX_T_Financial{Receive|Payment}Detail`, `IDX_M_Partner`, `IDX_M_DocumentType` (1 = Sales Invoice, 2 = Purchase Invoice), `IDX_DocumentNo` (ID invoice), `DocumentNo`, `AllocationID`, `COAAllocation`, `AllocationDate`, `AllocationAmount`, `RemarkAllocation`, `AllocationStatus` (`D` Draft, `A` Approved, `C` "Void" — tidak pernah di-set).

### 5.1 Create / Update
`USP_CM_ReceiveAllocation_Create/_Update`, `USP_CM_PaymentAllocation_Create/_Update` — param: `[@IDX_T_*Allocation,] @IDX_T_Financial*Detail, @IDX_M_Partner, @IDX_M_DocumentType, @IDX_DocumentNo, @AllocationID, @DocumentNo, @COAAllocation, @AllocationDate, @AllocationAmount, @RemarkAllocation, @AllocationStatus, @UserID, @RecordStatus`.
- `EXEC USP_CheckUserForm @UserID,'',@Output` → bila ≠1 "You Dont Have Access!" (**SP tidak ada di DB**).
- COA alokasi 0 → "Please check your COA Allocation !" (Receive memakai `= NULL` yang tak pernah true; di Update cek dilakukan **setelah** hitung error ⇒ tidak efektif).
- Payment Create: `AllocationAmount > FPD.PaymentAmount` → "Allocation amount is more than Payment Amount !"; jika dokumen diisi: `InvoiceTotal(Σ Qty×(Untaxed−Disc+Tax)) − Σ alokasi A > = AllocationAmount` else "Allocation amount is more than Outstanding Amount !". Payment Update: cek amount vs PaymentAmount.
- Receive Create **tidak** cek outstanding (InvoiceAmount dihitung tapi tidak dipakai).
- `DocumentNo` ditimpa dari `InvoiceNo` invoice (Receive dari Sales, Payment dari Purchase). Update tidak mengubah `IDX_T_Financial*Detail`. Tidak ada cek status (alokasi Approved bisa diubah).

### 5.2 Delete
`USP_CM_ReceiveAllocation_Delete(@id)` / `USP_CM_PaymentAllocation_Delete(@id)`: hapus alokasi **tanpa cek status** (alokasi Approved bisa dihapus tanpa membalik jurnal), lalu `UPDATE CM_T_Financial*Detail SET IDX_DocumentNo = 0, DocumentNo = ''` (memutus link dokumen di detail treasury).

### 5.3 `USP_CM_ReceiveAllocation_Approve(@id, @ApproveRemark, @ApproveDate, @UserID)`
Validasi: periode `@ApproveDate` closed → "Journal Period Already Closed!"; `AllocationDate > @ApproveDate` → "Approval Allocation Date Must be Same or Above Than Allocation Date!"; COAAllocation 0 → "Please check your COA Allocation !"; header FR masih `D` → "Approve Financial Receive Transaction First!"; `Σ AllocationAmount` di FR detail (semua status) > `FRD.ReceiveAmount` → "Total Receive Allocation > Detail Amount!".
Proses:
- Jika `COAAllocation <> FRD.COADetail` dan status D: set `A`; buat jurnal **tipe 8** (ReferenceNo = VoucherNo, Remark `'Receive Allocation Journal ' + AllocationID`, PostingNotes = remark, JournalDate = `@ApproveDate`):
  - Jika ada alokasi negatif untuk invoice yang sama dalam FR detail tsb: D `FRD.COADetail` = Σ alokasi invoice itu (net); D `COAAllocation` = ABS(alokasi negatif) per baris; seluruh alokasi invoice itu di-set `A`.
  - Else: D `FRD.COADetail` = AllocationAmount.
  - Selalu: K `COAAllocation` = AllocationAmount (baris yang di-approve).
  (Makna: reklasifikasi dari akun penampung penerimaan (`COADetail`, mis. uang muka/titipan) ke akun piutang invoice (`COAAllocation`).)
- Jika COA sama: hanya set `A`, tanpa jurnal.

### 5.4 `USP_CM_PaymentAllocation_Approve(@id, @ApproveRemark, @UserID)`
Validasi: periode bulan **`AllocationDate`** closed → "Journal Period Already Closed!" (tanpa cek status FP, tanpa cek total). Set `A` (tanpa cek status awal → bisa approve dua kali ⇒ jurnal ganda); jurnal **tipe 9** selalu dibuat, JournalDate = `GETDATE()`, ReferenceNo = AllocationID, Remark 'Payment Allocation Journal': D `COAAllocation` (Hutang) = AllocationAmount; K `FPD.COADetail` = AllocationAmount. Jika COA sama ⇒ jurnal D/K akun yang sama.
Tidak dipakai: `USP_CM_PaymentAllocation_CreateMultiple` (loop CSV `@InvoiceList`, insert alokasi `AllocationID='APP-'+id`, amount = Σ Qty×(UnitPrice−Disc) − terbayar, status D), `*_Journal_List`.

### 5.5 Read model
`USP_CM_ReceiveAllocation_List/_Info`, `USP_CM_PaymentAllocation_List/_Info`: per FR/FP header; `URLDocument = 'fm-sales-invoice/update/{id}'` (tipe 1) atau purchase; `StatusDesc` D/A/C. `USP_CM_ReceiveAllocation_Journal_List` (tidak dipakai) — jurnal tipe 8 per FR.

**Definisi outstanding (untuk recode, konsisten di semua tempat):**
```
InvoiceTotal  = Σ_detail (Untaxed − Disc) × Qty  +  Σ_taxrow TaxAmount × Qty      (PPN positif, PPh negatif)
Paid          = Σ Allocation.AllocationAmount WHERE AllocationStatus='A' AND IDX_M_DocumentType = invoice.DocType AND IDX_DocumentNo = invoice.ID
Outstanding   = InvoiceTotal − Paid   (Purchase list: < 1 → 0)
```
Saat ini setiap SP memakai varian berbeda (UnitPrice vs Untaxed, dengan/tanpa pajak, TotalSalesAmount) — wajib distandarkan.
**Aging**: tidak ada SP aging di scope ini; due date tersedia di `InvoiceDueDate` (Aging AR/AP ada di `USP_MC_R_AR/_AP` modul lain).

---

## 6. Refund (Retur)

Semua SP refund **tidak dipanggil kode** dan tidak ada SP untuk mengisi `RefundQuantity/RefundPrice` (tidak ada `SalesRefundDetail_Create/Update`) ⇒ alur tidak lengkap.

### 6.1 Sales Refund
- **`USP_CM_SalesRefundHeader_Create`** (`@IDX_T_SalesInvoiceHeader, @IDX_M_Company, @IDX_M_Branch, @IDX_M_Currency, @IDX_M_LocationInventory, @IDX_M_Partner, @IDX_M_DocumentType, @IDX_M_SalesPerson, @InvoiceReferenceNo, @TaxInvoiceNo, @RefundNo, @RefundDate, @RefundDueDate, @ReferenceNo, @DeliveryNo, @RemarkHeader, @RefundStatus, @COAHeader, @IsProforma, @IsCreateJournal, @UserID VARCHAR(10), @RecordStatus`):
  - COA 0 → "Please entry COA!"; `RefundDate > RefundDueDate` → "Refund date must be less than refund due date!"; sudah ada refund `A` untuk invoice tsb → "This sales invoice has been refund!" (maks. satu refund approved per invoice).
  - `RefundNo = 'DRAFT-'+id`. Jika `@IDX_M_DocumentType = 10`: copy semua detail invoice ke `CM_T_SalesRefundDetail` (link `IDX_T_SalesInvoiceDetail`) dan pajak ke `CM_T_SalesRefundTax` (urutan kolom DCreate/UCreate tertukar di INSERT detail).
- **`USP_CM_SalesRefundHeader_Update`**: validasi sama, update semua kolom.
- **`USP_CM_SalesRefund_Approve(@id, @ApprovalDate, @ApprovalRemark, @UserID)`**: validasi "No Data in Detail Transaction", "This refund invoice already approved!" (A/F), "GL period is already closed!", `Σ RefundQuantity = 0` → "No item is refunded!". Nomor `{DocTypeID}-{BranchID}-{YY}{MM}-{NNNN}` (seq per branch/bulan approve, status A/F). Status `A`.
  Kalkulasi: `Untaxed = Σ RefundPrice × RefundQuantity`; PPN/PPh = `Σ refundTax.TaxAmount × RefundQuantity` (pajak per unit invoice; kolom `TaxRefundAmount` tidak dipakai di jurnal).
  Jurnal **tipe 3**, voucher `SR-{Branch}-{MMYY}-{NNNN}`, ReferenceNo = RefundNo: K `COAHeader` (Piutang) = Untaxed + PPN − |PPh|; D `detail.IDX_M_COA` = RefundPrice × RefundQty (baris qty≠0); D PPN akun = PPN (desc hardcode 'PPN Keluaran'); K PPh akun = |PPh| (desc 'PPh 23 Sales Tax'). Jika `IsCreateJournal <> 1` jurnal langsung di-set `RecordStatus='I'` + log 'Unposting' "IsCreateJournal not checked".
- **`USP_CM_SalesRefund_Void(@id, @VoidDate, @VoidReason, @UserID)`**: tanpa detail → "No data in detail transaction"; periode closed; `ApprovedDate > @VoidDate` → "Void date must be same or older than approved date!" (teks terbalik). Status V; jurnal tipe 11 membalik (swap D/K) semua jurnal posted dengan ReferenceNo = RefundNo.
- Read: `USP_CM_SalesRefund_List`, `USP_CM_SalesRefund_Journal_List`, `USP_CM_SalesRefundTax_List/_Info`, `USP_CM_SalesInvoice_SalesRefund_OWN_List` (pilih invoice untuk direfund). Beberapa memakai kolom `GC.Name`/`GMP.Name` yang tidak ada di skema AVK (`CompanyName`/`PartnerName`) ⇒ kemungkinan error.

### 6.2 Purchase Refund
- `USP_CM_PurchaseRefundHeader_Create/_Update`: hanya insert header (tidak copy detail; tidak ada SP detail) ⇒ tidak bisa di-approve.
- `USP_CM_PurchaseRefund_Approve`: status kolom `InvoiceStatus`; jurnal ditulis dengan `IDX_M_JournalType = 1` (komentar "SJ") tetapi seq & voucher `PJ-` dari tipe 2 (inkonsisten). Jurnal: D `COAHeader` (Hutang) = Untaxed+PPN−|PPh|; K biaya per detail; K PPN; D PPh. Kalkulasi memakai `Quantity` (bukan refund qty).
- `USP_CM_PurchaseRefund_List`, `_SelectInvoice`, `USP_CM_PurchaseRefundTax_List/_Info`: read-only (kolom `GMP.Name` tidak ada).

---

## 7. Nomor Faktur Pajak (NSFP) & e-Faktur

Tabel: `CM_M_FakturNumber` (periode `YYYYMM`, `StatusFaktur` 'Open'/'Close'), `CM_M_FakturNumberLine` (`FakturNumber`, `isUsed`, `IDX_T_Transaction`), `CM_T_FakturPajak` (tidak dipakai SP manapun di scope). Semua SP faktur **tidak dipanggil kode**.

- **`USP_CM_FakturNumber_Create(@PeriodYear, @UserID, @RecordStatus)`**: tolak jika sudah ada periode aktif berawalan tahun tsb → "Period Faktur is already exists!". Insert 12 baris `PeriodFaktur = YYYY01..YYYY12` (via `master..spt_values`). **Tidak mengisi `StatusFaktur` (NOT NULL)** — gagal kecuali ada default constraint (tidak terlihat di metadata).
- **`USP_CM_FakturNumber_Line_Create(@IDX_M_FakturNumber, @Qty, @StartingNo, @PrefixNo, @UserID, @RecordStatus)`**: loop `x = 0..Qty-1`: `Prefix` di-pad 3 digit, `Num = StartingNo + x` di-pad 13 digit, `FakturNumber = {PPP}.{Num[1..3]}-{Num[4..5]}.{Num[6..13]}` (contoh `010.000-20.00000001`). Tanpa validasi duplikat/overlap/periode Open.
- **`USP_CM_FakturNumber_ClosePeriod/_OpenPeriod(@id, …)`**: toggle `StatusFaktur` Open↔Close; error "Period Faktur is not exists!" / "Period Faktur is already open!".
- **`USP_CM_FakturNumber_Line_List`**: nomor dengan period `Open` dan `isUsed = 0` (pilihan nomor faktur). `_List` (min/max nomor per periode), `_Info` (nomor + InvoiceNo pemakai), `_Info2` (header periode).
- Pemakaian: `USP_CM_SalesInvoice_Approve` men-set `isUsed=1, IDX_T_Transaction` berdasarkan `TaxInvoiceNo` (tanpa cek). Reverse/Void tidak melepas nomor.
- **`USP_CM_SalesInvoice_FakturHeader_Export(@IDX_T_SalesInvoice)`** → baris CSV e-Faktur `FK`: `KD_JENIS_TRANSAKSI = LEFT(TaxInvoiceNo,2)`, `FG_PENGGANTI = SUBSTRING(…,3,1)`, `NOMOR_FAKTUR = digit dari SUBSTRING(…,5,15)`, `MASA_PAJAK = MONTH(InvoiceDate)`, `TAHUN_PAJAK`, `TANGGAL_FAKTUR dd/mm/yyyy`, `NPWP` (tanpa titik/strip), `NAMA`, `ALAMAT_LENGKAP` (alamat tipe 1 + Zip), `JUMLAH_DPP = FLOOR(Σ Qty×(Untaxed−Disc))`, `JUMLAH_PPN = FLOOR(Σ Qty×detail.TaxAmount)`, PPnBM/uang muka = 0, `REFERENSI = InvoiceNo`. Hanya header FK (tidak ada baris OF/LT).
- `USP_CM_SalesInvoice_Faktur_List`: daftar invoice untuk pengelolaan faktur (dynamic SQL; tidak dipakai).
- **Pajak lain** (`CM_T_TaxInvoiceHeader/Detail`, `CM_T_FakturPajak`, `MC_T_PurchaseOrderTax`, `PR_T_PurchaseOrderTax`): tidak ada SP di scope yang menulisnya; semuanya 0 row.

---

## 8. Laporan (`USP_CM_R_*`)

| SP | Dipakai | Route / Controller | Parameter |
|---|---|---|---|
| `USP_CM_R_SalesInvoice_Period` | Ya | `/fm-rpt-sales-invoice` `RptSalesInvoiceController` | Company, Branch(0=semua), StartDate, EndDate, Partner(0=semua) |
| `USP_CM_R_PurchaseInvoice_Period` | Ya | `/fm-rpt-purchase-invoice` | Company, Branch, Start, End, Partner |
| `USP_CM_R_PaymentPO_Period` | Ya | `/fm-rpt-payment-po` | Company, Branch, Start, End, Partner(0), Project(-1=semua) |
| `USP_CM_R_PaymentSPK_Period` | Ya | `/fm-rpt-payment-spk` | idem |
| `USP_CM_R_FinancialPayment_Period` | Ya | `/fm-rpt-financial-payment` | Company, Branch, Start, End |
| `USP_CM_R_FinancialReceive_Period` | Ya | `/fm-rpt-financial-receive` | Company, Branch, Start, End |
| `USP_CM_R_BankTransfer_Period` | Ya | `/fm-rpt-bank-transfer` | FinancialAccount, Start, End |
| `USP_CM_R_Cashflow` | Tidak | – | Company, Branch, Start, End |
| `USP_CM_R_CashflowBank` | Tidak | – | Company, Branch, Tanggal |
| `USP_CM_R_SalesInvoice_DetailBySalesPersonSummary`, `_Item`, `_ItemCategorySummary` (+ `_Backup`, `-Backup`) | Tidak | – | Company, Branch, (SalesPerson), Start, End, (ItemName, Partner, Item) |

### 8.1 `USP_CM_R_SalesInvoice_Period`
4 cabang (`IF Branch=0 / ≠0` × `IF Partner=0 / ≠0`), masing-masing `UNION ALL` invoice + refund, ORDER BY Company, Branch, PartnerName, Partner, InvoiceNo.
- Invoice: status `A`/`F`, `InvoiceDate` dalam periode, company (branch & partner sesuai cabang). `TotalInvoice = Σ Qty×(Untaxed−Disc) + Σ Qty×tax.TaxAmount` dengan join pajak via **`IDX_Prev_T_SalesInvoiceDetail`** (hanya invoice hasil duplikat yang pajaknya ikut — bug); cabang terakhir memakai rumus lain `Σ Qty×(UnitPrice−Disc+TaxAmount)`. `TotalDPP = TotalTax≠0 ? Total/1.1 : Total`, `TotalPPN = Total − Total/1.1` (**rate 10% hardcode**, juga mencampur PPh). `ReceiveAmount = Σ alokasi A` (tanpa filter tanggal).
- Refund (status A/F, RefundDate dalam periode) sebagai baris negatif: `Total = −Σ RefundQty×(RefundPrice − Disc + TaxRefundAmount)`, DPP/PPN rumus 1.1, `RemarkHeader + ' - ' + RefundNo + ' - SI Number: ' + InvoiceReferenceNo`, TaxInvoiceNo '-'.
- Bug: cabang Branch≠0 & Partner=0 tetap memfilter refund `IDX_M_Partner = @IDX_M_Partner` (=0) ⇒ refund hilang.
- Kolom: IDX_T_SalesInvoiceHeader, IDX_M_Company, IDX_M_Branch, InvoiceDate, InvoiceNo, IDX_M_Partner, PartnerName, SalesPersonName, TotalDPP, TotalPPN, TotalInvoice, ReceiveAmount, RemarkHeader, TaxInvoiceNo.

### 8.2 `USP_CM_R_PurchaseInvoice_Period`
Invoice status A/F dalam periode. `TotalInvoice = Σ Qty×(Untaxed−Disc) + Σ Qty×tax` (join pajak via detail, benar). `PaymentAmount`: cabang Partner=0 → Σ `CM_T_PaymentAllocation` A dengan `AllocationDate` dalam periode; cabang Partner≠0 → Σ `CM_T_FinancialPaymentDetail.PaymentAmount` (FP status `A`, `ValidationDate` dalam periode) yang menunjuk invoice — **dua definisi berbeda**. Cabang Partner=0 menambah kolom `BankName, AccountName, AccountNumber` partner. Filter branch dikomentari di cabang Branch=0.

### 8.3 `USP_CM_R_PaymentPO_Period` / `USP_CM_R_PaymentSPK_Period`
Rekap PO → Invoice → Pembayaran. Sumber `PR_T_PurchaseOrder` (+Detail) — **tidak ada di AVKDB**. Per PO (`POStatus <> 'D'`, `PONumber LIKE 'PO-%'` / SPK: invoice `ReferenceNo LIKE 'spk-%'`, `PODate` dalam periode, company & branch, opsional partner & project via `GN_M_Project`): `POAmount = Σ Qty×(Untaxed−Disc+Tax)`; invoice (status A, `IDX_ReferenceNo = PO`) `InvoiceAmount = Σ Qty×(UnitPrice − Disc + Σtax)`; `InvoiceAmountNoPPH` = hanya pajak non-PPh (SPK: kecuali item 177 'Pembulatan' — hardcode); pembayaran = Σ alokasi A dari FP status `H`/`F`, kolom PaymentID, PDCNo, PaymentDescription. ORDER BY PODate.

### 8.4 `USP_CM_R_FinancialPayment_Period` / `USP_CM_R_FinancialReceive_Period` (data treasury)
Daftar header FP/FR per company+branch dengan tanggal transaksi dalam periode (semua status termasuk Draft/Void), `PaymentAmount/ReceiveAmount = Σ detail RecordStatus 'A'`, currency, payment type (`GN_M_PaymentType.Name`), financial account, status desc (FP: D Draft/A Approved/F Validate; FR: D/A/F Confirm), partner (FP). ORDER BY company, branch, tanggal, nomor.

### 8.5 `USP_CM_R_BankTransfer_Period`
Mutasi satu financial account: baris `PAYMENT` (kredit = `PaymentAmount` header, tanggal PaymentDate, posted = ValidationDate, status ≠ V) dan `RECEIVE` (debet, ApprovalDate), plus baris `BALANCE` saldo awal = `GL_T_AccountBalance.BEndingBalance` periode bulan sebelum StartDate untuk COA financial account. `Balance` baris transaksi = `Debet − Credit` (bukan saldo berjalan — running balance harus dihitung di view). Saldo awal tidak memperhitungkan transaksi tanggal 1..StartDate−1 bila StartDate bukan awal bulan. Kolom: Counting (0 saldo awal/1 transaksi), IDX_FA, FA_Desc, TransType, TransDate, PostedDate, VoucherNo, TransStatus, Debet, Credit, Balance, Remarks, URLTransaction.

### 8.6 `USP_CM_R_Cashflow` (tidak dipakai)
Default company/branch = 1. Ambil jurnal tipe 6 & 7 posted dalam periode (`PostingDate`), baris yang **bukan** akun bank; klasifikasi dari `GL_M_COA.IDX_M_CashflowIn/Out` → `CM_M_CashflowID` (kosong) atau 'UN-MAPPED'; subtotal per digit pertama kode (1 PENERIMAAN, 2 PENERIMAAN LAIN, 3 BIAYA POKOK, 4 BIAYA PROYEK, 5 BIAYA OPERASIONAL, 6 BIAYA PAJAK, 7 BIAYA CIBODAS, 8 LAINNYA), Total IN/OUT per bulan. Kategori hardcode dari klien lain.

### 8.7 `USP_CM_R_CashflowBank` (tidak dipakai)
Posisi kas/bank per financial account pada tanggal: saldo awal (`GL_T_AccountBalance` periode lalu + mutasi awal bulan s.d. H−1), mutasi hari itu (D/K), saldo akhir, outstanding giro (FP payment type 5,6 belum validasi), outstanding FP (type 1–4 belum `F`), `SaldoAktual = saldo akhir − giro − FP`.

### 8.8 Laporan item/sales person (tidak dipakai)
Agregasi per item / kategori item / sales person: Quantity, `WeightNetto = Σ Qty × IN_M_Item.WeightNetto`, `Amount = Σ Qty × UnitPrice`, `NetPrice = Amount / Weight`, dikurangi refund (nilai negatif). Bergantung `IN_M_Item`/kategori (tidak ada di AVKDB). Dynamic SQL.

---

## 9. Tabel dalam scope

| Tabel | Rows | Tujuan & kolom kunci | Relasi implisit (tanpa FK) | Status |
|---|---|---|---|---|
| `CM_T_SalesInvoiceHeader` | 0 | Header AR: `InvoiceNo` (DRAFT-n → final), `InvoiceStatus`, `COAHeader` (akun piutang), `TaxInvoiceNo`, `ERPNo`, `TotalSalesAmount` (hanya data upload), `AuditNotes`, approve/void fields | Partner, Branch, Company, SalesPerson, DocumentType(1), COA | Tidak dipakai |
| `CM_T_SalesInvoiceDetail` | 0 | Baris: Project, Item, COA (pendapatan), `IDX_M_Tax`, `IncludeTax`, `Quantity`, `UnitPrice`, `UntaxedAmount`, `DiscountAmount`, `TaxAmount` (PPN per unit), `IDX_Prev_T_SalesInvoiceDetail` (duplikasi) | → Header | Tidak dipakai |
| `CM_T_SalesInvoiceTax` | 0 | Pajak per baris (PPN auto `AllowEdit N`, PPh manual `Y`), `TaxAmount` per unit, `TaxCOA` | → Header, Detail, `GL_M_Tax` | Tidak dipakai |
| `CM_T_PurchaseInvoiceHeader/Detail/Tax` | 0/0/0 | Mirror AP; header + `VendorInvoiceNo`, `FakturPajak` (teks), `IsTaxChecked`, `SupplierDeliveryNo`, `IDX_ReferenceNo` (PO) | → PR_T_PurchaseOrder (tidak ada) | Tidak dipakai |
| `CM_T_SalesRefundHeader/Detail/Tax` | 0 | Retur penjualan; detail punya `RefundQuantity`, `RefundPrice`, `TaxRefundAmount` | → SalesInvoice header/detail | Tidak dipakai |
| `CM_T_PurchaseRefundHeader/Detail/Tax` | 0 | Retur pembelian (header pakai kolom `Invoice*`) | → PurchaseInvoice | Tidak dipakai |
| `CM_T_ReceiveAllocation` | 0 | Alokasi FR detail → Sales Invoice | → `CM_T_FinancialReceiveDetail` (1972 row), invoice via (`IDX_M_DocumentType`,`IDX_DocumentNo`) | Tidak dipakai |
| `CM_T_PaymentAllocation` | 0 | Alokasi FP detail → Purchase Invoice | → `CM_T_FinancialPaymentDetail` (2466 row) | Tidak dipakai |
| `CM_M_FakturNumber` | 0 | Periode NSFP `PeriodFaktur` YYYYMM, `StatusFaktur` Open/Close | – | Tidak dipakai |
| `CM_M_FakturNumberLine` | 0 | Nomor NSFP, `isUsed`, `IDX_T_Transaction` (ID invoice) | → FakturNumber, SalesInvoice | Tidak dipakai |
| `CM_T_FakturPajak` | 0 | Data faktur (KodeTransaksi, FakturPengganti, NomorFaktur, Masa/Tahun) | `IDX_T_Transaction`+`TransactionType` | Tidak dipakai, tanpa SP |
| `CM_T_TaxInvoiceHeader/Detail` | 0 | Faktur pajak generik (NPWP, PPNBM, Valas/Rupiah) | `ReferenceTable`+`IDX_DocumentNo` | Tidak dipakai, tanpa SP |
| `CM_M_CashflowID` | 0 | Master klasifikasi arus kas (`CashflowID`, In/OutFlag, parent) | ← `GL_M_COA.IDX_M_CashflowIn/Out` | Tidak dipakai |
| `GL_M_Tax` (pendukung) | 0 | Master pajak: `TaxRate`, `COAIn` (sales), `COAOut` (purchase), `IsWithHoldingTax` | – | **Kosong** → semua kalkulasi pajak tidak bisa jalan |
| `GL_M_FiscalPeriod` (pendukung) | 0 | Kunci periode (`GLStatus=1` closed) | – | **Kosong** → kunci periode tak berfungsi |

Kode dokumen (`GN_M_DocumentType`, 13 row): controller memakai 1 = Sales Invoice, 2 = Purchase Invoice; SP memakai 3 (FR header), 4 (FP header), 10 (sales refund auto-copy), 700 (POS). Verifikasi isi `GN_M_DocumentType` sebelum recode.

---

## 10. SP tidak terpakai & SP yang dipanggil tetapi tidak ada (scope ini)

**Ada di DB tetapi tidak dipanggil kode (48):**
`USP_CM_FakturNumber_ClosePeriod`, `_Create`, `_Info`, `_Info2`, `_Line_Create`, `_Line_List`, `_List`, `_OpenPeriod`; `USP_CM_PaymentAllocation_CreateMultiple`, `USP_CM_PaymentAllocation_Journal_List`; `USP_CM_PurchaseInvoiceItem_List`, `USP_CM_PurchaseInvoice_Journal_Inquiry`, `USP_CM_PurchaseInvoice_OS_List`, `USP_CM_PurchaseInvoice_Void`; `USP_CM_PurchaseRefundHeader_Create`, `_Update`, `USP_CM_PurchaseRefundTax_Info`, `_List`, `USP_CM_PurchaseRefund_Approve`, `_List`, `_SelectInvoice`; `USP_CM_R_Cashflow`, `USP_CM_R_CashflowBank`, `USP_CM_R_PurchaseInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_DetailBySalesPersonSummary` (+`_Backup`), `USP_CM_R_SalesInvoice_Item` (+`_Backup`), `USP_CM_R_SalesInvoice_ItemCategorySummary` (+`_Backup`), `USP_CM_R_SalesInvoice_Period-Backup`, `USP_CM_R_SalesInvoice_Period_Backup`; `USP_CM_ReceiveAllocation_Journal_List`; `USP_CM_SalesInvoiceItem_List`, `USP_CM_SalesInvoice_FakturHeader_Export`, `USP_CM_SalesInvoice_Faktur_List`, `USP_CM_SalesInvoice_List_bak`, `USP_CM_SalesInvoice_List_new`, `USP_CM_SalesInvoice_OS_List`, `USP_CM_SalesInvoice_SalesRefund_OWN_List`; `USP_CM_SalesRefundHeader_Create`, `_Update`, `USP_CM_SalesRefundTax_Info`, `_List`, `USP_CM_SalesRefund_Approve`, `_Journal_List`, `_List`, `_Void`.
→ Kandidat dibuang (backup, _bak, _new) atau dijadikan spesifikasi bila fitur refund/faktur memang dibutuhkan.

**Dipanggil tetapi tidak ada di DB:**
- `USP_CM_Tax_List` — hanya di kode yang dikomentari (`SalesInvoiceController::inquiry_data_tax`), aman.
- `USP_QP_UploadSummary_Sales`, `USP_QP_UploadSummary_Member` — dipanggil `SalesInvoiceController::generate_daily_summary_pdf` (di luar prefix scope, tapi rute invoice) → error runtime.
- Dari dalam SP: `USP_CheckUserForm` (alokasi), `fn_GetSalesInvoicePayment` (`USP_CM_SalesInvoice_Info`), `View_PurchaseInvoiceOS` (`USP_CM_PurchaseInvoice_Void`), serta tabel `IN_M_*`, `PR_T_PurchaseOrder*`, `PS_T_PosOrderLine`, `X_*Summary_Quality` (lihat §0; perlu konfirmasi apakah benar tidak ada atau berupa synonym/view lintas DB).

---

## 11. Catatan recode

### 11.1 Logika tersembunyi / risiko
- **Transaksi**: CATCH bisa `COMMIT` sebagian; beberapa SP (Detail_Delete, Tax_Delete, Allocation_Delete) tanpa transaksi. Recode: satu `DB::transaction()` per use-case, rollback total.
- **Penomoran** (invoice, voucher, refund, ERPNo): `TOP 1 … ORDER BY … DESC` tanpa lock, filter `PostingStatus='P'` ⇒ duplikasi saat concurrent/after reverse. Recode: tabel counter (`document_sequences` per prefix/branch/periode) dengan `SELECT … WITH (UPDLOCK, HOLDLOCK)`/`lockForUpdate()`, plus unique index pada `InvoiceNo`/`VoucherNo`.
- **Format inkonsisten**: InvoiceNo pakai `YYMM`, voucher pakai `MMYY`. Putuskan & dokumentasikan.
- **Hardcode**: JournalType 1/2/3/8/9/11, ApplicationID 1, currency 1, DocumentType 1/2/3/4/10/700, rate PPN 10/11 (laporan /1.1), form `CF-APPR-001`, item 177 "Pembulatan", tanggal `2019-12-16`, ERPNo seed 10719, project `LIKE '%ho'`, `LEN(ReferenceNo)=13` = data upload Excel, label COA 'PPN Keluaran'/'PPh 23 Sales Tax'. Pindahkan ke config/master.
- **PPN rate**: include-tax hanya mendukung 10% & 11%; PPN 12% (2025) tidak didukung — rate lain menghasilkan Tax = UnitPrice (dari controller). Recode: `DPP = round(gross / (1 + rate/100))`, `PPN = gross − DPP`, generik.
- **Pembulatan**: PPN exclusive = truncate (FLOOR menuju nol) per unit lalu dikali Qty; PPN inclusive = ROUND 0 desimal DPP per unit; purchase memakai FLOOR agregat di jurnal. Perbedaan per-unit vs per-baris vs per-dokumen menyebabkan selisih & jurnal tidak seimbang. Recode: tetapkan satu aturan (rekomendasi DJP: hitung per baris/dokumen, bulatkan ke bawah rupiah) dan **validasi Σ Debet = Σ Kredit sebelum commit**.
- **Diskon ganda** pada include-tax (lihat §3.5).
- **Multi PPN/PPh**: Approve hanya menangani satu akun PPN & satu akun PPh (variabel diisi dari baris terakhir GROUP BY). Recode: jurnal pajak di-group per `TaxCOA`.
- **Status tidak dijaga**: detail/pajak/header bisa diubah setelah approve; header Update menimpa `InvoiceStatus='D'`; allocation approved bisa dihapus/diubah; PaymentAllocation bisa di-approve berulang; Void tidak cek refund/status; Reverse tidak cek status. Recode: policy/guard per state.
- **Reverse**: menghapus detail jurnal (bukan jurnal pembalik) → jejak audit hilang; `ApprovedDate` tidak di-reset sehingga re-approve terkunci ke bulan yang sama (cek hanya bulan, bukan tahun).
- **Void Sales**: blok jika ada alokasi berstatus apa pun dengan `IDX_DocumentNo` sama tanpa memeriksa tipe dokumen (ID purchase/sales bisa bentrok).
- **Faktur**: nomor tidak dilepas saat reverse/void; tidak ada cek nomor sudah dipakai; `TaxInvoiceNo` tidak pernah diisi dari UI; Create periode tidak mengisi `StatusFaktur`.
- **Dynamic SQL & injection**: `USP_CM_SalesInvoice_List`, `USP_CM_PurchaseInvoice_List`, `*_Faktur_List`, `*_Refund_List`, `FakturNumber_*List`, report item — semua concatenation input user. Plus `exec_sp` di PHP juga concatenation. Recode: query builder + binding.
- **Temp table / cursor**: `#TempInvoice`, `#TempReceive`, `#TAMPUNG` (OUTPUT clause untuk mapping detail lama→baru pada Duplicate), loop WHILE di `FakturNumber_Line_Create` & `PaymentAllocation_CreateMultiple` (CSV parsing manual). Tidak ada CURSOR.
- **Keamanan**: `ApprovalBy` dari request dipakai sebagai user approver; prefix `XXX` merusak audit trail.
- **Data upload (X_*Summary_Quality)**: ada cabang logika khusus (jurnal piutang `TotalSalesAmount − DiffFactor`, larangan ubah/duplikat) untuk transaksi hasil upload Excel klien lama — kemungkinan tidak relevan untuk AVK; konfirmasi dengan bisnis sebelum di-port.

### 11.2 Usulan struktur Laravel
- `App\Services\Finance\Invoice\InvoiceCalculator` — hitung DPP/PPN/PPh per baris & total (pure function, mudah di-unit-test). Input: unitPrice, discount, qty, taxRate, includeTax; output: untaxed, taxPerUnit, lineDpp, lineTax.
- `SalesInvoiceService` / `PurchaseInvoiceService` (atau satu `InvoiceService` dengan strategy `direction = AR|AP`): `createDraft`, `updateDraft`, `addLine`, `updateLine`, `removeLine`, `addWithholdingTax`, `approve`, `reverse`, `void`, `duplicate`.
- `InvoiceJournalBuilder` (AR/AP/Refund/Void) → menghasilkan DTO baris jurnal; `JournalPoster` (dipakai lintas modul, milik GL) memvalidasi D=K, period lock, membuat voucher.
- `DocumentNumberGenerator` (invoice, voucher, refund) berbasis tabel sequence ber-lock.
- `FiscalPeriodGuard` (satu sumber kunci periode — sinkron dengan yang dipakai Treasury).
- `AllocationService` (Receive/Payment): create/update/delete/approve + `OutstandingCalculator` (definisi tunggal §5.5).
- `RefundService`, `TaxNumberService` (NSFP pool: reserve/consume/release), `EFakturExporter`.
- `InvoiceStatus` enum (`D,A,F,V,C`) + state machine (mis. spatie/laravel-model-states atau guard manual).
- Read model/report: Query class per laporan (`SalesInvoicePeriodReport`, dll.) memakai definisi total/outstanding yang sama.

### 11.3 Test case penting
1. Kalkulasi baris: exclusive 11% (`UnitPrice 100.000, Disc 0, Qty 3` → DPP 300.000, PPN 33.000); inclusive 11% (`111.000` → DPP 100.000, PPN 11.000); rate 12%; nilai yang menghasilkan pecahan (truncate vs round); baris negatif (potongan) → pajak negatif terpotong menuju nol; diskon per unit.
2. PPh tambahan: hanya `IsWithHoldingTax=1` diterima; PPN via additional tax ditolak; PPh pada detail purchase ditolak; edit/hapus pajak `AllowEdit='N'` ditolak.
3. Approve AR: jurnal seimbang (Piutang = DPP + PPN − PPh), baris potongan didebit, multi-COA pendapatan, multi tarif PPN (harus tetap seimbang), invoice tanpa detail ditolak, UnitPrice 0 ditolak, ApprovalDate < InvoiceDate ditolak, periode tutup ditolak, approve ulang ditolak.
4. Approve AP: cek batas PO (Σ invoice approved + ini ≤ PO, pesan dengan angka), detail tanpa COA ditolak, jurnal seimbang termasuk FLOOR PPN.
5. Penomoran: urutan per branch per bulan, reset bulan baru, format `{Doc}-{Branch}-{YYMM}-{NNNN}`, re-approve setelah reverse mempertahankan nomor, re-approve beda bulan ditolak, concurrency (dua approve paralel tidak menghasilkan nomor sama).
6. Reverse: ditolak bila ada alokasi/refund approved/periode tutup; status kembali D; jurnal tidak lagi aktif (recode: jurnal pembalik/unpost sesuai kebijakan GL).
7. Void AR: jurnal pembalik = kebalikan persis jurnal asal; ditolak bila ada alokasi; void dua kali ditolak.
8. Alokasi: amount > nilai detail FR/FP ditolak; > outstanding ditolak (AR juga, perbaikan); approve sebelum FR/FP approved ditolak; COA sama → tanpa jurnal; COA beda → D COADetail / K COAAllocation; alokasi negatif; hapus alokasi approved ditolak (perbaikan); outstanding invoice berkurang hanya oleh alokasi `A`.
9. Refund: hanya satu refund approved per invoice; RefundQty 0 ditolak; jurnal SR seimbang; void refund membalik jurnal; laporan menampilkan refund sebagai negatif.
10. Faktur: generate 12 periode; generate range nomor (format `PPP.NNN-YY.NNNNNNNN`); nomor terpakai tidak muncul di pilihan; close/open periode; export FK (NPWP tanpa tanda baca, DPP/PPN dibulatkan ke bawah).
11. Laporan: Sales period dengan/ tanpa branch & partner (refund tidak hilang saat branch dipilih), DPP/PPN memakai rate aktual (bukan /1.1), Purchase period definisi pembayaran konsisten, Bank transfer saldo awal + running balance.
12. Keamanan: filter list tidak bisa diinjeksi; user hanya melihat branch di `SM_M_UserBranch`; approver = user login (bukan field request).
