# Dokumentasi Recode Business Logic AVK

Dokumentasi detail logika bisnis yang saat ini berada di **stored procedure SQL Server**
(`AVKDB`). Tujuannya agar logika itu bisa dipindahkan (recode) ke kode aplikasi Laravel atau
diubah dengan aman.

- **Sumber:** snapshot DB lokal `BERNARDINUS4256\SQLEXPRESS` / `AVKDB` (koneksi `.env`),
  diambil 2026-11-21, berisi 494 SP + 1 fungsi, 150 tabel, 0 view, 0 trigger.
- **Source SP lengkap:** [`database/sqlserver/procedures/`](../../database/sqlserver/procedures/)
- Ringkasan singkat untuk agent/dev ada di [`CLAUDE.md`](../../CLAUDE.md). Dokumen ini adalah
  versi detailnya.

## Daftar isi

| # | Dokumen | Isi |
|---|---|---|
| 01 | [Arsitektur & Peta Modul](01_arsitektur_dan_peta_modul.md) | Alur request → SP, koneksi DB, peta modul/route/SP, volume data, konvensi penamaan |
| 02 | [Strategi Recode & Temuan Kritis](02_strategi_recode_dan_temuan_kritis.md) | **Baca dulu.** Risiko keamanan & akuntansi, prinsip recode, urutan fase, keputusan bisnis |
| 03 | [Money Changer (MC)](03_money_changer.md) | Beli/jual valas, stok per pecahan, HPP/COGS, open/close kasir, kurs BI, LTKM/LTKT/DTTOT |
| 04 | [Cash Management – Kas & Bank](04_cash_management.md) | Financial Payment/Receive, Internal Transfer, Petty Cash, rekonsiliasi rekening koran, closing |
| 05 | [Cash Management – Invoice, Refund, Pajak & Laporan](05_ar_ap_tax_reports.md) | Sales/Purchase Invoice, alokasi, refund, faktur pajak, laporan `USP_CM_R_*` |
| 06 | [General Ledger & Fixed Asset](06_gl_fa.md) | COA, jurnal & posting, journal type, laporan keuangan, depresiasi & disposal aset |
| 07 | [General, Security & Infrastruktur](07_general_security_infra.md) | `exec_sp`/`store()`/DataTables, login & permission, master data, partner, DTTOT, attachment |
| A | [Katalog Stored Procedure](A_katalog_sp.md) | Semua SP: parameter, pemanggil di PHP, objek yang direferensikan, SP yang hilang |
| B | [Kamus Tabel](B_kamus_tabel.md) | Semua tabel: kolom, tipe, PK, FK, jumlah baris, SP pemakai |

Penanda di dokumen modul: **[VERIFIKASI]** / **[belum pasti]** = belum bisa dipastikan dari
source saja, jadi cek dengan data atau test sebelum dijadikan acuan.

## Memperbarui dokumentasi

Lampiran A & B serta folder `database/sqlserver/procedures/` dihasilkan dari metadata DB
(`sys.sql_modules`, `sys.parameters`, `sys.columns`, `sys.sql_expression_dependencies`) dan
`grep` nama SP di `app/` & `routes/`. Setelah SP diubah di DB, ekspor ulang source SP ke folder
tersebut, lalu perbarui bagian modul yang terkait.
