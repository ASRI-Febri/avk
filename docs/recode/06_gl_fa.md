# Modul General Ledger (GL) & Fixed Asset (FA)

> Cakupan: 53 SP `USP_GL_*`, 22 SP `USP_FA_*`, fungsi `ufn_SPLITSTRING`, tabel `GL_*` dan `FA_*`, serta "kontrak jurnal" yang dipakai modul lain (CM/Finance, MC/Money Changer, Petty Cash, Bank Statement).
> Sumber: definisi SP dari DB lokal (AVKDB = produksi), `meta/*` (params, deps, row count), controller `app/Http/Controllers/Accounting/*`, `routes/web/accounting.php`, `app/Services/Accounting/*ReportBuilder.php`, `app/StoredProcedure/*.sql`, `docs/project_plan_fixed_asset.md`, `docs/uat_checklist_fixed_asset.md`.
> Bagian yang tidak bisa dipastikan tanpa query data (mis. isi master Journal Type) ditandai **[belum pasti]**.

---

## 0. Konvensi umum yang berlaku di semua SP modul ini

### 0.1 Pola "TableLog" (kontrak hasil ke PHP)
Hampir semua SP tulis (Create/Update/Save/Posting/Generate) mengembalikan **satu result set** `@TableLog(Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500))`:
- Validasi dilakukan dulu; setiap pelanggaran = `INSERT ('error', <id>, '<pesan>')`. Validasi **tidak berhenti di error pertama** — semua pesan dikumpulkan.
- Bila `COUNT(@TableLog) = 0` → eksekusi DML, lalu `('success', <IDX baru/terkait>, 'Data Sudah Disimpan' | 'Data berhasil disimpan.' | pesan khusus)`.
- PHP (`MyController::store()`/`exec_sp`) membaca baris pertama: `Result` = flag, `ID` = id untuk redirect `next_url/{ID}`, `LogDesc` = pesan.
- Recode: kembalikan objek hasil `{flag, id, messages[]}`; pertahankan agregasi semua error (UI menampilkan list).

### 0.2 Transaksi & error handling
- SP lama (COA, Group, FiscalPeriod, JournalHeader/Detail, Posting/Unposting, Duplicate) memakai `BEGIN TRY / BEGIN TRANSACTION ... COMMIT`. CATCH standar: `INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE()))` → **bug**: `INT + VARCHAR` memicu error konversi di dalam CATCH, jadi pesan asli hilang dan exception naik ke PHP. SP baru (FA, Recurring, JournalType) sudah benar: `CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE()`.
- CATCH **meng-COMMIT** transaksi bila `XACT_STATE() = 1` (masih committable) → potensi *partial commit* bila error terjadi di tengah. Recode: selalu rollback.
- SP tanpa transaksi: `USP_GL_JournalDetail_Delete`, `USP_GL_JournalType_Create/Update`, `USP_GL_RecurringJournal_Create/Update`, `USP_FA_AssetCategory_Create/Update`, `USP_FA_Asset_Create/Update` (single statement, aman tapi tidak atomik dengan validasi → race condition cek-duplikat).

### 0.3 Pemanggilan dari PHP
`MyController::exec_sp()` membangun string `EXEC sp v1,v2,...` **posisional**: nilai numerik ditulis apa adanya, string dibungkus `'...'`; prefix `'XXX'` memaksa nilai di-quote sebagai string (dipakai untuk kode/periode yang terlihat numerik, mis. `'XXX'.$period`). **Tidak ada escaping** (kecuali beberapa controller melakukan `str_replace("'", "''")` manual) → SQL injection. Urutan key `$param` harus sama dengan urutan parameter SP.
UserID dikirim sebagai `'XXX'.user_id` (prefix dibuang oleh exec_sp).

### 0.4 List SP (DataTables)
Pola `_List(@Page, @Row, @SortBy, @SortDir, @ReturnType, <filter...>)`:
- `@ReturnType='R'` → rows dengan `RowNumber` (ROW_NUMBER over sort) dipotong `BETWEEN (Page-1)*Row+1 AND Page*Row`; `'C'` → `SELECT COUNT(*) AS TotalRows`.
- Filter = `LIKE '%' + RTRIM(@x) + '%'` (string kosong = match semua).
- **Dynamic SQL dengan konkatenasi string** (filter, `@SortBy`, `@SortDir`) → SQL injection. Pengecualian: `USP_GL_Journal_List` (sp_executesql + parameter, sort di-whitelist). `USP_FA_Asset_List` / `USP_FA_Depreciation_List` bahkan menempelkan `@IDX_M_Company`/`@IDX_M_Branch` (VARCHAR) tanpa quote.
- Recode: query builder Eloquent/Query Builder + whitelist kolom sort; server-side DataTables.

### 0.5 Kolom audit & status
Semua tabel: `UCreate, DCreate, UModified, DModified, RecordStatus` (`'A'` aktif, `'I'` inaktif/soft delete). Nama user di-join dari `SM_M_User.LoginID`.

---

## 1. Struktur COA, Fiscal Period, Journal Type

### 1.1 Hirarki COA
```
GL_M_COAType (5 baris)          COATypeID: AS | LI | EQ | IC | EX  (Asset, Liability, Equity, Income, Expense)
  └─ GL_M_COACategory (9)       IDX_M_COAType, COACategoryID, COACategoryDesc(2)
  └─ GL_M_COAGroup1 (36)        IDX_M_COAType, COAGroup1ID, COAGroup1Name1/2, (HeaderSort, HeaderName1/2: tidak dipakai SP)
       └─ GL_M_COAGroup2 (0)    IDX_M_COAGroup1, COAGroup2ID, Name1/2
            └─ GL_M_COAGroup3 (0) IDX_M_COAGroup2, COAGroup3ID, Name1/2
GL_M_COA (159)                  akun buku besar
```
`GL_M_COA` kolom penting:
| Kolom | Arti / nilai |
|---|---|
| `IDX_M_COA` | PK identity, dipakai di semua FK implisit |
| `COAID` | kode akun (unik, dicek di SP), `COADesc`, `COADesc2` (bahasa ke-2) |
| `IDX_M_COAType` | tipe → menentukan **saldo normal & laporan** (AS/LI/EQ di neraca, IC/EX di laba rugi). **Saldo normal tidak diambil dari `DefaultBalance`**; semua laporan memakai konvensi *debit-positif* (`D - C`) lalu membalik tanda untuk LI/EQ/IC. |
| `IDX_M_COACategory` | kategori (hanya ditampilkan di Info) |
| `COAFlag` | `'A'` Account (bisa dijurnal), `'H'` Header |
| `ParentID` | parent COA (self-reference, hanya tampilan) |
| `AllowJournalEntry` | `'Y'/'N'`; hanya difilter oleh `USP_GL_COASearch_List` (lookup akun detail jurnal). **Tidak divalidasi** saat simpan detail jurnal. |
| `IsReconcile`, `DefaultBalance` | disimpan, tidak dipakai SP lain |
| `COAGroup1/2/3` | VARCHAR berisi IDX group (bukan kode). Laporan PL/BS join ke `GL_M_COAGroup1` via `COAGroup1` |
| `IDX_M_CashflowIn/Out` | mapping ke `CM_M_CashflowID` — **tidak dipakai** `USP_GL_R_CashflowStatement` |
| `COAStatus` | selalu di-set `'A'` oleh Create/Update |
| `TranslationRate` | selalu `'E'` (end-of-month rate) saat Create; hanya dipakai `usp_CM_ClosingPeriod` (legacy) |

Mapping ID tipe yang **hardcoded** di SP: `IDX_M_COAType IN (3,4)` = akun laba rugi (IC/EX) di `USP_GL_R_TrialBalance` dan `USP_GL_R_ProfitLoss` **[asumsi 3=IC, 4=EX; cek data]**.

Akun laba ditahan / laba berjalan: diambil dari `GN_M_Company.RetainedEarningAccount` dan `GN_M_Company.CurrentEarningAccount` (IDX_M_COA) oleh TB/BS/PL. **Kecuali** `USP_GL_R_GeneralLedger` yang hardcode `IDX_M_COA = 117` (laba berjalan) dan `115` (laba ditahan), dan `usp_CM_ClosingPeriod` yang hardcode `COAID '302.02.000'` (LTB) dan `'302.00.000'` (LD).

### 1.2 Fiscal Period & kunci periode
Tabel `GL_M_FiscalPeriod(IDX_M_Company, IDX_M_Branch, FiscalPeriod 'YYYYMM', StartDate, EndDate, GLStatus, SalesStatus, PurchaseStatus, FinanceStatus)` — status CHAR(1), SP mengirim BIT (`1` = tutup).
- **Tabel kosong (0 baris)** dan SP `USP_GL_FiscalPeriod_Create/List/Update` **tidak dipanggil dari kode** (tidak ada menu). Artinya **kunci periode saat ini tidak pernah aktif**.
- Cara cek di SP (GL & CM): `IF (SELECT GLStatus FROM GL_M_FiscalPeriod WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@Tanggal,112),6)) = 1 → error`. Tidak memfilter company/branch → bila nanti diisi per cabang, subquery mengembalikan >1 baris → runtime error. `USP_CM_SalesInvoice_Approve` memakai varian `@ApprovalDate BETWEEN StartDate AND EndDate AND GLStatus = 1`.
- `SalesStatus/PurchaseStatus/FinanceStatus` tidak dicek oleh SP manapun di scope ini.
- Recode: `PeriodLockService::assertOpen(companyId, branchId, date, module='GL')` dengan definisi tegas (per company atau per cabang), dipakai oleh **semua** penulis jurnal (saat ini jurnal otomatis FA, recurring, MC, dll. tidak mengecek).

### 1.3 Journal Type
`GL_M_JournalType(JournalTypeID VARCHAR(32), JournalTypeDesc, AllowJournalEntry 'Y'/'N', JournalLabel)` — 11 baris.
- `JournalTypeID` dipakai sebagai **prefix nomor voucher** saat posting (`<JournalTypeID>-<BranchID>-YYMM-NNNN`).
- `AllowJournalEntry` **tidak divalidasi** saat membuat jurnal manual (hanya data master).
- Modul lain memakai **IDX numerik hardcoded** (lihat §2.9). Nilai yang dipakai: 1,2,3,4,5,6,7,8,9,10,11,12,13,19 → beberapa (12, 13, 19) kemungkinan **tidak ada** di master (11 baris) **[belum pasti]**. Satu IDX dipakai untuk makna berbeda di SP berbeda (mis. 7 = Financial Payment Validate **dan** FA Disposal; 11 = Sales Invoice Void, Sales Refund Void **dan** FA Depreciation).
- Mapping yang tersirat dari `USP_GL_R_GeneralLedger` (URL drill-down): `1` = jurnal manual (`ac-journal`), `2` = MC Purchase Order, `3` = Financial Receive, `4` = Financial Payment, `5` = MC Sales Order.
- Validasi Create/Update: `JournalTypeID` & `Desc` wajib; `AllowJournalEntry ∈ {Y,N}`; `JournalTypeID` unik di antara record `RecordStatus='A'`. Update error tambahan `'Journal type tidak ditemukan!'`.

**Terverifikasi dari DB lokal (2026-11-21)** — isi `GL_M_JournalType` dan pemakaian di `GL_T_JournalHeader`:

| IDX | JournalTypeID | Deskripsi | AllowJournalEntry | RecordStatus | Jml jurnal |
|---:|---|---|---|---|---:|
| 1 | JM | Journal Memorial | Y | A | 113 |
| 2 | MB | Journal Pembelian Valas | N | A | 2.345 |
| 3 | FR | Journal Penerimaan Uang | N | A | 1.969 |
| 4 | FP | Journal Pengeluaran Uang | N | A | 2.458 |
| 5 | MS | Journal Penjualan Valas | N | A | 1.855 |
| 6 | TM | Journal Termination | N | **I** | 0 |
| 7 | RE | Journal Renewal | N | **I** | 0 |
| 8 | HP | Journal Perhitungan HPP | N | A | 1.648 |
| 9 | CFR | Journal Penerimaan Angsuran | N | **I** | 48 |
| 10 | PC | Journal Petty Cash | N | A | 0 |
| 11 | FA | Journal Fixed Asset | Y | A | 0 |
| 12, 19 | — | **tidak ada di master** | | | 0 |
| 13 | — | **tidak ada di master** | | | **2** (jurnal orphan) |

Artinya: 12, 13 dan 19 memang tidak ada. IDX 6/7/9 berstatus Inactive tetapi masih dipakai SP
(mis. 9 untuk Internal Transfer/alokasi, sehingga 48 jurnal IT tercatat bertipe "Penerimaan Angsuran").
Saat recode, **buat enum journal type baru yang unik per sumber dokumen**, lalu migrasikan data lama.

---

## 2. Jurnal (GL_T_JournalHeader / GL_T_JournalDetail)

### 2.1 Siklus hidup jurnal manual (UI `/ac-journal`)
```
[Create header]  USP_GL_JournalHeader_Create  → PostingStatus='U', VoucherNo='DRAFT-<IDX>'
[Detail CRUD]    USP_GL_JournalDetail_Create/Update/Delete (boleh saat 'U')
[Posting]        USP_GL_Journal_Posting       → cek ada detail, balance, periode; nomor voucher final; 'P'; log 'Posting'
[Unposting]      USP_GL_Journal_Unposting     → cek periode; 'U'; kosongkan PostedBy/PostingDate/Notes; log 'Unposting' (VoucherNo final TETAP)
[Duplicate]      USP_GL_Journal_Duplicate     → salin header+detail ke jurnal baru DRAFT
```
Tidak ada SP **void/reverse/delete header** untuk jurnal manual di modul GL. "Reverse" di modul lain = hapus fisik jurnal sistem atau unposting (lihat §2.9). Jurnal manual yang salah hanya bisa di-unposting lalu diubah, atau dibuat jurnal koreksi manual.

### 2.2 Header — `USP_GL_JournalHeader_Create`
Parameter (urutan): `IDX_M_Company, IDX_M_Branch, IDX_M_JournalType, IDX_M_Partner, ApplicationID, IDX_ReferenceNo, ReferenceNo, VoucherNo, JournalDate, RemarkHeader, PartnerDesc, PostingStatus, DebetAmount, CreditAmount, JournalSource, UserID, RecordStatus`.
- Validasi: `ISNULL(@IDX_M_Partner,0)=0` → `'Please Select Business Partner!'`.
- Bila `IDX_M_Company = 0` → diambil dari `GN_M_Branch.IDX_M_Company`.
- Insert apa adanya, lalu `VoucherNo = 'DRAFT-' + IDX` (mengabaikan VoucherNo input).
- Controller default: `PostingStatus='U'`, `JournalSource='M'` (M = manual, S = system), `IDX_ReferenceNo=0`, `ApplicationID=0`. Validasi Laravel: Company, Branch, JournalType, JournalDate, RemarkHeader, Partner wajib.
- `DebetAmount/CreditAmount` header **tidak dihitung ulang** dari detail (jurnal sistem mengisi 0) → jangan diandalkan; total selalu dari detail.

### 2.3 Header — `USP_GL_JournalHeader_Update`
- Error `'Transaction Already Posted!'` bila status `'P'`.
- `'Please Select Business Partner!'`.
- Bila VoucherNo **bukan** `DRAFT*` (pernah diposting lalu di-unposting): tidak boleh ganti company/branch → `'VoucherNo Already Exist, Cannot Change Company Information. Please Void & Create New Transaction!'` / `'... Cannot Change Branch Information ...'`.
- Update semua kolom **termasuk `VoucherNo` dan `PostingStatus` dari input form** (hidden field) → celah: user bisa mengirim `PostingStatus='P'` tanpa melalui posting. Recode: kolom ini read-only, hanya diubah oleh PostingService.

### 2.4 Detail — `USP_GL_JournalDetail_Create` / `_Update` / `_Delete`
Parameter detail: `IDX_T_JournalHeader, IDX_M_Project, IDX_M_Department, IDX_M_COA, IDX_M_Partner, JournalSeqNo, COADescription, RemarkDetail, OriginalCurrencyID, ODebetAmount, OCreditAmount, ExchangeRate DECIMAL(5,2), BaseCurrencyID, BDebetAmount, BCreditAmount, UserID, RecordStatus` (+ `IDX_T_JournalDetail` di depan untuk Update).
Validasi (Create & Update):
- Project harus satu cabang dengan header: `GN_M_Project.IDX_M_Branch <> GL_T_JournalHeader.IDX_M_Branch` → `'Selected Project Not Under The Same Group Company / Branch!'` (bila project NULL/tidak ketemu, perbandingan NULL → lolos).
- `ODebet = 0 AND OCredit = 0` → `'Debet and Credit are zero!'`.
- `ODebet > 0 AND OCredit > 0` → `'Please choose only one, Debet or Credit !'`.
- (Tidak ada cek nilai negatif; tidak ada cek `AllowJournalEntry`/`COAFlag='A'`.)
Update tambahan bila header sudah `'P'`:
- Bila COA/Partner/Currency/ODebet/OCredit/ExchangeRate berubah → `'Journal already Posted! You can only change Detail Notes!'`.
- Bila `RemarkDetail` tidak berubah → `'Change Detail Notes or Cancel your Detail Update Action!'`.
**Create tidak mengecek status posted** → detail bisa ditambahkan ke jurnal posted (jurnal jadi tidak balance). Recode: tolak.
Nilai yang **ditimpa SP** (input diabaikan):
- `IDX_M_Partner` = partner header.
- `COADescription` = `GL_M_COA.COADesc`.
- `BaseCurrencyID` = `GN_M_Company.IDX_M_Currency` milik company header.
- `BDebetAmount = ODebetAmount × ExchangeRate`, `BCreditAmount = OCreditAmount × ExchangeRate` (controller juga menghitung, tapi SP yang menang).
**Risiko**: parameter `@ExchangeRate DECIMAL(5,2)` (maks 999.99, 2 desimal) padahal kolom `DECIMAL(22,4)` → kurs IDR/USD (±16.000) **overflow/error**; kurs pecahan terpotong. Praktisnya jurnal manual hanya dipakai dengan kurs 1 (default form `1.00`).
Delete: error `'Can not delete journal that already posted !'` bila header `'P'`; hapus **fisik** baris detail; return ID header, `'Data Sudah Dihapus'`.

### 2.5 Posting — `USP_GL_Journal_Posting(@IDX_T_JournalHeader, @PostingDate DATE, @ApprovalRemark, @UserID, @RecordStatus='A')`
Validasi berurutan (semua dikumpulkan):
1. Jumlah detail (semua RecordStatus) = 0 → `'No Data in Detail Transaction'`.
2. `SUM(BDebetAmount)` vs `SUM(BCreditAmount)` atas detail `RecordStatus='A'` (NULL→0), dibandingkan **eksak pada 4 desimal** → `'Journal is not balance!'`.
3. Periode **berdasarkan `@PostingDate`** (bukan JournalDate) tutup (`GLStatus=1`) → `'Journal Period Already Closed!'`.
Tidak dicek: status sudah `'P'` (posting ulang menimpa PostingDate/PostedBy), COA aktif, JournalType.
Proses:
- Penomoran (lihat 2.6); `VoucherNo` hanya diganti bila masih `DRAFT*`.
- `PostingStatus='P', PostedBy=@UserID, PostingNotes=@ApprovalRemark, PostingDate=@PostingDate`.
- Insert `GL_T_JournalHeaderLog(LogType='Posting', LogDate=GETDATE(), LogRemark=@ApprovalRemark)`.
Controller: `/ac-journal/save-posting`, wajib `PostingDate` & `PostingNotes`; default PostingDate di form = JournalDate.
**Celah kunci periode**: jurnal dengan JournalDate di bulan tertutup bisa diposting dengan PostingDate di bulan terbuka; semua laporan memakai `JournalDate`.

### 2.6 Penomoran voucher (persis seperti SP)
```
prefix   = GL_M_JournalType.JournalTypeID  (header.IDX_M_JournalType)
branch   = GN_M_Branch.BranchID            (header.IDX_M_Branch)
YY, MM   = dari @PostingDate
last     = IDX_T_JournalHeader TERBESAR dari jurnal dengan
           MONTH/YEAR(PostingDate) = bulan @PostingDate, branch sama, journal type sama, VoucherNo bukan 'DRAFT%'
           (0 bila tidak ada)
VoucherNo = prefix + '-' + branch + '-' + YY + MM + '-' + RIGHT('00000' + (last + 1), 4)
```
**Bug**: yang diambil adalah *IDX identity* jurnal terakhir, bukan nomor urut → nomor = 4 digit terakhir dari (IDX+1), tidak berurutan, bisa bentrok (mis. IDX 10437 dan 20437), tidak ada unique constraint. Variabel `@_VoucherNo VARCHAR(20)` dan kolom `VARCHAR(32)` → prefix panjang terpotong. Recode: tabel sequence `(company, branch, journal_type, yyyymm) → last_no` dengan row lock (`SELECT ... FOR UPDATE`/`UPDLOCK`), format sama agar kompatibel.
Modul CM memakai pola serupa di SP-nya sendiri (`@_JournalTypeID + '-' + BranchID + '-' ...`, `'SJ-'`, `'PJ-'`).

### 2.7 Unposting — `USP_GL_Journal_Unposting(@IDX_T_JournalHeader, @UnpostingDate, @PostingNotes, @UserID)`
- Periode dari **PostingDate lama** tutup → `'Cannot Reverse Because Journal Period Already Closed!'`.
- Tidak cek status saat ini, tidak cek `JournalSource` → user bisa unposting **jurnal sistem** (FA depresiasi, recurring, MC, CM) lalu mengubah detailnya; dokumen sumber tidak ikut berubah (mis. `FA_T_Depreciation.DeprStatus` tetap `'P'`). Recode: tolak unposting `JournalSource='S'` kecuali via modul sumber.
- `PostingStatus='U'`, `PostedBy/PostingNotes/PostingDate = NULL`; VoucherNo tetap. Log `'Unposting'`. `@UnpostingDate` tidak dipakai.

### 2.8 Duplicate — `USP_GL_Journal_Duplicate(@IDX_T_JournalHeader, @UserID)`
Salin header: `IDX_ReferenceNo=0`, `VoucherNo='DRAFT-<new>'`, `JournalDate=GETDATE()`, `PostingStatus='U'`, Posting* NULL, field lain sama. Salin **semua** detail (termasuk RecordStatus 'I') apa adanya. Pesan `'Data Berhasil Duplikat ke ' + VoucherNo` (variabel `VARCHAR(10)` → nomor terpotong di pesan).

### 2.9 Validasi balance & pembulatan
- Balance hanya dicek di `USP_GL_Journal_Posting`. Jurnal otomatis modul lain di-insert langsung `PostingStatus='P'` **tanpa cek balance** dan **tanpa cek periode**.
- `USP_GL_CheckJournalBalance` (tidak dipanggil kode): daftar jurnal **posted** yang `SUM(BDebet) <> SUM(BCredit)` (LEFT JOIN detail, tanpa filter RecordStatus detail) → output `IDX_T_JournalHeader, VoucherNo, TotalDebet, TotalCredit`. Jadikan health-check terjadwal / test.
- Pembulatan: kolom amount `DECIMAL(22,4)`. Laporan (temp table) `DECIMAL(22,2)` → pembulatan per akun bisa membuat neraca selisih sen. `app/StoredProcedure/FIX_GL_JournalDetail_Rounding.sql` (script satu kali): bulatkan O/B Debet/Credit ke 2 desimal pada baris yang >2 desimal, lalu per jurnal yang jadi tidak balance, *plug* selisih `Residu = SUM(BDebet - BCredit)` ke baris aktif dengan nilai terbesar (bila baris debet: `BDebet -= Residu`, `ODebet -= Residu`; bila kredit: `BCredit += Residu`, `OCredit += Residu`), lalu verifikasi 0 baris >2 desimal & 0 jurnal tidak balance. Penyebab: `USP_MC_COGSValasJournal_Create` (HPP valas, voucher `HP-SMC-*`) menyimpan 4 desimal.
- **Aturan recode**: JournalService harus `round(x, 2)` setiap baris (half-up, sama dengan `ROUND` SQL Server untuk DECIMAL) dan memplug selisih ke baris terbesar sebelum menyimpan; tolak bila |selisih| > toleransi (mis. 0.05).

### 2.10 Log jurnal — `GL_T_JournalHeaderLog`
`(IDX_T_JournalHeader, LogType, LogDate, LogRemark)`; 224 baris. Ditulis oleh Posting/Unposting GL (`'Posting'`, `'Unposting'`) dan SP reverse CM (`USP_CM_*_ReverseValidate`, `USP_CM_FinancialReceive_ReverseApproval`, `USP_CM_SalesRefund_Approve`) dengan `LogType='Unposting'`. Hanya status, bukan snapshot isi jurnal.

### 2.11 Recurring Journal
Tabel `GL_M_RecurringJournal` (1 baris) + `GL_T_RecurringJournalLog` (4 baris). UI `/ac-recurring-journal`, generate `/ac-recurring-journal/save-generate`, log `/ac-recurring-journal-log`.
Template: `IDX_M_Company, IDX_M_Branch, RecurringCode, RecurringName, RecurringDesc, IDX_M_COA_Debet, IDX_M_COA_Credit, RecurringAmount DECIMAL(18,2), TotalAmount (NULL bila 0), AdjustLastPeriod 'Y'/'N', StartPeriod 'YYYYMM', EndPeriod (NULL = tanpa akhir), RecurringStatus ('A' aktif), RecordStatus`.
Validasi `USP_GL_RecurringJournal_Create` / `_Update` (pesan dikutip):
- `'Kode recurring belum diisi!'`, `'Nama recurring belum diisi!'`
- Debet/Kredit kosong → `'Akun debet dan kredit wajib dipilih!'`; sama → `'Akun debet dan kredit tidak boleh sama!'`
- `RecurringAmount <= 0` → `'Nilai per periode harus lebih dari 0!'`
- StartPeriod bukan 6 digit numerik / bulan ∉ 1..12 → `'Periode mulai tidak valid! Gunakan format YYYYMM.'`
- EndPeriod (bila diisi) tidak valid → `'Periode akhir tidak valid! Gunakan format YYYYMM atau kosongkan.'`; `< StartPeriod` → `'Periode akhir tidak boleh lebih kecil dari periode mulai!'`
- Kode duplikat (RecordStatus 'A') → `'Kode recurring <kode> sudah terdaftar!'`
- `AdjustLastPeriod ∉ {Y,N,''}` → `'Opsi penyesuaian periode terakhir tidak valid! Gunakan Y atau N.'`
- Bila `AdjustLastPeriod='Y'`: EndPeriod wajib (`'Penyesuaian periode terakhir membutuhkan Periode Akhir!'`); TotalAmount > 0 (`'Nilai total kontrak harus diisi bila penyesuaian periode terakhir aktif!'`); TotalAmount ≥ RecurringAmount (`'Nilai total kontrak tidak boleh lebih kecil dari nilai per periode!'`).
- Update saja: `'Template recurring tidak ditemukan!'`; bila log untuk `EndPeriod` sudah ada → `'Periode terakhir (<EndPeriod>) sudah pernah digenerate! Perubahan penyesuaian tidak berlaku lagi.'`. (Nilai per periode tetap boleh diubah walau sudah ada generate.)
Generate — `USP_GL_RecurringJournal_Generate(@IDX_M_Company, @Period 'YYYYMM', @UserID)` (cursor, satu transaksi):
1. Period invalid → `'Periode tidak valid! Gunakan format YYYYMM.'`. `JournalDate = EOMONTH(Period)`.
2. Tidak ada template aktif (`RecordStatus='A' AND RecurringStatus='A' AND StartPeriod <= @Period AND (EndPeriod IS NULL OR EndPeriod >= @Period)`) → `'Tidak ada template recurring aktif untuk periode <P>!'`.
3. Per template (urut RecurringCode):
   - Sudah ada log aktif untuk (template, period) → `('success', id, '[SKIP] <code> sudah pernah digenerate untuk periode <P>.')` (idempoten).
   - `Amount = RecurringAmount`. Bila `AdjustLastPeriod='Y' AND EndPeriod = @Period AND TotalAmount > 0` → `Amount = TotalAmount − SUM(GeneratedAmount log aktif template)` (plug periode terakhir).
   - `Amount <= 0` → `[SKIP] ... (total kontrak sudah habis teramortisasi)`.
   - Insert header: company, branch template, `IDX_M_JournalType = 1` (hardcoded), Partner NULL, `ApplicationID=0`, `IDX_ReferenceNo = IDX_M_RecurringJournal`, `ReferenceNo = VoucherNo = 'RJ-<code>-<YYYYMM>'`, `RemarkHeader = '<Name> periode <P>'`, **`PostingStatus='P'`**, `PostingDate = JournalDate`, `PostedBy=@UserID`, `DebetAmount=CreditAmount=0`, `JournalSource='S'`.
   - Detail 1: COA Debet, Project=99, Department=99, Partner NULL, SeqNo 0, `COADescription=COADesc`, Remark = RemarkHeader, OriginalCurrency=1, ODebet=Amount, Rate=1, BaseCurrency=1, BDebet=Amount. Detail 2: COA Kredit, sisi kredit.
   - Insert log `(IDX_M_RecurringJournal, RecurringPeriod, IDX_T_JournalHeader, GeneratedAmount)`; pesan `'[OK] <code> - jurnal RJ-... sebesar <amount>(info penyesuaian).'`.
4. Ringkasan `'Selesai. N jurnal digenerate, M template dilewati (sudah pernah digenerate).'`.
Catatan: tidak cek periode tutup; tidak ada SP batal-generate (bila jurnal dihapus/unposted, log tetap → periode tidak bisa digenerate ulang); currency ID 1 dan project/department 99 hardcoded.

### 2.12 Kontrak jurnal untuk modul lain (produsen GL_T_Journal*)
Semua produsen menulis **langsung** ke `GL_T_JournalHeader` + `GL_T_JournalDetail` (tidak memanggil SP GL). Kolom kontrak yang dipakai:

| Kolom header | Konvensi |
|---|---|
| `IDX_M_Company` | dari dokumen sumber; **MC hardcode `1`** |
| `IDX_M_Branch` | cabang dokumen (FA depresiasi: dipilih user) |
| `IDX_M_JournalType` | konstanta numerik per SP (tabel di bawah) |
| `IDX_ReferenceNo` | **IDX dokumen sumber** (kunci untuk cari/hapus jurnal) |
| `ReferenceNo` | nomor dokumen sumber (PaymentID, ReceiveID, SONumber, InvoiceNo, `FA-DEPR-YYYYMM`, `FA-DISP-NNNNNN`, `RJ-...`) |
| `VoucherNo` | = ReferenceNo, atau nomor voucher format `<TypeID>-<Branch>-YYMM-NNNN`, `'SJ-…'`, `'PJ-…'`, `'HP-'+SONumber` (HPP), atau `DRAFT-<IDX>` untuk jurnal yang masih U |
| `ApplicationID` | 0 atau 1 (tidak bermakna konsisten) |
| `PostingStatus` | **`'P'` langsung** untuk hampir semua; `'U'` untuk Bank Statement dan Petty Cash Close |
| `PostingDate/PostedBy` | = tanggal dokumen / user |
| `JournalSource` | `'S'` (system) |
| `DebetAmount/CreditAmount` | umumnya 0 (kecuali InternalTransfer, BankStatement, PettyCash = total) |
| Detail `IDX_M_Project/Department` | sering hardcode `99/99` (FinancialPayment/Receive CreateJournal, InternalTransfer_Approve, FA, Recurring) |
| Detail currency | `OriginalCurrencyID`, `ExchangeRate`, `BaseCurrencyID` (FA/Recurring hardcode 1/1/1) |

Tabel produsen (dari grep `INSERT INTO GL_T_JournalHeader`):

| SP produsen | IDX_M_JournalType | Status | ReferenceNo / VoucherNo | IDX_ReferenceNo |
|---|---|---|---|---|
| `USP_CM_FinancialReceive_CreateJournal` | 3 | P | ReceiveID / ReceiveID | IDX_T_FinancialReceiveHeader |
| `USP_CM_FinancialPayment_CreateJournal` | 4 | P | PaymentID / PaymentID | IDX_T_FinancialPaymentHeader |
| `USP_CM_FinancialPayment_Validate` | 7 | P | PaymentID / `<TypeID>-<Branch>-...` (+VoucherNoManual) | IDX_T_FinancialPaymentHeader |
| `USP_CM_FinancialPayment_Void` | 12 | P | PaymentID / VoidID, remark `'VOID TRANSACTION - '` | idem |
| `USP_CM_FinancialReceive_Void` | 13 | P | ReceiveID / VoidID | IDX_T_FinancialReceiveHeader |
| `USP_CM_PaymentAllocation_Approve` | 9 | P | AllocationID / voucher, JournalDate = GETDATE() | IDX_T_PaymentAllocation |
| `USP_CM_ReceiveAllocation_Approve` | 8 | P | voucher / voucher | IDX_T_ReceiveAllocation |
| `USP_CM_InternalTransfer_Validate` | 10 | P | TransferID / voucher | IDX_T_InternalTransferHeader |
| `USP_CM_InternalTransfer_Approve` | 9 | P | TransferID / TransferID | idem |
| `USP_CM_SalesInvoice_Approve` | 1 | P | InvoiceNo / `SJ-<Branch>-...` | IDX_T_SalesInvoiceHeader |
| `USP_CM_SalesInvoice_Void` | 11 | P | InvoiceNo / voucher (remark VOID) | idem |
| `USP_CM_SalesRefund_Approve` | 3 | P | RefundNo / voucher | IDX_T_SalesRefundHeader |
| `USP_CM_SalesRefund_Void` | 11 | P | RefundNo / voucher | idem |
| `USP_CM_PurchaseInvoice_Approve` | 2 | P | InvoiceNo / `PJ-<Branch>-...` | IDX_T_PurchaseInvoiceHeader |
| `USP_CM_PurchaseInvoice_Void` | 2 | P | InvoiceNo / voucher, JournalDate = GETDATE() | idem |
| `USP_CM_PurchaseRefund_Approve` | 1 | P | InvoiceNo / voucher | IDX_T_PurchaseRefundHeader |
| `USP_CM_PettyCash_Close` | 10 | **U** | TransactionID / TransactionID | IDX_T_PettyCashHeader |
| `USP_CM_BankStatement_InsertJournal` | lookup `JournalTypeID='JM'` | **U** | ReferenceNo/StatementNo / `DRAFT-<IDX>` | IDX_T_BankStatementHeader |
| `USP_MC_SalesJournal_Create` | 5 | P | SONumber / SONumber | IDX_T_SalesOrder |
| `USP_MC_PurchaseJournal_Create` | 2 | P | PONumber / PONumber | IDX_T_PurchaseOrder |
| `USP_MC_COGSJournal_Create`, `USP_MC_COGSValasJournal_Create` | 8 | P | SONumber / `HP-`+SONumber | IDX_T_SalesOrder |
| `USP_FA_GenerateJournalDepreciation` | **11** (DB) / 7 (file repo) | P | `FA-DEPR-YYYYMM` (keduanya) | IDX_T_Depreciation |
| `USP_FA_AssetDisposal_Save` | 7 | P | `FA-DISP-NNNNNN` (keduanya) | IDX_T_AssetDisposal |
| `USP_GL_RecurringJournal_Generate` | 1 | P | `RJ-<code>-<YYYYMM>` | IDX_M_RecurringJournal |

Pembatalan jurnal oleh modul lain (tidak lewat GL): **hapus fisik** header+detail (`USP_MC_SalesOrder_Reverse`, `USP_MC_PurchaseOrder_Reverse`, `USP_CM_InternalTransfer_Void`, `USP_CM_FinancialPayment_Delete`, `USP_CM_FinancialReceive_Delete`, `USP_CM_PettyCash_Reopen` (hanya yang belum P)); `USP_CM_FinancialReceive_ReverseApproval/ReverseValidate` menghapus header (dan detail jurnal alokasi) lalu menulis log `'Unposting'`. Pencarian jurnal sumber umumnya `WHERE IDX_M_JournalType = <n> AND IDX_ReferenceNo = <IDX dok>` → **kombinasi (JournalType, IDX_ReferenceNo) adalah foreign key implisit** yang wajib dipertahankan.
Konsumen yang memfilter tipe: `USP_CM_*_Journal_List`, `*_PrintJournal`, `USP_CM_R_Cashflow` (`IN (6,7)`), `USP_CM_R_CashflowBank` (`= 19`), `USP_MC_GenerateJournalCOGS*` (`= 5`), `COGSCalculationController` (raw SQL `= 8`), `USP_GL_R_GeneralLedger` (`<> 5`, URL drill-down).

**Kontrak yang disarankan untuk recode** (`JournalService::post(JournalDTO)` satu pintu):
```
JournalDTO { companyId, branchId, journalTypeCode (bukan IDX), journalDate, source='S'|'M',
             sourceType (mis. 'FA_DEPR'), sourceId, referenceNo, remark, partnerId?,
             lines[]: { coaId, debit, credit, currencyId, rate, projectId?, departmentId?, partnerId?, remark } }
```
Aturan: tepat satu sisi > 0 per baris; round 2 desimal + plug; Σdebit = Σkredit (base); COA aktif & `AllowJournalEntry='Y'`; periode terbuka berdasarkan **journalDate**; nomor voucher dari sequence; `(sourceType, sourceId)` unik untuk jurnal aktif (idempoten); log ke HeaderLog; reverse = **jurnal balik** (bukan hapus fisik) bila periode sudah tutup.

### 2.13 SP baca jurnal
- `USP_GL_Journal_List(Page, Row, SortBy, SortDir, ReturnType, IDX_M_Company, IDX_M_Branch, ReferenceNo, VoucherNo, RemarkHeader, PostingStatus, PartnerDesc, UserID, JournalDateFrom='', JournalDateTo='', IDX_M_JournalType=0)`: **filter otorisasi cabang** — hanya jurnal di cabang yang ada di `SM_M_UserBranch` (RecordStatus 'A') untuk `SM_M_User.LoginID = @UserID`; company/branch/type filter bila > 0; tanggal dari/ke (ditukar bila terbalik, `JournalDate < To+1`); posting status eksak; LIKE untuk teks; OFFSET/FETCH; sort whitelist (default `IDX_T_JournalHeader DESC`).
- `USP_GL_JournalHeader_Info`, `USP_GL_JournalDetail_Info`, `USP_GL_JournalDetail_List(@IDX_T_JournalHeader)` (detail `RecordStatus='A'`, urut IDX), `USP_GL_JournalItem_List` (list per baris detail dengan filter COA/voucher/remark/amount sebagai teks).

---

## 3. Laporan Keuangan (`USP_GL_R_*`)

Aturan umum semua laporan: hanya `JH.PostingStatus='P'`, `JH.RecordStatus='A'`, `JD.RecordStatus='A'`; nilai **base currency** (`BDebetAmount/BCreditAmount`); tanggal = `CONVERT(DATE, JH.JournalDate)`; konvensi saldo *debit-positif*. Kolom O-currency tidak dipakai laporan (tidak ada laporan multi-currency/translasi di scope GL; translasi `T*` hanya di `usp_CM_ClosingPeriod`).

### 3.1 Trial Balance — `USP_GL_R_TrialBalance(@IDX_M_Company, @IDX_M_Branch (0=semua), @StartDate, @EndDate)`
Juga dipakai sebagai sumber oleh BS, BS_V2, Equity (`INSERT INTO #TB EXEC ...` — urutan kolom output harus dipertahankan).
1. Baris = semua COA `RecordStatus='A'` + `COATypeID` sebagai `AccountType`; BranchID/Desc = `'ALL'` bila branch 0.
2. **Saldo awal (BB)**: bila ada `GL_T_AccountBalance` untuk company & periode `StartDate−1 bulan` → `SUM(BEndingBalance)` per COA (filter branch bila >0). Jika tidak ada (kondisi sekarang: tabel kosong) → `SUM(D − C)` semua jurnal `JournalDate < StartDate` (company, dan branch bila >0).
3. Laba ditahan & laba berjalan:
   - `TotalRetainedEarning = Σ(D − C)` akun tipe IDX 3/4 dengan `YEAR(JournalDate) < YEAR(StartDate)`.
   - `Total_BB_CurrentEarning = Σ(D − C)` akun tipe 3/4 dengan `JournalDate < StartDate` dan tahun sama.
   - BB akun IC/EX di-set 0; BB `RetainedEarningAccount += TotalRetainedEarning`; BB `CurrentEarningAccount += Total_BB_CurrentEarning` (akun dari `GN_M_Company`).
4. Mutasi: `BDebet = ΣD`, `BCredit = ΣC`, `BMovement = D − C` untuk `JournalDate BETWEEN StartDate AND EndDate`.
5. `BEBalance = BB + Movement`. Output semua COA urut COAID (termasuk nol).
Kolom output: `IDX_M_Company, IDX_M_Branch, IDX_M_COA, CompanyID, CompanyDesc, BranchID, BranchDesc, COA, COADesc, AccountType, BBBalanceAmount, BDebetAmount, BCreditAmount, BMovementAmount, BEBalanceAmount` (DECIMAL(22,2) → pembulatan per akun).
Controller `RptTBController` (`/ac-rpt-tb`), drill-down `/ac-rpt-tb/get-detail` → `USP_GL_R_GeneralLedger`.

### 3.2 General Ledger — `USP_GL_R_GeneralLedger(@IDX_M_Company, @IDX_M_Branch, @StartDate, @EndDate, @COA VARCHAR(5000))`
- `@COA` = `'0'`/`''` → semua COA (termasuk inaktif); selain itu daftar IDX dipisah koma yang **ditempel ke dynamic SQL** `WHERE IDX_M_COA IN (<@COA>)` (SQL injection; controller memotong koma terakhir).
- Baris transaksi (`COA_Count=1`): jurnal posted di periode; branch filter bila ≠0 (bila 0, IDX_M_Branch output = 0). `ReferenceNo` = `VoucherNo + ' / ' + ReferenceNo` untuk JournalType 5, selain itu ReferenceNo. `JournalDesc` = RemarkDetail (+ `' - ' + VoucherNoManual`). `URLTransaction` per tipe: 5→`mc-sales-order/update/{IDX_ReferenceNo}`, 2→`mc-purchase-order/update/..`, 3→`fm-financial-receive/update/..`, 4→`fm-financial-payment/update/..`, 1→`ac-journal/update/{IDX_T_JournalHeader}`.
- Baris saldo awal (`COA_Count=0`) per COA: `'Saldo Awal <COAID> - <Desc>'`; nilai dari `GL_T_AccountBalance` periode sebelumnya (company-wide) atau `Σ(D−C)` semua jurnal `< StartDate` **company-wide** → **mengabaikan filter cabang** (beda dengan TB). Tidak ada pemindahan laba rugi ke laba ditahan kecuali **bila StartDate bulan Januari**: BB COA **117** ditambahkan ke COA **115**, lalu BB 117 dan semua IC/EX = 0 (IDX hardcoded). Di bulan selain Januari, saldo awal akun IC/EX = kumulatif sejak awal (tidak di-reset per tahun) → tidak konsisten dengan TB.
- `NotaManual` diisi dari `MC_T_SalesOrder.ReferenceNo` (ReferenceNo jurnal diawali `SMC`, SO aktif) / `MC_T_PurchaseOrder.ReferenceNo` (`PMC`).
- `BBalanceAmount` baris transaksi = `D − C` baris itu (saldo berjalan dihitung di view). NULL → `''` (JournalDate NULL → 1900-01-01).
- Urut: Company, Branch, COA, COA_Count, JournalDate, VoucherNo.

### 3.3 Balance Sheet
**`USP_GL_R_BalanceSheet` (versi di DB, `/ac-rpt-bs`)**: #TB ← TB(company, branch, start, end); `BEBalance *= −1` untuk LI/EQ **hanya bila negatif** (saldo abnormal tetap positif → tanda hilang); akun RetainedEarning dibalik bila positif; output dikelompokkan `AccountType, COAGroup1ID, COAGroup1Name1` dengan `SUM(BB, D, C, BEBalance AS Amount)`, exclude IC/EX. **Tidak memasukkan laba periode berjalan** → neraca tidak balance sebesar L/R periode StartDate..EndDate. File repo `app/StoredProcedure/USP_GL_R_BalanceSheet.sql` sudah berisi FIX (injeksi laba periode ke CurrentEarningAccount, sama seperti V2) tetapi **belum dideploy ke DB**.
**`USP_GL_R_BalanceSheet_V2` (`/ac-rpt-bs-v2`, dipakai `BalanceSheetReportBuilder`)**:
1. #TB ← TB.
2. `PeriodPL = Σ(BCredit − BDebet)` akun IC/EX (mutasi periode).
3. Akun `CurrentEarningAccount`: `BCredit += PeriodPL`, `BEBalance = BB + BDebet − (BCredit + PeriodPL)`.
4. `BEBalance *= −1` untuk semua LI/EQ.
5. Output level COA (`IDX_M_COA, COA, COADesc, AccountType, COAGroup1ID, COAGroup1Name1, BB, D, C, Amount`) untuk AS/LI/EQ yang tidak nol; urut AS, LI, EQ, Group1ID, COA.
PHP builder: prior = BB × sign, current = (D − C) × sign (sign AS=+1, LI/EQ=−1), ending = Amount; cek `Aset − (Liab+Ekuitas)` ≤ toleransi.
Identitas yang harus dijaga di recode: `Σ AS = Σ LI + Σ EQ` setelah laba ditahan (tahun lalu) + laba berjalan (YTD sebelum periode, via BB CurrentEarning) + laba periode ditambahkan.

### 3.4 Profit & Loss — `USP_GL_R_ProfitLoss(@Period 'YYYYMM', @IDX_M_Company, @IDX_M_Branch, @IDX_M_Project ('ALL'/0 = semua))`
- Baris: COA dengan `IDX_M_COAType IN (3,4)` + `COATypeID`, `COAGroup1ID/Name1`.
  - Project ≠ 0: satu set baris untuk project itu.
  - Project = 0: **cursor** atas semua project aktif di branch&company → satu set baris COA **per project**. Lalu update nilai join hanya pada Company/Branch/COA (tanpa project) → **setiap project mendapat total cabang yang sama** (angka terduplikasi bila cabang punya >1 project; laporan kosong bila cabang tanpa project). **[bug — verifikasi dengan data]**
- Mutasi bulan: `ΣD`, `ΣC` untuk `YEAR/MONTH(JournalDate) = Period` (company & branch; **filter project tidak diterapkan di WHERE**, hanya lewat join project di mode project).
- `BB = Σ(D − C)` tahun berjalan sebelum tanggal 1 periode (YTD s/d bulan lalu). Januari: BB IC/EX & CurrentEarning = 0.
- `BEBalance = BB + D − C` (YTD). Variabel `PrevRetainedEarningAmount` dihitung tapi tidak dipakai.
- `SEQ` (urutan tampil) berdasarkan `COAGroupID`: `5000`→2; `4100`,`7100`→4; `5100`,`6100`,`6200`,`8000`→5; lain 1 (hardcoded).
- Output baris `BEBalance <> 0`, urut Company, SEQ, ProjectID, AccountType DESC, COA. Tanda: IC negatif (kredit). 
- PHP: `/ac-rpt-pl` (view lama), `/ac-rpt-pl-standard`, `/ac-rpt-pl-v3` (`ProfitLossReportBuilder`: bucket `PO` = IC & group desc 'Pendapatan Usaha'; `HPP` = EX & 'Harga Pokok Penjualan'; `BO` = EX & Group1ID diawali '6'; `PL` = IC lain; `BL` = EX lain; IC dibalik tanda; kolom prior/current/YTD; laba bersih = (PO+PL) − (HPP+BO+BL)).

### 3.5 Cash Flow — `USP_GL_R_CashflowStatement(@Period, @IDX_M_Company, @IDX_M_Branch, @IDX_M_Project)` (metode tidak langsung, "movement approach")
- Kas & setara kas = COA dengan `LEFT(COAID,4) IN ('1110','1111')`.
- Untuk setiap COA **non-kas** (semua status): `CashFlowAmount = ΣC − ΣD` jurnal posted bulan itu (company, **branch eksak — branch 0 tidak didukung**, project bila ≠0).
- Klasifikasi berdasarkan `LEFT(COAID,4)` (hardcoded):
  - default: Section 1 'ARUS KAS DARI AKTIVITAS OPERASI', SubGroup 12 'Perubahan Modal Kerja & Penyesuaian', SEQ 120;
  - `4100,4200,7110,5110,5113,6110,6111,6112,6113,8110,8111` → SubGroup 11 'Laba/(Rugi) Bersih', SEQ 110;
  - `1410` → Section 2 'ARUS KAS DARI AKTIVITAS INVESTASI' (21, SEQ 210);
  - `2114,2116,3110,3180,3190` → Section 3 'ARUS KAS DARI AKTIVITAS PENDANAAN' (31, SEQ 310).
- Ringkasan: `BeginningCash = Σ(D−C)` akun kas sebelum tanggal 1 periode; `CashMovement = Σ(D−C)` akun kas bulan itu; baris `BEGINCASH` (Section 9/SubGroup 90/SEQ 900) dan `ENDCASH = Begin + Movement` (91/910).
- Output baris `CashFlowAmount <> 0` + 2 baris ringkasan, urut Section, SubGroup, SEQ, COA. Identitas: Σ baris arus kas = Kas Akhir − Kas Awal (benar hanya bila semua jurnal per cabang balance).
- Mapping `GL_M_COA.IDX_M_CashflowIn/Out`, `GL_T_JournalDetail.IDX_M_CashflowID`, `GL_T_JournalCashflow` **tidak dipakai**.

### 3.6 Perubahan Ekuitas — `USP_GL_R_StatementOfChangesInEquity(@Period, @IDX_M_Company, @IDX_M_Branch)`
#TB ← TB(bulan penuh). `NetIncome = Σ(BMovement × −1)` akun IC/EX. Output: baris `EQUITY` per akun EQ yang tidak nol: `BeginBalance = −BB`, `Additions = BCredit`, `Reductions = BDebet`, `EndBalance = −BE`; plus baris `NETINCOME` `'Laba/(Rugi) Bersih Periode Berjalan'` (Additions = End = NetIncome). Urut GroupSEQ, COA.

### 3.7 Saldo periode — `GL_T_AccountBalance`
Tabel snapshot saldo per (JournalPeriod, Company, Branch, COA) dengan B* (base) dan T* (translasi). **0 baris**; hanya ditulis oleh `usp_CM_ClosingPeriod` (tidak dipanggil kode; legacy: memakai `GL_T_JournalHeader.JournalPeriod` yang tidak pernah diisi SP manapun, kurs `M_Rate`, cross-DB `MasterGlobalDB.dbo.M_GroupsCompany`, COAID hardcoded `302.02.000`/`302.00.000`). TB & GL report membaca tabel ini bila ada baris periode sebelumnya → **bila suatu saat closing dijalankan, hasil laporan berubah perilaku**. Recode: putuskan apakah snapshot saldo dipakai (disarankan: tabel saldo bulanan yang dibangun ulang saat posting/unposting atau saat tutup buku, dengan invalidasi).

---

## 4. Fixed Asset

### 4.1 Kategori — `FA_M_AssetCategory` (2 baris)
Kolom: `IDX_M_Company, CategoryCode, CategoryName, IDX_M_COA_Asset, IDX_M_COA_AccumDepr, IDX_M_COA_DeprExpense, IDX_M_COA_GainDisposal (opsional), IDX_M_COA_LossDisposal (opsional), DefaultUsefulLifeMonth, DefaultDeprMethod ('SL'|'DB'), FiscalGroup`.
Validasi `USP_FA_AssetCategory_Create/Update`: `'Kode kategori belum diisi!'`, `'Nama kategori belum diisi!'`, `'Metode penyusutan tidak valid! Gunakan SL (Garis Lurus) atau DB (Saldo Menurun).'`, `'Umur manfaat (bulan) harus lebih dari 0!'`, `'Akun Aset, Akumulasi Penyusutan dan Beban Penyusutan wajib dipilih!'`, `'Kode kategori <kode> sudah terdaftar!'` (unik global antar record aktif, bukan per company), Update: `'Kategori aset tidak ditemukan!'`. Gain/Loss `0 → NULL`.
Default umur/metode hanya prefill form (aset menyimpan nilainya sendiri).
Kelompok fiskal (UU PPh) → umur fiskal bulan: `'1'`=48, `'2'`=96, `'3'`=192, `'4'`=240, `'BP'` (bangunan permanen)=240, `'BN'` (non-permanen)=120, lainnya 0 (tidak disusutkan fiskal).

### 4.2 Registrasi aset — `FA_M_Asset` (0 baris)
`USP_FA_Asset_Create` (UI `/ac-fa-asset`, import Excel `/ac-fa-asset-import` memanggil SP yang sama per baris). Parameter: `IDX_M_Company, IDX_M_Branch, IDX_M_Department (0→NULL), IDX_M_AssetCategory, AssetCode ('' = auto), AssetName, AssetDesc, AcquisitionDate, UsageStartDate, AcquisitionCost, ResidualValue, UsefulLifeMonth, DeprMethod, FiscalGroup, FiscalDeprMethod, IDX_T_PurchaseInvoice (0→NULL), ReferenceNo, AssetStatus, OpeningAccumDepr, UserID, RecordStatus`.
Validasi: `'Kategori aset belum dipilih!'`, `'Nama aset belum diisi!'`, `'Tanggal perolehan belum diisi!'`, `'Tanggal mulai pakai belum diisi!'`, `'Tanggal mulai pakai tidak boleh sebelum tanggal perolehan!'`, `'Harga perolehan harus lebih dari 0!'`, `'Nilai residu tidak valid! Harus >= 0 dan lebih kecil dari harga perolehan.'`, `'Umur manfaat (bulan) harus lebih dari 0!'`, metode ∉ {SL,DB}, `'Akumulasi penyusutan saldo awal melebihi dasar penyusutan (harga perolehan - residu)!'`, `'Kode aset <kode> sudah terdaftar!'`. Sukses: `'Data berhasil disimpan. Kode aset: <kode>'`.
Kode otomatis (inline di Create; sama dengan `USP_FA_Asset_GenerateCode` yang tidak dipanggil): `FA/<BranchID|'XX'>/<YYYYMM AcquisitionDate>/<seq 4 digit>`, `seq = MAX(RIGHT(AssetCode,4) numerik) + 1` dari kode dengan prefix sama (race condition, tanpa lock).
Status aset: `D` Draft (tidak disusutkan, dikecualikan rekonsiliasi), `A` Aktif, `S` Dijual, `W` Hapus Buku, `H` Hibah.
**Registrasi tidak membuat jurnal perolehan** (perolehan diasumsikan sudah dijurnal via Purchase Invoice / jurnal manual / saldo awal migrasi; link `IDX_T_PurchaseInvoice` selalu 0 dari controller).
`USP_FA_Asset_Update`: validasi serupa + `'Aset tidak ditemukan!'`, `'Aset sudah dilepas (dijual/hapus buku/hibah), tidak dapat diubah!'`; bila aset punya detail depresiasi di run `DeprStatus='P'`, perubahan `AcquisitionCost, ResidualValue, UsefulLifeMonth, DeprMethod, OpeningAccumDepr` ditolak: `'Aset sudah memiliki penyusutan yang diposting! Harga perolehan, residu, umur manfaat, metode dan saldo awal tidak dapat diubah.'`. **Celah**: Update tetap mengizinkan ubah `IDX_M_Branch` (tanpa riwayat mutasi), `IDX_M_AssetCategory` (mengubah COA jurnal berikutnya), `UsageStartDate`, dan `AssetStatus` bebas (mis. set `S` tanpa jurnal disposal). Update tidak memvalidasi AcquisitionDate/UsageStartDate NULL.
`USP_FA_Asset_Info`: + `AccumDepr = OpeningAccumDepr + Σ DeprAmount (run P)`, `BookValue = Cost − AccumDepr`.

### 4.3 Depresiasi — `USP_FA_Depreciation_Calculate(@IDX_M_Company, @DeprPeriod 'YYYYMM', @UserID)`
Validasi:
- Periode invalid → `'Periode tidak valid! Gunakan format YYYYMM.'`
- Run aktif untuk (company, periode) sudah ada → `'Penyusutan periode <P> sudah pernah dihitung! Batalkan dulu bila ingin hitung ulang.'`
- Run aktif terakhir: `LastPeriod >= @DeprPeriod` → `'Periode <P> tidak boleh mundur! Periode terakhir: <L>.'`; `DeprStatus <> 'P'` → `'Periode <L> belum digenerate jurnalnya! Generate atau batalkan dulu.'`. (Periode boleh **melompat** — tidak wajib berurutan bulan demi bulan; bulan yang dilewati tidak pernah disusutkan kecuali tertangkap oleh plug akhir umur.)
Data per aset (`FA_M_Asset` company, `RecordStatus='A'`, `AssetStatus='A'`, `UsageStartDate <= EOMONTH(periode)`; **semua cabang**):
```
Cost        = AcquisitionCost
Residual    = ResidualValue
Life        = UsefulLifeMonth
PriorAccum  = OpeningAccumDepr + Σ DeprAmount (semua detail aktif dari run aktif company)
PriorFiscal = Σ FiscalDeprAmount (idem)  -- tanpa saldo awal fiskal
Elapsed     = DATEDIFF(MONTH, UsageStartDate, tgl 1 periode) + 1    -- bulan mulai pakai = bulan ke-1, PENUH (tanpa pro-rata hari)
Base        = Cost − Residual
Remaining   = Base − PriorAccum
```
Komersial (`DeprAmount`):
```
if Remaining <= 0                 → 0
elif Elapsed >= Life              → Remaining                (plug: habiskan sisa di bulan terakhir umur atau sesudahnya)
elif Method = 'SL'                → min( ROUND(Base / Life, 2), Remaining )
elif Method = 'DB'                → min( ROUND((Cost − PriorAccum) × 2 / Life, 2), Remaining )   -- double declining, tarif bulanan 2/Life atas nilai buku (tanpa residu)
else                              → 0
```
Catatan: SL **tidak** memperhitungkan OpeningAccumDepr dalam tarif (tetap Base/Life); selisih migrasi/bulan terlewat tertampung di plug bulan ke-Life. Dokumen rencana menyebut DB = "nilai buku awal tahun × tarif tahunan/12" — implementasi memakai nilai buku **bulanan** (beda hasil).
Fiskal (`FiscalDeprAmount`, dasar = harga perolehan penuh tanpa residu, umur dari FiscalGroup, metode `FiscalDeprMethod` default SL):
```
if FiscalLife = 0 or Cost − PriorFiscal <= 0 → 0
elif Elapsed >= FiscalLife                  → Cost − PriorFiscal
elif FiscalMethod = 'DB'                    → min( ROUND((Cost − PriorFiscal) × 2 / FiscalLife, 2), Cost − PriorFiscal )
else                                        → min( ROUND(Cost / FiscalLife, 2), Cost − PriorFiscal )
```
Simpan hanya aset dengan `DeprAmount > 0 OR FiscalDeprAmount > 0`; bila tidak ada → `'Tidak ada aset aktif yang perlu disusutkan pada periode <P>!'`. Insert `FA_T_Depreciation(IDX_M_Company, DeprPeriod, IDX_T_JournalHeader=NULL, DeprStatus='C')` + `FA_T_DepreciationDetail(IDX_M_Asset, DeprAmount, FiscalDeprAmount, AccumDeprAfter = PriorAccum + DeprAmount, BookValueAfter = Cost − AccumDeprAfter)`. Pesan `'Penyusutan periode <P> berhasil dihitung untuk <n> aset.'`.

### 4.4 Generate jurnal depresiasi — `USP_FA_GenerateJournalDepreciation(@IDX_M_Company, @IDX_M_Branch, @DeprPeriod, @UserID)`
Validasi: run tidak ada → `'Penyusutan periode <P> belum dihitung!'`; sudah P → `'Jurnal penyusutan periode <P> sudah pernah digenerate!'`; branch 0 → `'Cabang pembukuan jurnal belum dipilih!'`; jurnal `ReferenceNo='FA-DEPR-<P>'` & `IDX_ReferenceNo=run` aktif sudah ada → `'Jurnal FA-DEPR-<P> sudah ada di GL!'`; kategori tanpa COA beban/akumulasi (untuk aset dengan DeprAmount>0) → `'Ada <n> kategori aset yang mapping akun beban/akumulasi penyusutannya belum lengkap!'`; total = 0 → `'Total penyusutan komersial periode <P> adalah 0, tidak ada jurnal yang perlu dibuat!'`.
Jurnal (satu per periode per company, langsung **Posted**, tanpa cek periode tutup):
- Header: `IDX_M_JournalType = 11` (DB; file repo = 7 — **drift**), Partner NULL, `ApplicationID 0`, `IDX_ReferenceNo = IDX_T_Depreciation`, `ReferenceNo = VoucherNo = 'FA-DEPR-YYYYMM'`, `JournalDate = PostingDate = EOMONTH`, Remark `'Penyusutan aset tetap periode <P>'`, `JournalSource 'S'`.
- Detail Debet: per (COA beban, kategori) `Σ DeprAmount` — Remark `'Beban penyusutan <Kategori> periode <P>'`.
- Detail Kredit: per (COA akumulasi, kategori) `Σ DeprAmount` — `'Akumulasi penyusutan <Kategori> periode <P>'`. Project/Dept 99, currency 1, rate 1, SeqNo 0.
- Seluruh beban dibukukan di **satu cabang** yang dipilih (bukan per cabang aset) → L/R per cabang terdistorsi.
- Update run `DeprStatus='P'`, `IDX_T_JournalHeader`. Pesan `'Jurnal penyusutan FA-DEPR-<P> berhasil digenerate. Total: <n>'`.
Fiskal tidak dijurnal.

### 4.5 Batal depresiasi — `USP_FA_Depreciation_Cancel(@IDX_M_Company, @DeprPeriod, @UserID)`
Hanya bila status `'C'`: `'Penyusutan periode <P> tidak ditemukan!'`; status P → `'Jurnal penyusutan periode <P> sudah digenerate! Batalkan jurnal GL dulu sebelum membatalkan perhitungan.'` — **tetapi tidak ada proses untuk membatalkan jurnal FA dan mengembalikan run ke C** (unposting GL tidak mengubah run). Soft delete: detail & header `RecordStatus='I'`.

### 4.6 Mutasi — `USP_FA_AssetMutation_Save(@IDX_M_Asset, @MutationDate, @IDX_M_Branch_To, @IDX_M_Department_To, @MutationNotes, @UserID)`
Validasi: `'Aset tidak ditemukan!'`; status S/W/H → `'Aset sudah dilepas (dijual/hapus buku/hibah), tidak dapat dimutasi!'`; `'Tanggal mutasi belum diisi!'`; `'Cabang tujuan belum dipilih!'`; tujuan = posisi sekarang (dept 0 dianggap sama) → `'Cabang / departemen tujuan sama dengan posisi aset saat ini, tidak ada yang dimutasi!'`. Insert `FA_T_AssetMutation(From/To branch & dept)` lalu update `FA_M_Asset.IDX_M_Branch/IDX_M_Department` (dept 0 → NULL). **Tanpa jurnal** (antar-cabang di luar scope). MutationDate tidak divalidasi terhadap periode depresiasi.

### 4.7 Disposal — `USP_FA_AssetDisposal_Save(@IDX_M_Asset, @DisposalDate, @DisposalType 'S'|'W'|'H', @DisposalProceed, @IDX_M_COA_Proceed, @DisposalNotes, @UserID)`
Perhitungan:
```
AccumDepr = OpeningAccumDepr + Σ DeprAmount (run DeprStatus='P', aktif)     -- TIDAK ada depresiasi parsial bulan pelepasan
BookValue = Cost − AccumDepr
GainLoss  = Proceed − BookValue        (W/H: Proceed=0, COA_Proceed=NULL → GainLoss = −BookValue)
```
Validasi: `'Aset tidak ditemukan!'`, `'Aset sudah pernah dilepas!'`, `'Hanya aset berstatus Aktif yang dapat dilepas!'`, `'Tipe pelepasan tidak valid! Gunakan S (Dijual), W (Hapus Buku), atau H (Hibah).'`, `'Tanggal pelepasan belum diisi!'`, `'Tanggal pelepasan tidak boleh sebelum tanggal mulai pakai aset!'`; tipe S: `'Harga jual tidak boleh negatif!'`, `'Akun penerima hasil penjualan (kas/bank) belum dipilih!'`; ada run company status C → `'Masih ada perhitungan penyusutan berstatus Calculated! Generate jurnal atau batalkan dulu sebelum melepas aset.'`; `YYYYMM(DisposalDate) < periode depresiasi posted terakhir aset` → `'Tanggal pelepasan tidak boleh lebih kecil dari periode penyusutan terakhir (<P>)!'`; COA aset/akumulasi kosong → `'Mapping akun Aset / Akumulasi Penyusutan pada kategori aset belum lengkap!'`; laba tanpa COA laba / rugi tanpa COA rugi → pesan masing-masing.
Proses: insert `FA_T_AssetDisposal(..., AccumDeprAtDisposal, BookValueAtDisposal, GainLossAmount, DisposalStatus='A')`; `ReferenceNo = 'FA-DISP-' + RIGHT('000000'+IDX,6)`; jurnal Posted, `IDX_M_JournalType = 7`, branch = cabang aset saat ini, `JournalDate = PostingDate = DisposalDate`, Remark `'Pelepasan aset <code> - <name> (dijual|hapus buku|hibah)'`:
| # | Sisi | Akun | Nilai | Kondisi |
|---|---|---|---|---|
| 1 | D | COA_Proceed | Proceed | tipe S & Proceed > 0 |
| 2 | D | Akumulasi | AccumDepr | AccumDepr ≠ 0 |
| 3 | D | Rugi pelepasan | |GainLoss| | GainLoss < 0 |
| 4 | K | Aset | Cost | selalu |
| 5 | K | Laba pelepasan | GainLoss | GainLoss > 0 |
Balance: `Proceed + Accum + Rugi = Cost + Laba`. Lalu `FA_M_Asset.AssetStatus = DisposalType`, `DisposalDate`. Tidak ada SP batal disposal. Tidak ada cek periode GL.

### 4.8 Laporan FA
- `USP_FA_R_AssetList(@IDX_M_Company, @IDX_M_Branch (0=semua), @CutOffDate, @IDX_M_AssetCategory (0=semua))`: aset aktif record, `AcquisitionDate <= CutOff`; `AccumDepr = Opening + Σ DeprAmount run P dengan DeprPeriod <= YYYYMM(CutOff)`; `BookValue = Cost − AccumDepr`; termasuk aset yang sudah dilepas (dengan status/tgl disposal). Urut kategori, kode.
- `USP_FA_R_AssetCard(@IDX_M_Asset)`: event kronologis (urut tanggal, seq): 1 Perolehan (AcquisitionDate, Cost), 2 Saldo Awal (UsageStartDate, Opening, bila ≠0), 3 Penyusutan per run P (EOMONTH periode, Amount, AccumAfter, BookValueAfter), 4 Mutasi (teks dari→ke cabang), 5 Pelepasan (`Dijual/Hapus Buku/Hibah`, harga jual, laba/rugi, BookValueAfter 0).
- `USP_FA_R_DepreciationSchedule(@IDX_M_Company, @DeprPeriod)`: detail run aktif periode itu (C atau P) per aset: DeprAmount, FiscalDeprAmount, AccumDeprAfter, BookValueAfter, status `Calculated`/`Journal Posted`.
- `USP_FA_R_FiscalDepreciation(@IDX_M_Company, @TaxYear)`: format Lampiran 1A SPT; aset dengan FiscalGroup terisi & tahun perolehan ≤ TaxYear; `FiscalAccumBefore = Σ Fiscal run P tahun < TaxYear`; `FiscalBookValueBegin = Cost − before`; `FiscalDeprCurrentYear = Σ Fiscal run P tahun = TaxYear`; `FiscalBookValueEnd`. Tidak ada saldo awal fiskal untuk aset migrasi.
- `USP_FA_R_Reconciliation(@IDX_M_Company, @CutOffDate)`: per kategori aktif — Register: `RegisterCost = Σ Cost`, `RegisterAccum = Σ(Opening + depr P s/d periode cut-off)`, aset non-D, perolehan ≤ cut-off, kecuali yang sudah dilepas ≤ cut-off. GL: `GLAssetBalance = Σ(D−C)` COA aset, `GLAccumBalance = −Σ(D−C)` COA akumulasi, jurnal posted company s/d cut-off. `DiffAsset`, `DiffAccum` (0 = sinkron). Bila satu COA dipakai >1 kategori, saldo GL terhitung ganda per kategori.
- List: `USP_FA_Asset_List` (+akumulasi P, filter company/branch/kategori/status/search), `USP_FA_AssetCategory_List`, `USP_FA_AssetMutation_List`, `USP_FA_AssetDisposal_List` (filter tipe), `USP_FA_Depreciation_List` (per run: total aset, total depr, total fiskal, voucher jurnal).

---

## 5. Katalog SP

Kolom "Pemanggil" = controller (route). Semua di namespace `App\Http\Controllers\Accounting`.

### 5.1 COA & master
| SP | Parameter penting | Pemanggil | Baca / Tulis | Validasi & pesan |
|---|---|---|---|---|
| `USP_GL_COAGroup1_Create` | IDX_M_COAType, COAGroup1ID, Name1, Name2, UserID, RecordStatus | COAGroup1Controller (`/ac-coa-group1/save`) | W GL_M_COAGroup1 | ID duplikat (trim) → `'COAGroup 1 ID Already Exist!'` |
| `USP_GL_COAGroup1_Update` | + IDX | idem | W | tidak cek duplikat |
| `USP_GL_COAGroup1_Info` / `_List` | IDX / filter COATypeDesc, ID, Name1, Name2 | idem | R COAGroup1, COAType, SM_M_User | — |
| `USP_GL_COAGroup2_Create/Update/Info/List` | IDX_M_COAGroup1, COAGroup2ID, Name1/2 | COAGroup2Controller | W/R GL_M_COAGroup2 | `'COAGroup 2 ID Already Exist!'` |
| `USP_GL_COAGroup3_Create/Update/Info/List` | IDX_M_COAGroup2, COAGroup3ID, Name1/2 | COAGroup3Controller | W/R GL_M_COAGroup3 | `'COAGroup 3 ID Already Exist!'`; List menampilkan RecordStatus milik Group2 (bug) |
| `USP_GL_COA_Create` | Category, Type, COAFlag, COAID, Desc, Desc2, ParentID, CashflowIn/Out, AllowJournalEntry, IsReconcile, DefaultBalance, COAStatus, Group1/2/3, UserID, RecordStatus | COAController (`/ac-coa/save`) | W GL_M_COA | `'COA ID already exists!'`; COAStatus='A', TranslationRate='E' dipaksa |
| `USP_GL_COA_Update` | + IDX_M_COA | idem | W | `'COA ID already exists!'` (selain diri); tidak cek pemakaian di jurnal |
| `USP_GL_COA_Duplicate` | IDX_M_COA, COAID, Desc, Desc2, UserID | COAController (`/ac-coa/save-duplicate`) | W | `'COA ID already exists!'`; menyalin UCreate/DCreate lama (audit salah) |
| `USP_GL_COA_Info` | IDX | COAController, JournalItemController | R COA, Category, Type, Parent, CM_M_CashflowID | — |
| `USP_GL_COA_List` | filter COA, Desc, Desc2, Group1Name1 | COAController, Finance FinancialAccount/PurchaseInvoice/SalesInvoice controllers (lookup) | R | — |
| `USP_GL_COASearch_List` | SearchValue | COAController (`/ac-search-coa-journal-detail`) | R COA aktif & AllowJournalEntry='Y' | — |
| `USP_GL_JournalType_Create/Update/Info/List` | JournalTypeID, Desc, AllowJournalEntry, JournalLabel | JournalTypeController (`/ac-journal-type`) | W/R GL_M_JournalType | lihat §1.3 |
| `USP_GL_FiscalPeriod_Create/Update/List` | Company (0→dari branch), Branch, FiscalPeriod, Start, End, GL/Sales/Purchase/FinanceStatus | **tidak dipanggil** | W/R GL_M_FiscalPeriod | tidak ada validasi (duplikat/overlap bebas) |
| `USP_GL_Tax_List` | filter Name, Alias, Notes, COA in/out | **tidak dipanggil** | R GL_M_Tax | **rusak**: memilih kolom `Name, Alias, Value` yang tidak ada di tabel (`TaxID, TaxName, TaxRate`) |

### 5.2 Jurnal
| SP | Parameter | Pemanggil | Baca / Tulis | Validasi |
|---|---|---|---|---|
| `USP_GL_JournalHeader_Create` | §2.2 | JournalController (`/ac-journal/save`) | W JournalHeader | partner wajib |
| `USP_GL_JournalHeader_Update` | §2.3 | idem | W | posted, partner, ganti company/branch setelah bernomor |
| `USP_GL_JournalHeader_Info` | IDX | JournalController (form, posting, PDF) | R Header, Company, Branch, JournalType, Partner, User | — |
| `USP_GL_JournalDetail_Create/Update` | §2.4 | JournalDetailController (`/ac-journal-detail/save`) | R Project, Header, Company, COA; W JournalDetail | §2.4 |
| `USP_GL_JournalDetail_Delete` | IDX_T_JournalDetail | JournalDetailController (`/ac-journal-detail/save-delete`) | W (DELETE) | posted |
| `USP_GL_JournalDetail_Info` / `_List` | IDX / IDX header | JournalDetailController, JournalController | R | — |
| `USP_GL_JournalItem_List` | Company, Branch, COAID, COADesc, Voucher, Remark, Status, Partner, RemarkDetail, BDebet, BCredit (teks) | JournalDetailController, JournalItemController | R | — |
| `USP_GL_Journal_List` | §2.13 | JournalController (`/ac-journal-list`) | R Header, SM_M_UserBranch | — |
| `USP_GL_Journal_Posting` | §2.5 | JournalController (`/ac-journal/save-posting`) | R Detail, FiscalPeriod, Branch, JournalType; W Header, HeaderLog | §2.5 |
| `USP_GL_Journal_Unposting` | §2.7 | JournalController (`/ac-journal/save-unposting`) | R FiscalPeriod; W Header, HeaderLog | §2.7 |
| `USP_GL_Journal_Duplicate` | IDX, UserID | JournalController (`/ac-journal/save-duplicate`) | W Header, Detail | — |
| `USP_GL_CheckJournalBalance` | — | **tidak dipanggil** | R | — |
| `USP_GL_RecurringJournal_Create/Update/Info/List` | §2.11 | RecurringJournalController | W/R GL_M_RecurringJournal (+Log untuk Update/List) | §2.11 |
| `USP_GL_RecurringJournal_Generate` | Company, Period, UserID | RecurringJournalController (`/ac-recurring-journal/save-generate`) | R template, Log, COA; W Header, Detail, Log | §2.11 |
| `USP_GL_RecurringJournalLog_List` | SearchText, RecurringPeriod | RecurringJournalController (`/ac-recurring-journal-log-list`) | R Log, template, Header | — |

### 5.3 Laporan GL
| SP | Parameter | Pemanggil (route) |
|---|---|---|
| `USP_GL_R_TrialBalance` | Company, Branch, Start, End | RptTBController (`/ac-rpt-tb`); dipanggil juga oleh BS, BS_V2, Equity |
| `USP_GL_R_GeneralLedger` | Company, Branch, Start, End, COA list | RptGLController (`/ac-rpt-gl`), RptTBController & RptBSController (`get_detail_from_gl`, param ke-5 = IDX_M_COA tunggal) |
| `USP_GL_R_BalanceSheet` | Company, Branch, Start, End | RptBSController (`/ac-rpt-bs`) |
| `USP_GL_R_BalanceSheet_V2` | idem | RptBSController (`/ac-rpt-bs-v2`) + BalanceSheetReportBuilder |
| `USP_GL_R_ProfitLoss` | Period, Company, Branch, Project | RptPLController (`/ac-rpt-pl`, `-standard`, `-v3` + ProfitLossReportBuilder) |
| `USP_GL_R_CashflowStatement` | Period, Company, Branch, Project | RptCFController (`/ac-rpt-cf`) |
| `USP_GL_R_StatementOfChangesInEquity` | Period, Company, Branch | RptEQController (`/ac-rpt-eq`) |
Semua read-only; memakai temp table `#TB/#PL/#CF/#Ledger/#COA`; TB/BS/Equity memakai `INSERT ... EXEC` bersarang.

### 5.4 Fixed Asset
| SP | Pemanggil (route) | Baca / Tulis |
|---|---|---|
| `USP_FA_AssetCategory_Create/Update/Info/List` | FACategoryController (`/ac-fa-category`) | FA_M_AssetCategory (+GL_M_COA) |
| `USP_FA_Asset_Create` | FAAssetController (`/ac-fa-asset/save`), FAAssetImportController (`/ac-fa-asset-import/save`) | W FA_M_Asset; R GN_M_Branch |
| `USP_FA_Asset_Update` | FAAssetController | W FA_M_Asset; R depr |
| `USP_FA_Asset_Info` | FAAssetController, FADisposalController, RptFACardController | R |
| `USP_FA_Asset_List` | FAAssetController (`/ac-fa-asset-list`) | R |
| `USP_FA_Asset_GenerateCode` | **tidak dipanggil** | R |
| `USP_FA_Depreciation_Calculate` | FADepreciationController (`/ac-fa-depreciation/save`) | R Asset, Depr; W FA_T_Depreciation(+Detail) |
| `USP_FA_GenerateJournalDepreciation` | FADepreciationController (`/ac-fa-depreciation/save-generate-journal`) | R Depr, Asset, Category, COA; W GL Header/Detail, FA_T_Depreciation |
| `USP_FA_Depreciation_Cancel` | FADepreciationController (`/ac-fa-depreciation/save-cancel`) | W Depr(+Detail) soft delete |
| `USP_FA_Depreciation_List` | FADepreciationController | R |
| `USP_FA_AssetMutation_Save` / `_List` | FAMutationController (`/ac-fa-mutation`) | W FA_T_AssetMutation, FA_M_Asset |
| `USP_FA_AssetDisposal_Save` / `_List` | FADisposalController (`/ac-fa-disposal`) | W FA_T_AssetDisposal, FA_M_Asset, GL Header/Detail |
| `USP_FA_R_AssetList` | RptFAListController (`/ac-rpt-fa-list`) | R |
| `USP_FA_R_AssetCard` | RptFACardController (`/ac-rpt-fa-card`) | R |
| `USP_FA_R_DepreciationSchedule` | RptFADeprController (`/ac-rpt-fa-depr`) | R |
| `USP_FA_R_FiscalDepreciation` | RptFAFiscalController (`/ac-rpt-fa-fiscal`) | R |
| `USP_FA_R_Reconciliation` | RptFAReconController (`/ac-rpt-fa-recon`) | R FA + GL |

### 5.5 `ufn_SPLITSTRING(@List VARCHAR(MAX), @Delimiter VARCHAR(255)) RETURNS TABLE(Item VARCHAR(8000))`
Loop `CHARINDEX`: menambahkan delimiter di akhir, mengembalikan setiap potongan (termasuk string kosong). Bug: posisi maju `+1` sehingga hanya benar untuk delimiter 1 karakter. **Tidak dipakai** SP/kode mana pun. Pengganti PHP: `explode()` / `array_filter`.

---

## 6. Tabel GL_* / FA_*

Tidak ada FOREIGN KEY fisik untuk tabel GL/FA (relasi semuanya implisit). PK = kolom IDX identity.

| Tabel | Baris | Tujuan | Kolom kunci / relasi implisit |
|---|---|---|---|
| `GL_M_COAType` | 5 | Tipe akun AS/LI/EQ/IC/EX | `COATypeID CHAR(2)` |
| `GL_M_COACategory` | 9 | Kategori akun | `IDX_M_COAType` → COAType |
| `GL_M_COAGroup1` | 36 | Grup level 1 (dipakai laporan BS/PL) | `IDX_M_COAType`; `COAGroup1ID` (mis. '4100','5000' dipakai SEQ PL) |
| `GL_M_COAGroup2` | 0 | Grup level 2 | `IDX_M_COAGroup1` |
| `GL_M_COAGroup3` | 0 | Grup level 3 | `IDX_M_COAGroup2` |
| `GL_M_COA` | 159 | Chart of accounts | Type, Category, `COAGroup1..3` (VARCHAR→IDX group), `ParentID`→COA, `IDX_M_CashflowIn/Out`→`CM_M_CashflowID`; dirujuk `GN_M_Company.RetainedEarningAccount/CurrentEarningAccount`, `CM_M_FinancialAccount.IDX_M_COA`, `FA_M_AssetCategory.*COA*`, `GL_M_Tax.COAIn/Out`, `GL_M_RecurringJournal` |
| `GL_M_FiscalPeriod` | 0 | Kunci periode | (Company, Branch, `FiscalPeriod` YYYYMM), status CHAR '1'/'0' |
| `GL_M_JournalType` | 11 | Tipe jurnal & prefix voucher | `JournalTypeID` (prefix), IDX dipakai hardcoded |
| `GL_M_Tax` | 0 | Master pajak (dipakai modul CM/MC) | `COAIn/COAOut` → COA |
| `GL_M_RecurringJournal` | 1 | Template jurnal berulang | Company, Branch, COA Debet/Kredit |
| `GL_T_JournalHeader` | 10.438 | Header jurnal | Company, Branch, JournalType, Partner→`GN_M_Partner`; **(IDX_M_JournalType, IDX_ReferenceNo)** → dokumen sumber; `VoucherNo` (tidak unik di DB), `VoucherNoManual` (diisi CM), `JournalPeriod` (tidak diisi SP manapun), `PostingStatus` U/P, `JournalSource` M/S |
| `GL_T_JournalDetail` | 32.093 | Baris jurnal | `IDX_T_JournalHeader`, COA, Project→`GN_M_Project` (99 = dummy), Department (99), Partner, `IDX_M_CashflowID` (tidak dipakai), O/B amount DECIMAL(22,4), ExchangeRate DECIMAL(22,4) |
| `GL_T_JournalHeaderLog` | 224 | Log posting/unposting | `IDX_T_JournalHeader`, `LogType` |
| `GL_T_AccountBalance` | 0 | Snapshot saldo bulanan (legacy closing) | (JournalPeriod, Company, Branch, COA); B*/T* DECIMAL(20,4) |
| `GL_T_JournalCashflow` | 0 | Alokasi cashflow per detail | **tidak dipakai** |
| `GL_T_ReconcileHeader/Detail` | 0/0 | Rekonsiliasi akun | **tidak dipakai** di scope (rekonsiliasi bank ada di `CM_T_BankStatement*`) |
| `GL_T_RecurringJournalLog` | 4 | Jejak generate recurring (idempotensi) | (`IDX_M_RecurringJournal`, `RecurringPeriod`) unik secara logika; `IDX_T_JournalHeader` |
| `FA_M_AssetCategory` | 2 | Kategori aset + mapping 5 COA | Company, COA × 5 |
| `FA_M_Asset` | 0 | Register aset | Company, Branch, Department, Category, `IDX_T_PurchaseInvoice` (opsional), `AssetCode` unik (logika) |
| `FA_T_Depreciation` | 0 | Run depresiasi per (company, periode) | `DeprStatus` C/P, `IDX_T_JournalHeader` |
| `FA_T_DepreciationDetail` | 0 | Nilai depresiasi per aset per run | `IDX_T_Depreciation`, `IDX_M_Asset` |
| `FA_T_AssetMutation` | 0 | Riwayat pindah cabang/dept | Asset, Branch From/To, Dept From/To |
| `FA_T_AssetDisposal` | 0 | Pelepasan aset | Asset, `IDX_M_COA_Proceed`, `IDX_T_JournalHeader`, nilai snapshot |

---

## 7. SP tidak terpakai & SP hilang

**Ada di DB, tidak dipanggil kode** (scope ini):
- `USP_GL_FiscalPeriod_Create`, `USP_GL_FiscalPeriod_List`, `USP_GL_FiscalPeriod_Update` — tidak ada UI; tabel kosong → kunci periode mati.
- `USP_GL_CheckJournalBalance` — utilitas diagnostik.
- `USP_GL_Tax_List` — rusak (kolom tidak ada).
- `USP_FA_Asset_GenerateCode` — logikanya diduplikasi inline di `USP_FA_Asset_Create`.
- `ufn_SPLITSTRING` — tidak dipakai di mana pun.
- (Di luar prefix tapi relevan: `usp_CM_ClosingPeriod`, satu-satunya penulis `GL_T_AccountBalance`, tidak dipanggil kode.)

**Dipanggil kode, tidak ada di DB**:
- `USP_GL_COA_Save` — `JournalItemController::save()` (`/ac-journal-item/save`) → selalu error. Kemungkinan sisa copy-paste; layar Journal Item sebenarnya hanya inquiry.

**Drift file repo vs DB** (`app/StoredProcedure/*.sql`):
- `USP_GL_R_BalanceSheet`: repo berisi FIX injeksi laba periode berjalan (19 Jul 2026), DB belum.
- `USP_FA_GenerateJournalDepreciation`: repo `@_IDX_M_JournalType = 7`, DB `= 11`.
- `USP_GL_R_TrialBalance`: hanya beda header komentar.
- SP GL lain (COA, Journal, Posting, dll.) tidak ada salinannya di repo — sumber kebenaran hanya DB.

---

## 8. Catatan Recode

### 8.1 Risiko & logika tersembunyi (prioritas)
1. **Kunci periode tidak berfungsi** (tabel kosong, cek berdasarkan PostingDate, jurnal sistem tidak mengecek, subquery tanpa filter company/branch).
2. **Nomor voucher** berbasis IDX identity (bukan sequence), tanpa unique constraint, VARCHAR(20) terpotong.
3. **ExchangeRate DECIMAL(5,2)** di SP detail jurnal → kurs nyata overflow; B-amount dihitung ulang di SP.
4. **Header Update menerima PostingStatus/VoucherNo dari form**; Detail Create tidak cek status posted.
5. **Unposting jurnal sistem** diizinkan dan memutus sinkronisasi dengan dokumen sumber (FA run tetap P, recurring log tetap ada).
6. **JournalType numerik hardcoded** dan bertabrakan antar modul (7, 8, 9, 10, 11 dipakai ganda; 12/13/19 mungkin tidak ada); FA depresiasi beda antara repo (7) dan DB (11). Rekap jurnal per tipe di laporan/CM bisa salah.
7. **Laporan**:
   - BS (DB) tidak balance (laba periode tidak dimasukkan) dan tanda saldo abnormal hilang; pakai V2.
   - GL report: saldo awal company-wide meski filter cabang; IC/EX tidak di-reset per tahun kecuali Januari; COA 115/117 hardcoded; SQL injection pada `@COA`.
   - PL mode semua project: duplikasi nilai per project (cursor + join tanpa project).
   - CF: klasifikasi berdasarkan prefix COAID hardcoded (`1110/1111`, `1410`, …), branch 0 tidak didukung, mapping cashflow master diabaikan.
   - TB/BS/PL membaca `GL_T_AccountBalance` bila ada → perilaku berubah bila closing legacy dijalankan.
   - Pembulatan 2 desimal per akun di temp table vs 4 desimal di detail (lihat FIX script).
8. **FA**:
   - Tidak ada pro-rata (bulan mulai pakai = penuh), tidak ada depresiasi bulan disposal, periode depresiasi boleh melompat (catch-up hanya lewat plug akhir umur).
   - DB = 2/Life × nilai buku bulanan (beda dari dokumen rencana).
   - Jurnal depresiasi satu cabang; jurnal FA langsung Posted tanpa cek periode/balance; tidak ada pembatalan jurnal FA/disposal yang menyinkronkan status.
   - Asset_Update bisa mengubah cabang/kategori/status tanpa jejak & jurnal.
   - Registrasi tidak membuat jurnal perolehan → wajib rekonsiliasi (`USP_FA_R_Reconciliation`) sebelum go-live (lihat `docs/uat_checklist_fixed_asset.md` §8).
9. **Teknis**: dynamic SQL + konkatenasi (SQL injection di hampir semua `_List` dan `USP_GL_R_GeneralLedger`), cursor (`USP_GL_RecurringJournal_Generate`, `USP_GL_R_ProfitLoss`), temp table & `INSERT…EXEC` bersarang (TB sebagai sumber BS/EQ), CATCH yang meng-COMMIT dan CATCH yang crash (konversi INT+VARCHAR), `WITH(NOLOCK)` di validasi (dirty read), race condition pada kode aset/nomor voucher, `exec_sp` tanpa escaping, hardcoded IDX (company 1 di MC, project/dept 99, currency 1, COA 115/117, COAType 3/4).
10. **Data**: `GL_T_JournalHeader.JournalPeriod` tidak pernah diisi; header Debet/CreditAmount tidak reliable; delete fisik jurnal oleh modul lain (bisa meninggalkan detail yatim bila hanya header dihapus — cek `USP_CM_FinancialReceive_ReverseApproval`).

### 8.2 Saran arsitektur Laravel
- `App\Services\GL\JournalService` — **satu-satunya pintu** tulis `GL_T_Journal*`:
  - `createDraft(JournalDTO)`, `addLine/updateLine/removeLine` (tolak bila posted), `post(id, postingDate, notes)`, `unpost(id, notes)` (tolak `source='S'` kecuali dipanggil modul sumber), `reverse(id, date)` (buat jurnal balik, bukan delete), `postSystemJournal(JournalDTO)` (create+post atomik, idempoten per `(sourceType, sourceId)`), `deleteSystemJournal(sourceType, sourceId)` (hanya bila periode terbuka; selain itu reverse).
  - Validasi bersama: satu sisi per baris, ≥2 baris, round 2 desimal + plug, balance base, COA aktif & `AllowJournalEntry`, project ∈ branch, periode terbuka (journalDate), currency & rate (DECIMAL(22,4)), base amount = round(O × rate, 2).
  - Semua dalam `DB::transaction()` dengan lock pada sequence voucher.
- `VoucherNumberService` (tabel sequence; format `<TypeID>-<BranchID>-YYMM-NNNN` untuk kompatibilitas).
- `PeriodLockService` (+ UI fiscal period yang saat ini tidak ada).
- `JournalTypeRegistry`: konstanta berbasis `JournalTypeID` (kode string), mapping ke IDX dibaca dari master; migrasi data untuk memisahkan IDX yang bertabrakan.
- `GL\ReportService`: `trialBalance()`, `generalLedger()`, `balanceSheet()`, `profitLoss()`, `cashFlow()`, `equity()` dibangun di atas satu query saldo `(coa, opening, debit, credit)` dengan aturan closing laba (prior years → RetainedEarning, YTD → CurrentEarning) yang sama di semua laporan; builder PHP yang sudah ada (`BalanceSheetReportBuilder`, `ProfitLossReportBuilder`) dipertahankan sebagai lapisan presentasi.
- `FA\DepreciationService` (calculate/cancel/generateJournal via JournalService), `FA\DisposalService`, `FA\MutationService`, `FA\AssetCodeGenerator`, `RecurringJournalService` — semuanya memanggil `JournalService::postSystemJournal`.

### 8.3 Test case penting (golden test terhadap output SP lama)
1. Posting: tanpa detail → error; tidak balance (selisih 0.0001) → error; periode tutup (by PostingDate) → error; nomor voucher format & reset per bulan/branch/type; posting ulang jurnal bernomor tidak mengganti nomor.
2. Detail: debet & kredit 0 / keduanya >0 → error; posted hanya boleh ubah remark; project beda cabang → error; kurs 16.250 tersimpan benar (regresi bug DECIMAL(5,2)).
3. Header update setelah unposting: ganti branch/company ditolak.
4. Recurring: generate dua kali periode sama → SKIP; AdjustLastPeriod = Total − Σgenerated di EndPeriod; sisa ≤ 0 → SKIP; EndPeriod NULL berjalan terus; validasi format YYYYMM.
5. TB: Σ BB = 0, Σ D = Σ C, Σ BE = 0 untuk company & per branch; saldo awal tahun baru memindahkan L/R tahun lalu ke RetainedEarning; YTD sebelum StartDate ke CurrentEarning.
6. BS_V2: Aset = Liabilitas + Ekuitas untuk periode sembarang (tengah tahun, Januari, lintas tahun).
7. PL: YTD = BB + mutasi; Januari BB = 0; mode semua project tidak menggandakan nilai (bandingkan dengan total branch).
8. CF: Σ arus kas = Kas Akhir − Kas Awal.
9. GL report: saldo awal + mutasi = saldo akhir TB per COA (perhatikan perbedaan filter cabang yang ada di SP lama — putuskan perilaku yang benar).
10. FA SL: Cost 120.000.000, residu 0, umur 48 → 2.500.000/bulan; bulan ke-48 plug; total = Base. Residu > 0 dan pembulatan (Base/Life tidak bulat) → plug akhir menutup selisih.
11. FA DB: Cost 100.000.000, umur 60 → bulan 1 = 3.333.333,33; bulan 2 = (100.000.000 − 3.333.333,33) × 2/60; berhenti di Base; plug di bulan ke-60.
12. FA migrasi: OpeningAccumDepr > 0, UsageStartDate jauh di masa lalu (Elapsed ≥ Life → seluruh sisa disusutkan sekaligus); periode lompat.
13. Fiskal: kelompok 1 (48 bln), BP (240), FiscalGroup kosong → 0; dasar tanpa residu.
14. Urutan run: calculate periode ≤ terakhir → error; periode terakhir masih C → error; cancel status P → error.
15. Generate jurnal depresiasi: mapping COA kosong → error; jurnal per kategori balance; idempoten (`FA-DEPR-YYYYMM`).
16. Disposal S laba, S rugi, W, H: jurnal balance sesuai tabel §4.7; aset berhenti disusutkan; disposal sebelum periode depr terakhir → error; ada run C → error.
17. Mutasi: tujuan sama → error; aset dilepas → error; riwayat tercatat.
18. Rekonsiliasi FA vs GL = 0 setelah skenario lengkap (perolehan via jurnal manual + import + depr + disposal).
19. Kontrak modul lain: setiap produsen menghasilkan jurnal balance, `JournalSource='S'`, `(type, IDX_ReferenceNo)` dapat ditemukan; void/reverse modul sumber menghapus/membalik jurnal yang tepat.
20. Otorisasi: `Journal_List` hanya menampilkan cabang milik user (`SM_M_UserBranch`).
