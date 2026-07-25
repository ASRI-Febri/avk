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
--				  - Saldo awal        : BB_ForeignAmount / BB_BaseAmount
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
--				Kurs tengah: (BuyRate + SellRate) / 2 dari master currency, bisa
--				dikoreksi admin di layar preview.
-- =============================================

-- EXEC USP_MC_BIMonthly_Preview '202603'

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
		MiddleRate			DECIMAL(18,4)
	)

	INSERT INTO #Data
	SELECT C.IDX_M_Currency, RTRIM(ISNULL(C.CurrencyID,'')), RTRIM(ISNULL(C.CurrencyName,'')),
		0, 0, 0, 0, 0, 0,
		(ISNULL(C.BuyRate,0) + ISNULL(C.SellRate,0)) / 2
	FROM MC_M_Currency C
	WHERE RTRIM(ISNULL(C.Recordstatus,'')) = 'A'
		AND RTRIM(ISNULL(C.CurrencyID,'')) <> ''
		AND RTRIM(ISNULL(C.CurrencyID,'')) <> 'IDR'

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
		@HasCOGS AS HasCOGS,
		SavedRows = (SELECT COUNT(*) FROM MC_T_BIMonthly M
			WHERE M.ReportPeriod = @ReportPeriod AND RTRIM(ISNULL(M.RecordStatus,'')) = 'A')
	FROM #Data D
	WHERE D.OpeningForeign <> 0 OR D.BuyForeign <> 0 OR D.SellForeign <> 0
	ORDER BY D.CurrencyID
END
GO
