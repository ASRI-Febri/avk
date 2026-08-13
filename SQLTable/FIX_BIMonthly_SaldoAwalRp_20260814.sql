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
--   Pada Laporan Bulanan BI (form B0001) yang sudah tersimpan, kolom Saldo Awal
--   Rp tidak sama dengan Saldo Akhir Rp bulan sebelumnya. Penyebabnya
--   [USP_MC_BIMonthly_Preview] dulu mengambil saldo awal rupiah dari
--   MC_T_COGSValasCalculation.BB_BaseAmount (nilai perolehan rata-rata HPP),
--   sedangkan saldo akhir dinilai memakai kurs tengah BI. Karena basisnya
--   berbeda, angkanya tidak pernah nyambung antar bulan.
--
--   Sudah dicegah: [USP_MC_BIMonthly_Preview] kini mengambil saldo awal dari
--   saldo akhir periode sebelumnya (atau, kalau periode itu belum tersimpan,
--   dari saldo akhir valas HPP bulan lalu x kurs tengah BI akhir bulan lalu).
--
-- Perbaikan:
--   HANYA kolom OpeningIDR yang diperbarui, disamakan dengan ClosingIDR periode
--   sebelumnya. Kolom lain tidak disentuh sama sekali, termasuk koreksi manual
--   admin, kurs tengah, volume beli/jual, dan saldo akhir.
--
--   Aman dan tidak merambat: ClosingForeign = OpeningForeign + Beli - Jual
--   (tidak memakai rupiah) dan ClosingIDR = ClosingForeign x MiddleRate, jadi
--   mengubah OpeningIDR tidak mengubah saldo akhir mana pun, juga tidak
--   mengubah saldo awal bulan berikutnya.
--
--   Baris hanya diperbaiki bila periode sebelumnya benar benar tersimpan
--   (RecordStatus = 'A') dan valutanya ada di periode itu. Script idempotent,
--   boleh dijalankan berulang.
-- =============================================

BEGIN TRANSACTION;

-- Pasangan periode: baris laporan vs baris periode sebelumnya untuk valuta yang sama
;WITH Pasangan AS (
	SELECT M.IDX_T_BIMonthly,
		M.ReportPeriod,
		M.CurrencyID,
		M.OpeningForeign,
		OpeningIDR_Lama	= M.OpeningIDR,
		OpeningIDR_Baru	= P.ClosingIDR,
		P.ClosingForeign
	FROM MC_T_BIMonthly M
		INNER JOIN MC_T_BIMonthly P
			ON RTRIM(ISNULL(P.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
			AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
			AND P.ReportPeriod = CONVERT(VARCHAR(6),
					DATEADD(MONTH, -1, DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1)), 112)
	WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
)
SELECT 'SEBELUM' AS Tahap, ReportPeriod, CurrencyID, OpeningForeign,
	OpeningIDR_Lama, OpeningIDR_Baru,
	Selisih = OpeningIDR_Baru - OpeningIDR_Lama
INTO #Koreksi
FROM Pasangan
WHERE ABS(OpeningIDR_Lama - OpeningIDR_Baru) > 0.01

SELECT * FROM #Koreksi ORDER BY ReportPeriod, CurrencyID

SELECT 'RINGKASAN' AS Tahap, ReportPeriod, JumlahBaris = COUNT(*), TotalSelisih = SUM(Selisih)
FROM #Koreksi GROUP BY ReportPeriod ORDER BY ReportPeriod

-- ---------------------------------------------------------------------------
-- KOREKSI: hanya kolom OpeningIDR
-- ---------------------------------------------------------------------------
UPDATE M SET
	 M.OpeningIDR	= P.ClosingIDR
	,M.UModified	= 'FIX-BISALDOAWAL-20260814'
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
-- SESUDAH: sisa yang belum nyambung (harus 0)
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH' AS Tahap, SisaTidakNyambung = COUNT(*)
FROM MC_T_BIMonthly M
	INNER JOIN MC_T_BIMonthly P
		ON RTRIM(ISNULL(P.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
		AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
		AND P.ReportPeriod = CONVERT(VARCHAR(6),
				DATEADD(MONTH, -1, DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1)), 112)
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND ABS(M.OpeningIDR - P.ClosingIDR) > 0.01

-- ---------------------------------------------------------------------------
-- PERLU DICEK MANUAL: baris yang periode sebelumnya belum tersimpan, atau
-- valutanya belum ada di periode sebelumnya, padahal saldo awalnya tidak nol.
-- Baris seperti ini sengaja TIDAK disentuh script.
-- ---------------------------------------------------------------------------
SELECT 'PERLU DICEK' AS Tahap, M.ReportPeriod, M.CurrencyID, M.OpeningForeign, M.OpeningIDR
FROM MC_T_BIMonthly M
WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	AND (M.OpeningForeign <> 0 OR M.OpeningIDR <> 0)
	AND NOT EXISTS (
		SELECT 1 FROM MC_T_BIMonthly P
		WHERE RTRIM(ISNULL(P.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
			AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'
			AND P.ReportPeriod = CONVERT(VARCHAR(6),
					DATEADD(MONTH, -1, DATEFROMPARTS(LEFT(M.ReportPeriod,4), RIGHT(M.ReportPeriod,2), 1)), 112))
ORDER BY M.ReportPeriod, M.CurrencyID

DROP TABLE #Koreksi

COMMIT TRANSACTION;
GO
