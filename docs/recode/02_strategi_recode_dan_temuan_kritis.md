# 02 — Strategi Recode & Temuan Kritis

Dokumen ini merangkum temuan lintas modul dari analisis 495 SP (snapshot DB lokal 2026-11-21)
dan memberi urutan kerja yang disarankan. Detail dan bukti per modul ada di dokumen 03–07.

Tingkat kepastian: **✔ terverifikasi** = sudah dicek langsung ke kode/DB saat penyusunan;
selain itu berasal dari pembacaan source SP dan perlu dibuktikan dengan test saat recode.

## 1. Temuan kritis (perbaiki atau putuskan sebelum/selama recode)

### 1.1 Keamanan

| # | Temuan | Lokasi | Status |
|---|---|---|---|
| S1 | **SQL injection sebelum login**: input `UserID` dan password digabung langsung ke `EXEC [USP_SM_CheckLoginValidation] '$user_id','$user_password'` | `app/Http/Controllers/LoginController.php:55` | ✔ |
| S2 | `exec_sp`/`exec_sp_multi` merangkai parameter tanpa escaping. Prefix `XXX` hanya memaksa tanda kutip | `MyController.php:341`, `:476` | ✔ |
| S3 | SP `*_List` memakai dynamic SQL dari filter/kolom sort DataTables, sehingga terbuka untuk injection di `ORDER BY`/`WHERE` | banyak SP `_List`, `USP_GL_R_GeneralLedger` | 07 §1, 06 §8 |
| S4 | Password disimpan sebagai MD5 tanpa salt. Reset password membuat password = MD5(LoginID) | `USP_SM_*` | 07 §2 |
| S5 | Login tidak mengecek `RecordStatus`/`IsLocked`. `check_permission` mengabaikan `RecordStatus`, dan sebagian besar endpoint save tidak mengecek permission | `LoginController`, `MyController::check_permission` | 07 §2 |

### 1.2 Integritas akuntansi

| # | Temuan | Modul |
|---|---|---|
| A1 | **Kunci periode tidak berfungsi.** `GL_M_FiscalPeriod` kosong ✔ dan tidak punya UI. Jurnal sistem (MC, CM, FA, recurring) tidak pernah mengecek periode | 06, 04, 03 |
| A2 | Approve dokumen bisa sukses tanpa jurnal. Kegagalan pembuatan jurnal tidak terdeteksi, `store()` membaca baris hasil terakhir, dan CATCH bisa `COMMIT` sebagian | 03, 04 |
| A3 | Pola CATCH `CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE())` memicu error konversi kedua, sehingga pesan asli hilang | semua SP lama |
| A4 | Journal type numerik di-hardcode dan bentrok. ✔ IDX 12/13/19 tidak ada di master, ada 2 jurnal orphan bertipe 13, dan IDX 9 (Inactive "Penerimaan Angsuran") dipakai Internal Transfer | 06 §1.3 |
| A5 | **Void Financial Receive/Payment tidak membalik jurnal** (yang dibalik tipe salah). Reverse/Void menghapus jurnal yang sudah Posted secara fisik, tanpa jurnal pembalik | 04 |
| A6 | Jurnal approve FP/FR bisa tidak balance bila detail > 1 dokumen. Saat ini data selalu 1 detail per header, jadi belum terpicu | 04 |
| A7 | `@ExchangeRate DECIMAL(5,2)` (maks 999,99) di `USP_GL_JournalDetail_Create/_Update` ✔, sehingga kurs IDR riil overflow | 06 |
| A8 | Jurnal sistem bisa di-unpost/diubah dari menu GL tanpa sinkron ke dokumen sumber. Detail bisa ditambah ke jurnal yang sudah Posted | 06 |
| A9 | Laporan tidak konsisten: `USP_GL_R_BalanceSheet` (versi di DB) tidak memasukkan laba berjalan (V2 benar). GL report mengabaikan filter branch pada saldo awal. Cash flow memakai prefix COAID hardcoded | 06 §3 |

### 1.3 Money Changer (inti bisnis)

| # | Temuan |
|---|---|
| M1 | Reverse penjualan tidak menghapus stock-in dari baris "beli dari customer" pada nota yang sama, tidak mengecek pembayaran, dan tidak menghapus jurnal HPP. Controller juga mengirim parameter dengan urutan salah |
| M2 | Reverse pembelian tidak mengecek apakah stok sudah terjual, sehingga stok bisa negatif |
| M3 | Nota yang sudah approve masih bisa diedit di level SP (hanya UI yang memblokir) |
| M4 | Perlakuan HPP untuk baris "beli dari customer" dan kredit ke Hutang Usaha yang tidak pernah dilunasi **butuh keputusan akuntan** sebelum diporting |
| M5 | Hardcoded COA (5/12/102), kas (3), company (1). Penomoran nota memakai `MAX()+1` tanpa lock dan *wrap* setelah 9.999 per cabang per tahun |

### 1.4 Fitur mati / rusak

- **AR/AP, pajak, refund, alokasi (05)**: semua tabel 0 baris, dan SP inti merujuk objek yang
  ✔ **tidak ada** (`IN_M_Item`, `PR_T_PurchaseOrder`, `X_SalesSummary_Quality`,
  `fn_GetSalesInvoicePayment`, `USP_CheckUserForm`). Kode SP ini salinan dari produk lain. Recode
  harus dirancang ulang dari kebutuhan, bukan diporting 1:1.
- **56 SP dipanggil kode tetapi tidak ada di DB** (Loan `USP_CF_*`, Parking `USP_QP_*`,
  `usp_T_ReceiptMembership*`, `USP_PR_*`, sebagian `USP_MC_*`, `USP_GL_COA_Save`,
  `USP_GN_DocumentType_Save`, `USP_SM_User_ChangePassword`). Lihat [Lampiran A](A_katalog_sp.md#sp-dipanggil-kode-tetapi-tidak-ada-di-database).
- **112 SP di DB tidak dipanggil kode.** Sebagian dipanggil SP lain (cek kolom referensi di Lampiran A).

## 2. Prinsip recode

1. **Satu pintu jurnal.** Buat `JournalService` (create → validate balance → assign number →
   post / reverse dengan jurnal pembalik, bukan delete) yang wajib dipakai semua modul. Aturan
   periode (`FiscalPeriodGuard`) dijalankan di sini.
2. **Transaksi DB di PHP.** `DB::transaction()` membungkus dokumen + stok + jurnal. Exception
   harus menggagalkan seluruh operasi, tanpa commit sebagian.
3. **Query dengan binding.** Ganti `exec_sp`/string concat dengan Query Builder atau
   `DB::select('EXEC sp ?,?', $bindings)` selama masa transisi.
4. **State machine eksplisit** per dokumen (Draft → Approved → Void/Reversed), divalidasi di
   service, bukan hanya disembunyikan di UI.
5. **Penomoran dokumen terpusat** (`DocumentNumberService`) dengan tabel counter + row lock
   (`UPDLOCK, HOLDLOCK`), format tetap sama dengan yang sekarang (lihat tiap modul).
6. **Konfigurasi, bukan hardcode.** COA default, kas default, dan journal type disimpan di tabel
   mapping (mis. `GL_M_AccountMapping`) atau di config.
7. **Paritas dulu, perbaikan kemudian.** Untuk MC dan CM treasury, bangun test paritas yang
   membandingkan output service baru dengan SP lama di DB lokal (hasil jurnal, stok, HPP) sebelum
   memperbaiki bug yang sudah dikonfirmasi bisnis. Perbedaan yang disengaja dicatat.

## 3. Urutan kerja yang disarankan

| Fase | Lingkup | Alasan |
|---|---|---|
| 0 | Perbaiki S1 (login) & S2 (binding di `exec_sp`), cabut akses SP berbahaya dari user aplikasi | Risiko keamanan tertinggi, perubahannya kecil |
| 1 | Fondasi: `JournalService`, `DocumentNumberService`, `FiscalPeriodGuard`, enum journal type, auth middleware + permission | Dipakai semua modul |
| 2 | GN & SM (master, user, permission) | Ketergantungan paling sedikit |
| 3 | GL: COA, jurnal manual, posting, laporan TB/GL/BS/PL | Validasi jurnal baru vs laporan lama |
| 4 | CM treasury: Financial Payment/Receive, Internal Transfer, Petty Cash, Bank Statement | Volume besar, sudah dipakai produksi |
| 5 | MC: PO/SO, stok, HPP, open/close, LTKM/LTKT/DTTOT | Inti bisnis. Perlu test paritas HPP & stok terlengkap |
| 6 | FA (depresiasi, disposal) | Tabel masih kosong, jadi bisa dibangun langsung benar |
| 7 | AR/AP/pajak | Implementasi baru, butuh spesifikasi bisnis (tarif PPN, PPh, e-Faktur) |
| 8 | Hapus route/controller legacy (Loan, Parking, Pawn, Procurement, Inventory) setelah konfirmasi tidak dipakai | Mengurangi permukaan serangan |

Selama transisi, SP lama tetap ada. Fitur dipindah per endpoint (strangler pattern): controller
memanggil service baru, sedangkan SP lama hanya dipakai sebagai pembanding di test.

## 4. Keputusan bisnis yang dibutuhkan

- Perlakuan akuntansi baris "beli dari customer" di nota jual (HPP & Hutang Usaha). Lihat 03 §5.
- Apakah reverse/void boleh menghapus jurnal Posted, atau wajib jurnal pembalik.
- Kebijakan kunci periode: siapa yang boleh membuka periode, dan apakah jurnal sistem ikut terkunci.
- Metode depresiasi FA (pro-rata bulan pertama, double-declining) mengikuti
  `docs/project_plan_fixed_asset.md` atau perilaku SP saat ini.
- Apakah modul AR/AP/pajak, Loan, Parking, Procurement, Inventory masih dibutuhkan.

## 5. Checklist sebelum menyentuh database

1. `SELECT @@SERVERNAME` harus menghasilkan `BERNARDINUS4256\SQLEXPRESS` (lokal), **bukan**
   `WIN-U77CDEKVAKS` (produksi).
2. Simpan SP versi lama ke `database/sqlserver/procedures/` sebelum `ALTER`, supaya diff terlihat di git.
3. Uji kompilasi dengan `SET NOEXEC ON`, dan backup baris sebelum `DELETE`/`UPDATE` massal.
