SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Stock & rata-rata pembelian per valas
--
-- AverageValue logic (per IDX_M_Valas):
--   1. Jika MC_T_COGSValasCalculation untuk periode sebelumnya ADA:
--        - Saldo awal = EB_BaseAmount / EB_ForeignAmount dari periode sebelumnya.
--        - Tambahkan pembelian periode berjalan dari MC_T_PurchaseOrder
--          (PODate dalam bulan berjalan dan <= @AsOfDate).
--        - AverageValue = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign).
--   2. Jika tidak ada: fallback ke logika lama (cumulative semua PO sejak awal).
-- =============================================

-- EXEC USP_MC_R_Dashboard_Stock '2026-03-29'
-- EXEC USP_MC_R_Dashboard_Stock '2026-04-15'


ALTER PROCEDURE [dbo].[USP_MC_R_Dashboard_Stock]
	@AsOfDate           DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- DERIVE PERIOD
	-- ============================================================
	DECLARE @_StartOfMonth	DATE       = DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1)
	DECLARE @_PrevPeriod	VARCHAR(6) = CONVERT(VARCHAR(6), DATEADD(MONTH, -1, @_StartOfMonth), 112)

	DECLARE @_HasPrev BIT = 0
	IF EXISTS (
		SELECT 1 FROM MC_T_COGSValasCalculation WHERE COGSPeriod = @_PrevPeriod
	)
		SET @_HasPrev = 1

	-- ============================================================
	-- TEMP TABLE (STOCK)
	-- ============================================================
	CREATE TABLE #Temp (
		AsOfDate                    DATE,
		IDX_M_Currency				INT,
		IDX_M_Valas					BIGINT,
		-----------------------------------------------------------
		SortPriority                INT,
		CurrencyID                  VARCHAR(3),
		CurrencyName                VARCHAR(50),
		ValasSKU					VARCHAR(50),
		ValasName					VARCHAR(50),
		ValasChangeNumber           DECIMAL(18,4),
		-----------------------------------------------------------
		IN_Quantity					DECIMAL(18,4),
		OUT_Quantity				DECIMAL(18,4),
		EB_Quantity					DECIMAL(18,4),
		-----------------------------------------------------------
		AverageValue				DECIMAL(18,4)
	)

	INSERT INTO #Temp
	SELECT @AsOfDate, MV.IDX_M_Currency, MV.IDX_M_Valas, ISNULL(MC.SortPriority,1000),
		MC.CurrencyID, MC.CurrencyName, MV.ValasSKU, MV.ValasName, VC.ValasChangeNumber,
		0, 0, 0, 0
	FROM MC_M_Valas MV
	LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = MV.IDX_M_ValasChange

	UPDATE #Temp SET IN_Quantity = A.IN_Qty, OUT_Quantity = A.OUT_Qty
	FROM (
		SELECT S.IDX_M_Valas, SUM(S.StockInQty) AS IN_Qty, SUM(S.StockOutQty) AS OUT_Qty
		FROM [dbo].MC_T_StockCardValas S
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
		LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = MV.IDX_M_Currency
		WHERE S.RecordStatus = 'A' AND CONVERT(DATE, S.TransactionDate) <= @AsOfDate
		GROUP BY S.IDX_M_Valas
	) A
	INNER JOIN #Temp ON #Temp.IDX_M_Valas = A.IDX_M_Valas

	-- ============================================================
	-- AVERAGE TEMP TABLE
	-- ============================================================
	CREATE TABLE #Average (
		AsOfDate                    DATE,
		IDX_M_Currency				INT,
		IDX_M_Valas					INT,
		-----------------------------------------------------------
		SortPriority                INT,
		CurrencyID                  VARCHAR(3),
		CurrencyName                VARCHAR(150),
		ValasSKU					VARCHAR(50),
		ValasName					VARCHAR(150),
		-----------------------------------------------------------
		BB_BaseAmount				DECIMAL(22,4),
		BB_ForeignAmount			DECIMAL(22,4),
		IN_BaseAmount				DECIMAL(22,4),
		IN_ForeignAmount			DECIMAL(22,4),
		AverageValue				DECIMAL(22,4)
	)

	INSERT INTO #Average
	SELECT @AsOfDate, C.IDX_M_Currency, V.IDX_M_Valas,
		C.SortPriority,
		C.CurrencyID, C.CurrencyName,
		V.ValasSKU, V.ValasName,
		0, 0, 0, 0, 0
	FROM MC_M_Valas V
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency

	IF @_HasPrev = 1
	BEGIN
		-- ========================================================
		-- MODE A: Saldo awal dari HPP periode sebelumnya
		--         + pembelian periode berjalan
		-- ========================================================

		-- ---- Saldo awal per IDX_M_Valas dari MC_T_COGSValasCalculation
		UPDATE #Average SET
			 BB_BaseAmount    = ISNULL(BB.EB_BaseAmount, 0)
			,BB_ForeignAmount = ISNULL(BB.EB_ForeignAmount, 0)
		FROM MC_T_COGSValasCalculation BB
		INNER JOIN #Average ON #Average.IDX_M_Valas = BB.IDX_M_Valas
		WHERE BB.COGSPeriod = @_PrevPeriod

		-- ---- Pembelian periode berjalan per IDX_M_Valas
		UPDATE #Average SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
		FROM (
			SELECT
				V.IDX_M_Valas,
				SUM(SD.BaseCurrencyAmount)                  AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)     AS ForeignAmount
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas        = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
			WHERE S.POStatus = 'A'
				AND CONVERT(DATE, S.PODate) >= @_StartOfMonth
				AND CONVERT(DATE, S.PODate) <= @AsOfDate
			GROUP BY V.IDX_M_Valas
		) SD
		INNER JOIN #Average ON #Average.IDX_M_Valas = SD.IDX_M_Valas

		-- ---- AverageValue = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign)
		UPDATE #Average SET
			AverageValue = (BB_BaseAmount + IN_BaseAmount) / (BB_ForeignAmount + IN_ForeignAmount)
		WHERE (BB_ForeignAmount + IN_ForeignAmount) <> 0
	END
	ELSE
	BEGIN
		-- ========================================================
		-- MODE B (FALLBACK): cumulative semua PO sejak awal
		-- ========================================================
		UPDATE #Average SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
			,AverageValue     = SD.AverageValue
		FROM (
			SELECT
				V.IDX_M_Valas,
				SUM(SD.BaseCurrencyAmount)                                                      AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)                                         AS ForeignAmount,
				SUM(SD.BaseCurrencyAmount) / NULLIF(SUM(SD.Quantity * VC.ValasChangeNumber), 0) AS AverageValue
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas        = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
			WHERE CONVERT(DATE, S.PODate) <= @AsOfDate AND S.POStatus = 'A'
			GROUP BY V.IDX_M_Valas
		) SD
		INNER JOIN #Average ON #Average.IDX_M_Valas = SD.IDX_M_Valas
	END

	-- ============================================================
	-- UPDATE ENDING BALANCE QUANTITY
	-- ============================================================
	UPDATE #Temp SET EB_Quantity = IN_Quantity - OUT_Quantity

	-- ============================================================
	-- UPDATE AVERAGE VALUE
	-- ============================================================
	UPDATE #Temp SET AverageValue = A.AverageValue
	FROM (
		SELECT IDX_M_Valas, AverageValue
		FROM #Average
	) A
	INNER JOIN #Temp ON #Temp.IDX_M_Valas = A.IDX_M_Valas

	-- ============================================================
	-- OUTPUT DATA
	-- ============================================================
	SELECT * FROM #Temp
	ORDER BY SortPriority, CurrencyID, ValasChangeNumber, ValasSKU, ValasName

	DROP TABLE #Temp
	DROP TABLE #Average
END
GO
