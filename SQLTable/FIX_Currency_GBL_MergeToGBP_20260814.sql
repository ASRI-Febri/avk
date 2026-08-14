USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Penggabungan currency, 14 Agustus 2026
--
-- Masalah:
--   MC_M_Currency punya dua currency untuk mata uang yang sama:
--     IDX 18   = GBP "Poundsterling"       (kode ISO, benar)
--     IDX 1020 = GBL "POUNDSTERLING LAMA"  (kode karangan, tidak standar)
--
--   GBL dipakai untuk membedakan uang kertas lama, tapi keduanya memakai COA
--   yang sama (COGS 135, Pembelian 134, Penjualan 133) sehingga di GL memang
--   sudah tergabung. Akibat kode tidak standar, Laporan Bulanan BI periode Mei
--   sampai Juli 2026 ditolak website Bank Indonesia.
--
--   Kode GBL juga tidak pernah ada di MC_T_BIMiddleRate, sehingga baris GBL di
--   laporan BI selama ini memakai kurs master (22.500 + 0) / 2 = 11.250, bukan
--   kurs tengah BI.
--
-- Perbaikan:
--   1. Pecahan GBL-20 dan GBL-50 dipindahkan ke currency GBP (IDX 18). Angka
--      pengali pecahannya sudah sama (20 dan 50), jadi kartu stok, HPP, dan
--      jurnal tetap benar. SKU-nya diganti GBP-20L / GBP-50L supaya tidak ada
--      lagi kode GBL, tetapi tetap terpisah sebagai pecahan uang lama.
--   2. Baris hasil Perhitungan HPP untuk kedua pecahan itu ikut dipindah ke
--      currency GBP, supaya kalau laporan BI dihitung ulang volumenya tetap
--      masuk ke GBP, tidak hilang.
--   3. Currency 1020 dinonaktifkan (RecordStatus = 'N'), TIDAK dihapus, karena
--      masih menjadi rujukan historis.
--   4. Baris GBL di MC_T_BIMonthly digabung ke baris GBP periode yang sama:
--      volume pembelian dan penjualan dijumlahkan, lalu baris GBL dihapus.
--      Saldo awal dan saldo akhir GBL nol di semua periode, jadi saldo akhir
--      GBP tidak berubah, hanya kolom volume yang bertambah.
--
-- Transaksi (MC_T_PurchaseOrderDetail, MC_T_SalesOrderDetail, kartu stok,
-- jurnal) menyimpan IDX_M_Valas, bukan kode currency, jadi tidak perlu diubah.
-- =============================================

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- SEBELUM
-- ---------------------------------------------------------------------------
SELECT 'SEBELUM - CURRENCY' AS Tahap, IDX_M_Currency, CurrencyID, CurrencyName, RecordStatus
FROM MC_M_Currency WHERE IDX_M_Currency IN (18, 1020)

SELECT 'SEBELUM - VALAS' AS Tahap, IDX_M_Valas, ValasSKU, ValasName, IDX_M_Currency
FROM MC_M_Valas WHERE IDX_M_Currency IN (18, 1020) ORDER BY IDX_M_Currency, IDX_M_Valas

SELECT 'SEBELUM - LAPORAN BI' AS Tahap, ReportPeriod, CurrencyID,
	OpeningForeign, BuyForeign, SellForeign, ClosingForeign, MiddleRate, ClosingIDR
FROM MC_T_BIMonthly WHERE CurrencyID IN ('GBP','GBL') AND RTRIM(ISNULL(RecordStatus,'')) = 'A'
ORDER BY ReportPeriod, CurrencyID

-- ---------------------------------------------------------------------------
-- 1. PECAHAN GBL PINDAH KE CURRENCY GBP
-- ---------------------------------------------------------------------------
UPDATE MC_M_Valas SET
	 IDX_M_Currency	= 18
	,ValasSKU		= REPLACE(RTRIM(ValasSKU), 'GBL-', 'GBP-') + 'L'
	,UModified		= 'FIX-GBL-20260814'
	,DModified		= GETDATE()
WHERE IDX_M_Currency = 1020

-- ---------------------------------------------------------------------------
-- 2. HASIL PERHITUNGAN HPP IKUT PINDAH KE CURRENCY GBP
-- ---------------------------------------------------------------------------
UPDATE MC_T_COGSValasCalculation SET
	 IDX_M_Currency	= 18
	,UModified		= 'FIX-GBL-20260814'
	,DModified		= GETDATE()
WHERE IDX_M_Currency = 1020

-- ---------------------------------------------------------------------------
-- 3. CURRENCY GBL DINONAKTIFKAN
-- ---------------------------------------------------------------------------
UPDATE MC_M_Currency SET
	 RecordStatus	= 'N'
	,CurrencyName	= 'POUNDSTERLING LAMA - KE GBP'
	,UModified		= 'FIX-GBL-20260814'
	,DModified		= GETDATE()
WHERE IDX_M_Currency = 1020

-- ---------------------------------------------------------------------------
-- 4. LAPORAN BULANAN BI: VOLUME GBL DIGABUNG KE BARIS GBP
-- ---------------------------------------------------------------------------
UPDATE G SET
	 G.BuyForeign	= G.BuyForeign  + L.BuyForeign
	,G.BuyIDR		= G.BuyIDR      + L.BuyIDR
	,G.SellForeign	= G.SellForeign + L.SellForeign
	,G.SellIDR		= G.SellIDR     + L.SellIDR
	,G.UModified	= 'FIX-GBL-20260814'
	,G.DModified	= GETDATE()
FROM MC_T_BIMonthly G
	INNER JOIN MC_T_BIMonthly L
		ON L.ReportPeriod = G.ReportPeriod
		AND RTRIM(ISNULL(L.CurrencyID,'')) = 'GBL'
		AND RTRIM(ISNULL(L.RecordStatus,'')) = 'A'
WHERE RTRIM(ISNULL(G.CurrencyID,'')) = 'GBP'
	AND RTRIM(ISNULL(G.RecordStatus,'')) = 'A'

-- Baris GBL yang periodenya TIDAK punya baris GBP: ubah kodenya saja, jangan dibuang
UPDATE MC_T_BIMonthly SET
	 CurrencyID		= 'GBP'
	,UModified		= 'FIX-GBL-20260814'
	,DModified		= GETDATE()
WHERE RTRIM(ISNULL(CurrencyID,'')) = 'GBL'
	AND RTRIM(ISNULL(RecordStatus,'')) = 'A'
	AND NOT EXISTS (SELECT 1 FROM MC_T_BIMonthly G
					WHERE G.ReportPeriod = MC_T_BIMonthly.ReportPeriod
						AND RTRIM(ISNULL(G.CurrencyID,'')) = 'GBP'
						AND RTRIM(ISNULL(G.RecordStatus,'')) = 'A')

-- Sisanya (yang volumenya sudah dipindah ke baris GBP) dihapus
DELETE FROM MC_T_BIMonthly
WHERE RTRIM(ISNULL(CurrencyID,'')) = 'GBL'

-- ---------------------------------------------------------------------------
-- SESUDAH
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH - CURRENCY' AS Tahap, IDX_M_Currency, CurrencyID, CurrencyName, RecordStatus
FROM MC_M_Currency WHERE IDX_M_Currency IN (18, 1020)

SELECT 'SESUDAH - VALAS' AS Tahap, IDX_M_Valas, ValasSKU, ValasName, IDX_M_Currency
FROM MC_M_Valas WHERE IDX_M_Currency IN (18, 1020) ORDER BY IDX_M_Valas

SELECT 'SESUDAH - LAPORAN BI' AS Tahap, ReportPeriod, CurrencyID,
	OpeningForeign, BuyForeign, SellForeign, ClosingForeign, MiddleRate, ClosingIDR
FROM MC_T_BIMonthly WHERE CurrencyID = 'GBP' AND RTRIM(ISNULL(RecordStatus,'')) = 'A'
ORDER BY ReportPeriod

-- Harus 0: sisa kode GBL di mana pun
SELECT 'SESUDAH - SISA KODE GBL' AS Tahap,
	DiMaster	= (SELECT COUNT(*) FROM MC_M_Currency WHERE RTRIM(ISNULL(CurrencyID,'')) = 'GBL' AND RTRIM(ISNULL(RecordStatus,'')) = 'A'),
	DiLaporanBI	= (SELECT COUNT(*) FROM MC_T_BIMonthly WHERE RTRIM(ISNULL(CurrencyID,'')) = 'GBL'),
	DiValas		= (SELECT COUNT(*) FROM MC_M_Valas WHERE ValasSKU LIKE 'GBL%')

-- Harus 0: periode dengan kode valuta ganda di laporan BI
SELECT 'SESUDAH - KODE GANDA' AS Tahap, ReportPeriod, CurrencyID, Jumlah = COUNT(*)
FROM MC_T_BIMonthly WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'
GROUP BY ReportPeriod, CurrencyID HAVING COUNT(*) > 1

COMMIT TRANSACTION;
GO
