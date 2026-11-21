# 01 — Arsitektur & Peta Modul

## 1. Gambaran umum

AVK adalah aplikasi Laravel 7 (PHP 7.3 di lokal, `^7.2.5|^8.0` di composer) dengan SQL Server sebagai
backend. **Hampir semua business logic berada di stored procedure (SP)**. PHP hanya:

1. menerima request, menyusun array parameter **posisional**,
2. memanggil `MyController::exec_sp()` yang merangkai string `EXEC <SP> 'a',1,...` (tanpa binding),
3. membaca result set (pesan, ID, status) lalu me-render Blade / JSON DataTables.

```
Browser ──HTTP──▶ routes/web/*.php ──▶ Controller (extends MyController)
                                         │  $param = [...] (urutan = urutan parameter SP)
                                         ▼
                                  exec_sp('USP_XX_Entity_Action', $param)
                                         │  "EXEC USP_.. 'v1',2,'v3'"  (string concat)
                                         ▼
                              SQL Server AVKDB ── SP: validasi, penomoran, hitung,
                                                     tulis transaksi, jurnal GL, stok, log
```

Konsekuensi untuk recode:

- Aturan bisnis, validasi, penomoran dokumen, pembentukan jurnal, kunci periode dan mutasi stok
  **tidak ada di PHP**. Setiap SP `_Save`, `_Approve`, `_Void`, `_Reverse`, `_Calculate`,
  `_GenerateJournal*` adalah unit logika yang harus dipindahkan.
- Struktur tabel tidak dikelola migration Laravel. Hanya ada 6 foreign key fisik; relasi lain
  implisit lewat kolom `IDX_*` (lihat [Lampiran B](B_kamus_tabel.md)).
- Tidak ada trigger, view, maupun fungsi skalar selain `ufn_SPLITSTRING`. Jadi seluruh logika DB ada
  di 494 SP + 1 fungsi.

## 2. Koneksi database

| Item | Nilai (2026-11-21) |
|---|---|
| Koneksi Laravel | `sqlsrv` (default `DB_CONNECTION=sqlsrv`, `config/database.php`) |
| Host di `.env` | `tcp:10.211.55.3`, port `49725` (VM Parallels lokal) |
| `@@SERVERNAME` | `BERNARDINUS4256\SQLEXPRESS` — **database lokal**, SQL Server 2014 Express (12.0.2000.8) |
| Database | `AVKDB` (instance yang sama juga memuat `KUATDB`) |
| Produksi | `WIN-U77CDEKVAKS`, aplikasi di `C:\xampp7\htdocs\avk` (lihat `DEPLOYMENT.md`) |

`config/database.php` hanya membaca `env()`. Tidak ada host yang di-hardcode di kode PHP. Untuk
pindah server cukup ubah blok `DB_*` di `.env`, lalu jalankan `php artisan config:clear`.

> ⚠️ `.env` pernah mengarah ke server produksi. **Sebelum menjalankan DDL, deploy SP, atau
> perubahan data, cek `SELECT @@SERVERNAME`** dan pastikan hasilnya bukan `WIN-U77CDEKVAKS`.

Cek cepat dari CLI:

```bash
php artisan tinker
>>> DB::connection('sqlsrv')->select("SELECT @@SERVERNAME s, DB_NAME() d");
```

## 3. Peta modul

| Modul (UI) | Folder controller | Prefix route | File route | Jml route | Prefix SP | Jml SP di DB | Status |
|---|---|---|---|---:|---|---:|---|
| General / Master | `General/` | `gn-` | `routes/web/general.php` | 62 | `USP_GN_` | 45 | Aktif |
| Security / User | `UserManagement/`, `LoginController` | `sm-` | `routes/web/security.php` | 53 | `USP_SM_` | 41 | Aktif |
| Accounting (GL) | `Accounting/` | `ac-` | `routes/web/accounting.php` | 126 | `USP_GL_` | 53 | Aktif |
| Fixed Asset | `Accounting/FA*`, `Rpt FA*` | `ac-fa-` | `routes/web/accounting.php` | (termasuk di atas) | `USP_FA_` | 22 | Baru (tabel FA masih kosong) |
| Finance / Cash Management | `Finance/` | `fm-` | `routes/web/finance.php` | 289 | `USP_CM_` | 229 | Aktif (Payment/Receive/Bank Statement). Invoice/refund/pajak: tabel kosong |
| Money Changer | `MoneyChanger/` | `mc-` | `routes/web/moneychanger.php` | 214 | `USP_MC_` | 104 | **Inti bisnis**, volume terbesar |
| Loan | `Loan/` | `cf-` | `routes/web/loan.php` | 5 | `USP_CF_` | 0 | Legacy, SP tidak ada |
| Parking / Membership | — | `qp-` | `routes/web/parking.php` | 31 | `USP_QP_` | 0 | Legacy, SP tidak ada |
| Pawn | — | `pw-` | `routes/web/pawn.php` | 2 | — | 0 | Stub |
| Procurement | — | `pr-` | `routes/web/procurement.php` | 72 | `USP_PR_` | 0 | Legacy, SP tidak ada |
| Inventory | — | `in-` | `routes/web/inventory.php` | 9 | `USP_IN_` | 0 | Legacy, SP tidak ada |

> Catatan: `CLAUDE.md` menyebut prefix SP `FM`/`AC`. Prefix sebenarnya di DB adalah **`CM`**
> (Finance) dan **`GL`/`FA`** (Accounting). Route tetap memakai `fm-`/`ac-`.

### 3.1 Volume data (snapshot DB lokal)

Tabel dengan data terbanyak, yang menunjukkan fitur yang benar-benar dipakai:

| Area | Tabel | Baris |
|---|---|---:|
| GL | `GL_T_JournalDetail` / `GL_T_JournalHeader` | 32.093 / 10.438 |
| MC | `MC_T_StockCardValas` | 8.944 |
| MC | `MC_T_PurchaseOrder` / `Detail` / `Upload` | 2.349 / 4.739 / 4.527 |
| MC | `MC_T_SalesOrder` / `Detail` / `Upload` | 1.855 / 4.215 / 4.448 |
| MC | `MC_T_COGSValasCalculation` | 995 |
| CM | `CM_T_FinancialPaymentHeader` / `Detail` | 2.466 / 2.466 |
| CM | `CM_T_FinancialReceiveHeader` / `Detail` | 1.972 / 1.972 |
| CM | `CM_T_BankStatementDetail` | 1.024 |
| GN | `GN_M_Partner` / `GN_M_PartnerAddress` | 2.609 / 2.275 |
| GN | `GN_M_DTTOT` | 531 |

Tabel yang **kosong** (fitur belum/tidak dipakai): semua tabel invoice/refund/pajak CM
(`CM_T_SalesInvoice*`, `CM_T_PurchaseInvoice*`, `*Refund*`, `CM_T_FakturPajak`,
`CM_T_*Allocation`), `FA_*` transaksi, `GL_M_FiscalPeriod`, `GL_T_AccountBalance`,
`GL_T_Reconcile*`, `MC_T_LTKM`, `MC_T_LTKT`, `MC_T_NotaScan*`, `MC_T_POSValas*`, `SM_T_Session*`.
Kosong di DB lokal belum tentu kosong di produksi, jadi konfirmasi dulu sebelum memutuskan
fitur itu tidak perlu di-recode.

## 4. Konvensi penamaan

### 4.1 Stored procedure

`USP_<Modul>_<Entitas>_<Aksi>`

| Aksi | Arti umum |
|---|---|
| `_List` | Data untuk DataTables (server-side) atau dropdown |
| `_Info` | Satu record (form edit/view) |
| `_Save` | Insert **atau** update (pembeda biasanya `IDX = 0` vs `> 0`, atau parameter `@State`) |
| `_Create` / `_Update` | Insert / update terpisah (dipakai pola Header/Detail baru) |
| `_Delete` | Hapus (sering *soft*: set `RecordStatus`/`Status`) |
| `_Approve`, `_ReverseApprove`, `_Void`, `_Reverse`, `_Reopen` | Transisi status dokumen, sering memicu jurnal GL / stok |
| `_Journal_List`, `Generate*Journal*` | Lihat/bentuk jurnal |
| `USP_<M>_R_*` | Laporan |
| `*SearchByValue*` | Lookup/autocomplete |

### 4.2 Tabel

`<Modul>_<M|T>_<Entitas>`: `M_` = master, `T_` = transaksi. PK umumnya `IDX_<M|T>_<Entitas>`
(bigint IDENTITY). Kolom audit yang lazim: `UserID`/`CreatedBy`, `CreatedDate`, `UpdatedBy`,
`UpdatedDate`, `RecordStatus`. Detail lengkap ada di [Lampiran B](B_kamus_tabel.md).

### 4.3 Folder SQL di repo

| Folder | Isi |
|---|---|
| `database/sqlserver/procedures/` | **Snapshot lengkap** 495 SP + fungsi dari DB lokal (2026-11-21). Ini baseline untuk recode dan diff. |
| `app/StoredProcedure/` | SP yang dikembangkan/di-patch lewat repo (sebagian lebih baru dari DB, mis. PettyCash) + skrip `ALTER_`/`FIX_` |
| `app/SQLTable/` | DDL tabel FA & recurring journal |

## 5. Alur request standar (contoh)

Diringkas dari `app/Http/Controllers/Finance/FinancialPaymentController.php::save()`:

```php
// routes/web/finance.php
Route::post('/fm-financial-payment/save', 'Finance\FinancialPaymentController@save');

// Controller
$this->sp_create = '[dbo].[USP_CM_FinancialPaymentHeader_Create]';
$this->sp_update = '[dbo].[USP_CM_FinancialPaymentHeader_Update]';

// logika kecil yang ada di PHP: COA header diambil dari rekening kas/bank (SQL di-concat langsung)
$sql = "SELECT IDX_M_COA FROM CM_M_FinancialAccount
        WHERE RecordStatus = 'A' AND IDX_M_FinancialAccount = " . $data['IDX_M_FinancialAccount'];

if ($state == 'update') $param['IDX_T_FinancialPaymentHeader'] = $data['IDX_T_FinancialPaymentHeader'];
$param['IDX_M_Company'] = $data['IDX_M_Company'];
// ... urutan key HARUS sama dengan urutan parameter SP (nama key diabaikan)
$param['PaymentStatus'] = 'D';                                         // Draft
$param['PaymentAmount'] = (double) str_replace(',', '', $data['PaymentAmount']);
$param['UserID']        = 'XXX' . $this->data['user_id'];              // 'XXX' = paksa dikutip sebagai string
$param['RecordStatus']  = 'A';

return $this->store($state, $param);   // → exec_sp(sp_create|sp_update, $param)
```

`store()` dan `validate_return()` membaca kolom hasil SP (pesan sukses/gagal, ID baru) lalu
membalas JSON / SweetAlert. Detail mekanismenya ada di
[07 — General, Security & Infrastruktur](07_general_security_infra.md).
