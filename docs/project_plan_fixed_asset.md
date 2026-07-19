# Project Plan — Fixed Asset (Aset Tetap) di Module Accounting

**Aplikasi:** AVK · **Modul induk:** Accounting · **Prefix baru:** `FA`
**Standar acuan:** PSAK 16 (Aset Tetap), PSAK 48 (Penurunan Nilai), UU PPh & PMK-72/2023 (penyusutan fiskal)

---

## 1. Latar Belakang & Tujuan

Modul Accounting saat ini sudah memiliki COA, Journal (header/detail), posting, dan laporan keuangan (GL, TB, Neraca, PL, CF, Ekuitas). Belum ada pencatatan aset tetap — perolehan, penyusutan, mutasi, dan pelepasan aset masih dijurnal manual.

**Tujuan:**
1. Registrasi aset tetap dengan nilai perolehan, umur manfaat, nilai residu, dan mapping COA per kategori.
2. Penyusutan otomatis bulanan (komersial) yang menghasilkan jurnal ke `GL_T_JournalHeader` / `GL_T_JournalDetail` dan ikut ter-posting ke laporan keuangan existing.
3. Pencatatan penyusutan fiskal paralel (kelompok harta pajak) untuk lampiran SPT.
4. Proses mutasi antar cabang/departemen dan pelepasan aset (jual / hapus buku / hibah) dengan jurnal gain/loss otomatis.
5. Laporan daftar aset, kartu aset, dan jadwal penyusutan.

---

## 2. Kesesuaian dengan PSAK 16

| Ketentuan PSAK 16 | Implementasi di sistem |
|---|---|
| Pengakuan awal sebesar biaya perolehan (harga beli + biaya yang dapat diatribusikan) | Field `AcquisitionCost` = harga beli + biaya lain (instalasi, pengiriman, dll.) yang diinput saat registrasi |
| Penyusutan sistematis selama umur manfaat | Metode Garis Lurus (straight line) & Saldo Menurun (declining balance); umur manfaat & nilai residu per aset |
| Penyusutan dimulai saat aset siap digunakan | Field `UsageStartDate` terpisah dari `AcquisitionDate`; penyusutan dihitung dari bulan mulai pakai |
| Review umur manfaat / nilai residu | Fitur ubah estimasi (prospektif) — sisa nilai buku disusutkan dengan estimasi baru |
| Penghentian pengakuan (disposal) | Transaksi disposal: keluarkan harga perolehan & akumulasi penyusutan, akui laba/rugi pelepasan |
| Penurunan nilai (PSAK 48) | Transaksi impairment manual (adjustment nilai buku) — fase lanjutan |
| Model revaluasi | Di luar scope fase awal (cost model saja); disiapkan di desain tabel (`RevaluationAmount`) |

**Penyusutan fiskal (UU PPh):** setiap aset diberi Kelompok Harta (Kelompok 1 = 4 th, Kelompok 2 = 8 th, Kelompok 3 = 16 th, Kelompok 4 = 20 th, Bangunan Permanen = 20 th, Non-Permanen = 10 th) dengan metode Garis Lurus atau Saldo Menurun sesuai pilihan fiskal. Disimpan paralel di kolom `Fiscal*` — tidak membuat jurnal, hanya untuk laporan pajak.

---

## 3. Jurnal Standar yang Dihasilkan

| Transaksi | Debit | Kredit |
|---|---|---|
| Perolehan aset | Aset Tetap (per kategori) | Kas/Bank/Hutang (via jurnal manual atau link Purchase Invoice) |
| Penyusutan bulanan | Beban Penyusutan | Akumulasi Penyusutan |
| Pelepasan — jual (untung) | Kas/Bank, Akumulasi Penyusutan | Aset Tetap, Laba Pelepasan Aset |
| Pelepasan — jual (rugi) | Kas/Bank, Akumulasi Penyusutan, Rugi Pelepasan Aset | Aset Tetap |
| Hapus buku (write-off) | Akumulasi Penyusutan, Rugi Penghapusan Aset | Aset Tetap |

Mapping akun (aset, akumulasi, beban penyusutan, laba/rugi pelepasan) didefinisikan **per kategori aset** ke `GL_M_COA`.

---

## 4. Desain Database (SQL Server)

Mengikuti konvensi existing: PK `IDX_[M/T]_[Entity]` (BIGINT/INT IDENTITY), audit kolom `UCreate (default suser_name())`, `DCreate (default sysdatetime())`, `UModified`, `DModified`, `RecordStatus (default 'A')`.

### 4.1 Master

**`FA_M_AssetCategory`** — kategori aset + mapping COA
| Kolom | Tipe | Keterangan |
|---|---|---|
| IDX_M_AssetCategory | INT IDENTITY PK | |
| IDX_M_Company | INT | |
| CategoryCode / CategoryName | VARCHAR(20/100) | |
| IDX_M_COA_Asset | BIGINT | akun Aset Tetap |
| IDX_M_COA_AccumDepr | BIGINT | akun Akumulasi Penyusutan |
| IDX_M_COA_DeprExpense | BIGINT | akun Beban Penyusutan |
| IDX_M_COA_GainDisposal | BIGINT | akun Laba Pelepasan |
| IDX_M_COA_LossDisposal | BIGINT | akun Rugi Pelepasan |
| DefaultUsefulLifeMonth | INT | default umur manfaat (bulan) |
| DefaultDeprMethod | CHAR(2) | 'SL' garis lurus, 'DB' saldo menurun |
| FiscalGroup | CHAR(2) | '1'–'4', 'BP' (bangunan permanen), 'BN' (non-permanen) |
| Audit columns | | UCreate, DCreate, UModified, DModified, RecordStatus |

**`FA_M_Asset`** — register aset
| Kolom | Tipe | Keterangan |
|---|---|---|
| IDX_M_Asset | BIGINT IDENTITY PK | |
| IDX_M_Company / IDX_M_Branch / IDX_M_Department | INT | lokasi & pemilik saat ini |
| IDX_M_AssetCategory | INT | |
| AssetCode | VARCHAR(50) | auto-number: `FA/{Cabang}/{YYYYMM}/{seq}` |
| AssetName | VARCHAR(200) | |
| AssetDesc | VARCHAR(5000) | merk/tipe/no seri |
| AcquisitionDate | DATE | tanggal perolehan |
| UsageStartDate | DATE | mulai disusutkan |
| AcquisitionCost | DECIMAL(18,2) | biaya perolehan (PSAK 16) |
| ResidualValue | DECIMAL(18,2) | nilai residu |
| UsefulLifeMonth | INT | umur manfaat (bulan) |
| DeprMethod | CHAR(2) | 'SL' / 'DB' |
| FiscalGroup / FiscalDeprMethod | CHAR(2) | penyusutan fiskal |
| IDX_T_PurchaseInvoice | BIGINT NULL | link ke invoice pembelian (opsional) |
| ReferenceNo | VARCHAR(50) | |
| AssetStatus | CHAR(1) | 'D' Draft, 'A' Aktif, 'S' Dijual, 'W' Hapus Buku, 'H' Hibah |
| DisposalDate | DATE NULL | |
| OpeningAccumDepr | DECIMAL(18,2) | akumulasi penyusutan saldo awal (migrasi aset lama) |
| Audit columns | | |

### 4.2 Transaksi

**`FA_T_Depreciation`** (header per periode) + **`FA_T_DepreciationDetail`** (per aset per periode)
- Header: `IDX_T_Depreciation`, `IDX_M_Company`, `DeprPeriod VARCHAR(6)` (YYYYMM), `IDX_T_JournalHeader` (jurnal hasil generate), `DeprStatus` ('C' Calculated, 'P' Posted), audit.
- Detail: `IDX_T_DepreciationDetail`, `IDX_T_Depreciation`, `IDX_M_Asset`, `DeprAmount`, `FiscalDeprAmount`, `AccumDeprAfter`, `BookValueAfter`, audit.
- Unique constraint `(IDX_M_Company, DeprPeriod)` — satu run per periode; re-run harus batalkan dulu.

**`FA_T_AssetMutation`** — mutasi cabang/departemen: `IDX_T_AssetMutation`, `IDX_M_Asset`, `MutationDate`, `IDX_M_Branch_From/To`, `IDX_M_Department_From/To`, `MutationNotes`, audit.

**`FA_T_AssetDisposal`** — pelepasan: `IDX_T_AssetDisposal`, `IDX_M_Asset`, `DisposalDate`, `DisposalType` ('S' jual/'W' hapus buku/'H' hibah), `DisposalProceed` (harga jual), `AccumDeprAtDisposal`, `BookValueAtDisposal`, `GainLossAmount`, `IDX_T_JournalHeader`, `DisposalStatus`, audit.

### 4.3 Stored Procedures (konvensi `USP_FA_[Entity]_[Action]`)

| Stored Procedure | Fungsi |
|---|---|
| `USP_FA_AssetCategory_List / _Info / _Save` | CRUD kategori |
| `USP_FA_Asset_List / _Info / _Save / _Delete` | CRUD register aset |
| `USP_FA_Asset_GenerateCode` | auto-number kode aset |
| `USP_FA_Depreciation_Calculate` | hitung penyusutan 1 periode (semua aset aktif) → isi `FA_T_Depreciation(+Detail)` |
| `USP_FA_GenerateJournalDepreciation` | buat `GL_T_JournalHeader/Detail` dari hasil kalkulasi (pola sama dengan `USP_MC_GenerateJournalCOGSValas`), grouping beban per kategori/cabang |
| `USP_FA_Depreciation_Cancel` | batalkan run periode (hanya jika jurnal belum diposting) |
| `USP_FA_AssetMutation_List / _Save` | mutasi aset |
| `USP_FA_AssetDisposal_List / _Info / _Save` | pelepasan + generate jurnal gain/loss |
| `USP_FA_R_AssetList` | daftar aset tetap (per tanggal cut-off: cost, akum, nilai buku) |
| `USP_FA_R_AssetCard` | kartu aset (riwayat per aset) |
| `USP_FA_R_DepreciationSchedule` | jadwal/rekap penyusutan per periode |
| `USP_FA_R_FiscalDepreciation` | daftar penyusutan fiskal (format lampiran SPT 1771) |

**Logika penyusutan bulanan:**
- Garis Lurus: `(AcquisitionCost − ResidualValue) / UsefulLifeMonth`
- Saldo Menurun: `NilaiBuku awal tahun × (tarif tahunan / 12)`, sisa nilai buku disusutkan penuh di akhir umur manfaat
- Berhenti otomatis saat akumulasi = (cost − residu) atau aset sudah disposal
- Validasi: tidak boleh hitung periode N jika periode N−1 belum diposting; tidak boleh disposal jika penyusutan periode berjalan belum final

---

## 5. Desain Aplikasi (Laravel)

### 5.1 Routes — `routes/web/accounting.php` (prefix `ac-fa-`)

```php
// FIXED ASSET - CATEGORY
Route::get('/ac-fa-category', 'Accounting\FACategoryController@inquiry');
Route::post('/ac-fa-category-list', 'Accounting\FACategoryController@inquiry_data');
Route::get('/ac-fa-category/create/{id?}', 'Accounting\FACategoryController@create');
Route::get('/ac-fa-category/update/{id}', 'Accounting\FACategoryController@update');
Route::post('/ac-fa-category/save', 'Accounting\FACategoryController@save');

// FIXED ASSET - REGISTER
Route::get('/ac-fa-asset', 'Accounting\FAAssetController@inquiry');
Route::post('/ac-fa-asset-list', 'Accounting\FAAssetController@inquiry_data');
Route::get('/ac-fa-asset/create', 'Accounting\FAAssetController@create');
Route::get('/ac-fa-asset/update/{id}', 'Accounting\FAAssetController@update');
Route::post('/ac-fa-asset/save', 'Accounting\FAAssetController@save');

// FIXED ASSET - DEPRECIATION RUN
Route::get('/ac-fa-depreciation', 'Accounting\FADepreciationController@inquiry');
Route::post('/ac-fa-depreciation-list', 'Accounting\FADepreciationController@inquiry_data');
Route::get('/ac-fa-depreciation/create', 'Accounting\FADepreciationController@create');
Route::post('/ac-fa-depreciation/calculate', 'Accounting\FADepreciationController@calculate');
Route::post('/ac-fa-depreciation/generate-journal', 'Accounting\FADepreciationController@generate_journal');
Route::post('/ac-fa-depreciation/cancel', 'Accounting\FADepreciationController@cancel');

// FIXED ASSET - MUTATION & DISPOSAL
Route::get('/ac-fa-mutation', 'Accounting\FAMutationController@inquiry');
Route::post('/ac-fa-mutation/save', 'Accounting\FAMutationController@save');
Route::get('/ac-fa-disposal', 'Accounting\FADisposalController@inquiry');
Route::post('/ac-fa-disposal-list', 'Accounting\FADisposalController@inquiry_data');
Route::get('/ac-fa-disposal/create/{asset_id}', 'Accounting\FADisposalController@create');
Route::post('/ac-fa-disposal/save', 'Accounting\FADisposalController@save');

// FIXED ASSET - REPORT
Route::get('/ac-rpt-fa-list', 'Accounting\RptFAListController@period');
Route::post('/ac-rpt-fa-list', 'Accounting\RptFAListController@period_report');
Route::get('/ac-rpt-fa-card', 'Accounting\RptFACardController@period');
Route::post('/ac-rpt-fa-card', 'Accounting\RptFACardController@period_report');
Route::get('/ac-rpt-fa-depr', 'Accounting\RptFADeprController@period');
Route::post('/ac-rpt-fa-depr', 'Accounting\RptFADeprController@period_report');
Route::get('/ac-rpt-fa-fiscal', 'Accounting\RptFAFiscalController@period');
Route::post('/ac-rpt-fa-fiscal', 'Accounting\RptFAFiscalController@period_report');
```

### 5.2 Controllers — `app/Http/Controllers/Accounting/`
`FACategoryController`, `FAAssetController`, `FADepreciationController`, `FAMutationController`, `FADisposalController`, `RptFAListController`, `RptFACardController`, `RptFADeprController`, `RptFAFiscalController` — semua extend `MyController`, pola `inquiry / inquiry_data / create / update / save` seperti `JournalController`.

### 5.3 Views — `resources/views/accounting/`
`fa_category_list/form`, `fa_asset_list/form`, `fa_depreciation_list/form`, `fa_mutation_form`, `fa_disposal_list/form`, `rpt_fa_*_form/report` — memakai komponen existing (`x-textbox`, `x-dropdown`, `x-date-picker`, DataTables server-side).

### 5.4 Sidebar — `navigation/sidebar_accounting.blade.php`
Grup menu baru **Fixed Asset** di antara *Transaction* dan *Report*:

```
ACCOUNTING
├── Dashboard
├── Transaction
│   ├── Lihat Journal / Input Journal / Lihat Detail Journal
├── Fixed Asset                ← BARU
│   ├── Daftar Aset
│   ├── Input Aset
│   ├── Penyusutan Bulanan
│   ├── Mutasi Aset
│   └── Pelepasan Aset
├── Report
│   ├── (existing...)
│   ├── Daftar Aset Tetap      ← BARU
│   ├── Kartu Aset             ← BARU
│   ├── Rekap Penyusutan       ← BARU
│   └── Penyusutan Fiskal      ← BARU
└── Setting
    ├── (existing...)
    └── Kategori Aset          ← BARU
```

---

## 6. Fase Pengerjaan & Estimasi

| Fase | Deliverable | Estimasi |
|---|---|---|
| **Fase 1 — Master & Register** | Tabel `FA_M_AssetCategory`, `FA_M_Asset` + SP CRUD + controller/view kategori & register aset + auto-number + menu sidebar | 2 minggu |
| **Fase 2 — Penyusutan & Jurnal** | `FA_T_Depreciation(+Detail)`, SP calculate + generate journal + cancel, layar proses penyusutan bulanan, integrasi posting GL | 2 minggu |
| **Fase 3 — Mutasi & Disposal** | `FA_T_AssetMutation`, `FA_T_AssetDisposal`, jurnal gain/loss, validasi status aset | 1,5 minggu |
| **Fase 4 — Laporan & Fiskal** | 4 laporan (daftar aset, kartu aset, rekap penyusutan, fiskal SPT) + export PDF/Excel | 1,5 minggu |
| **Fase 5 — Migrasi & UAT** | Import saldo awal aset existing (template Excel via `maatwebsite/excel`, kolom `OpeningAccumDepr`), UAT dengan akunting, go-live | 1 minggu |

**Total: ± 8 minggu.** Setiap fase diakhiri deploy ke staging + verifikasi jurnal terhadap Trial Balance existing.

---

## 7. Titik Integrasi dengan Sistem Existing

1. **Jurnal** — semua jurnal FA masuk `GL_T_JournalHeader/Detail` dengan `IDX_M_JournalType` baru (mis. "FA Depreciation", "FA Disposal") di master Journal Type, sehingga otomatis muncul di GL/TB/Neraca/PL existing.
2. **COA** — mapping akun per kategori memakai lookup COA existing (`/ac-select-coa`, `USP_GL_COA_List`).
3. **Purchase Invoice (Finance)** — opsional link `IDX_T_PurchaseInvoice` saat registrasi aset dari pembelian; fase awal cukup referensi nomor, otomatisasi kapitalisasi dari invoice bisa menyusul.
4. **Master umum** — `GN_M_Company`, `GN_M_Branch`, `GN_M_Department` untuk lokasi/pemilik aset.

---

## 8. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Saldo awal aset lama tidak akurat (akumulasi penyusutan berjalan) | Template import + kolom `OpeningAccumDepr` + rekonsiliasi ke saldo akun Aset Tetap & Akumulasi di TB sebelum go-live |
| Dobel jurnal penyusutan satu periode | Unique constraint `(Company, DeprPeriod)` + status run + validasi di SP |
| Penyusutan dijalankan mundur/loncat periode | Validasi urutan periode di `USP_FA_Depreciation_Calculate` |
| Selisih pembulatan akumulasi vs (cost − residu) | Periode terakhir menyusutkan sisa nilai buku (plug ke sisa) |
| Perbedaan buku komersial vs fiskal membingungkan user | Kolom fiskal hanya tampil di register & laporan fiskal; tidak pernah membuat jurnal |
| Jurnal FA di-unposting/diedit manual dari layar Journal | Tandai jurnal hasil generate (ReferenceNo = kode run FA) + validasi di `USP_GL_Journal_Unposting` |
