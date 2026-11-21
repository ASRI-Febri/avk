-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC USP_MC_R_StockCard 1,'2025-11-01','2025-11-30',1,0
-- EXEC USP_MC_R_StockCard 1,'2025-11-01','2025-11-30',2,0
-- EXEC USP_MC_R_StockCard 1,'2026-03-01','2026-03-31',0,0

CREATE PROCEDURE [dbo].[USP_MC_R_StockCard]
	@IDX_M_Branch				INT,
	@StartDate					DATE,
	@EndDate					DATE,
	@IDX_M_Valas				INT = 0,
	@IDX_M_Currency				INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- TEMP TABLE SALDO AWAL
	-- ============================================================
	CREATE TABLE #BB (
		IDX_M_Branch				INT,
		IDX_M_Currency				INT,
		IDX_M_Valas					BIGINT,
		ValasSKU					VARCHAR(50),
		-----------------------------------------------------------
		IN_Quantity					DECIMAL(18,4),
		OUT_Quantity				DECIMAL(18,4),
		EB_Quantity					DECIMAL(18,4),
		EB_ForeignAmount			DECIMAL(18,4)
	)

	INSERT INTO #BB
	SELECT S.IDX_M_Branch, MV.IDX_M_Currency, S.IDX_M_Valas, MV.ValasSKU, 
		SUM(StockInQty), SUM(StockOutQty),
		EBQty = SUM(StockInQty) - SUM(StockOutQty),
		EBForeignAmount = SUM(S.StockInForeignAmount) - SUM(S.StockOutForeignAmount)
	FROM [dbo].MC_T_StockCardValas S 
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) < @StartDate
	GROUP BY S.IDX_M_Branch, MV.IDX_M_Currency, S.IDX_M_Valas, MV.ValasSKU

	-- ============================================================
	-- TEMP TABLE MUTASI VALAS
	-- ============================================================
	CREATE TABLE #Movement (
		IDX_T_StockCardValas		BIGINT,
		IDX_M_Currency				INT,
		IDX_M_Valas					BIGINT,
		IDX_M_ValasChange			BIGINT,
        IDX_M_TransactionType		INT,
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
		TransactionTypeName			VARCHAR(50),
		ReferenceNo					VARCHAR(50),
		-----------------------------------------------------------
		BB_Quantity					DECIMAL(18,4),
		IN_Quantity					DECIMAL(18,4),
		OUT_Quantity				DECIMAL(18,4),
		EB_Quantity					DECIMAL(18,4),
		EB_ForeignAmount			DECIMAL(18,4)
	)

	--SELECT * FROM #BB WHERE IDX_M_Valas = @IDX_M_Valas

	--SELECT 0, B.IDX_M_Valas, MV.IDX_M_ValasChange, 
	--	L.BranchID, L.BranchName, 
	--	MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
	--	0, 'SALDO AWAL', DATEADD(d,-1,@StartDate),
	--	--------------------------------------------------------------
	--	BBQty = 0,
	--	B.IN_Quantity, 
	--	B.OUT_Quantity, 
	--	B.EB_Quantity,
	--	B.EB_ForeignAmount
	--FROM #BB B
	--LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = B.IDX_M_Branch
	--LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = B.IDX_M_Valas
	--LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange

    -- INSERT BEGINING BALANCE
	INSERT INTO #Movement
	SELECT 0, B.IDX_M_Currency, B.IDX_M_Valas, MV.IDX_M_ValasChange, 0,
		L.BranchID, L.BranchName, 
		C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
		0, 'SALDO AWAL', DATEADD(d,-1,@StartDate), 'Saldo Awal', '', 
		--------------------------------------------------------------
		BBQty = 0,
		B.IN_Quantity, 
		B.OUT_Quantity, 
		B.EB_Quantity,
		B.EB_ForeignAmount
	FROM #BB B
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = B.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = B.IDX_M_Valas
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange

	INSERT INTO #Movement
	SELECT S.IDX_T_StockCardValas, MV.IDX_M_Currency, S.IDX_M_Valas, MVC.IDX_M_ValasChange, 
        S.IDX_M_TransactionType,
		L.BranchID, L.BranchName, 
		C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
		S.IDX_Transaction, S.TransactionNo, S.TransactionDate, TT.TransactionTypeName, '', 
		--------------------------------------------------------------
		BBQty = 0,
		S.StockInQty, --S.StockInForeignAmount, S.ExchangeRateIn, S.StockInBaseAmount,
		S.StockOutQty, --S.StockOutForeignAmount, S.ExchangeRateOut, S.StockOutBaseAmount,
		BalanceQty = (StockInQty - StockOutQty),
		BalanceForeignAmount = (S.StockInForeignAmount - S.StockOutForeignAmount)
	FROM [dbo].MC_T_StockCardValas S 
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = S.IDX_M_TransactionType
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @StartDate AND @EndDate
	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas

	-- UPDATE REFERENCE NO (NO NOTA)
	UPDATE #Movement SET ReferenceNo = S.ReferenceNo
	FROM (
		SELECT IDX_T_SalesOrder, SONumber, ReferenceNo 
		FROM MC_T_SalesOrder
		WHERE RecordStatus = 'A' AND SOStatus = 'A'
	) S
	INNER JOIN #Movement ON #Movement.IDX_Transaction = S.IDX_T_SalesOrder AND #Movement.TransactionNo = S.SONumber
	WHERE #Movement.IDX_M_TransactionType = 2

	UPDATE #Movement SET ReferenceNo = S.ReferenceNo
	FROM (
		SELECT IDX_T_PurchaseOrder, PONumber, ReferenceNo 
		FROM MC_T_PurchaseOrder
		WHERE RecordStatus = 'A' AND POStatus = 'A'
	) S
	INNER JOIN #Movement ON #Movement.IDX_Transaction = S.IDX_T_PurchaseOrder AND #Movement.TransactionNo = S.PONumber
	WHERE #Movement.IDX_M_TransactionType = 3

	--SELECT * FROM #BB

    IF @IDX_M_Currency = 0 AND @IDX_M_Valas = 0 
    BEGIN
        SELECT * 
        FROM #Movement
        ORDER BY IDX_M_Currency, ValasSKU, TransactionDate, IDX_Transaction
    END

    IF @IDX_M_Currency = 0 AND @IDX_M_Valas <> 0 
    BEGIN
        SELECT * 
        FROM #Movement
        WHERE IDX_M_Valas = @IDX_M_Valas
        ORDER BY IDX_M_Currency, ValasSKU, TransactionDate, IDX_Transaction
    END

    IF @IDX_M_Currency <> 0 AND @IDX_M_Valas = 0 
    BEGIN 

        SELECT * 
        FROM #Movement
        WHERE IDX_M_Currency = @IDX_M_Currency 
        ORDER BY IDX_M_Currency, ValasSKU, TransactionDate, IDX_Transaction
    END

    IF @IDX_M_Currency <> 0 AND @IDX_M_Valas <> 0 
    BEGIN 

        SELECT * 
        FROM #Movement
        WHERE IDX_M_Currency = @IDX_M_Currency AND IDX_M_Valas = @IDX_M_Valas
        ORDER BY IDX_M_Currency, ValasSKU, TransactionDate, IDX_Transaction
    END




 --   IF @IDX_M_Valas = 0 AND @IDX_M_Currency = 0
	--BEGIN
	--	SELECT S.IDX_T_StockCardValas, S.IDX_M_Valas, MVC.IDX_M_ValasChange, 
	--		L.BranchID, L.BranchName, 
	--		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
	--		S.IDX_Transaction, S.TransactionNo, S.TransactionDate,
	--		S.StockInQty, S.StockInForeignAmount, S.ExchangeRateIn, S.StockInBaseAmount,
	--		S.StockOutQty, S.StockOutForeignAmount, S.ExchangeRateOut, S.StockOutBaseAmount,
	--		BalanceQty = (StockInQty - StockOutQty),
	--		BalanceForeignAmount = (S.StockInForeignAmount - S.StockOutForeignAmount)
	--	FROM [dbo].MC_T_StockCardValas S 
	--	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	--	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	--	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @StartDate AND @EndDate
	--	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas
	--END

	--IF @IDX_M_Valas <> 0 AND @IDX_M_Currency = 0
	--BEGIN
	--	SELECT S.IDX_T_StockCardValas, S.IDX_M_Valas, MVC.IDX_M_ValasChange, 
	--		L.BranchID, L.BranchName, 
	--		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
	--		S.IDX_Transaction, S.TransactionNo, S.TransactionDate,
	--		S.StockInQty, S.StockInForeignAmount, S.ExchangeRateIn, S.StockInBaseAmount,
	--		S.StockOutQty, S.StockOutForeignAmount, S.ExchangeRateOut, S.StockOutBaseAmount,
	--		BalanceQty = (StockInQty - StockOutQty),
	--		BalanceForeignAmount = (S.StockInForeignAmount - S.StockOutForeignAmount)
	--	FROM [dbo].MC_T_StockCardValas S 
	--	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	--	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	--	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @StartDate AND @EndDate
	--		AND MV.IDX_M_Valas = @IDX_M_Valas
	--	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas
	--END

	--IF @IDX_M_Valas = 0 AND @IDX_M_Currency <> 0
	--BEGIN
	--	SELECT S.IDX_T_StockCardValas, S.IDX_M_Valas, MVC.IDX_M_ValasChange, 
	--		L.BranchID, L.BranchName, 
	--		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
	--		S.IDX_Transaction, S.TransactionNo, S.TransactionDate,
	--		S.StockInQty, S.StockInForeignAmount, S.ExchangeRateIn, S.StockInBaseAmount,
	--		S.StockOutQty, S.StockOutForeignAmount, S.ExchangeRateOut, S.StockOutBaseAmount,
	--		BalanceQty = (StockInQty - StockOutQty),
	--		BalanceForeignAmount = (S.StockInForeignAmount - S.StockOutForeignAmount)
	--	FROM [dbo].MC_T_StockCardValas S 
	--	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	--	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	--	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @StartDate AND @EndDate
	--		AND MV.IDX_M_Currency = @IDX_M_Currency
	--	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas
	--END

	--IF @IDX_M_Valas <> 0 AND @IDX_M_Currency <> 0
	--BEGIN
	--	SELECT S.IDX_T_StockCardValas, S.IDX_M_Valas, MVC.IDX_M_ValasChange, 
	--		L.BranchID, L.BranchName, 
	--		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
	--		S.IDX_Transaction, S.TransactionNo, S.TransactionDate,
	--		S.StockInQty, S.StockInForeignAmount, S.ExchangeRateIn, S.StockInBaseAmount,
	--		S.StockOutQty, S.StockOutForeignAmount, S.ExchangeRateOut, S.StockOutBaseAmount,
	--		BalanceQty = (StockInQty - StockOutQty),
	--		BalanceForeignAmount = (S.StockInForeignAmount - S.StockOutForeignAmount)
	--	FROM [dbo].MC_T_StockCardValas S 
	--	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	--	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	--	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @StartDate AND @EndDate
	--		AND MV.IDX_M_Valas = @IDX_M_Valas
	--		AND MV.IDX_M_Currency = @IDX_M_Currency
	--	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas
	--END

END
