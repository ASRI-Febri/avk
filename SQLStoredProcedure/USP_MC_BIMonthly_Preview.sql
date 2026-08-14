USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Hitung usulan angka Laporan Bulanan BI (form B0001) per jenis valuta.
--
--				MODE UTAMA (HasCOGS = 1): angka diambil dari hasil Perhitungan HPP
--				(MC_T_COGSValasCalculation) periode laporan, sehingga PASTI konsisten
--				dengan closing bulanan, jurnal HPP, neraca, dan laba rugi:
--				  - Saldo awal        : saldo akhir periode sebelumnya (lihat blok
--				                        SALDO AWAL di bawah), bukan BB_BaseAmount HPP
--				  - Volume pembelian  : IN_ForeignAmount / IN_BaseAmount (PO stok valas)
--				  - Volume penjualan  : Sold_ForeignAmount / Sold_BaseAmount
--				  - Saldo akhir valas : saldo awal + pembelian - penjualan (rumus form B0001,
--				                        identik dengan EB_Qty = BB + IN - Sold di HPP)
--
--				MODE FALLBACK (HasCOGS = 0): HPP periode laporan belum diproses; angka
--				dihitung langsung dari transaksi MEMAKAI METODE YANG SAMA dengan
--				USP_MC_COGSValasCalculation (IN = PO, Sold = seluruh MC_T_SalesOrderDetail
--				dengan ForeignAmount > 0 dan BaseCurrencyAmount > 0), saldo awal dari
--				EB HPP periode sebelumnya. Proses HPP dulu agar angka final.
--
--				Kurs tengah: dari MC_T_BIMiddleRate (upload website BI) pada tanggal
--				akhir bulan periode laporan (RateSource = 'BI'). Untuk valuta yang tidak
--				ada di daftar kurs transaksi BI, dipakai kurs riil transaksi sendiri
--				(RateSource = 'RIIL') sesuai pedoman LKPBU. Master hanya dipakai kalau
--				valuta itu belum pernah ditransaksikan (RateSource = 'MASTER').
--				Semua kurs masih bisa dikoreksi admin di layar preview.
--				JPY memakai satuan per 100 mengikuti publikasi BI, dan saldo akhir
--				rupiahnya otomatis dibagi 100.
-- =============================================

-- EXEC USP_MC_BIMonthly_Preview '202603'

IF OBJECT_ID('[dbo].[USP_MC_BIMonthly_Preview]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_BIMonthly_Preview]
GO

CREATE PROCEDURE [dbo].[USP_MC_BIMonthly_Preview]
	@ReportPeriod		VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate	DATE = DATEFROMPARTS(CAST(LEFT(@ReportPeriod,4) AS INT), CAST(RIGHT(@ReportPeriod,2) AS INT), 1)
	DECLARE @EndDate	DATE = EOMONTH(@StartDate)
	DECLARE @PrevPeriod	VARCHAR(6) = CONVERT(VARCHAR(6), DATEADD(MONTH, -1, @StartDate), 112)

	DECLARE @HasCOGS	BIT = 0
	IF EXISTS (SELECT 1 FROM MC_T_COGSValasCalculation WHERE COGSPeriod = @ReportPeriod)
		SET @HasCOGS = 1

	CREATE TABLE #Data (
		IDX_M_Currency		INT,
		CurrencyID			VARCHAR(3),
		CurrencyName		VARCHAR(50),
		OpeningForeign		DECIMAL(18,2),
		OpeningIDR			DECIMAL(18,2),
		BuyForeign			DECIMAL(18,2),
		BuyIDR				DECIMAL(18,2),
		SellForeign			DECIMAL(18,2),
		SellIDR				DECIMAL(18,2),
		MiddleRate			DECIMAL(18,4),
		RateSource			VARCHAR(6),
		OpeningSource		VARCHAR(6)
	)

	INSERT INTO #Data
	SELECT C.IDX_M_Currency, RTRIM(ISNULL(C.CurrencyID,'')), RTRIM(ISNULL(C.CurrencyName,'')),
		0, 0, 0, 0, 0, 0,
		(ISNULL(C.BuyRate,0) + ISNULL(C.SellRate,0)) / 2,
		'MASTER',
		'HPP'
	FROM MC_M_Currency C
	WHERE RTRIM(ISNULL(C.Recordstatus,'')) = 'A'
		AND RTRIM(ISNULL(C.CurrencyID,'')) <> ''
		AND RTRIM(ISNULL(C.CurrencyID,'')) <> 'IDR'

	-- ============================================================
	-- KURS TENGAH, URUTAN SUMBER:
	--   1. BI     : upload website BI pada tanggal akhir bulan periode laporan
	--   2. RIIL   : kurs riil transaksi penyelenggara, sesuai pedoman LKPBU:
	--               "Jika mata uang yang bersangkutan tidak ada pada daftar kurs
	--               transaksi BI, maka kurs tengah untuk mata uang tersebut
	--               menggunakan kurs riil transaksi Penyelenggara KUPVA Bukan Bank"
	--               (mis. INR, MOP, QAR, TRY, TWD)
	--   3. MASTER : rata rata kurs papan master, hanya kalau valuta itu belum
	--               pernah ditransaksikan sama sekali
	-- ============================================================
	UPDATE #Data SET MiddleRate = R.MiddleRate, RateSource = 'BI'
	FROM MC_T_BIMiddleRate R
	INNER JOIN #Data ON #Data.CurrencyID = RTRIM(ISNULL(R.CurrencyID,''))
	WHERE R.RateDate = @EndDate
		AND RTRIM(ISNULL(R.RecordStatus,'')) = 'A'

	-- (2) KURS RIIL TRANSAKSI PENYELENGGARA, untuk valuta yang tidak ada di
	-- daftar kurs transaksi BI (mis. INR, MOP, QAR, TRY, TWD).
	-- Kurs tengah = titik tengah antara kurs beli riil dan kurs jual riil
	-- pada periode laporan, dihitung dari nilai rupiah dibagi nominal valuta
	-- transaksi yang sudah Approved. Kalau hanya ada satu sisi, sisi itu yang
	-- dipakai. Kalau periode laporan tidak ada transaksi sama sekali, dipakai
	-- kurs riil dari periode terakhir yang ada transaksinya.
	CREATE TABLE #KursRiil (
		IDX_M_Currency	INT,
		Periode			VARCHAR(6),
		KursBeli		DECIMAL(18,6),
		KursJual		DECIMAL(18,6),
		KursTengah		DECIMAL(18,6)
	)

	INSERT INTO #KursRiil (IDX_M_Currency, Periode, KursBeli, KursJual, KursTengah)
	SELECT X.IDX_M_Currency, X.Periode,
		KursBeli	= CASE WHEN SUM(X.BeliValas) > 0 THEN SUM(X.BeliRupiah) / SUM(X.BeliValas) END,
		KursJual	= CASE WHEN SUM(X.JualValas) > 0 THEN SUM(X.JualRupiah) / SUM(X.JualValas) END,
		KursTengah	= CASE
			WHEN SUM(X.BeliValas) > 0 AND SUM(X.JualValas) > 0
				THEN ((SUM(X.BeliRupiah) / SUM(X.BeliValas)) + (SUM(X.JualRupiah) / SUM(X.JualValas))) / 2
			WHEN SUM(X.BeliValas) > 0 THEN SUM(X.BeliRupiah) / SUM(X.BeliValas)
			WHEN SUM(X.JualValas) > 0 THEN SUM(X.JualRupiah) / SUM(X.JualValas)
		END
	FROM (
		SELECT V.IDX_M_Currency, Periode = LEFT(CONVERT(VARCHAR, O.PODate, 112), 6),
			BeliValas = D.ForeignAmount, BeliRupiah = D.BaseCurrencyAmount,
			JualValas = 0, JualRupiah = 0
		FROM MC_T_PurchaseOrderDetail D WITH(NOLOCK)
			INNER JOIN MC_T_PurchaseOrder O WITH(NOLOCK) ON O.IDX_T_PurchaseOrder = D.IDX_T_PurchaseOrder
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = D.IDX_M_Valas
		WHERE O.POStatus = 'A' AND O.PODate <= @EndDate
			AND D.ForeignAmount > 0 AND D.BaseCurrencyAmount > 0
		UNION ALL
		SELECT V.IDX_M_Currency, LEFT(CONVERT(VARCHAR, O.SODate, 112), 6),
			0, 0, D.ForeignAmount, D.BaseCurrencyAmount
		FROM MC_T_SalesOrderDetail D WITH(NOLOCK)
			INNER JOIN MC_T_SalesOrder O WITH(NOLOCK) ON O.IDX_T_SalesOrder = D.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = D.IDX_M_Valas
		WHERE O.SOStatus = 'A' AND O.SODate <= @EndDate
			AND D.ForeignAmount > 0 AND D.BaseCurrencyAmount > 0
	) X
	GROUP BY X.IDX_M_Currency, X.Periode

	-- (2a) kurs riil periode laporan
	UPDATE #Data SET
		MiddleRate	= CASE WHEN #Data.CurrencyID = 'JPY' THEN K.KursTengah * 100 ELSE K.KursTengah END,
		RateSource	= 'RIIL'
	FROM #KursRiil K
	INNER JOIN #Data ON #Data.IDX_M_Currency = K.IDX_M_Currency
	WHERE #Data.RateSource <> 'BI' AND K.Periode = @ReportPeriod AND K.KursTengah > 0

	-- (2b) belum ada transaksi di periode laporan: pakai periode terakhir yang ada
	UPDATE #Data SET
		MiddleRate	= CASE WHEN #Data.CurrencyID = 'JPY' THEN K.KursTengah * 100 ELSE K.KursTengah END,
		RateSource	= 'RIIL'
	FROM (
		SELECT R.IDX_M_Currency, R.KursTengah
		FROM #KursRiil R
			INNER JOIN (SELECT IDX_M_Currency, Periode = MAX(Periode) FROM #KursRiil
						WHERE KursTengah > 0 AND Periode <= @ReportPeriod
						GROUP BY IDX_M_Currency) L
				ON L.IDX_M_Currency = R.IDX_M_Currency AND L.Periode = R.Periode
	) K
	INNER JOIN #Data ON #Data.IDX_M_Currency = K.IDX_M_Currency
	WHERE #Data.RateSource NOT IN ('BI','RIIL') AND K.KursTengah > 0

	IF @HasCOGS = 1
	BEGIN
		-- ============================================================
		-- MODE UTAMA: AMBIL DARI HASIL PERHITUNGAN HPP PERIODE LAPORAN
		-- ============================================================
		UPDATE #Data SET
			OpeningForeign	= H.BB_F,
			OpeningIDR		= H.BB_B,
			BuyForeign		= H.IN_F,
			BuyIDR			= H.IN_B,
			SellForeign		= H.Sold_F,
			SellIDR			= H.Sold_B
		FROM (
			SELECT IDX_M_Currency,
				SUM(ISNULL(BB_ForeignAmount,0))		AS BB_F,
				SUM(ISNULL(BB_BaseAmount,0))		AS BB_B,
				SUM(ISNULL(IN_ForeignAmount,0))		AS IN_F,
				SUM(ISNULL(IN_BaseAmount,0))		AS IN_B,
				SUM(ISNULL(Sold_ForeignAmount,0))	AS Sold_F,
				SUM(ISNULL(Sold_BaseAmount,0))		AS Sold_B
			FROM MC_T_COGSValasCalculation
			WHERE COGSPeriod = @ReportPeriod
			GROUP BY IDX_M_Currency
		) H
		INNER JOIN #Data ON #Data.IDX_M_Currency = H.IDX_M_Currency
	END
	ELSE
	BEGIN
		-- ============================================================
		-- MODE FALLBACK: HPP BELUM DIPROSES - HITUNG DARI TRANSAKSI
		-- DENGAN METODE YANG SAMA DENGAN USP_MC_COGSValasCalculation
		-- ============================================================

		-- SALDO AWAL: SALDO AKHIR (EB) HPP PERIODE SEBELUMNYA
		UPDATE #Data SET OpeningForeign = BB.F, OpeningIDR = BB.B
		FROM (
			SELECT IDX_M_Currency, SUM(ISNULL(EB_ForeignAmount,0)) AS F, SUM(ISNULL(EB_BaseAmount,0)) AS B
			FROM MC_T_COGSValasCalculation
			WHERE COGSPeriod = @PrevPeriod
			GROUP BY IDX_M_Currency
		) BB
		INNER JOIN #Data ON #Data.IDX_M_Currency = BB.IDX_M_Currency

		-- VOLUME PEMBELIAN: PO STOK VALAS (SAMA DENGAN "IN" DI HPP)
		UPDATE #Data SET BuyForeign = T.F, BuyIDR = T.B
		FROM (
			SELECT V.IDX_M_Currency,
				SUM(ISNULL(SD.ForeignAmount,0)) AS F,
				SUM(ISNULL(SD.BaseCurrencyAmount,0)) AS B
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
			WHERE YEAR(S.PODate) = LEFT(@ReportPeriod, 4) AND MONTH(S.PODate) = RIGHT(@ReportPeriod, 2)
				AND S.POStatus = 'A'
				AND SD.ForeignAmount > 0
				AND SD.BaseCurrencyAmount > 0
			GROUP BY V.IDX_M_Currency
		) T
		INNER JOIN #Data ON #Data.IDX_M_Currency = T.IDX_M_Currency

		-- VOLUME PENJUALAN: SELURUH DETAIL SALES ORDER (SAMA DENGAN "Sold" DI HPP)
		UPDATE #Data SET SellForeign = T.F, SellIDR = T.B
		FROM (
			SELECT V.IDX_M_Currency,
				SUM(ISNULL(SD.ForeignAmount,0)) AS F,
				SUM(ISNULL(SD.BaseCurrencyAmount,0)) AS B
			FROM MC_T_SalesOrder S
			LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
			WHERE YEAR(S.SODate) = LEFT(@ReportPeriod, 4) AND MONTH(S.SODate) = RIGHT(@ReportPeriod, 2)
				AND S.SOStatus = 'A'
				AND SD.ForeignAmount > 0
				AND SD.BaseCurrencyAmount > 0
			GROUP BY V.IDX_M_Currency
		) T
		INNER JOIN #Data ON #Data.IDX_M_Currency = T.IDX_M_Currency
	END

	-- ============================================================
	-- SALDO AWAL HARUS SAMA DENGAN SALDO AKHIR PERIODE SEBELUMNYA
	--
	-- Saldo awal valas & rupiah tidak boleh diambil dari nilai perolehan HPP
	-- (BB_BaseAmount), karena saldo akhir di form B0001 dinilai dengan kurs
	-- tengah BI. Kalau basisnya beda, saldo awal bulan ini tidak akan pernah
	-- sama dengan saldo akhir bulan lalu. Rupiah saldo awal SENGAJA tetap
	-- memakai kurs tengah periode SEBELUMNYA, bukan kurs periode laporan.
	--
	--   (a) Kalau laporan periode sebelumnya sudah tersimpan, pakai angka itu
	--       apa adanya, karena itulah yang sudah dilaporkan ke Bank Indonesia
	--       (termasuk koreksi manual yang dilakukan admin di layar preview).
	--   (b) Kalau belum tersimpan, hitung: saldo akhir valas periode sebelumnya
	--       (EB hasil Perhitungan HPP) x kurs tengah BI akhir bulan sebelumnya.
	-- ============================================================
	DECLARE @PrevEndDate DATE = EOMONTH(DATEADD(MONTH, -1, @StartDate))

	-- (a) DARI LAPORAN PERIODE SEBELUMNYA YANG SUDAH TERSIMPAN
	UPDATE #Data SET
		OpeningForeign	= ISNULL(P.ClosingForeign,0),
		OpeningIDR		= ISNULL(P.ClosingIDR,0),
		OpeningSource	= 'SAVED'
	FROM MC_T_BIMonthly P
	INNER JOIN #Data ON #Data.CurrencyID = RTRIM(ISNULL(P.CurrencyID,''))
	WHERE P.ReportPeriod = @PrevPeriod
		AND RTRIM(ISNULL(P.RecordStatus,'')) = 'A'

	-- (b) BELUM TERSIMPAN: SALDO AKHIR VALAS HPP BULAN LALU x KURS TENGAH BI BULAN LALU
	UPDATE #Data SET
		OpeningForeign	= X.EB_F,
		OpeningIDR		= CASE WHEN #Data.CurrencyID = 'JPY'
							THEN (X.EB_F * X.PrevRate) / 100
							ELSE X.EB_F * X.PrevRate END,
		OpeningSource	= 'HITUNG'
	FROM (
		SELECT E.IDX_M_Currency,
			EB_F = SUM(ISNULL(E.EB_ForeignAmount,0)),
			PrevRate = ISNULL(
				(SELECT TOP 1 R.MiddleRate FROM MC_T_BIMiddleRate R
				 WHERE RTRIM(ISNULL(R.CurrencyID,'')) = RTRIM(ISNULL(MC.CurrencyID,''))
					AND R.RateDate = @PrevEndDate
					AND RTRIM(ISNULL(R.RecordStatus,'')) = 'A'),
				(ISNULL(MC.BuyRate,0) + ISNULL(MC.SellRate,0)) / 2)
		FROM MC_T_COGSValasCalculation E
		INNER JOIN MC_M_Currency MC ON MC.IDX_M_Currency = E.IDX_M_Currency
		WHERE E.COGSPeriod = @PrevPeriod
		GROUP BY E.IDX_M_Currency, MC.CurrencyID, MC.BuyRate, MC.SellRate
	) X
	INNER JOIN #Data ON #Data.IDX_M_Currency = X.IDX_M_Currency
	WHERE #Data.OpeningSource <> 'SAVED'

	-- Periode paling awal (belum ada bulan sebelumnya): saldo awal nol
	UPDATE #Data SET OpeningForeign = 0, OpeningIDR = 0, OpeningSource = 'NIHIL'
	WHERE OpeningSource = 'HPP'

	-- ============================================================
	-- OUTPUT: HANYA VALUTA YANG ADA NILAINYA
	-- ============================================================
	SELECT D.CurrencyID, D.CurrencyName,
		'1' AS ProductType,
		D.OpeningForeign, D.OpeningIDR,
		D.BuyForeign, D.BuyIDR,
		D.SellForeign, D.SellIDR,
		D.OpeningForeign + D.BuyForeign - D.SellForeign AS ClosingForeign,
		D.MiddleRate,
		ClosingIDR = CASE WHEN D.CurrencyID = 'JPY'
			THEN ((D.OpeningForeign + D.BuyForeign - D.SellForeign) * D.MiddleRate) / 100
			ELSE (D.OpeningForeign + D.BuyForeign - D.SellForeign) * D.MiddleRate END,
		D.RateSource,
		D.OpeningSource,
		@HasCOGS AS HasCOGS,
		SavedRows = (SELECT COUNT(*) FROM MC_T_BIMonthly M
			WHERE M.ReportPeriod = @ReportPeriod AND RTRIM(ISNULL(M.RecordStatus,'')) = 'A')
	FROM #Data D
	WHERE D.OpeningForeign <> 0 OR D.BuyForeign <> 0 OR D.SellForeign <> 0
	ORDER BY D.CurrencyID
END
GO
