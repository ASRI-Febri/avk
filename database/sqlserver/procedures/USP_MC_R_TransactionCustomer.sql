-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jun 2025
-- Description:	Laporan transaksi jual, beli atau pembelian stok berdasarkan customer
-- =============================================

-- EXEC USP_MC_R_TransactionCustomer 1,0,'2025-01-01','2025-06-30',0,0, 0
-- EXEC USP_MC_R_TransactionCustomer 1,0,'2025-01-01','2025-06-30',0,0, 1

CREATE PROCEDURE [dbo].[USP_MC_R_TransactionCustomer]
	@IDX_M_Branch				INT,
	@IDX_M_Transaction			INT,
	@StartDate					DATE,
	@EndDate					DATE,
	@IDX_M_Valas				INT = 0,
	@IDX_M_Currency				INT = 0,
    @IDX_M_Partner				INT = 0
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
		-----------------------------------------------------------
		ForeignAmount				DECIMAL(18,4),
		Quantity					DECIMAL(18,4),
		ExchangeRate				DECIMAL(18,4),
		BaseAmount					DECIMAL(18,4)
	)

	-- INSERT PENJUALAN VALAS
	INSERT INTO #Transaction
	SELECT S.IDX_M_Branch, MV.IDX_M_Currency, SD.IDX_M_Valas, MVC.IDX_M_ValasChange, SD.IDX_M_TransactionType,
        S.IDX_M_Partner,
		TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
		S.IDX_T_SalesOrder, S.SONumber, S.SODate, 
		--------------------------------------------------------------
		SD.ForeignAmount, SD.Quantity, SD.ExchangeRate, SD.BaseCurrencyAmount
	FROM [dbo].MC_T_SalesOrder S 
	LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
	LEFT JOIN GN_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate
		AND S.SOStatus = 'A'
	ORDER BY MV.ValasSKU, S.SODate

	-- INSERT PEMBELIAN PO VALAS
	INSERT INTO #Transaction
	SELECT S.IDX_M_Branch, MV.IDX_M_Currency, SD.IDX_M_Valas, MVC.IDX_M_ValasChange, 3,
        S.IDX_M_Partner, 
		TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
		S.IDX_T_PurchaseOrder, S.PONumber, S.PODate, 
		--------------------------------------------------------------
		SD.ForeignAmount, SD.Quantity, SD.ExchangeRate, SD.BaseCurrencyAmount
	FROM [dbo].MC_T_PurchaseOrder S 
	LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
	LEFT JOIN GN_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = 3
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.PODate) BETWEEN @StartDate AND @EndDate
		AND S.POStatus = 'A'
	ORDER BY MV.ValasSKU, S.PODate

	--SELECT * FROM #BB

    IF @IDX_M_Partner = 0
    BEGIN
        SELECT * 
        FROM #Transaction
        ORDER BY IDX_M_Branch, IDX_M_TransactionType, ValasSKU, TransactionDate, IDX_Transaction
    END 
    ELSE 
    BEGIN 
        SELECT * 
        FROM #Transaction
        WHERE IDX_M_Partner = @IDX_M_Partner
        ORDER BY IDX_M_Branch, IDX_M_Partner, IDX_M_TransactionType, ValasSKU, TransactionDate, IDX_Transaction
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
