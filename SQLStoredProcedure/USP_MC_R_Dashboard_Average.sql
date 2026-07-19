SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 13 Jan 2026
-- Description:	Nilai rata-rata pembelian per valas
--
-- Logic:
--   1. Tentukan @_CurrentPeriod dan @_PrevPeriod dari @AsOfDate.
--   2. Jika MC_T_COGSValasCalculation untuk @_PrevPeriod ADA:
--        - Saldo awal per IDX_M_Currency = SUM(EB_BaseAmount) / SUM(EB_ForeignAmount)
--          dari perhitungan periode sebelumnya.
--        - Tambahkan pembelian (MC_T_PurchaseOrder) di periode berjalan
--          (PODate dalam bulan berjalan dan <= @AsOfDate).
--        - AverageValue = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign).
--   3. Jika MC_T_COGSValasCalculation untuk @_PrevPeriod TIDAK ada:
--        - Fallback ke perilaku lama: agregasi semua PO sejak awal (PODate <= @AsOfDate).
-- =============================================

-- EXEC USP_MC_R_Dashboard_Average '2026-01-13'
-- EXEC USP_MC_R_Dashboard_Average '2026-04-15'


ALTER PROCEDURE [dbo].[USP_MC_R_Dashboard_Average]
	@AsOfDate           DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- DERIVE PERIOD
	-- ============================================================
	DECLARE @_CurrentPeriod		VARCHAR(6) = CONVERT(VARCHAR(6), @AsOfDate, 112)               -- YYYYMM
	DECLARE @_StartOfMonth		DATE       = DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1)
	DECLARE @_PrevPeriod		VARCHAR(6) = CONVERT(VARCHAR(6), DATEADD(MONTH, -1, @_StartOfMonth), 112)

	-- ============================================================
	-- TEMP TABLE
	-- ============================================================
	CREATE TABLE #Temp (
		AsOfDate                    DATE,
		IDX_M_Currency				INT,
		-----------------------------------------------------------
		SortPriority                INT,
		CurrencyID                  VARCHAR(3),
		CurrencyName                VARCHAR(50),
		-----------------------------------------------------------
		BB_BaseAmount				DECIMAL(22,4),
		BB_ForeignAmount			DECIMAL(22,4),
		IN_BaseAmount				DECIMAL(22,4),
		IN_ForeignAmount			DECIMAL(22,4),
		AverageValue				DECIMAL(22,4)
	)

	INSERT INTO #Temp
	SELECT @AsOfDate, C.IDX_M_Currency,
		C.SortPriority,
		C.CurrencyID, C.CurrencyName,
		0, 0, 0, 0, 0
	FROM MC_M_Currency C

	-- ============================================================
	-- CHECK APAKAH DATA HPP PERIODE SEBELUMNYA ADA
	-- ============================================================
	DECLARE @_HasPrev BIT = 0
	IF EXISTS (
		SELECT 1
		FROM MC_T_COGSValasCalculation
		WHERE COGSPeriod = @_PrevPeriod
	)
		SET @_HasPrev = 1

	IF @_HasPrev = 1
	BEGIN
		-- ========================================================
		-- MODE A: Pakai saldo awal dari HPP periode sebelumnya
		--         + pembelian periode berjalan
		-- ========================================================

		-- ---- Saldo awal dari MC_T_COGSValasCalculation periode sebelumnya
		--      (aggregate IDX_M_Valas -> IDX_M_Currency)
		UPDATE #Temp SET
			 BB_BaseAmount    = BB.EB_BaseAmount
			,BB_ForeignAmount = BB.EB_ForeignAmount
		FROM (
			SELECT
				CV.IDX_M_Currency,
				SUM(ISNULL(CV.EB_BaseAmount, 0))    AS EB_BaseAmount,
				SUM(ISNULL(CV.EB_ForeignAmount, 0)) AS EB_ForeignAmount
			FROM MC_T_COGSValasCalculation CV
			WHERE CV.COGSPeriod = @_PrevPeriod
			GROUP BY CV.IDX_M_Currency
		) BB
		INNER JOIN #Temp ON #Temp.IDX_M_Currency = BB.IDX_M_Currency

		-- ---- Pembelian periode berjalan dari MC_T_PurchaseOrder
		--      (hanya bulan berjalan dan PODate <= @AsOfDate)
		UPDATE #Temp SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
		FROM (
			SELECT
				C.IDX_M_Currency,
				SUM(SD.BaseCurrencyAmount)                  AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)     AS ForeignAmount
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas         = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange  = V.IDX_M_ValasChange
			LEFT JOIN MC_M_Currency     C  ON C.IDX_M_Currency      = V.IDX_M_Currency
			WHERE S.POStatus = 'A'
				AND CONVERT(DATE, S.PODate) >= @_StartOfMonth
				AND CONVERT(DATE, S.PODate) <= @AsOfDate
			GROUP BY C.IDX_M_Currency
		) SD
		INNER JOIN #Temp ON #Temp.IDX_M_Currency = SD.IDX_M_Currency

		-- ---- AverageValue = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign)
		UPDATE #Temp SET
			AverageValue = (BB_BaseAmount + IN_BaseAmount) / (BB_ForeignAmount + IN_ForeignAmount)
		WHERE (BB_ForeignAmount + IN_ForeignAmount) <> 0
	END
	ELSE
	BEGIN
		-- ========================================================
		-- MODE B (FALLBACK): Tidak ada HPP periode sebelumnya
		--                   Pakai logika lama (cumulative PO)
		-- ========================================================
		UPDATE #Temp SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
			,AverageValue     = SD.AverageValue
		FROM (
			SELECT
				C.IDX_M_Currency,
				SUM(SD.BaseCurrencyAmount)                                                       AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)                                          AS ForeignAmount,
				SUM(SD.BaseCurrencyAmount) / NULLIF(SUM(SD.Quantity * VC.ValasChangeNumber), 0)  AS AverageValue
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas         = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange  = V.IDX_M_ValasChange
			LEFT JOIN MC_M_Currency     C  ON C.IDX_M_Currency      = V.IDX_M_Currency
			WHERE CONVERT(DATE, S.PODate) <= @AsOfDate AND S.POStatus = 'A'
			GROUP BY C.IDX_M_Currency
		) SD
		INNER JOIN #Temp ON #Temp.IDX_M_Currency = SD.IDX_M_Currency
	END

	-- ============================================================
	-- OUTPUT
	-- ============================================================
	SELECT * FROM #Temp
	ORDER BY SortPriority, CurrencyID, CurrencyName

	DROP TABLE #Temp
END
GO
