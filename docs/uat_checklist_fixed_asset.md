# UAT Checklist — Modul Fixed Asset (Aset Tetap)

**Aplikasi:** AVK · **Modul:** Accounting → Fixed Asset
**Standar acuan:** PSAK 16, UU PPh (penyusutan fiskal)
**Peserta UAT:** Tim Akunting + IT · **Lingkungan:** Staging dengan salinan data produksi

Tandai setiap butir: ✅ Lulus / ❌ Gagal (catat nomor temuan) / ⏭ Dilewati (beri alasan).

---

## 0. Prasyarat Deploy

- [ ] Seluruh script `app/SQLTable/FA_*.sql` sudah dijalankan (6 tabel FA)
- [ ] Seluruh script `app/StoredProcedure/USP_FA_*.sql` sudah dijalankan (CRUD, penyusutan, mutasi, disposal, 6 laporan)
- [ ] Journal Type "FA Depreciation" terdaftar di `/ac-journal-type` dan IDX-nya **sama** dengan konstanta `@_IDX_M_JournalType` di `USP_FA_GenerateJournalDepreciation` dan `USP_FA_AssetDisposal_Save`
- [ ] Master COA untuk aset tetap tersedia: akun Aset, Akumulasi Penyusutan, Beban Penyusutan, Laba Pelepasan, Rugi Pelepasan

## 1. Master — Kategori Aset (`/ac-fa-category`)

- [ ] Buat kategori baru dengan mapping 5 akun COA lengkap → tersimpan
- [ ] Kode kategori duplikat → ditolak dengan pesan jelas
- [ ] Simpan tanpa akun Aset/Akumulasi/Beban → ditolak
- [ ] Umur manfaat 0 atau negatif → ditolak
- [ ] Edit kategori existing → perubahan tersimpan dan tampil di list

## 2. Register Aset (`/ac-fa-asset`)

- [ ] Input aset baru dengan kode dikosongkan → kode tergenerate `FA/{Cabang}/{YYYYMM}/{seq}`
- [ ] Input aset dengan kode manual duplikat → ditolak
- [ ] Nilai residu ≥ harga perolehan → ditolak
- [ ] Tanggal mulai pakai < tanggal perolehan → ditolak
- [ ] Kolom Akum. Penyusutan dan Nilai Buku di list & form update sesuai perhitungan manual
- [ ] Aset yang sudah punya penyusutan posted: ubah harga/umur/metode → ditolak; ubah nama/keterangan → boleh

## 3. Import Saldo Awal (`/ac-fa-asset-import`)

- [ ] Download template menghasilkan file Excel dengan kolom lengkap + 1 baris contoh
- [ ] Upload file dengan campuran baris valid & salah (kategori tidak terdaftar, tanggal salah, akum awal > dasar penyusutan) → preview menandai baris merah dengan pesan per baris
- [ ] Simpan → hanya baris valid yang masuk; hasil menampilkan jumlah sukses/gagal
- [ ] Aset hasil import berstatus Aktif dan `akum_penyusutan_awal` tersimpan di `OpeningAccumDepr`
- [ ] Nilai buku aset import = harga perolehan − akum awal (cek di list aset)

## 4. Penyusutan Bulanan (`/ac-fa-depreciation`)

- [ ] Proses periode berjalan → status Calculated, jumlah aset & total sesuai
- [ ] Proses periode yang sama dua kali → ditolak
- [ ] Proses periode mundur → ditolak
- [ ] Proses periode baru saat periode sebelumnya masih Calculated → ditolak
- [ ] **Cek angka**: aset Garis Lurus = (perolehan − residu) / umur, dibandingkan hitungan manual 2-3 aset
- [ ] **Cek angka**: aset Saldo Menurun = nilai buku × (2/umur), dibandingkan hitungan manual
- [ ] Aset import dengan saldo awal: penyusutan melanjutkan dari akum awal, tidak mulai dari nol
- [ ] Aset yang umurnya habis di periode tsb: penyusutan = sisa (plug), akum akhir = perolehan − residu
- [ ] Generate Journal → jurnal `FA-DEPR-{periode}` muncul di `/ac-journal` (posted), debet Beban per kategori = kredit Akumulasi
- [ ] Beban penyusutan muncul di Trial Balance & Profit Loss periode tsb
- [ ] Batalkan run Calculated → bisa; batalkan run Posted → ditolak

## 5. Mutasi Aset (`/ac-fa-mutation`)

- [ ] Mutasi ke cabang lain → posisi aset berubah, riwayat tercatat
- [ ] Mutasi ke posisi yang sama → ditolak
- [ ] Aset yang sudah dilepas → tidak bisa dimutasi
- [ ] Tombol Mutasi di daftar aset membuka form dengan aset terpilih

## 6. Pelepasan Aset (`/ac-fa-disposal`)

- [ ] Jual di atas nilai buku → jurnal: debet kas + akumulasi, kredit aset + laba pelepasan; nilai cocok
- [ ] Jual di bawah nilai buku → rugi pelepasan di sisi debet; jurnal balance
- [ ] Hapus buku → rugi = nilai buku; tanpa baris kas
- [ ] Tipe Dijual tanpa akun kas / harga jual → ditolak
- [ ] Pelepasan saat ada run penyusutan Calculated → ditolak
- [ ] Setelah dilepas: status aset berubah, aset tidak ikut penyusutan periode berikutnya, tidak bisa diedit/dimutasi
- [ ] Jurnal disposal `FA-DISP-*` muncul di GL dan laba/rugi pelepasan tampil di Profit Loss

## 7. Laporan

- [ ] **Daftar Aset Tetap** (`/ac-rpt-fa-list`): total per kategori = jumlah manual; nilai buku = perolehan − akumulasi di setiap baris
- [ ] **Kartu Aset** (`/ac-rpt-fa-card`): kronologi lengkap (perolehan → saldo awal → penyusutan per bulan → mutasi → pelepasan); saldo akhir cocok dengan register
- [ ] **Rekap Penyusutan** (`/ac-rpt-fa-depr`): total kolom komersial = nilai jurnal `FA-DEPR-{periode}` di GL
- [ ] **Penyusutan Fiskal** (`/ac-rpt-fa-fiscal`): kelompok harta & umur fiskal benar; dasar fiskal = harga perolehan penuh; format sesuai kebutuhan Lampiran Khusus 1A
- [ ] **Rekonsiliasi Aset vs GL** (`/ac-rpt-fa-recon`): lihat bagian 8

## 8. Rekonsiliasi Go-Live (WAJIB SEBELUM PRODUKSI)

Prosedur migrasi saldo awal:

1. [ ] Siapkan jurnal saldo awal GL: debet akun Aset Tetap per kategori sebesar total harga perolehan, kredit akun Akumulasi Penyusutan sebesar total akumulasi (lawan: akun ekuitas saldo awal / rekening konversi) — ATAU pastikan saldo akun sudah benar dari pembukuan lama
2. [ ] Import seluruh aset via `/ac-fa-asset-import` dengan `akum_penyusutan_awal` per tanggal cut-off yang sama dengan jurnal saldo awal
3. [ ] Jalankan **Rekonsiliasi Aset vs GL** per tanggal cut-off:
   - [ ] Selisih HARGA PEROLEHAN = 0 untuk semua kategori
   - [ ] Selisih AKUMULASI PENYUSUTAN = 0 untuk semua kategori
4. [ ] Jalankan penyusutan bulan pertama pasca-migrasi → bandingkan total dengan perhitungan Excel pembukuan lama
5. [ ] Trial Balance tetap seimbang (BEGIN = 0, DEBET = CREDIT, ENDING = 0) setelah semua jurnal FA masuk

## 9. Regresi Singkat Modul Lain

- [ ] Input & posting journal manual masih normal
- [ ] Laporan GL / TB / Neraca / PL masih seimbang setelah ada jurnal FA
- [ ] Proses HPP money changer (perhitungan & generate journal) tidak terpengaruh

---

## Catatan Temuan

| No | Tanggal | Layar/Proses | Deskripsi Temuan | Severity | Status |
|----|---------|--------------|------------------|----------|--------|
| 1  |         |              |                  |          |        |
| 2  |         |              |                  |          |        |

**Sign-off UAT**

| Peran | Nama | Tanggal | Tanda Tangan |
|-------|------|---------|--------------|
| Akunting (user) | | | |
| Kepala Akunting | | | |
| IT | | | |
