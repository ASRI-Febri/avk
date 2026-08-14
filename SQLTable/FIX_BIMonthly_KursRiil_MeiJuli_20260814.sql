USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Perbaikan data, 14 Agustus 2026
--
-- Masalah:
--   Laporan Bulanan BI yang tersimpan memakai rata rata kurs papan master untuk
--   valuta yang tidak ada di daftar kurs transaksi BI (INR, MOP, QAR, TRY, TWD).
--   Pedoman LKPBU mengharuskan kurs tengah untuk valuta seperti itu memakai
--   kurs riil transaksi Penyelenggara KUPVA Bukan Bank.
--
--   Pencegahan sudah dipasang di [USP_MC_BIMonthly_Preview]: urutan sumber kurs
--   menjadi BI -> RIIL (kurs riil transaksi) -> MASTER.
--
-- Cakupan:
--   HANYA periode 202605 sampai 202607, yaitu laporan yang ditolak Bank
--   Indonesia dan akan dikirim ulang. Maret dan April sengaja TIDAK disentuh
--   karena sudah diterima BI dengan angka lama.
--
-- Perbaikan:
--   1. MiddleRate diisi kurs riil transaksi: titik tengah kurs beli riil dan
--      kurs jual riil pada periode itu. Kalau hanya ada satu sisi, sisi itu yang
--      dipakai. Kalau periode itu tidak ada transaksi, dipakai periode terakhir
--      yang ada transaksinya. Hanya baris yang memang tidak punya kurs BI.
--   2. ClosingIDR dihitung ulang = ClosingForeign x kurs (JPY dibagi 100).
--   3. Saldo awal rupiah periode berikutnya diselaraskan lagi dengan saldo akhir
--      periode sebelumnya, supaya rantai antar bulan tetap nyambung.
--
--   Volume beli/jual dan saldo valas tidak disentuh sama sekali.
-- =============================================

BEGIN TRANSACTION;

DECLARE @Dari VARCHAR(6) = '202605'
DECLARE @Sampai VARCHAR(6) = '202607'

-- ---------------------------------------------------------------------------
-- Kurs riil transaksi per valuta per periode (sama dengan logika di SP preview)
-- ---------------------------------------------------------------------------
SELECT X.IDX_M_Currency, X.Periode,
	KursTengah = CASE
		WHEN SUM(X.BeliValas) > 0 AND SUM(X.JualValas) > 0
			THEN ((SUM(X.BeliRupiah) / SUM(X.BeliValas)) + (SUM(X.JualRupiah) / SUM(X.JualValas))) / 2
		WHEN SUM(X.BeliValas) > 0 THEN SUM(X.BeliRupiah) / SUM(X.BeliValas)
		WHEN SUM(X.JualValas) > 0 THEN SUM(X.JualRupiah) / SUM(X.JualValas)
	END
INTO #KursRiil
FROM (
	SELECT V.IDX_M_Currency, Periode = LEFT(CONVERT(VARCHAR, O.PODate, 112), 6),
		BeliValas = D.ForeignAmount, BeliRupiah = D.BaseCurrencyAmount, JualValas = 0, JualRupiah = 0
	FROM MC_T_PurchaseOrderDetail D WITH(NOLOCK)
		INNER JOIN MC_T_PurchaseOrder O WITH(NOLOCK) ON O.IDX_T_PurchaseOrder = D.IDX_T_PurchaseOrder
		INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = D.IDX_M_Valas
	WHERE O.POStatus = 'A' AND D.ForeignAmount > 0 AND D.BaseCurrencyAmount > 0
	UNION ALL
	SELECT V.IDX_M_Currency, LEFT(CONVERT(VARCHAR, O.SODate, 112), 6),
		0, 0, D.ForeignAmount, D.BaseCurrencyAmount
	FROM MC_T_SalesOrderDetail D WITH(NOLOCK)
		INNER JOIN MC_T_SalesOrder O WITH(NOLOCK) ON O.IDX_T_SalesOrder = D.IDX_T_SalesOrder
		INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = D.IDX_M_Valas
	WHERE O.SOStatus = 'A' AND D.ForeignAmount > 0 AND D.BaseCurrencyAmount > 0
) X
GROUP BY X.IDX_M_Currency, X.Periode

-- Kurs yang berlaku untuk tiap baris laporan yang akan dikoreksi
SELECT M.IDX_T_BIMonthly, M.ReportPeriod, M.CurrencyID, M.ClosingForeign,
	KursLama = M.MiddleRate,
	AkhirRpLama = M.ClosingIDR,
	KursBaru = COALESCE(
		-- kurs riil periode laporan
		(SELECT K.KursTengah FROM #KursRiil K
		 WHERE K.IDX_M_Currency = C.IDX_M_Currency AND K.Periode = M.ReportPeriod AND K.KursTengah > 0),
		-- kalau tidak ada transaksi, kurs riil periode terakhir sebelum itu
		(SELECT TOP 1 K.KursTengah FROM #KursRiil K
		 WHERE K.IDX_M_Currency = C.IDX_M_Currency AND K.Periode <= M.ReportPeriod AND K.KursTengah > 0
		 ORDER BY K.Periode DESC))
INTO #Koreksi
FROM MC_T_BIMonthly M
	INNER JOIN MC_M_Currency C ON RTRIM(ISNULL(C.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
		AND RTRIM(ISNULL(C.RecordStatus,'')) = 'A'
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND M.ReportPeriod BETWEEN @Dari AND @Sampai
	-- hanya valuta yang tidak ada di daftar kurs transaksi BI
	AND NOT EXISTS (SELECT 1 FROM MC_T_BIMiddleRate R
					WHERE RTRIM(ISNULL(R.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
						AND R.RateDate = EOMONTH(DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1))
						AND RTRIM(ISNULL(R.RecordStatus,'')) = 'A')

DELETE FROM #Koreksi WHERE KursBaru IS NULL OR ABS(KursBaru - KursLama) < 0.000001

SELECT 'AKAN DIKOREKSI' AS Tahap, ReportPeriod, CurrencyID, ClosingForeign,
	KursLama, KursBaru, AkhirRpLama,
	AkhirRpBaru = CASE WHEN RTRIM(CurrencyID) = 'JPY' THEN (ClosingForeign * KursBaru) / 100 ELSE ClosingForeign * KursBaru END
FROM #Koreksi ORDER BY ReportPeriod, CurrencyID

-- ---------------------------------------------------------------------------
-- 1 & 2. KURS DAN SALDO AKHIR RUPIAH
-- ---------------------------------------------------------------------------
-- Kurs dibulatkan 4 desimal dulu, baru dipakai menghitung saldo akhir rupiah.
-- File TXT ke BI hanya memuat kurs 4 desimal (kurs x 10000), jadi kalau saldo
-- akhir dihitung dari kurs presisi penuh, hasil rekonsiliasi BI akan meleset
-- beberapa rupiah.
UPDATE M SET
	 M.MiddleRate	= ROUND(K.KursBaru, 4)
	,M.ClosingIDR	= CASE WHEN RTRIM(ISNULL(M.CurrencyID,'')) = 'JPY'
						THEN (M.ClosingForeign * ROUND(K.KursBaru, 4)) / 100
						ELSE M.ClosingForeign * ROUND(K.KursBaru, 4) END
	,M.UModified	= 'FIX-KURSRIIL-20260814'
	,M.DModified	= GETDATE()
FROM MC_T_BIMonthly M
	INNER JOIN #Koreksi K ON K.IDX_T_BIMonthly = M.IDX_T_BIMonthly

-- ---------------------------------------------------------------------------
-- 3. RANTAI SALDO: saldo awal rupiah = saldo akhir rupiah periode sebelumnya
-- ---------------------------------------------------------------------------
UPDATE M SET
	 M.OpeningIDR	= P.ClosingIDR
	,M.UModified	= 'FIX-KURSRIIL-20260814'
	,M.DModified	= GETDATE()
FROM MC_T_BIMonthly M
	INNER JOIN MC_T_BIMonthly P
		ON RTRIM(ISNULL(P.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
		AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
		AND P.ReportPeriod = CONVERT(VARCHAR(6),
				DATEADD(MONTH, -1, DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1)), 112)
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND ABS(M.OpeningIDR - P.ClosingIDR) > 0.01

-- ---------------------------------------------------------------------------
-- SESUDAH
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH' AS Tahap, M.ReportPeriod, M.CurrencyID, M.OpeningForeign, M.OpeningIDR,
	M.ClosingForeign, M.MiddleRate, M.ClosingIDR
FROM MC_T_BIMonthly M
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND M.CurrencyID IN (SELECT CurrencyID FROM #Koreksi)
	AND M.ReportPeriod BETWEEN @Dari AND @Sampai
ORDER BY M.CurrencyID, M.ReportPeriod

-- Harus 0: saldo awal yang tidak sama dengan saldo akhir bulan sebelumnya
SELECT 'SESUDAH - RANTAI TIDAK NYAMBUNG' AS Tahap, SisaTidakNyambung = COUNT(*)
FROM MC_T_BIMonthly M
	INNER JOIN MC_T_BIMonthly P
		ON RTRIM(ISNULL(P.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
		AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
		AND P.ReportPeriod = CONVERT(VARCHAR(6),
				DATEADD(MONTH, -1, DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1)), 112)
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND ABS(M.OpeningIDR - P.ClosingIDR) > 0.01

DROP TABLE #Koreksi
DROP TABLE #KursRiil

COMMIT TRANSACTION;
GO
