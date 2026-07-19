SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jun 2025
-- Description:	Laporan transaksi jual, beli atau pembelian stok
-- =============================================

-- PEMBELIAN
-- EXEC USP_MC_R_Transaction 1,1,'2026-03-01','2026-03-31',0,0,0,'VALAS'
-- EXEC USP_MC_R_Transaction 1,1,'2026-03-01','2026-03-31',0,0,57,'NOTA'
-- EXEC USP_MC_R_Transaction 1,1,'2026-03-01','2026-03-31',0,0,0,'PARTNER'

-- PENJUALAN
-- EXEC USP_MC_R_Transaction 1,2,'2026-03-01','2026-03-31',0,0,0,'VALAS'
-- EXEC USP_MC_R_Transaction 1,2,'2026-03-01','2026-03-31',0,0,57,'NOTA'
-- EXEC USP_MC_R_Transaction 1,2,'2026-03-01','2026-03-31',0,0,0,'PARTNER'

ALTER PROCEDURE [dbo].[USP_MC_R_Transaction]
	@IDX_M_Branch				INT,
	@IDX_M_Transaction			INT,
	@StartDate					DATE,
	@EndDate					DATE,
	@IDX_M_Valas				INT = 0,
	@IDX_M_Currency				INT = 0,
    @IDX_M_Partner				INT = 0,
	-------------------------------------------
	@GroupBy					VARCHAR(10) = 'VALAS' -- VALAS, NOTA, PARTNER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SELECT * FROM MC_M_TransactionType
	--1	BUY
	--2	SELL
	--3	PO
	--4	ADJIN
	--5	ADJOUT

	-- ============================================================
	-- TEMP TABLE TRANSACTION
	-- ============================================================
	CREATE TABLE #Transaction (
		IDX_M_Branch				BIGINT,
		IDX_M_Currency				INT,
		IDX_M_Valas					BIGINT,
		IDX_M_ValasChange			BIGINT,
		IDX_M_TransactionType		INT,
        IDX_M_Partner               INT,
        PartnerName					VARCHAR(150),
		TransactionTypeName			VARCHAR(50),
		BranchID					VARCHAR(50),
		BranchName					VARCHAR(150),
		CurrencyID					VARCHAR(5),
		CurrencyName				VARCHAR(50),
		ValasSKU					VARCHAR(50),
		ValasName					VARCHAR(50),
		ValasChangeName				VARCHAR(50),
		ValasChangeNumber			INT,
		IDX_Transaction				BIGINT,
		TransactionNo				VARCHAR(50),
		TransactionDate				DATE, 
		ReferenceNo					VARCHAR(50),
		-----------------------------------------------------------
		ForeignAmount				DECIMAL(18,4),
		Quantity					DECIMAL(18,4),
		ExchangeRate				DECIMAL(18,4),
		BaseAmount					DECIMAL(18,4),
		-----------------------------------------------------------
		AverageAmount				DECIMAL(18,4)
		------------------------------------------------------------
	)

	-- ============================================================
	-- AVERAGE TABLE
	--
	-- AverageValue logic (per IDX_M_Valas, basis: bulan dari @EndDate):
	--   1. Jika MC_T_COGSValasCalculation untuk periode sebelumnya ADA:
	--        - Saldo awal = EB_BaseAmount / EB_ForeignAmount periode sebelumnya
	--          (per IDX_M_Valas, di-join langsung).
	--        - Tambahkan pembelian bulan berjalan dari MC_T_PurchaseOrder
	--          (PODate dalam bulan @EndDate dan <= @EndDate).
	--        - AverageValue = (BB_Base + IN_Base) / (BB_Foreign + IN_Foreign).
	--   2. Jika tidak ada: fallback ke logika lama (cumulative semua PO sejak awal).
	--
	-- Join key untuk BB & IN: (IDX_M_Currency, IDX_M_Valas).
	-- ============================================================
	DECLARE @_StartOfMonth	DATE       = DATEFROMPARTS(YEAR(@EndDate), MONTH(@EndDate), 1)
	DECLARE @_PrevPeriod	VARCHAR(6) = CONVERT(VARCHAR(6), DATEADD(MONTH, -1, @_StartOfMonth), 112)

	DECLARE @_HasPrev BIT = 0
	IF EXISTS (
		SELECT 1 FROM MC_T_COGSValasCalculation WHERE COGSPeriod = @_PrevPeriod
	)
		SET @_HasPrev = 1

	CREATE TABLE #Average (
		AsOfDate                    DATE,
		IDX_M_Currency				INT,
		IDX_M_Valas					INT,
        -----------------------------------------------------------
        SortPriority                INT,
        CurrencyID                  VARCHAR(3),
		CurrencyName                VARCHAR(50),
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
	SELECT @EndDate, C.IDX_M_Currency, V.IDX_M_Valas,
		C.SortPriority,
		C.CurrencyID, C.CurrencyName,
		V.ValasSKU, V.ValasName,
		0, 0, 0, 0, 0
	FROM MC_M_Valas V
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency

	IF @_HasPrev = 1
	BEGIN
		-- MODE A: BB dari HPP periode sebelumnya + IN periode berjalan
		UPDATE #Average SET
			 BB_BaseAmount    = ISNULL(BB.EB_BaseAmount, 0)
			,BB_ForeignAmount = ISNULL(BB.EB_ForeignAmount, 0)
		FROM MC_T_COGSValasCalculation BB
		INNER JOIN #Average ON #Average.IDX_M_Currency = BB.IDX_M_Currency
						   AND #Average.IDX_M_Valas    = BB.IDX_M_Valas
		WHERE BB.COGSPeriod = @_PrevPeriod

		UPDATE #Average SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
		FROM (
			SELECT
				C.IDX_M_Currency,
				V.IDX_M_Valas,
				SUM(SD.BaseCurrencyAmount)               AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)  AS ForeignAmount
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas        = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
			LEFT JOIN MC_M_Currency     C  ON C.IDX_M_Currency     = V.IDX_M_Currency
			WHERE S.POStatus = 'A'
				AND CONVERT(DATE, S.PODate) >= @_StartOfMonth
				AND CONVERT(DATE, S.PODate) <= @EndDate
			GROUP BY C.IDX_M_Currency, V.IDX_M_Valas
		) SD
		INNER JOIN #Average ON #Average.IDX_M_Currency = SD.IDX_M_Currency
						   AND #Average.IDX_M_Valas    = SD.IDX_M_Valas

		UPDATE #Average SET
			AverageValue = (BB_BaseAmount + IN_BaseAmount) / (BB_ForeignAmount + IN_ForeignAmount)
		WHERE (BB_ForeignAmount + IN_ForeignAmount) <> 0
	END
	ELSE
	BEGIN
		-- MODE B (FALLBACK): cumulative semua PO sejak awal
		UPDATE #Average SET
			 IN_BaseAmount    = SD.BaseCurrencyAmount
			,IN_ForeignAmount = SD.ForeignAmount
			,AverageValue     = SD.AverageValue
		FROM (
			SELECT
				C.IDX_M_Currency,
				V.IDX_M_Valas,
				SUM(SD.BaseCurrencyAmount)                                                      AS BaseCurrencyAmount,
				SUM(SD.Quantity * VC.ValasChangeNumber)                                         AS ForeignAmount,
				SUM(SD.BaseCurrencyAmount) / NULLIF(SUM(SD.Quantity * VC.ValasChangeNumber), 0) AS AverageValue
			FROM MC_T_PurchaseOrder S
			LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
			LEFT JOIN MC_M_Valas        V  ON V.IDX_M_Valas        = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange  VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
			LEFT JOIN MC_M_Currency     C  ON C.IDX_M_Currency     = V.IDX_M_Currency
			WHERE CONVERT(DATE, S.PODate) <= @EndDate AND S.POStatus = 'A'
			GROUP BY C.IDX_M_Currency, V.IDX_M_Valas
		) SD
		INNER JOIN #Average ON #Average.IDX_M_Currency = SD.IDX_M_Currency
						   AND #Average.IDX_M_Valas    = SD.IDX_M_Valas
	END

	-- ======================================================================================================================
	-- INSERT ALL VALAS
	-- ======================================================================================================================
	IF @IDX_M_Transaction = 0
	BEGIN
		INSERT INTO #Transaction
		SELECT S.IDX_M_Branch, MV.IDX_M_Currency, SD.IDX_M_Valas, MVC.IDX_M_ValasChange, SD.IDX_M_TransactionType,
			ISNULL(S.IDX_M_Partner, 0), ISNULL(GMP.PartnerName,''), 
			TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
			MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
			S.IDX_T_SalesOrder, S.SONumber, S.SODate, S.ReferenceNo, 
			--------------------------------------------------------------
			SD.ForeignAmount, SD.Quantity, SD.ExchangeRate, SD.BaseCurrencyAmount, 0
		FROM [dbo].MC_T_SalesOrder S 
		LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate
			AND S.SOStatus = 'A'
		ORDER BY MV.ValasSKU, S.SODate
	END

	-- ======================================================================================================================
	-- INSERT PENJUALAN VALAS
	-- ======================================================================================================================
	IF @IDX_M_Transaction = 2
	BEGIN
		INSERT INTO #Transaction
		SELECT S.IDX_M_Branch, MV.IDX_M_Currency, SD.IDX_M_Valas, MVC.IDX_M_ValasChange, SD.IDX_M_TransactionType,
			ISNULL(S.IDX_M_Partner, 0), ISNULL(GMP.PartnerName,''), 
			TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
			MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
			S.IDX_T_SalesOrder, S.SONumber, S.SODate, S.ReferenceNo,
			--------------------------------------------------------------
			SD.ForeignAmount, SD.Quantity, SD.ExchangeRate, SD.BaseCurrencyAmount, 0
		FROM [dbo].MC_T_SalesOrder S 
		LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate
			AND S.SOStatus = 'A'
		ORDER BY MV.ValasSKU, S.SODate

		-- UPDATE AVERAGE AMOUNT (HPP)
		UPDATE #Transaction SET AverageAmount = #Average.AverageValue * ValasChangeNumber * Quantity
		FROM #Average
		INNER JOIN #Transaction ON #Transaction.IDX_M_Currency = #Average.IDX_M_Currency
							   AND #Transaction.IDX_M_Valas    = #Average.IDX_M_Valas
	END

	-- ========================================================================================================
	-- INSERT PEMBELIAN PO VALAS
	-- ========================================================================================================
	IF @IDX_M_Transaction = 1
	BEGIN		
		INSERT INTO #Transaction
		SELECT S.IDX_M_Branch, MV.IDX_M_Currency, SD.IDX_M_Valas, MVC.IDX_M_ValasChange, 3,
			ISNULL(S.IDX_M_Partner, 0), ISNULL(GMP.PartnerName,''), 
			TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
			MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
			S.IDX_T_PurchaseOrder, S.PONumber, S.PODate, S.ReferenceNo,
			--------------------------------------------------------------
			SD.ForeignAmount, SD.Quantity, SD.ExchangeRate, SD.BaseCurrencyAmount, 0
		FROM [dbo].MC_T_PurchaseOrder S 
		LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = 3
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.PODate) BETWEEN @StartDate AND @EndDate
			AND S.POStatus = 'A'
		ORDER BY MV.ValasSKU, S.PODate

		-- UPDATE AVERAGE AMOUNT (HPP)
		UPDATE #Transaction SET AverageAmount = #Average.AverageValue * ValasChangeNumber * Quantity
		FROM #Average
		INNER JOIN #Transaction ON #Transaction.IDX_M_Currency = #Average.IDX_M_Currency
							   AND #Transaction.IDX_M_Valas    = #Average.IDX_M_Valas
	END

	--SELECT * FROM #BB
	-- UPDATE #Transaction SET ExchangeRate = ExchangeRate * -1, 
	-- 	BaseAmount = BaseAmount * -1
	-- WHERE IDX_M_TransactionType = 2

    IF @IDX_M_Partner = 0 AND @IDX_M_Currency = 0 AND @IDX_M_Valas = 0
    BEGIN
        IF @GroupBy = 'VALAS'
		BEGIN
			SELECT * 
			FROM #Transaction
			ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'NOTA'
		BEGIN
			SELECT * 
			FROM #Transaction
			ORDER BY IDX_M_Branch, TransactionNo, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'PARTNER'
		BEGIN
			SELECT * 
			FROM #Transaction
			ORDER BY IDX_M_Branch, PartnerName, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
    END
    
	IF @IDX_M_Partner <> 0 AND @IDX_M_Currency = 0 AND @IDX_M_Valas = 0
    BEGIN
		PRINT 'Partner <> 0'
		IF RTRIM(@GroupBy) = 'VALAS'
		BEGIN
			PRINT 'VALAS'
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Partner = @IDX_M_Partner
			ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF RTRIM(@GroupBy) = 'NOTA'
		BEGIN
			PRINT 'NOTA'
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Partner = @IDX_M_Partner
			ORDER BY IDX_M_Branch, TransactionNo, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF RTRIM(@GroupBy) = 'PARTNER'
		BEGIN
			PRINT 'PARTNER'
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Partner = @IDX_M_Partner
			ORDER BY IDX_M_Branch, PartnerName, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
    END

	IF @IDX_M_Currency <> 0 AND @IDX_M_Partner = 0 AND @IDX_M_Valas = 0
    BEGIN
		PRINT 'Currency <> 0'
		IF @GroupBy = 'VALAS'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Currency = @IDX_M_Currency
			ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'NOTA'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Currency = @IDX_M_Currency
			ORDER BY IDX_M_Branch, TransactionNo, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'PARTNER'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Currency = @IDX_M_Currency
			ORDER BY IDX_M_Branch, PartnerName, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
    END

	IF @IDX_M_Valas <> 0 AND @IDX_M_Partner = 0 AND @IDX_M_Currency = 0
    BEGIN
		PRINT 'Valas <> 0'
		IF @GroupBy = 'VALAS'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Valas = @IDX_M_Valas
			ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'NOTA'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Valas = @IDX_M_Valas
			ORDER BY IDX_M_Branch, TransactionNo, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
		IF @GroupBy = 'PARTNER'
		BEGIN
			SELECT * 
			FROM #Transaction
			WHERE IDX_M_Valas = @IDX_M_Valas
			ORDER BY IDX_M_Branch, PartnerName, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
		END
    END




END
GO
