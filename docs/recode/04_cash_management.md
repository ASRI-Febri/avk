# Modul Cash Management – Kas & Bank (CM)

> Cakupan: sisi treasury modul CM – Financial Payment (FP), Financial Receive (FR), Internal Transfer (IT), Petty Cash (PC), Rekening Koran / Rekonsiliasi Bank (Bank Statement, BS), master Financial Account, Cashflow ID, Mapping Cashflow, `usp_CM_ClosingPeriod`, SP Branch/Company/Partner/SearchByValue versi CM, beserta tabel `CM_*` terkait.
> Invoice/refund/pajak/faktur/alokasi (`CM_T_PaymentAllocation`, `CM_T_ReceiveAllocation`, `USP_CM_*Invoice*`, `USP_CM_R_*`) dibahas di bagian lain; di sini hanya disebut pada titik interaksi.
>
> Sumber: definisi SP dari DB lokal `AVKDB` (hasil ekstraksi), controller `app/Http/Controllers/Finance/*`, `routes/web/finance.php`, view `resources/views/finance/*`, service `app/Services/BankStatement/*`, folder `SQLStoredProcedure/` & `app/StoredProcedure/` di repo, serta git log. Tidak ada query ke DB yang dijalankan untuk dokumen ini. Bila ada hal yang tidak bisa dipastikan dari kode, ditandai **(belum pasti)**.

---

## 1. Ringkasan fitur & alur bisnis end-to-end

| Fitur | Menu / route prefix | Controller | Fungsi bisnis |
|---|---|---|---|
| Financial Account | `/fm-financial-account` | `FinancialAccountController` | Master rekening kas/bank/deposito per cabang, dipetakan ke 1 COA GL. Menjadi prefix penomoran FP/FR dan sumber COA bank untuk jurnal. |
| Financial Payment (FP) | `/fm-financial-payment`, `/fm-financial-payment-detail` | `FinancialPaymentController`, `FinancialPaymentDetailController` | Pengeluaran kas/bank ke partner. Header = rekening sumber + total; detail = baris COA lawan (biaya/hutang/rekening antara) + dokumen referensi (PO valas / PI). |
| Financial Receive (FR) | `/fm-financial-receive`, `/fm-financial-receive-detail` | `FinancialReceiveController`, `FinancialReceiveDetailController` | Penerimaan kas/bank dari partner (cermin FP). |
| Internal Transfer (IT) | `/fm-internal-transfer` | `InternalTransferController` | Pemindahan dana antar Financial Account (kas ↔ bank, bank ↔ bank). |
| Petty Cash (PC) | `/fm-petty-cash`, `/fm-petty-cash-detail` | `PettyCashController`, `PettyCashDetailController` | Kas kecil metode imprest: catat pengeluaran, saat *Close* dibuat jurnal reimburse. |
| Rekening Koran & Rekonsiliasi | `/fm-bank-statement*` | `BankStatementController` + `App\Services\BankStatement\{MandiriStatementParser, LedgerReconciler, PdfDecryptor}` | Upload PDF Kopra Mandiri → simpan baris mutasi → buat jurnal (per baris, gabungan, biaya admin, akhir bulan) → rekonsiliasi dengan ledger COA bank (cocok otomatis, cocok manual, jurnal penyesuaian). |
| Pembayaran dari Money Changer | (modul MC) `USP_MC_PurchaseOrder_Payment`, `USP_MC_SalesOrder_Payment` | `MoneyChanger\*PaymentController`, `PurchaseQuickController`, `SalesQuickController` | Membuat FP/FR otomatis berstatus Approved + jurnal saat pembayaran nota beli/jual valas. **Sumber mayoritas data FP/FR** (2.466 FP, 1.972 FR; 1 detail per header). |

### Alur end-to-end (sederhana)

```
Master: GN_M_Branch ─┬─ CM_M_FinancialAccount (IDX_M_COA = COA kas/bank)
                     └─ GN_M_Partner (+ GN_M_PartnerAddress)

FP / FR manual:
  Create header (status D, nomor DRAFT-<id>)
    → tambah detail COA (+ link ke dokumen PO/SO valas)
    → Approve: nomor final <FAID>-<BranchID>-<YYMM>-<NNNN>, status A,
               jurnal GL Posted (type 4 FP / type 3 FR)
    → (opsional) Reverse to Draft: hapus jurnal, status D (nomor dipertahankan)
    → (FR saja di UI) Void: status V + jurnal "VOID" (lihat bug §2.2.7)

FP / FR otomatis (modul MC):
  USP_MC_PurchaseOrder_Payment / USP_MC_SalesOrder_Payment
    → insert header+detail langsung status A (nomor <DocTypeID><IDX_M_Branch>-<id>, mis. FP1-61398)
    → EXEC USP_CM_FinancialPayment_CreateJournal / USP_CM_FinancialReceive_CreateJournal

Internal Transfer: Create (D, nomor IT/<Company>/<yyyyMM>/<id6>) → Approve (A, jurnal type 9 Posted)
                   → Reverse (D, jurnal dihapus) | Void (V, jurnal dihapus)

Petty Cash: Create (O, nomor PC-<BranchID>-<yyyyMM>-<NNNN>) → detail pengeluaran
            → Close (C, jurnal type 10 Unposted) → Reopen (O, jurnal dihapus bila belum Posted)

Rekening koran: Upload PDF → Preview → Save (header+detail)
   → Jurnal per baris / gabungan / biaya admin / akhir bulan (GL type 'JM', Unposted, VoucherNo DRAFT-<id>)
   → Rekonsiliasi: LedgerReconciler (in-memory) + Match manual + Jurnal penyesuaian
   → Posting jurnal dilakukan di menu Accounting > Journal (di luar modul ini)
```

### Konvensi teknis yang berlaku di seluruh modul
- Semua SP transaksi mengembalikan result set `Result` (`'success'|'error'`), `ID`, `LogDesc`. `MyController::store()` mengambil **baris terakhir** sebagai hasil (penting: lihat §5 risiko "error tertutup success").
- `MyController::exec_sp()` merangkai `EXEC sp a,b,'c'` secara positional; nilai numerik tanpa kutip, string dengan kutip tunggal tanpa escaping. Prefix `'XXX'` pada nilai = paksa diperlakukan string (prefix dibuang). Contoh `UserID = 'XXX'.$user_id`. BankStatementController memakai `esc()` (`'` → `''`) manual; controller lain tidak → rawan SQL injection.
- Pola standar SP: `BEGIN TRY / BEGIN TRANSACTION`, kumpulkan error di table variable `@TableLog`, jika `COUNT(*) = 0` lakukan aksi, `COMMIT`. `CATCH` standar: insert error `CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())` (bug: `INT + VARCHAR` → error konversi di dalam CATCH), lalu `ROLLBACK` jika `XACT_STATE() = -1` tetapi **`COMMIT` jika `XACT_STATE() = 1`** (perubahan parsial bisa ter-commit).
- Kolom audit standar: `UCreate/DCreate/UModified/DModified/RecordStatus` (`'A'` aktif, `'D'`/`'I'` nonaktif).
- Pengecekan periode fiskal memakai `GL_M_FiscalPeriod.GLStatus = 1` dengan `FiscalPeriod = 'yyyyMM'`. **Tabel `GL_M_FiscalPeriod` berisi 0 baris** → semua kunci periode saat ini tidak pernah memblokir.

---

## 2. Detail per entitas / proses

### 2.1 Master Financial Account (`CM_M_FinancialAccount`)

| SP | Parameter penting | Dipanggil dari |
|---|---|---|
| `USP_CM_FinancialAccount_List` | paging standar (`@Page,@Row,@SortBy,@SortDir,@ReturnType` + filter) | `FinancialAccountController@inquiry_data` (`POST /fm-financial-account-list`) |
| `USP_CM_FinancialAccount_Info` | `@IDX_M_FinancialAccount` | `create`, `update/{id}` |
| `USP_CM_FinancialAccount_Create` | `@IDX_M_Company, @IDX_M_Branch, @IDX_M_Bank, @IDX_M_Currency, @IDX_M_COA, @FinancialAccountID, @FinancialAccountDesc, @FinancialAccountType, @AccountName, @AccountNo, @UserID, @RecordStatus` | `save` (state create) |
| `USP_CM_FinancialAccount_Update` | `@IDX_M_FinancialAccount` + sama | `save` (state update) |

Aturan:
- `FinancialAccountType`: `B`=Bank, `C`=Cash, `D`=Deposito (dropdown `DropdownController::account_type`).
- Create: jika `@IDX_M_Company = 0` → diisi dari `GN_M_Branch.IDX_M_Company`. Controller selalu mengirim `IDX_M_Company = 0`.
- **Bug**: Update tidak melakukan resolusi yang sama → setiap edit menyimpan `IDX_M_Company = 0`. `USP_CM_BankStatement_Save` sudah mengakali dengan `COALESCE(NULLIF(FA.IDX_M_Company,0), Branch.IDX_M_Company)`. Saat recode: selalu turunkan company dari branch.
- Tidak ada validasi unik `FinancialAccountID`, padahal dipakai sebagai prefix nomor FP/FR. Tidak ada validasi COA wajib.
- Dropdown FA di form transaksi difilter cabang user (`SM_M_UserBranch`).
- Kolom `isUsedByPOS` ada di tabel, tidak disentuh SP ini.

### 2.2 Financial Payment (FP) & Financial Receive (FR)

FP dan FR adalah pasangan simetris. Perbedaan dicatat di setiap sub-bagian.

#### 2.2.1 Daftar SP & pemanggil

| SP (FP) | SP (FR) | Route / method | Keterangan |
|---|---|---|---|
| `USP_CM_FinancialPayment_List` | `USP_CM_FinancialReceive_List` | `POST /fm-financial-payment-list` → `inquiry_data` | Dynamic SQL, filter LIKE, dibatasi cabang user (`SM_M_UserBranch`). `@PaymentAmount` diisi → `FLOOR(amount) = nilai`. |
| `USP_CM_FinancialPayment_Info` | `USP_CM_FinancialReceive_Info` | `create`, `update/{id}`, modal approve/reverse/void, PDF | Mengembalikan `StatusDesc`. |
| `USP_CM_FinancialPaymentHeader_Create` / `_Update` | `USP_CM_FinancialReceiveHeader_Create` / `_Update` | `POST …/save` | |
| `USP_CM_FinancialPaymentDetail_List/_Info/_Create/_Update/_Delete` | `USP_CM_FinancialReceiveDetail_*` | `…-detail/*` | |
| `USP_CM_FinancialPaymentDetail_LinkDocument` | `USP_CM_FinancialReceiveDetail_LinkDocument` | `POST …-detail/save-link-document` | Hubungkan detail ke PO/SO valas. |
| `USP_CM_FinancialDetail_DocumentSearch` | (sama) | `POST …-detail/search-document` | `@TransactionType` `'P'`→PO valas, lain→SO valas. |
| `USP_CM_FinancialPayment_Approve` | `USP_CM_FinancialReceive_Approve` | `POST …/save-approve` | Memanggil `*_CreateJournal`. |
| `USP_CM_FinancialPayment_CreateJournal` | `USP_CM_FinancialReceive_CreateJournal` | dipanggil SP lain (Approve, `USP_MC_*_Payment`) | Tidak dipanggil langsung dari PHP. |
| `USP_CM_FinancialPayment_ReverseApproval` | `USP_CM_FinancialReceive_ReverseValidate` | `POST …/save-reverse` | **Asimetris**: FP pakai `ReverseApproval`, FR pakai `ReverseValidate`. |
| `USP_CM_FinancialPayment_Validate` | — | `POST /fm-financial-payment/save-validate` | Route ada, tombol UI di-comment (legacy status `F`). |
| `USP_CM_FinancialPayment_Void` | `USP_CM_FinancialReceive_Void` | `POST …/save-cancel` | Tombol Void tampil hanya di FR (status A). Di FP tombol di-comment. |
| `USP_CM_FinancialPayment_Duplicate` | `USP_CM_FinancialReceive_Duplicate` | `POST …/save-duplicate` | |
| `USP_CM_FinancialPayment_Journal_List` | `USP_CM_FinancialReceive_Journal_List` | tab jurnal di form | Draft preview untuk status selain F/V. |
| `USP_CM_FinancialPayment_PrintJournal` | `USP_CM_FinancialReceive_PrintJournal` | `GET …/download-pdf/{id}` | |
| `USP_CM_FinancialPayment_GetAllocation_List` | `USP_CM_FinancialReceive_GetAllocation_List` | `GET …/update/getDocumentNo/{id}` | Daftar invoice outstanding per partner+branch (lingkup alokasi). |
| `USP_CM_FinancialPayment_Handover`, `_Delete`, `_ReverseValidate`, `_Validate-BACKUP` | `USP_CM_FinancialReceive_Delete`, `_ReverseApproval` | — | **Tidak dipakai** kode. |

#### 2.2.2 State machine

Kode status `PaymentStatus` / `ReceiveStatus`:

| Kode | Arti (`StatusDesc` di `*_Info`) | Dipakai aktif? |
|---|---|---|
| `D` | Draft | Ya |
| `A` | Approved | Ya (status akhir normal) |
| `H` | Handover (FP saja) | Tidak (SP `Handover` tak dipakai) |
| `C` | Cancel | Tidak ada SP yang men-set |
| `F` | Validate | Legacy (FP `Validate`) |
| `V` | Void | FR (via UI), FP (route ada, tombol hidden) |

Transisi aktif:

```
            Header_Create                Approve                     ReverseApproval (FP)
  (none) ───────────────▶ D ─────────────────────────▶ A ───────────────────────────────▶ D
                          ▲                             │   ReverseValidate (FR)
                          │                             │
                          └─── Duplicate (dok baru D)   ├── Void ──▶ V   (FR via UI; FP hanya via POST langsung)
                                                        │
  USP_MC_*_Payment ───────────────────────────────────▶ A  (langsung, + jurnal)
Legacy FP: D/A ──Validate──▶ F ──ReverseValidate──▶ A ; F ──Void──▶ V
```

Guard status yang benar-benar ada di SP:
- `Header_Update`: error jika status ≠ `D`: `'Transaction status already not DRAFT, cannot change header information !'`.
- `Approve`: **tidak** mengecek status saat ini (UI hanya menampilkan tombol di D). Re-approve dokumen A via POST langsung akan meng-update ApprovalDate; jurnal tidak terduplikasi karena `CreateJournal` mengecek keberadaan jurnal.
- `ReverseApproval` (FP): tanpa cek status & tanpa cek periode.
- `ReverseValidate` (FR): error jika belum ada jurnal: `'This transaction is still not validated!'`; cek periode atas `ApprovalDate`: `'Cannot Reverse Because Journal Period Already Closed!'`.
- `Void`: hanya cek `VoidDate < ValidationDate` → `'Void Date < Validate Date!'` (ValidationDate NULL untuk alur normal → tidak pernah error). Tidak ada cek status.
- `Detail_Create/_Update/_Delete`: **tidak** mengecek status header (UI menyembunyikan tombol kalau bukan D).

#### 2.2.3 Header – create/update

Parameter FP (`USP_CM_FinancialPaymentHeader_Create`): `@IDX_M_Company, @IDX_M_Branch, @IDX_M_FinancialAccount, @IDX_M_DocumentType, @IDX_M_Partner, @IDX_M_Currency, @IDX_M_PaymentType, @COAHeader, @PaymentID, @VoucherNoManual, @PaymentDate, @RemarkHeader, @PaymentStatus, @PaymentAmount, @DestinationAccountName, @DestinationBank, @DestinationAccountNo, @PDCNo, @UserID, @RecordStatus`.
FR sama tanpa 4 field tujuan (`Destination*`, `PDCNo`) dan memakai `Receive*`.

Controller (`save`): mengambil `COAHeader` dari `CM_M_FinancialAccount.IDX_M_COA` (query inline), `PaymentStatus='D'`, `PaymentAmount = (double)str_replace(',','',…)`.

Validasi (pesan persis):

| Validasi | FP Create | FP Update | FR Create | FR Update |
|---|---|---|---|---|
| `IDX_M_Partner = 0` → `'Please Select Partner First!'` | ✔ | – | – | – |
| Company cabang ≠ `@IDX_M_Company` → `'Selected Branch Not Under The Same Group Company!'` | ✔ | – | ✔ | ✔ |
| `FA.IDX_M_Branch ≠ @IDX_M_Branch` → `'Selected Financial Account Not Under The Same Branch!'` | ✔ | – | ✔ | ✔ |
| status ≠ D → `'Transaction status already not DRAFT, cannot change header information !'` | – | ✔ | – | ✔ |

Aksi:
- `@IDX_M_Company` di-override dari `GN_M_Branch`; `@COAHeader` di-override dari `CM_M_FinancialAccount.IDX_M_COA`.
- Insert dengan `PaymentID=''`, lalu update `PaymentID = 'DRAFT-' + <IDX>` (FR: `ReceiveID`).
- Sukses: `('success', <IDX>, 'Data Sudah Disimpan')`.

#### 2.2.4 Detail

Kolom detail FP: `IDX_M_Project` (wajib, ≠0), `IDX_M_Branch` (diturunkan dari `GN_M_Project.IDX_M_Branch`), `IDX_M_Department` (=0), `IDX_M_DocumentType`, `IDX_DocumentNo`, `DocumentNo`, `COADetail`, `PaymentAmount` (boleh negatif), `RemarkDetail`. FR sama dengan `ReceiveAmount`.

Controller detail: `IDX_M_DocumentType` dipertahankan jika sudah ada, default `2` bila kosong/0 (komentar kode: sebelumnya dipaksa 2 sehingga detail dari PO valas doc type 11 hilang dari laporan AP).

Validasi:

| Pesan | FP Create | FP Update | FR Create | FR Update |
|---|---|---|---|---|
| `'Invalid chart of account!'` (COA tidak ada di `GL_M_COA`) | ✔ | ✔ | – | – |
| `'Please select Project/LocationID!'` (`@IDX_M_Project = 0`) | ✔ | ✔ | ✔ | ✔ |
| `'Selected Project Not Under The Same Group Company / Branch!'` (branch project ≠ branch header) | ✔ | ✔ | ✔ | ✔ |
| `'Total Payment Amount > Outstanding Amount !'` | ✔ | ✔ | – | – |

Rumus outstanding (FP, terhadap `CM_T_PurchaseInvoice*` dengan `IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo`):
- Create: `Outstanding = SUM(Quantity * UnitPrice)`
- Update: `Outstanding = SUM(Quantity*(UntaxedAmount-DiscountAmount) + Quantity*TaxAmount)`
- `PrevPayment = PaymentAmount` dari **satu** baris FP detail (bukan SUM) yang berstatus ≠ D untuk invoice tsb.
- Error jika `PrevPayment + @PaymentAmount > Outstanding`.
- Catatan: tabel Purchase Invoice kosong (0 baris) dan detail kini merujuk PO valas → `Outstanding` NULL → perbandingan NULL → **validasi ini efektif mati**.

Update detail FP: jika ada `CM_T_PaymentAllocation` untuk detail tsb, `COAAllocation` ikut di-update = `@COADetail`.

Delete detail: error jika ada alokasi: `'Please delete detail allocation first!'`; sukses `'Data Sudah Dihapus'`. Tanpa transaksi, tanpa cek status header.

`*_LinkDocument` (`@IDX_T_Financial…Detail, @IDX_M_DocumentType, @IDX_DocumentNo, @DocumentNo, @UserID`):
- `'Detail pembayaran tidak ditemukan!'` bila detail tidak ada.
- `'Detail ini sudah terhubung dengan dokumen <DocumentNo>!'` bila `DocumentNo` sudah terisi.
- FP: dokumen harus `MC_T_PurchaseOrder` dengan `IDX_T_PurchaseOrder=@IDX_DocumentNo AND RTRIM(PONumber)=RTRIM(@DocumentNo) AND POStatus='A'`, jika tidak `'Transaksi pembelian <no> tidak ditemukan atau belum di-approve!'`. FR analog terhadap `MC_T_SalesOrder` (`SOStatus='A'`), pesan tidak-ditemukan FR: `'Detail penerimaan tidak ditemukan!'`.
- Sukses: `'Pembayaran sudah dihubungkan dengan <no>'`.

`USP_CM_FinancialDetail_DocumentSearch(@TransactionType='R', @SearchValue='', @RowLimit=20)`: `RowLimit` di-clamp 1..100 (default 20). `'P'` → PO valas `POStatus='A'`, cari `PONumber`/`PartnerName` LIKE; else → SO valas `SOStatus='A'`. `DocumentAmount = SUM(BaseCurrencyAmount)` detail aktif. Urut ID desc.

#### 2.2.5 Approve – validasi, penomoran, jurnal

Parameter: `@IDX_T_…Header, @ApprovalDate VARCHAR(10), @ApproveRemark, @UserID`. UI default `ApprovalDate = PaymentDate/ReceiveDate`.

Validasi:

| Pesan | FP | FR |
|---|---|---|
| `'Journal Period Already Closed!'` (`GL_M_FiscalPeriod.GLStatus=1` untuk bulan ApprovalDate) | – | ✔ |
| `'Please Select Partner First'` (partner = 0) | ✔ | ✔ |
| `'No Data in Detail Transaction'` | ✔ | ✔ |
| FP: `'Total Amount <> Detail Amount'`; FR: `'Total receive <hdr> <> total detail <dtl>'` (header ≠ SUM detail, eksak 2 desimal) | ✔ | ✔ |
| `'Total Amount Cannot < Allocation Amount'` (header < SUM alokasi) | ✔ | – |
| `'Please Check Detail COA on Invoice Item'` (ada `COADetail = 0`) | – | ✔ |
| `'Every Selected COA Receive Allocation Detail Must be Same With Detail COA Transaction Item!'` | – | ✔ |
| Kunci bulan: jika `ApprovalDate` lama tidak NULL **dan** nomor berformat bulanan (`LIKE '%-[0-9]{4}-[0-9]{4}'`) **dan** `MONTH(ApprovalDate lama) <> MONTH(@ApprovalDate)` → `'VoucherNo Already Exist, Cannot Change Month Approval. Please VOID TRANSACTION!'` (FR: `…Please Void Transaction!`) | ✔ | ✔ |

> Kunci bulan dilonggarkan di commit `b2b1df8` (14-11-2026): sebelumnya berlaku untuk semua nomor, sehingga dokumen bernomor `FP1-<id>` (dari modul MC) yang di-reverse tidak bisa di-approve ulang pada tanggal transaksinya. Catatan: hanya `MONTH` yang dibandingkan (tahun diabaikan).

Penomoran (hanya bila nomor saat ini diawali `DRAFT`; selain itu nomor lama dipertahankan):

```
Nomor = RTRIM(FA.FinancialAccountID) + '-' + RTRIM(GN_M_Branch.BranchID) + '-' + YY + MM + '-' + NNNN
  YY, MM   = dari @ApprovalDate
  NNNN     = (nomor terakhir + 1), 4 digit, reset per (IDX_M_Branch, IDX_M_FinancialAccount, bulan+tahun ApprovalDate)
  nomor terakhir = RIGHT(ID,4) dari ID dengan LEN(ID) = 19, diurutkan RIGHT(ID,9) DESC ('YYMM-NNNN')
  FP Approve : kandidat hanya dari CM_T_FinancialPaymentHeader (UNION tabel yang sama dua kali)
  FR Approve : kandidat dari CM_T_FinancialReceiveHeader ∪ CM_T_FinancialPaymentHeader
```

Implikasi penting:
- Filter `LEN = 19` mengasumsikan panjang `FinancialAccountID + BranchID = 8` (mis. 5+3). Jika tidak, nomor lama tidak terbaca → selalu `0001` → **nomor duplikat**.
- FP dan FR dengan FA sama berbagi ruang nomor, tetapi FP Approve tidak melihat nomor FR → potensi duplikat antara FR dan FP.
- Tidak ada lock/sequence → race condition pada approval bersamaan.

Aksi Approve FP:
1. Update header: `PaymentID` (jika draft), `PaymentStatus='A'`, `ApprovalDate`, `ApprovedBy`, `ApprovalRemark`, `DModified/UModified`.
2. `CM_T_PaymentAllocation.AllocationStatus='A'` untuk semua alokasi detailnya.
3. Insert `CM_T_FinancialPaymentLog` (`LogType='Approval'`, `LogDate=@ApprovalDate`).
4. `EXEC USP_CM_FinancialPayment_CreateJournal`; bila `@Result <> 1` tambah error `'Create journal failed!'` **lalu tetap** tambah success `'Data Sudah Disimpan'` dan COMMIT.

Aksi Approve FR: sama (status, nomor, approval fields), panggil `USP_CM_FinancialReceive_CreateJournal`, lalu `CM_T_ReceiveAllocation.AllocationStatus='A'`. **FR tidak menulis log** (`CM_T_FinancialReceiveLog` hanya 1 baris).

#### 2.2.6 Jurnal GL Approve (`*_CreateJournal`)

Parameter: `@IDX_T_FinancialPayment|Receive BIGINT, @UCreate, @Result SMALLINT OUTPUT`.

Langkah:
1. **Hidden**: `UPDATE detail SET COADetail = 5 WHERE COADetail = 0` (COA ID 5 hardcoded; menurut `USP_MC_SalesOrder_Payment` = *Piutang Usaha*).
2. Bila belum ada `GL_T_JournalHeader` dengan `IDX_ReferenceNo = header id AND RTRIM(ReferenceNo) = RTRIM(PaymentID)` (status header A, RecordStatus A):

`GL_T_JournalHeader`:

| Kolom | Nilai |
|---|---|
| `IDX_M_JournalType` | FP: **4**, FR: **3** (hardcoded) |
| `IDX_M_Company/Branch/Partner` | dari header |
| `ApplicationID` | 0 |
| `IDX_ReferenceNo` | ID header FP/FR |
| `ReferenceNo` = `VoucherNo` | `PaymentID`/`ReceiveID` |
| `JournalDate` = `PostingDate` | **`PaymentDate`/`ReceiveDate`** (bukan ApprovalDate) |
| `RemarkHeader` | header remark |
| `PartnerDesc` | `GN_M_Partner.PartnerName` |
| `PostingStatus` | `'P'` (langsung Posted), `PostedBy=@UCreate` |
| `DebetAmount/CreditAmount` | 0 |
| `JournalSource` | `'S'` |
| `DCreate` | **NULL** (variabel belum diisi saat insert – bug) |

`GL_T_JournalDetail` – semua baris: `IDX_M_Project=99`, `IDX_M_Department=99`, `JournalSeqNo=0`, `OriginalCurrencyID=1`, `BaseCurrencyID=1`, `ExchangeRate=1`, `IDX_M_Partner=NULL` (bug: `@_IDX_M_Partner = @_IDX_M_Partner`), O-amount = B-amount (tanpa konversi kurs).

| Jurnal | Baris | Debit | Kredit | Remark |
|---|---|---|---|---|
| **FP** (type 4) | per detail `PaymentAmount > 0` | `COADetail` = `ABS(amount)` | | `'Pembayaran Pembelian ' + DocumentNo` |
| | per detail `PaymentAmount < 0` | | `COADetail` = `PaymentAmount` (**negatif, tidak di-ABS** – bug) | idem |
| | bank, per **kelompok dokumen** (`GROUP BY FA.COA, DocType, IDX_DocumentNo, DocumentNo`) | | `ISNULL(FA.IDX_M_COA, 9999)` = **total seluruh detail** | idem |
| **FR** (type 3) | bank, per kelompok dokumen | `ISNULL(FA.IDX_M_COA, 9999)` = total seluruh detail | | `'Penerimaan Piutang ' + DocumentNo` |
| | per detail `ReceiveAmount < 0` | `COADetail` = `ABS(amount)` | | idem |
| | per detail `ReceiveAmount > 0` | | `COADetail` = amount | idem |

> **Bug kritis**: baris bank memakai total seluruh detail tetapi dibuat satu baris per dokumen berbeda. Dokumen FP/FR dengan ≥2 detail yang `DocumentNo`-nya berbeda menghasilkan jurnal **tidak balance** (bank = total × jumlah dokumen). Tidak ada pengecekan balance. Data saat ini 1 detail/header sehingga belum terpicu.

3. `@Result = 1`. Bila error di CATCH, `@Result` tetap NULL dan pemanggil mengecek `IF @_JournalResult <> 1` → NULL → **kegagalan jurnal tidak terdeteksi**.

#### 2.2.7 Reverse, Void, Delete, Duplicate

**FP `USP_CM_FinancialPayment_ReverseApproval`** (`@IDX, @ApproveRemark, @UserID`):
1. Jika ada jurnal (`IDX_ReferenceNo = id AND ReferenceNo = PaymentID`, jenis apa pun): hapus `GL_T_JournalDetail` lalu `GL_T_JournalHeader` (hard delete, termasuk jurnal yang sudah Posted).
2. Jika ada alokasi berstatus A: daftar ID alokasi **diambil dari `CM_T_FinancialReceiveDetail/CM_T_ReceiveAllocation` memakai ID header FP** (bug salah tabel), set `CM_T_PaymentAllocation.AllocationStatus='D'` untuk ID tsb, dan hapus `GL_T_JournalHeader/Detail` type **9** yang `IDX_ReferenceNo` ∈ ID tsb (urutan: header dulu baru detail). Karena type 9 juga dipakai Internal Transfer, bug ini berpotensi menghapus jurnal IT. Saat ini `CM_T_ReceiveAllocation` kosong → tidak berdampak.
3. Header: `PaymentStatus='D'`, `ApprovedBy/ApprovalRemark/ValidateBy/ValidationRemark = NULL`. **`PaymentID` dan `ApprovalDate` tidak dikosongkan** (nomor final dipertahankan).
4. Semua alokasi detail → `AllocationStatus='D'`.
5. Log `CM_T_FinancialPaymentLog` `LogType='ReverseApproval'`.
- Tidak ada cek periode fiskal, tidak ada cek status.

**FR `USP_CM_FinancialReceive_ReverseValidate`** (`@IDX, @ReverseRemark, @UserID`):
- Validasi periode (`ApprovalDate`) dan harus ada jurnal (lihat §2.2.2).
- Header: `ReceiveStatus='D'`, `ApprovedBy=NULL`, `ApprovalRemark=NULL`, `ValidationDate=NULL`, `ValidateBy=@UserID`.
- Hapus jurnal (detail lalu header). Alokasi A → `D`, hapus jurnal alokasi type **8** (`IDX_ReferenceNo` ∈ ID alokasi).
- Log ke `GL_T_JournalHeaderLog` (`LogType='Unposting'`, `IDX_T_JournalHeader` = ID jurnal yang sudah dihapus).

**FP `USP_CM_FinancialPayment_ReverseValidate`** (tidak dipakai): F → A, hapus detail jurnal, set header jurnal `RecordStatus='I'`, log `GL_T_JournalHeaderLog`.

**Void** (`@IDX, @VoidDate DATE, @VoidReason, @UserID`) – FP & FR identik kecuali tipe jurnal:
1. Status `V`, `VoidDate/VoidReason/VoidBy`.
2. **Hard delete** semua alokasi (`CM_T_PaymentAllocation` / `CM_T_ReceiveAllocation`).
3. Buat jurnal pembalik: tipe FP **12**, FR **13**; `VoucherNo = JournalTypeID + '-' + BranchID + '-' + YY + <DD> + '-' + NNNN` (bug: `@_Month = RIGHT(RTRIM(@VoidDate),2)` → mengambil **hari**, bukan bulan; counter dari VoucherNo `LEN=16` tipe sama bulan sama, `YEAR(@VoidDate)=YEAR(@VoidDate)` tautologi). `ReferenceNo=PaymentID`, `RemarkHeader='VOID TRANSACTION - ' + remark`, `PostingStatus='P'`, tanggal `@VoidDate`.
4. Detail pembalik = salinan baris jurnal sumber dengan debit↔kredit ditukar, sumber = jurnal tipe **7** (FP) / **6** (FR) dengan `IDX_ReferenceNo` = id, Posted.
- **Bug kritis**: jurnal approve FP adalah tipe 4 dan FR tipe 3, sedangkan Void membalik tipe 7/6 (jurnal "Validate" legacy). Untuk dokumen hasil Approve, Void menghasilkan header jurnal tanpa detail dan **jurnal asli tetap Posted** → saldo kas/bank tidak berubah walau status V. Selain itu `GL_M_JournalType` hanya berisi 11 baris sehingga ID 12/13 kemungkinan tidak ada (**belum pasti**, isi tabel tidak diekstrak).
- Tidak ada cek periode, tidak ada cek status.

**Delete** (`USP_CM_Financial*_Delete`, tidak dipakai): blokir bila status A/F (`'Financial transaction already approved!'`) atau ada alokasi A/F (`'There are financial allocation that already approved!'`); log `'Delete'`; hapus detail, alokasi, header, dan jurnal tipe 4/3.

**Duplicate** (`@IDX, @UserID`): salin header ke dokumen baru dengan `PaymentDate = GETDATE()`, status `D`, semua field approval/validate/void/handover/voucher/PDC/tujuan = NULL, `PaymentID='DRAFT-<id baru>'`; salin detail dengan `IDX_DocumentNo=0`, `DocumentNo=NULL` (COA, project, amount, remark tetap). Pesan: `'Data Berhasil Duplikat ke DRAFT-<id>'`.

#### 2.2.8 FP Validate (legacy, route masih aktif)

`USP_CM_FinancialPayment_Validate(@IDX, @ValidationDate, @VoucherNoManual, @PDCNo, @ValidateRemark, @UserID)`; controller mengganti `VoucherNoManual` dengan `'-'` bila sama dengan `PDCNo`.
- Validasi: periode tutup `'Journal Period Already Closed!'`; `'Validation Date cannot earlier than Transaction Date'`; `'No Data in Detail Transaction'`; `'Total Amount <> Detail Allocation Amount'`; `'This payment already validate!'` (status F); `'Please Check Detail COA on Invoice Item'`; `'Every Selected COA Payment Allocation Detail Must be Same With Detail COA Transaction Item!'`; kunci bulan seperti Approve (tanpa pengecualian format).
- Nomor dokumen (bila draft) seperti Approve tetapi ruang nomor FR ∪ FP.
- Status `F`, isi Approval* **dan** Validation*, alokasi → A, log `'Approval'`.
- Jurnal tipe **7**, `VoucherNo = JournalTypeID + '-' + BranchID + '-' + MM + YY + '-' + NNNN` (urutan MMYY, beda dengan nomor dokumen YYMM), counter per bulan PostingDate + tipe + branch, `ApplicationID=1`, `VoucherNoManual`, `RemarkHeader=UPPER(remark)`, Posted. Detail: Dr `COADetail` (amount>0, `IDX_M_CashflowID` dari `GL_M_COA.IDX_M_CashflowOut`), Cr `COADetail` ABS (amount<0, cashflow In), Cr COA FA = SUM detail; bila COA alokasi ≠ COA detail: Dr `COAAllocation` / Cr `COADetail` per alokasi.
- Jika dokumen sudah di-Approve (jurnal tipe 4) lalu di-Validate → **dua jurnal** untuk transaksi yang sama.

#### 2.2.9 Read model & PDF

- `*_Journal_List`: status F/V → jurnal Posted yang `ReferenceNo = PaymentID AND IDX_ReferenceNo = id` (`VoucherNo` ditampilkan `ReferenceNo + '/' + VoucherNo`). Status lain → **draft preview** dari temp table `#DraftJournal`: 1 baris kredit `COAHeader` = SUM detail + per detail (Dr bila >0, Cr ABS bila <0), label `'FP' / 'Draft Financial Payment Journal'`. Catatan: untuk status A (normal) yang tampil tetap preview, bukan jurnal GL sebenarnya.
- `*_PrintJournal`: (1) jurnal Posted milik dokumen referensi (`ReferenceNo IN DocumentNo detail`), (2) "PaymentVoucher" = detail + baris COA FA.
- `*_GetAllocation_List(@IDX_M_Branch, @IDX_M_Partner)`: invoice `InvoiceStatus IN ('A','F')` dengan `Σ(Qty*(Untaxed-Discount)) + Σ(Qty*Tax) – Σ pembayaran FP non-V > 1` (toleransi 1 rupiah). Lingkup modul Invoice.

#### 2.2.10 Pembuatan FP/FR dari modul Money Changer (interaksi)

`USP_MC_PurchaseOrder_Payment(@IDX_T_PurchaseOrder, @IDX_M_FinancialAccount, @PaymentAmount, @RemarkHeader, @PaymentDate, @UserID)` / `USP_MC_SalesOrder_Payment` (analog untuk FR):
- Nota harus ada dan `POStatus/SOStatus='A'` (`'Nota pembelian … belum di-approve. Pembayaran hanya bisa diinput untuk nota yang sudah Approved.'`).
- Header: `IDX_M_DocumentType` 4 (FP) / 3 (FR), `IDX_M_Currency=1`, `IDX_M_PaymentType=0`, status A, `ApprovalDate=@PaymentDate`, remark default `'Pembayaran pembelian valas'`.
- Nomor: `RTRIM(GN_M_DocumentType.DocumentTypeID) + CONVERT(VARCHAR, IDX_M_Branch) + '-' + <IDX header>` (contoh `FP1-61398`). Tanpa bulan → tidak terkena kunci bulan.
- 1 detail: `COADetail` = **102** (FP, "rekening antara") / **5** (FR, "piutang usaha"), `IDX_M_DocumentType` = doc type nota, `IDX_DocumentNo` = ID nota, remark `'Pembayaran <PONumber> / <ReferenceNo>'`.
- Bila status A → `EXEC USP_CM_FinancialPayment_CreateJournal` / `USP_CM_FinancialReceive_CreateJournal`.

### 2.3 Internal Transfer (IT)

| SP | Parameter | Route |
|---|---|---|
| `USP_CM_InternalTransfer_List` | paging + filter | `POST /fm-internal-transfer-list` |
| `USP_CM_InternalTransfer_Info` | `@IDX_T_InternalTransferHeader` | `create`, `update/{id}`, modal |
| `USP_CM_InternalTransferHeader_Create/_Update` | `@IDX_M_Company, @IDX_M_Branch, @IDX_M_DocumentType, @IDX_M_FromFinancialAccount, @IDX_M_ToFinancialAccount, @FromCOA, @ToCOA, @TransferID, @VoucherNoManual, @TransferDate DATE, @RemarkHeader, @TransferStatus, @TransferAmount, @UserID, @RecordStatus` | `POST /fm-internal-transfer/save` |
| `USP_CM_InternalTransfer_Approve` | `@IDX, @ApprovalDate DATE, @ApprovalRemark, @UserID` | `save-approve` |
| `USP_CM_InternalTransfer_ReverseValidate` | `@IDX, @ApprovalRemark, @ApprovalBy` | `save-reverse` |
| `USP_CM_InternalTransfer_Void` | `@IDX, @VoidDate, @VoidReason, @UserID` | `save-void` |
| `USP_CM_InternalTransfer_Journal_List` | `@IDX` | tab jurnal |
| `USP_CM_InternalTransferDetail_*`, `_Delete`, `_ReverseApproval`, `_Validate` | — | **Tidak dipakai** (model lama header+detail; `CM_T_InternalTransferDetail` 0 baris). |

Controller `save` me-resolve `FromCOA`/`ToCOA` dari `CM_M_FinancialAccount.IDX_M_COA` (`get_financial_account_coa`) dan mewajibkan From/To FA.

State: `D` (Draft) → `A` (Approved) → `D` (Reverse) atau `V` (Void). Tidak ada status lain di `Info`.

Validasi Create: `'Perusahaan belum diisi!'`, `'Profit center belum diisi!'`, `'Financial account asal belum diisi!'`, `'Financial account tujuan belum diisi!'`, `'Financial account asal dan tujuan tidak boleh sama!'`, `'Jumlah transfer harus lebih dari 0!'`.
Update: `'Hanya transaksi berstatus Draft yang dapat diubah!'` + dua validasi terakhir. Approve: `'Transaksi tidak ditemukan atau sudah di-approve!'` (harus D). Reverse: `'Hanya transaksi berstatus Approved yang dapat di-reverse!'`. Void: `'Hanya transaksi berstatus Approved yang dapat di-void!'`.

Penomoran (saat Create, tidak berubah lagi walau tanggal diedit):
```
TransferID = 'IT/' + IDX_M_Company + '/' + FORMAT(TransferDate,'yyyyMM') + '/' + RIGHT('000000' + IDX_T_InternalTransferHeader, 6)
```

Jurnal saat Approve (Posted langsung, tidak ada cek periode):

| Kolom header | Nilai |
|---|---|
| `IDX_M_JournalType` | **9** |
| `IDX_ReferenceNo` / `ReferenceNo` / `VoucherNo` | id / `TransferID` / `TransferID` |
| `JournalDate` = `PostingDate` | `@ApprovalDate` |
| `DebetAmount` = `CreditAmount` | `TransferAmount` |
| `PostingStatus` / `JournalSource` | `'P'` / `'S'` |

| Seq | Debit | Kredit | Remark |
|---|---|---|---|
| 1 | `ToCOA` = TransferAmount | | `'Internal Transfer ' + TransferID` |
| 2 | | `FromCOA` = TransferAmount | idem |

(Project/Department 99, currency 1, rate 1.) Header IT: `TransferStatus='A'`, `ApprovalDate/Remark/By`. Log `CM_T_InternalTransferLog` (`'Approve'`, `'Reverse'`, `'Void'`).

Reverse: hapus jurnal tipe 9 (`IDX_ReferenceNo`+`ReferenceNo`), status D, `ApprovalDate/ApprovalBy=NULL`. Void: hapus jurnal yang sama (**tanpa jurnal pembalik**), status V, `VoidDate/Reason/By`. Keduanya tanpa cek periode → transaksi di periode yang sudah dilaporkan bisa hilang dari GL.

Catatan versi: `SQLStoredProcedure/dbo.USP_CM_InternalTransfer*.sql` di repo adalah versi **lama** (penomoran saat approve dari DocumentTypeID/Branch, tanpa jurnal); `Info`, `ReverseValidate`, `Void` tidak ada di repo. Sumber kebenaran = DB.

### 2.4 Petty Cash (PC)

| SP | Route |
|---|---|
| `USP_CM_PettyCash_List`, `USP_CM_PettyCash_Info` | `/fm-petty-cash-list`, form |
| `USP_CM_PettyCashHeader_Create/_Update` (`@IDX_M_Company, @IDX_M_Branch, @IDX_M_FinancialAccount, @OpeningDate, @TransactionType CHAR(3), @TransactionDesc, @CashierID, @PettyCashStatus, @UserID VARCHAR(10), @RecordStatus`) | `POST /fm-petty-cash/save` (`CashierID = session user_index`, status `'O'`) |
| `USP_CM_PettyCashDetail_Create/_Update/_Delete/_Info/_List` (`@IDX_M_DocumentType, @IDX_M_COA, @IDX_M_Partner, @IDX_Reference, @ReferenceNo, @TransactionDate, @PartnerName, @DetailDesc VARCHAR(50), @PettyCashAmount`) | `/fm-petty-cash-detail/*` |
| `USP_CM_PettyCash_Close(@IDX, @ClosingDate, @ClosingNotes, @UserID)` | `POST /fm-petty-cash/save-close` |
| `USP_CM_PettyCash_Reopen(@IDX, @ClosingNotes, @UserID)` | `POST /fm-petty-cash/save-reopen` |
| `USP_CM_PettyCash_Journal_List` | tab jurnal |

SP PC tidak memakai pola `@TableLog`; mereka `SELECT 'error'/'success' … ; RETURN`.

State: `O` (Open) → `C` (Closed) via Close → `O` via Reopen.

Penomoran & ID:
```
IDX_T_PettyCashHeader = MAX(IDX)+1   (bukan IDENTITY; detail juga MAX+1)
TransactionID = 'PC-' + RTRIM(ISNULL(BranchID,'XX')) + '-' + FORMAT(OpeningDate,'yyyyMM') + '-' + RIGHT('0000' + (COUNT(*) header branch & bulan itu + 1), 4)
```
Tanpa transaksi/lock → race condition; `COUNT+1` bisa menghasilkan duplikat bila ada header dihapus.

Validasi & pesan:
- Header_Update: `'Petty Cash sudah ditutup (Closed) dan tidak dapat diubah.'` (status C). `CashierID` & `PettyCashStatus` tidak diubah oleh Update.
- Detail Create/Update (harus O): `'Petty Cash sudah ditutup. Tidak dapat menambah pengeluaran.'` / `'… mengubah pengeluaran.'`; Delete (blokir bila C): `'… menghapus pengeluaran.'`. Tidak ada validasi COA/amount > 0 di Create/Update.
- Close: `'Petty Cash tidak dalam status Open.'`, `'Belum ada pengeluaran. Tidak dapat menutup Petty Cash kosong.'`, `'Masih ada baris pengeluaran tanpa Account (COA). Lengkapi terlebih dahulu.'`, `'Financial Account (Kas Kecil) belum diisi pada header.'`, `'Financial Account Kas Kecil tidak memiliki mapping COA.'`.
- Reopen: `'Petty Cash tidak dalam status Closed.'`, `'Jurnal Petty Cash sudah diposting ke GL. Tidak dapat dibuka kembali.'`.

Jurnal Close (dalam transaksi):

| Header | Nilai |
|---|---|
| `IDX_M_JournalType` | **10** |
| `IDX_ReferenceNo` / `ReferenceNo` / `VoucherNo` | id / `TransactionID` / `TransactionID` |
| `JournalDate` | `@ClosingDate` |
| `RemarkHeader` | `'Closing Petty Cash ' + TransactionID + ' - ' + TransactionDesc` |
| `PostingStatus` | **`'U'` (Unposted)** |
| Debet/CreditAmount | `Total = SUM(PettyCashAmount)` detail aktif |

| Seq | Debit | Kredit | Remark |
|---|---|---|---|
| 1..n (ROW_NUMBER per COA) | `IDX_M_COA` detail = SUM per COA | | `'Pengeluaran Petty Cash ' + TransactionID` |
| n+1 | | COA dari `CM_M_FinancialAccount` header = Total | `'Reimburse Petty Cash ' + TransactionID` |

Currency = `GN_M_Currency` `CurrencyID='IDR'` (fallback MIN ID), rate 1, `COADescription = COAID + ' - ' + COADesc`. Header PC: `PettyCashStatus='C'`, `ClosingDate/By/Notes`.
Reopen: hapus jurnal tipe 10 milik id yang belum Posted, status `O`, `ClosingDate/By=NULL`, `ClosingNotes=@ClosingNotes`.

Perbedaan repo vs DB: `app/StoredProcedure/USP_CM_PettyCash*.sql` identik dengan DB kecuali `USP_CM_PettyCash_Info` dan `USP_CM_PettyCash_List` (repo `U.UserName`, DB `U.Name` untuk `CashierName`). `ALTER_CM_PettyCash_AddJournalColumns.sql` menambah `CM_T_PettyCashHeader.IDX_M_FinancialAccount` dan `CM_T_PettyCashDetail.IDX_M_COA` (sudah ada di DB).

### 2.5 Rekening Koran & Rekonsiliasi Bank (Bank Statement)

#### 2.5.1 SP & route

| SP | Parameter | Route / pemanggil |
|---|---|---|
| `USP_CM_BankStatement_List` | `@Page,@Row,@SortBy,@SortDir,@ReturnType,@StatementNo,@FinancialAccount,@AccountNo,@Period,@UserID` | `POST /fm-bank-statement-list` (`LineCount`, `JournalCount`) |
| `USP_CM_BankStatement_Save` | header + `@DetailXml` + `@UserID` | `POST /fm-bank-statement/save` |
| `USP_CM_BankStatement_Info` | `@IDX_T_BankStatementHeader` | update/reconcile/journal/… (`AdminFeeCount/Amount` = baris IsAdminFee debit yang belum dijurnal) |
| `USP_CM_BankStatementDetail_List` | idem | detail + `IDX_T_JournalHeader/VoucherNo/PostingStatus` (join ke jurnal **aktif** saja) |
| `USP_CM_BankStatementDetail_SetAdminFee` | `@IDX_T_BankStatementDetail, @IsAdminFee, @UserID` | `POST /fm-bank-statement/set-admin-fee` (AJAX) |
| `USP_CM_BankStatement_CreateJournal` | `@IDX…Header, @RowsXml, @UserID` | `save-journal` (mode per baris) |
| `USP_CM_BankStatement_CreateMergedJournal` | `+ @IDX_M_COA, @JournalDate, @Remark` | `save-journal` (`JournalMode=merge`) |
| `USP_CM_BankStatement_CreateAdminFeeJournal` | `@IDX…Header, @IDX_M_COA, @JournalDate, @Remark, @UserID` | `save-admin-fee` |
| `USP_CM_BankStatement_MonthEndRows` | `@IDX…Header` | form detail (counter) & `month-end` |
| `USP_CM_BankStatement_CreateMonthEndJournal` | `@IDX…Header, @COAAdmin, @COAInterest, @COATax, @JournalDate, @ReferenceNo VARCHAR(32), @Remark, @UserID` | `save-month-end` |
| `USP_CM_BankStatement_InsertJournal` | `@IDX…Header, @JournalDate, @ReferenceNo, @Remark, @UserID, @IDX_T_JournalHeader OUTPUT` + temp table `#BankStatementJournalLine` dari pemanggil | helper internal (tidak dipanggil PHP) |
| `USP_CM_BankStatement_LedgerLines` | `@IDX…Header, @Days=3` | `reconcile`, `adjustment` |
| `USP_CM_BankStatement_LedgerBalance` | `@IDX…Header` | `reconcile` |
| `USP_CM_BankStatement_MatchLinks` / `_AdjustmentLinks` | `@IDX…Header` | `reconcile` |
| `USP_CM_BankStatement_Match_Save` | `@IDX…Header, @SourceXml, @UserID` | `POST /fm-bank-statement/match` (AJAX) |
| `USP_CM_BankStatement_Match_Delete` | `@IDX_T_BankStatementMatch, @UserID` | `POST /fm-bank-statement/unmatch` |
| `USP_CM_BankStatement_CreateAdjustmentJournal` | `@IDX…Header, @SourceXml, @LinesXml, @JournalDate, @Remark, @UserID` | `save-adjustment` |
| `USP_CM_BankStatement_Delete` | `@IDX…Header, @UserID` | `POST /fm-bank-statement/delete` |

Hak akses form: `FM-BS-C` (upload/save), `FM-BS-R` (lihat/download/rekonsiliasi), `FM-BS-J` (jurnal, admin fee, match), `FM-BS-D` (hapus).

Konvensi arah: di rekening koran **Debit = uang keluar**, **Credit = uang masuk** (perspektif bank). Di ledger COA bank: debit = uang masuk.

#### 2.5.2 Upload & simpan

1. `preview`: file wajib PDF ≤ 20 MB (`'File rekening koran belum dipilih!'`, `'File rekening koran harus berformat PDF.'`). `MandiriStatementParser`:
   - Dekripsi PDF bila terenkripsi (`PdfDecryptor`), ekstrak teks (smalot/pdfparser).
   - Harus mengandung `Account Statement` dan `Posting Date`, jika tidak `'Format PDF tidak dikenali. Gunakan Account Statement dari Kopra by Mandiri.'`; tanpa baris → `'Tidak ada transaksi yang terbaca dari PDF.'`.
   - Header: account no/name, currency (default IDR), periode `dd Mon yyyy - dd Mon yyyy`, opening/closing balance, total debit/credit.
   - Baris: diawali `dd Mon yyyy,`, baris jam `hh:mm:ss`, baris remark, diakhiri `<ref|-> <debit> <credit> <saldo>`; potongan remark di halaman berikut ditempel ke transaksi sebelumnya. Dicek terhadap saldo berjalan (`saldo sebelumnya - debit + kredit`) & total ringkasan → `warnings`.
   - **Auto admin fee**: debit > 0 dan remark berpola `^(\S+ \d+) \d{5}$` (nomor referensi transaksi lain + kode 5 digit), dan prefix `"<ref> <no> "` muncul di remark baris lain. `Biaya Adm` / `MONTHLY CARD CHARGE` sengaja tidak ditandai (masuk Jurnal Akhir Bulan).
   - File dipindah ke `storage/app/bank-statement/<YmdHis>_<nama-aman>`; hasil parse disimpan di session `bank_statement_upload`.
   - FA otomatis dipilih bila `REPLACE(AccountNo,'-',' ')` = nomor rekening PDF (digit saja).
2. `save`: susun XML `<rows><r s d m f db cr b a/></rows>` (`a=1` hanya bila dicentang user **dan** debit > 0); `BankName='Mandiri'` (hardcoded).
3. `USP_CM_BankStatement_Save`:
   - `'Financial Account tidak ditemukan.'` bila FA tidak aktif.
   - Overlap periode untuk FA yang sama (`PeriodStart <= @PeriodEnd AND PeriodEnd >= @PeriodStart`, RecordStatus A) → `'Rekening koran <FAID> untuk periode ini sudah pernah disimpan (<StatementNo>).'`.
   - `StatementNo = 'RK-' + FinancialAccountID + '-' + yyyymmdd(PeriodStart) + '-' + yyyymmdd(PeriodEnd)`.
   - Company = `COALESCE(NULLIF(FA.IDX_M_Company,0), Branch.IDX_M_Company)`, Branch = `FA.IDX_M_Branch`.
   - Detail dari XML; 0 baris → rollback `'Tidak ada baris transaksi untuk disimpan.'`. Sukses `'Rekening koran berhasil disimpan.'`.
4. `USP_CM_BankStatement_Delete`: ditolak bila ada baris yang terhubung ke jurnal aktif (`'Rekening koran tidak bisa dihapus karena sudah ada baris yang dijurnal.'`); soft delete header+detail (`RecordStatus='D'`). Match/adjustment tidak ikut dinonaktifkan.

#### 2.5.3 Pembuatan jurnal dari rekening koran

Semua jurnal melalui `USP_CM_BankStatement_InsertJournal`:

| Kolom `GL_T_JournalHeader` | Nilai |
|---|---|
| `IDX_M_JournalType` | `GL_M_JournalType` dengan `JournalTypeID = 'JM'` (lookup by code) |
| `IDX_M_Company/Branch` | dari header rekening koran |
| `IDX_M_Partner/PartnerDesc` | partner aktif pertama bernama `'Bank ' + BankName` (mis. "Bank Mandiri"), boleh NULL |
| `IDX_ReferenceNo` | ID header rekening koran |
| `ReferenceNo` | `LEFT(ISNULL(NULLIF(@ReferenceNo,''), StatementNo), 32)` |
| `VoucherNo` | `'DRAFT-' + IDX_T_JournalHeader` |
| `JournalDate` | `CONVERT(DATE, @JournalDate)` |
| `PostingStatus` | **`'U'`** (posting via menu Accounting > Journal) |
| Debet/CreditAmount | `SUM(Debit)` dari `#BankStatementJournalLine` |
| `JournalSource` | `'S'` |

Detail: dari `#BankStatementJournalLine (SeqNo, IDX_M_COA, Debit, Credit, Remark)`; `COADescription = COAID + ' - ' + COADesc`, `RemarkDetail = ISNULL(line.Remark, @Remark)`, currency IDR, rate 1, partner sama dengan header.

Validasi umum (urutan `CASE`, pesan pertama yang cocok dikembalikan):
`'Financial Account rekening koran belum memiliki mapping COA.'` → `'Jurnal otomatis hanya untuk rekening IDR.'` → validasi spesifik.

| Proses | Validasi spesifik | Baris jurnal |
|---|---|---|
| **Per baris** (`CreateJournal`, XML `<r id coa m/>`) | `'Pilih minimal satu baris rekening koran.'`, `'Ada baris yang sudah memiliki jurnal.'`, `'Setiap baris harus memiliki Chart of Account yang aktif dan boleh dijurnal.'` (`AllowJournalEntry='Y'`, aktif), `'Chart of Account lawan tidak boleh sama dengan COA bank.'` | Cursor per baris, **1 jurnal per baris**. Credit>0 (masuk): Dr Bank / Cr COA lawan. Lainnya: Dr COA lawan / Cr Bank. Amount = Debit + Credit. Tanggal = `PostingDate`. Remark = input atau remark rekening koran. Pesan: `'<n> jurnal berhasil dibuat (status Unposted). Posting melalui menu Accounting > Journal.'` |
| **Gabungan** (`CreateMergedJournal`) | `'Pilih minimal dua baris untuk digabung menjadi satu jurnal.'`, sudah berjurnal, `'Baris debit (uang keluar) dan kredit (uang masuk) tidak bisa digabung dalam satu jurnal.'`, COA valid, COA ≠ bank | 1 jurnal 2 baris; Amount = ΣDebit + ΣCredit; arah seperti per baris. |
| **Biaya admin** (`CreateAdminFeeJournal`) | baris = `IsAdminFee=1 AND DebitAmount>0` belum berjurnal; `'Tidak ada baris biaya admin yang belum dijurnal.'`, `'Pilih Chart of Account yang aktif dan boleh dijurnal.'`, `'Chart of Account biaya tidak boleh sama dengan COA bank.'` | Dr COA biaya / Cr Bank = Σ debit. |
| **Akhir bulan** (`CreateMonthEndJournal`) | baris dari `MonthEndRows`; `'Tidak ada baris biaya, bunga, atau pajak akhir bulan yang belum dijurnal.'`, `'Pilih Chart of Account yang aktif dan boleh dijurnal untuk setiap kategori.'`, `'Chart of Account kategori tidak boleh sama dengan COA bank.'` | 1 jurnal, 2 baris per transaksi (seq `2N-1`, `2N`, urut PostingDate, SeqNo): ADMIN & TAX → Dr COA kategori / Cr Bank; INTEREST → Dr Bank / Cr COA bunga. Remark baris = remark rekening koran. |

Klasifikasi `USP_CM_BankStatement_MonthEndRows` (hanya baris aktif tanpa jurnal aktif):
```
ADMIN    : DebitAmount > 0 AND IsAdminFee = 0 AND (Remark LIKE 'MONTHLY CARD CHARGE%' OR Remark LIKE 'Biaya Adm%')
INTEREST : CreditAmount > 0 AND Remark LIKE 'Bunga%'
TAX      : DebitAmount > 0 AND Remark LIKE 'Pajak%'
```
Default COA di form (controller `default_coa`, LIKE pada `COADesc`, urut `COAID`): ADMIN `%Biaya Admin%Bank%`, INTEREST `%Pendapatan Bunga%`, TAX `%Biaya Bunga%`. Default `JournalDate = PeriodEnd`, `ReferenceNo = 'Journal Biaya Bank YYYY-MM'`, `Remark = 'Rekening bank bulan <NamaBulan> <YYYY>'`.

Setelah jurnal dibuat: `CM_T_BankStatementDetail.IDX_T_JournalHeader = <id jurnal>`. **Link bersifat lunak**: seluruh pengecekan "sudah dijurnal" join ke `GL_T_JournalHeader` dengan `RecordStatus='A'`; jika jurnal dihapus/dinonaktifkan di modul Accounting, baris otomatis bisa dijurnal ulang.

`SetAdminFee`: ditolak bila baris sudah berjurnal (`'Baris ini sudah dijurnal.'`) atau menandai baris non-debit (`'Hanya baris debit yang bisa ditandai biaya admin.'`).

#### 2.5.4 Rekonsiliasi dengan ledger

Data ledger (`USP_CM_BankStatement_LedgerLines`): semua `GL_T_JournalDetail` aktif dengan `IDX_M_COA = FA.IDX_M_COA`, `JournalHeader.IDX_M_Company = header.Company`, RecordStatus A, `JournalDate` dalam `[PeriodStart - @Days, PeriodEnd + @Days]` (default 3 hari), **termasuk Unposted**. `InPeriod = 1` bila di `[PeriodStart, PeriodEnd]`. Remark = `RemarkDetail` atau `RemarkHeader`.

Saldo (`USP_CM_BankStatement_LedgerBalance`, filter COA bank + company + `JournalDate <= PeriodEnd`):
```
OpeningBalance = Σ(BDebet - BCredit) jurnal Posted dengan JournalDate < PeriodStart
ClosingBalance = Σ(BDebet - BCredit) jurnal Posted s/d PeriodEnd
UnpostedNet    = Σ(BDebet - BCredit) jurnal non-Posted dengan PeriodStart <= JournalDate <= PeriodEnd
```
View `bank_statement_reconcile`: `bankClosing = Header.OpeningBalance + bank_in - bank_out`; `ledgerClosing = Ledger.OpeningBalance + ledger_in - ledger_out` (ledger_in/out dari baris `in_period`, **termasuk Unposted**). Bila `UnpostedNet ≠ 0` tampil peringatan merah (commit `14fd2ce`, `4d217d4`): saldo akhir terlihat cocok tetapi saldo awal periode berikutnya (Posted saja) akan berselisih.

Algoritma `App\Services\BankStatement\LedgerReconciler::reconcile($bank, $ledger, $adjustments, $matches)` (sudah di PHP, hasil hanya untuk tampilan, tidak disimpan). Normalisasi: bank `in = CreditAmount`, `out = DebitAmount`; ledger `in = BDebetAmount`, `out = BCreditAmount`. Tahapan (baris yang sudah terpakai dikeluarkan dari pool):

| Tahap | Tipe grup | Aturan |
|---|---|---|
| 0a | `adjusted` | Per jurnal penyesuaian (`CM_T_BankStatementAdjustment`): baris bank yang menjadi sumber + baris ledger yang (a) milik jurnal penyesuaian tsb atau (b) menjadi sumber. Selisih ≥ 0,005 → `link_diff`. |
| 0b | `manual` | Per `CM_T_BankStatementMatch` aktif: baris bank & ledger yang dipilih user. Selisih → `link_diff`. |
| 1 | `link` | Baris bank yang punya `journal_id` dikelompokkan per jurnal, dipasangkan dengan baris ledger dari jurnal yang sama. Selisih → `link_diff`. |
| 2 | `exact` / `date` | Untuk `days = 0..3` (MAX_DAYS): pasangan 1-1 dengan in/out sama (toleransi < 0,005) dan selisih tanggal = `days`; iterasi per selisih hari agar tanggal tepat diutamakan. `days=0` → `exact`, lainnya `date`. |
| 3 | `combo` | 1 baris di satu sisi = jumlah 2..3 (MAX_COMBO) baris sisi lain pada **tanggal sama** dan arah sama, kandidat tiap baris lebih kecil, jumlah kandidat 2..25 (MAX_CANDIDATES); DFS pertama yang |Σ − target| < 0,005. Dijalankan bank→ledger lalu ledger→bank. Ditandai perlu dicek. |
| sisa | `bank_only` / `ledger_only` | Ledger di luar periode tidak ditampilkan sebagai `ledger_only`. |

`difference` grup = `(Σbank.in − Σbank.out) − (Σledger.in − Σledger.out)` dibulatkan 2 desimal. Urutan tampilan = tanggal terkecil; `summary` = total in/out per sisi + jumlah per tipe.

Tanda cocok manual (`USP_CM_BankStatement_Match_Save`, XML `<r t="B|L" id/>`):
- Sumber `B` harus baris aktif milik rekening koran ini; sumber `L` harus `GL_T_JournalDetail` aktif dengan COA = COA bank dan company sama; jumlah ditemukan ≠ diminta → `'Ada transaksi yang tidak ditemukan atau bukan milik rekening ini.'`.
- Minimal 1 B dan 1 L: `'Pilih minimal satu transaksi rekening koran dan satu transaksi ledger.'`.
- `Difference = Σ(B: Credit − Debit) − Σ(L: BDebet − BCredit)`; `|Difference| >= 0,005` → `'Total transaksi bank dan ledger belum sama (selisih <n>). Gunakan Jurnal Penyesuaian untuk selisihnya.'`.
- Tidak boleh sudah ditandai cocok (`'Ada transaksi yang sudah ditandai cocok.'`) atau sudah punya jurnal penyesuaian aktif (`'Ada transaksi yang sudah memiliki jurnal penyesuaian.'`).
- Insert `CM_T_BankStatementMatch` + `CM_T_BankStatementMatchDetail`. Pesan `'<n> transaksi ditandai cocok.'`.
- `Match_Delete`: soft delete (`RecordStatus='D'`); `'Pasangan tidak ditemukan atau sudah dibatalkan.'` / `'Tanda cocok dibatalkan.'`.

Jurnal penyesuaian (`USP_CM_BankStatement_CreateAdjustmentJournal`):
- Controller `adjustment` menghitung default: `Difference = Σbank(Credit − Debit) − Σledger(BDebet − BCredit)`; positif = bank perlu didebit. `JournalDate` = tanggal terbesar dari sumber; remark `'Penyesuaian rekonsiliasi ' + remark/voucher unik`.
- XML baris `<l coa d c m/>` (dibulatkan 2 desimal di controller & SP), side `D|C`.
- Validasi sumber seperti Match (B/L valid, belum di-adjust, belum di-match; `'Pilih minimal satu transaksi.'`), baris jurnal: `'Isi minimal satu baris jurnal.'`, `'Setiap baris jurnal harus berisi nilai debit atau kredit (salah satu).'`, COA valid, `'Baris COA bank dibuat otomatis; pilih COA lawan yang lain.'`.
- Baris bank otomatis (SeqNo 1): `BankAmount = ΣCredit − ΣDebit` baris lawan; >0 → Dr Bank, <0 → Cr Bank, =0 → tanpa baris bank. **SP tidak memvalidasi bahwa `BankAmount` = selisih rekonsiliasi** (hanya ditampilkan "sisa" di JS).
- Insert jurnal (Unposted, `DRAFT-<id>`) + `CM_T_BankStatementAdjustment` (1 baris per sumber). Pesan `'Jurnal penyesuaian DRAFT-<id> berhasil dibuat (status Unposted).'`.

### 2.6 Cashflow ID & Mapping Cashflow

- `USP_CM_CashflowID_List/_Info/_Create/_Update` atas `CM_M_CashflowID` (hierarki `IDX_ParentCashflowID`, `CategoryType`, `InFlag/OutFlag`). Validasi: `'CashflowID already exists!'`, `'CashflowID must contain exactly 7 amount of characters!'`. **Tidak dipakai kode**, tabel 0 baris.
- `GL_M_COA.IDX_M_CashflowIn/Out` → `CM_M_CashflowID`; dipakai FP Validate untuk mengisi `GL_T_JournalDetail.IDX_M_CashflowID`.
- `USP_CM_MappingCashflow_List` (tidak dipakai): daftar baris jurnal tipe 6/7, `JournalPeriod >= '202101'`, Posted, COA bukan COA bank (`CM_M_FinancialAccount`), `IDX_M_CashflowID = 0`, dengan total mapping dari `GL_T_JournalCashflow`. Dynamic SQL.

### 2.7 `usp_CM_ClosingPeriod` (tidak dipakai kode)

Parameter `@Bulan VARCHAR(2), @Tahun VARCHAR(4), @UCreate VARCHAR(7), @IgnoreUnpost VARCHAR(1)` (yang terakhir tidak dipakai). Membangun saldo bulanan `GL_T_AccountBalance` (sebenarnya closing GL, bukan CM):
1. Hapus `GL_T_AccountBalance` periode `yyyyMM` bila ada.
2. Ambil jurnal Posted periode (`JH.JournalPeriod = periode`), kecuali COA `302.02.000` (Laba Tahun Berjalan, hardcoded). Akun `TranslationRate='E'` dipindah ke tanggal akhir bulan; tanggal tanpa kurs `M_Rate` (non-IDR) dimundurkan 1 hari berulang (WHILE loop).
3. Agregasi per company/branch/COA, `T*Amount = B*Amount × Rate`.
4. Tambah baris COA LTB (`302.02.000`) = Σ akun tipe `EX`,`IC`, ditambah mutasi langsung ke LTB.
5. Saldo awal = saldo akhir periode sebelumnya; Januari: LTB direset 0, saldo `302.00.000` (Laba Ditahan) = LTB + LD tahun lalu, saldo awal akun P/L di-nol-kan.
6. Grup company USD: translasi saldo awal dengan kurs akhir bulan (`MasterGlobalDB.dbo.M_GroupsCompany` – **DB eksternal**).
7. Insert `GL_T_AccountBalance` (Notes `'Closing yyyyMM'`). Transaksi bernama, label `Errorsp` tidak pernah dituju (tidak ada error handling efektif).

Catatan: kolom `GL_T_JournalHeader.JournalPeriod` tidak diisi oleh SP CM mana pun yang dibaca; kemungkinan diisi trigger/proses lain **(belum pasti)**.

### 2.8 Branch, Company, Partner, SearchByValue (versi CM)

| SP | Fungsi | Dipakai |
|---|---|---|
| `USP_CM_Branch_List/_Info/_Update`, `USP_CM_Company_List/_Info` | CRUD ringan `GN_M_Branch` / `GN_M_Company` | **Tidak** (modul General memakai SP lain) |
| `USP_CM_Partner_List` | list partner (paging) | FP/FR lookup partner, `VendorController`, report, MC PO/SO, PI/SI |
| `USP_CM_Partner_Info` | info partner | `VendorController` |
| `USP_CM_Partner_Save` | create/update `GN_M_Partner` | `VendorController` |
| `USP_CM_Partner_Create/_Update` | versi lama | Tidak dipakai |
| `USP_CM_PartnerAddress_Create/_Update/_Delete/_Info` | `GN_M_PartnerAddress` | `General\PartnerAddressController`, `VendorAddressController`, `MoneyChanger\PartnerAddressController`, `PartnerController` |
| `USP_CM_PartnerAddress_List` | | Tidak dipakai |
| `USP_CM_PartnerSearchByValue_List(@SearchValue)` | `SELECT IDX_M_Partner, PartnerID + ' - ' + PartnerName` (ID/nama LIKE) | `FinancialPaymentDetailController@search_partner` |
| `USP_CM_COAAccountSearchByValue_List(@SearchValue)` | TOP 200 COA aktif `AllowJournalEntry='Y'`, COAID/COADesc LIKE | `PurchaseInvoiceDetailController` |
| `USP_CM_PurchaseOrderSearchByValue_List`, `USP_CM_SalesOrderSearchByValue_List` | pencarian PO/SO untuk invoice | `PurchaseInvoiceController`, `SalesInvoiceController` (scope invoice) |

`USP_CM_Partner_Save`:
- `'Partner name is required!'`, `'Partner ID Already Exists!'` (PartnerID tidak kosong & sudah dipakai partner lain, case-insensitive), `'Partner status is required!'` (`ActiveStatus` kosong/'0').
- `@IDX_M_Partner = 0` → insert dengan `PartnerID = 'BP-' + YY + RIGHT('00000' + (last+1), 5)`; last = `RIGHT(PartnerID,4)` dari PartnerID dengan `SUBSTRING(PartnerID,4,2) = YY` tahun berjalan, urut desc (bug: parse 4 digit vs format 5 digit → salah setelah 9.999 partner/tahun). Selain itu update semua field termasuk `PartnerID = @PartnerID`.
- Tanpa transaksi eksplisit.

`USP_CM_PartnerAddress_Create/_Update`: `'Street information is required!'`, `'Invalid postal code!'`, `'Address type is invalid !'`; bila `IsDefault='Y'` alamat lain partner tsb di-set `IsDefault='N'`. Delete = soft (`RecordStatus='I'`).

SearchByValue memakai dynamic SQL dengan `@SearchValue` disisipkan langsung → **SQL injection**.

---

## 3. Tabel `CM_*` dalam scope

| Tabel | Rows | Tujuan | Kolom kunci & relasi implisit |
|---|---|---|---|
| `CM_M_FinancialAccount` | 5 | Master rekening kas/bank | PK `IDX_M_FinancialAccount`; `IDX_M_Company`→`GN_M_Company`, `IDX_M_Branch`→`GN_M_Branch`, `IDX_M_Bank`→`GN_M_Bank`, `IDX_M_Currency`→`GN_M_Currency`, `IDX_M_COA`→`GL_M_COA`; `FinancialAccountID` (prefix nomor), `FinancialAccountType` B/C/D, `AccountNo` (dicocokkan dengan PDF), `isUsedByPOS` |
| `CM_M_CashflowID` | 0 | Kode arus kas | `IDX_ParentCashflowID` (self), `CashflowID` (7 char), `InFlag/OutFlag`; direferensi `GL_M_COA.IDX_M_CashflowIn/Out`, `GL_T_JournalDetail.IDX_M_CashflowID` |
| `CM_T_FinancialPaymentHeader` | 2.466 | Header pembayaran | `PaymentID` (nomor), `PaymentStatus`, `IDX_M_FinancialAccount`, `COAHeader` (= COA FA saat simpan), `IDX_M_Partner`, `IDX_M_DocumentType`, `PaymentAmount`, field Approval/Validation/Void/Handover, `Destination*`, `PDCNo`, `VoucherNoManual`. Relasi jurnal: `GL_T_JournalHeader.IDX_ReferenceNo = IDX` **dan** `ReferenceNo = PaymentID` |
| `CM_T_FinancialPaymentDetail` | 2.466 | Baris COA lawan FP | `IDX_T_FinancialPaymentHeader`, `IDX_M_Project`→`GN_M_Project`, `IDX_M_Branch`, `IDX_M_DocumentType` + `IDX_DocumentNo` + `DocumentNo` (polimorfik: PI=2, PO valas=11, dll.), `COADetail`, `PaymentAmount` (±), `IDX_T_DepositReceive` (tidak dipakai SP scope ini) |
| `CM_T_FinancialPaymentLog` | 206 | Audit FP | `LogType` (`Approval`, `ReverseApproval`, `Delete`), `LogDate`, `LogRemark` |
| `CM_T_FinancialReceiveHeader` | 1.972 | Header penerimaan | sama dengan FP (`ReceiveID`, `ReceiveStatus`, `ReceiveAmount`) + `TenderedAmount`, `CardNumber`, `CardHolderName` (tidak disentuh SP scope ini) |
| `CM_T_FinancialReceiveDetail` | 1.972 | Baris COA lawan FR | sama FP; **`IDX_M_DocumentType` bertipe VARCHAR** (beda dengan FP BIGINT) |
| `CM_T_FinancialReceiveLog` | 1 | Audit FR | praktis tidak dipakai (Approve FR tidak menulis log) |
| `CM_T_InternalTransferHeader` | 46 | Transfer antar rekening | `TransferID`, `TransferStatus` D/A/V, `IDX_M_From/ToFinancialAccount`, `FromCOA/ToCOA` (snapshot), `TransferAmount`, Approval*/Void* |
| `CM_T_InternalTransferDetail` | 0 | Model lama (detail COA) | tidak dipakai |
| `CM_T_InternalTransferLog` | 52 | Audit IT | `LogType` Approve/Reverse/Void/Delete/ReverseApproval |
| `CM_T_PettyCashHeader` | 1 | Sesi kas kecil | PK **non-IDENTITY** (MAX+1); `TransactionID`, `PettyCashStatus` O/C, `IDX_M_FinancialAccount` (COA kredit), `CashierID`→`SM_M_User.IDX_M_User` (**belum pasti**), Closing* |
| `CM_T_PettyCashDetail` | 4 | Pengeluaran kas kecil | PK non-IDENTITY; `IDX_M_COA` (debit), `PettyCashAmount`, `IDX_M_Partner`/`PartnerName`, `IDX_Reference`/`ReferenceNo`, `RecordStatus` |
| `CM_T_BankStatementHeader` | 3 | Rekening koran per periode | `StatementNo`, `IDX_M_FinancialAccount`, `PeriodStart/End` (unik non-overlap per FA aktif), Opening/Closing/TotalDebit/TotalCredit, `FileName` (arsip di `storage/app/bank-statement`) |
| `CM_T_BankStatementDetail` | 1.024 | Baris mutasi | `SeqNo`, `PostingDate`, `Remark`, `ReferenceNo`, `DebitAmount` (keluar), `CreditAmount` (masuk), `Balance`, `IsAdminFee`, `IDX_T_JournalHeader` (link lunak ke GL) |
| `CM_T_BankStatementMatch` | 9 | Grup cocok manual | `IDX_T_BankStatementHeader`, `RecordStatus` (soft delete) |
| `CM_T_BankStatementMatchDetail` | 27 | Anggota grup cocok | `SourceType` `B` (→ `CM_T_BankStatementDetail`) / `L` (→ `GL_T_JournalDetail`), `SourceID` |
| `CM_T_BankStatementAdjustment` | 42 | Sumber jurnal penyesuaian | `IDX_T_JournalHeader` (jurnal penyesuaian), `SourceType`/`SourceID` (B/L) |

Terkait (luar CM tapi ditulis modul ini): `GL_T_JournalHeader` (10.438), `GL_T_JournalDetail` (32.093), `GL_T_JournalHeaderLog` (224), `GL_M_FiscalPeriod` (**0**), `GL_M_JournalType` (11), `GN_M_Partner` (2.609), `GN_M_PartnerAddress` (2.275), `GL_T_AccountBalance`. Alokasi (`CM_T_PaymentAllocation`, `CM_T_ReceiveAllocation`) 0 baris.

Tidak ada FK fisik yang terlihat untuk relasi di atas; semua relasi implisit.

### ID tipe jurnal hardcoded (perlu diverifikasi terhadap isi `GL_M_JournalType`)

| ID | Dipakai oleh (scope CM) | Juga dipakai oleh |
|---|---|---|
| 3 | FR Approve (`USP_CM_FinancialReceive_CreateJournal`), FR Delete | `USP_CM_SalesRefund_Approve` |
| 4 | FP Approve (`USP_CM_FinancialPayment_CreateJournal`), FP Delete | – |
| 6 | target pembalik FR Void, MappingCashflow | `USP_FA_GenerateJournalDepreciation` |
| 7 | FP Validate (legacy), target pembalik FP Void, MappingCashflow | `USP_FA_AssetDisposal_Save` |
| 8 | jurnal alokasi receive (dihapus saat FR reverse) | `USP_MC_COGS*Journal_Create`, `USP_MC_GenerateJournalCOGSValas` |
| 9 | Internal Transfer; jurnal alokasi payment (dihapus saat FP reverse) | `USP_CM_PaymentAllocation_Approve` |
| 10 | Petty Cash Close/Reopen; IT Validate (legacy) | – |
| 12 / 13 | Void FP / FR (ID mungkin tidak ada – tabel 11 baris) | – |
| `'JM'` (by code) | semua jurnal rekening koran | – |

Tabrakan ID tipe membuat penghapusan berbasis `(IDX_M_JournalType, IDX_ReferenceNo)` tidak aman (lihat §5).

---

## 4. SP tidak terpakai & SP hilang

### 4.1 Ada di DB, tidak dipanggil kode PHP (scope ini)

| SP | Catatan |
|---|---|
| `USP_CM_BankStatement_InsertJournal` | helper internal, dipanggil SP lain (tetap dibutuhkan) |
| `USP_CM_FinancialPayment_CreateJournal`, `USP_CM_FinancialReceive_CreateJournal` | dipanggil `*_Approve` dan `USP_MC_PurchaseOrder_Payment` / `USP_MC_SalesOrder_Payment` (tetap dibutuhkan) |
| `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialReceive_Delete` | tidak ada fitur hapus dokumen |
| `USP_CM_FinancialPayment_Handover` | status `H` tidak dipakai |
| `USP_CM_FinancialPayment_ReverseValidate`, `USP_CM_FinancialReceive_ReverseApproval` | asimetris dengan yang dipakai |
| `USP_CM_FinancialPayment_Validate-BACKUP` | backup |
| `USP_CM_InternalTransfer_Delete`, `_ReverseApproval`, `_Validate`, `USP_CM_InternalTransferDetail_Create/_Delete/_Info/_List/_Update` | model lama |
| `USP_CM_CashflowID_Create/_Info/_List/_Update`, `USP_CM_MappingCashflow_List` | tidak ada menu |
| `USP_CM_Branch_Info/_List/_Update`, `USP_CM_Company_Info/_List` | – |
| `USP_CM_Partner_Create`, `USP_CM_Partner_Update`, `USP_CM_PartnerAddress_List` | digantikan `Partner_Save` |
| `usp_CM_ClosingPeriod` | closing GL (bergantung `MasterGlobalDB`) |

Dipakai via route tetapi tombol UI disembunyikan: `USP_CM_FinancialPayment_Validate`, `USP_CM_FinancialPayment_Void` (routes `/fm-financial-payment/save-validate`, `/save-cancel` tetap bisa di-POST).

### 4.2 Dipanggil kode tetapi tidak ada di DB
Tidak ditemukan untuk scope ini (semua `USP_CM_*` treasury yang dirujuk di `app/`, `resources/`, `routes/` ada di DB).

### 4.3 Sinkronisasi repo vs DB
- `SQLStoredProcedure/` (UTF-16, hasil "Script As"): sama dengan DB untuk FP/FR/FA/Partner/Cashflow (beda format saja), **berbeda besar** untuk `USP_CM_InternalTransferHeader_Create/_Update`, `USP_CM_InternalTransfer_Approve/_List/_Journal_List` (repo = versi lama).
- Tidak ada di repo sama sekali: seluruh `USP_CM_BankStatement*`, `USP_CM_FinancialDetail_DocumentSearch`, `USP_CM_Financial*Detail_LinkDocument`, `USP_CM_InternalTransfer_Info/_ReverseValidate/_Void`; `USP_CM_PettyCash*` hanya ada di `app/StoredProcedure/`.
- → DB adalah satu-satunya sumber kebenaran untuk logika rekening koran & IT.

---

## 5. Catatan recode

### 5.1 Risiko & bug yang harus diputuskan (jangan direplikasi diam-diam)

| # | Area | Temuan | Dampak |
|---|---|---|---|
| 1 | FP/FR CreateJournal | Baris bank = total semua detail, diulang per dokumen berbeda; detail negatif FP dikredit dengan nilai negatif | Jurnal tidak balance bila >1 dokumen / ada nilai negatif |
| 2 | FR Void (aktif di UI) & FP Void | Membalik jurnal tipe 6/7, padahal jurnal approve tipe 3/4; ID tipe 12/13 mungkin tidak ada; bulan di VoucherNo = hari | Status V tetapi GL tidak terbalik; jurnal void kosong |
| 3 | Approve + CreateJournal | `@Result` NULL saat gagal tidak terdeteksi; `store()` membaca baris terakhir (`success`) walau ada error; CATCH meng-COMMIT jika transaksi masih committable | Dokumen Approved tanpa jurnal / data parsial |
| 4 | Penomoran FP/FR | Asumsi `LEN = 19`; FP tidak melihat nomor FR; tanpa lock | Nomor duplikat |
| 5 | FP ReverseApproval | Ambil ID alokasi dari tabel Receive; hapus jurnal tipe 9 (bentrok IT); tanpa cek periode/status; hard delete jurnal Posted | Potensi hapus jurnal IT; audit hilang |
| 6 | IT Reverse/Void, FP/FR reverse | Hard delete jurnal Posted tanpa jurnal pembalik & tanpa cek periode | GL periode lalu berubah |
| 7 | Kunci periode | `GL_M_FiscalPeriod` kosong → tidak pernah memblokir; FP Approve & IT tidak mengecek sama sekali | Tidak ada period lock efektif |
| 8 | Kunci bulan approval | Bandingkan `MONTH` saja (tahun diabaikan) | Bisa lolos lintas tahun |
| 9 | Validasi outstanding FP | Bergantung tabel PI (kosong) → mati; Create vs Update rumus beda; `PrevPayment` bukan SUM | Overpayment tidak tercegah |
| 10 | Detail FP/FR | Tidak cek status header; FR tidak validasi COA | Edit detail dokumen Approved via POST |
| 11 | FA Update | Simpan `IDX_M_Company=0` | Data company FA rusak |
| 12 | `CreateJournal` | `UPDATE COADetail = 5 WHERE 0` (COA hardcoded), `JournalHeader.DCreate` NULL, `IDX_M_Partner` detail NULL, Project/Dept 99, `JournalDate = PaymentDate` (bukan ApprovalDate) | Data jurnal kurang/menyimpang |
| 13 | Petty Cash | ID & nomor via `MAX+1`/`COUNT+1` tanpa lock; Header_Create tanpa transaksi | Duplikat/collision |
| 14 | Keamanan | `exec_sp` concat tanpa escaping; dynamic SQL List/SearchByValue | SQL injection |
| 15 | Multi-currency | Semua jurnal FP/FR/IT/PC/BS memakai rate 1, currency 1/IDR; BS menolak non-IDR | FA valas tidak didukung |
| 16 | COA hardcoded | 5, 102, 9999 (fallback COA bank), `302.02.000`, `302.00.000` | Bergantung master data |

### 5.2 Logika tersembunyi yang wajib ikut dipindah

- Cursor: `USP_CM_BankStatement_CreateJournal` (1 jurnal per baris).
- Temp table lintas SP: `#BankStatementJournalLine` dibuat pemanggil, dibaca `USP_CM_BankStatement_InsertJournal`; `#DraftJournal` (preview jurnal); `#SourceJournal/#BakedSource/#LPAB/#FinAB` (closing).
- `INSERT … EXEC` (`CreateMonthEndJournal` ← `MonthEndRows`).
- XML sebagai parameter array (`DetailXml`, `RowsXml`, `SourceXml`, `LinesXml`).
- Dynamic SQL: semua `*_List`, `*SearchByValue*`, `MappingCashflow_List`.
- SP lintas modul: `USP_MC_*_Payment` → CM CreateJournal; FP/FR menyentuh tabel alokasi & invoice.
- Link lunak "sudah dijurnal" = ada `GL_T_JournalHeader` aktif (RecordStatus A) – jurnal yang dihapus di Accounting membebaskan baris rekening koran.
- Relasi jurnal ↔ dokumen = `(IDX_ReferenceNo, ReferenceNo)` dan/atau `IDX_M_JournalType`; tidak ada FK.
- Kolom `COAHeader` di FP/FR adalah snapshot COA FA saat simpan, namun jurnal mengambil COA FA **saat approve** (bisa berbeda).

### 5.3 Usulan pemetaan ke service Laravel

```
app/Services/CashManagement/
  FinancialAccountService        // CRUD + resolve company dari branch, unik FinancialAccountID
  DocumentNumberService          // FP/FR (<FAID>-<Branch>-<YYMM>-<NNNN>), IT, PC, BS, Partner
                                 // pakai tabel sequence + SELECT ... WITH (UPDLOCK, HOLDLOCK) / lock DB
  PeriodLockService              // satu tempat untuk GL_M_FiscalPeriod (+ kebijakan bila kosong)
  JournalPostingService          // builder GL_T_JournalHeader/Detail: assert balance, set DCreate,
                                 // JournalPeriod, partner, posting status; reverse = jurnal pembalik
  FinancialPaymentService        // createDraft, updateHeader, add/update/remove/linkDetail,
  FinancialReceiveService        //   approve, reverseToDraft, void, duplicate
  CashTransferService            // Internal Transfer
  PettyCashService               // open, add/update/remove expense, close, reopen
  BankStatement\ImportService    // MandiriStatementParser (sudah ada) + save
  BankStatement\JournalService   // perBaris, gabungan, adminFee, akhirBulan, penyesuaian
  BankStatement\MatchService     // match/unmatch
  BankStatement\LedgerReconciler // sudah ada di PHP
  PartnerService                 // save + address default
```
Setiap method publik dibungkus `DB::connection('sqlsrv')->transaction(...)`, melempar exception domain (pesan Indonesia/Inggris sama dengan SP agar UI tidak berubah), dan mengembalikan DTO `{Result, ID, LogDesc}` agar kompatibel dengan `MyController::store()` selama transisi. Enum status: `PaymentStatus {D,A,H,C,F,V}`, `TransferStatus {D,A,V}`, `PettyCashStatus {O,C}`. Simpan ID tipe jurnal di config (`config/cm.php`) atau lookup berdasarkan `JournalTypeID`, bukan angka hardcoded.

### 5.4 Urutan migrasi yang aman

1. **Read-only dulu**: `*_List`, `*_Info`, `*_Journal_List`, `DocumentSearch`, `BankStatement_*Lines/Balance/Links/MonthEndRows` → query builder + parameter binding (sekaligus menutup SQL injection). Bandingkan output dengan SP (snapshot test).
2. Master: Financial Account (perbaiki company), Partner/PartnerAddress.
3. Modul baru & terisolasi: Rekening Koran (upload, jurnal, match, adjustment) – sudah mayoritas PHP, SP-nya relatif bersih; lalu Petty Cash.
4. `JournalPostingService` + `DocumentNumberService` (dengan test balance & uniqueness), lalu Internal Transfer.
5. FP/FR: header/detail → Approve + jurnal → Reverse → Void (perbaiki bug §5.1 #1–#3 dengan keputusan bisnis: void = jurnal pembalik tipe yang benar).
6. Terakhir ubah `USP_MC_PurchaseOrder_Payment` / `USP_MC_SalesOrder_Payment` agar memanggil service PHP (atau port sekaligus dengan modul MC), karena keduanya sumber volume transaksi terbesar dan memanggil CreateJournal.
7. Pensiunkan SP tidak terpakai (§4.1) setelah konfirmasi tidak dipanggil job/report eksternal; selaraskan `SQLStoredProcedure/` dengan DB atau hapus.

Selama transisi: jangan jalankan versi SP dan PHP berdampingan untuk aksi yang sama (penomoran akan bentrok). Ingat `AVKDB` lokal = produksi.

### 5.5 Test case penting

**FP/FR**
- Create header: partner 0 (FP) ditolak; FA beda cabang ditolak; nomor `DRAFT-<id>`.
- Approve: header ≠ Σ detail ditolak; tanpa detail ditolak; nomor pertama bulan = `…-YYMM-0001`; nomor kedua `0002`; reset bulan berikut; FR melihat nomor FP pada FA yang sama (dan, setelah perbaikan, FP melihat FR); FA ID dengan panjang selain 5 / BranchID selain 3.
- Jurnal approve: 1 detail positif → Dr COADetail / Cr COA FA, balance; 2 detail beda dokumen → harus balance (regresi bug); detail negatif; COADetail 0 → 5 (atau ditolak, keputusan bisnis); JournalDate = PaymentDate.
- Kunci bulan: dokumen `…-2611-0003` di-reverse lalu approve Desember → ditolak; dokumen `FP1-61398` → boleh.
- Reverse to draft: jurnal hilang, nomor tetap, ApprovalDate tetap; re-approve tidak membuat nomor baru.
- Void FR status A: GL harus kembali nol (gagal di implementasi saat ini).
- Duplicate: tanggal hari ini, dokumen referensi dikosongkan.
- MC payment: PO belum approve ditolak; PO approve → FP status A nomor `FP<branch>-<id>`, jurnal Dr 102 / Cr COA FA.

**Internal Transfer**: FA sama ditolak; amount ≤ 0 ditolak; approve → Dr ToCOA / Cr FromCOA; reverse/void hanya dari A; nomor `IT/1/202611/000046`.

**Petty Cash**: close tanpa detail / detail tanpa COA / FA tanpa COA ditolak; jurnal Dr per COA (dijumlah) / Cr COA FA = total, Unposted; reopen ditolak bila jurnal sudah Posted; edit/hapus detail setelah close ditolak.

**Rekening koran**: parser terhadap PDF contoh (saldo berjalan & total cocok, remark terpotong halaman, auto admin fee); overlap periode ditolak; jurnal per baris arah masuk/keluar; gabung campuran debit+kredit ditolak; COA = COA bank ditolak; rekening non-IDR ditolak; month-end kategori ADMIN/INTEREST/TAX & arah bunga; jurnal dihapus di GL → baris bisa dijurnal ulang; delete rekening koran ditolak bila ada jurnal aktif.

**Rekonsiliasi**: exact vs date (tanggal tepat diutamakan ketika nominal sama muncul di dua hari), combo 2–3 baris tanggal sama, link via journal_id, manual match dengan selisih ≠ 0 ditolak (toleransi 0,005), adjustment dengan BankAmount 0 (tanpa baris bank), saldo awal hanya Posted & peringatan UnpostedNet.
