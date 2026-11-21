-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jun 2025
-- Description:	Laporan perhitungan harian
-- =============================================

-- EXEC USP_MC_R_DailyCalculation 1,0,'2026-01-10',0,0,0

CREATE PROCEDURE [dbo].[USP_MC_R_DailyCalculation]
	@IDX_M_Branch				INT,
	@IDX_M_Transaction			INT,
	@TransactionDate			DATE,
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
		-----------------------------------------------------------
		OpeningQuantity				DECIMAL(18,4),
		BuyQuantity					DECIMAL(18,4),
		BuyRate						DECIMAL(18,4),
		SellQuantity				DECIMAL(18,4),
		SellRate					DECIMAL(18,4),
		ClosingQuantity				DECIMAL(18,4),
		------------------------------------------------------------
		ClosingQuantityManual		DECIMAL(18,4),
		DiffQuantity				DECIMAL(18,4)
	)

	-- INSERT DAILY TRANSACTION
	INSERT INTO #Transaction
	SELECT O.IDX_M_Branch, C.IDX_M_Currency, O.IDX_M_Valas, MVC.IDX_M_ValasChange, SD.IDX_M_TransactionType,
		ISNULL(SD.IDX_M_Partner, 0), ISNULL(GMP.PartnerName,''), 
		TT.TransactionTypeName, L.BranchID, L.BranchName, C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber,
		SD.IDX_T_SalesOrder, SD.SONumber, SD.SODate, 
		--------------------------------------------------------------
		O.OpenQty, 
		BuyQuantity = CASE SD.IDX_M_TransactionType WHEN 1 THEN SD.Quantity ELSE 0 END,
		BuyRate = CASE SD.IDX_M_TransactionType WHEN 1 THEN SD.ExchangeRate ELSE 0 END,
		SellQuantity = CASE SD.IDX_M_TransactionType WHEN 2 THEN SD.Quantity ELSE 0 END,
		SellRate = CASE SD.IDX_M_TransactionType WHEN 2 THEN SD.ExchangeRate ELSE 0 END,
		0, ISNULL(O.CloseQty, 0), 0
	FROM (	SELECT OC.IDX_M_Branch, OC.TransactionDate, OCD.IDX_M_Valas, 
				OCD.OpenQty, ISNULL(OCD.CloseQty,0) AS CloseQty 
			FROM MC_T_OpenCloseDailyDetail OCD
    		LEFT JOIN MC_T_OpenCloseDaily OC ON OC.IDX_T_OpenCloseDaily = OCD.IDX_T_OpenCloseDaily
			WHERE CONVERT(DATE, OC.TransactionDate) = @TransactionDate) O 

	--LEFT JOIN MC_T_SalesOrderDetail SD ON O.IDX_M_Valas = SD.IDX_M_Valas

	LEFT JOIN (	SELECT S.IDX_T_SalesOrder, IDX_T_SalesOrderDetail,
					SOStatus, SODate, IDX_M_Partner, SONumber, IDX_M_Company, IDX_M_Branch, 
					SD.IDX_M_Valas, SD.Quantity, SD.IDX_M_TransactionType, SD.ExchangeRate
				FROM MC_T_SalesOrder S
				LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
				WHERE IDX_M_Branch = @IDX_M_Branch AND SOStatus = 'A' 
					AND CONVERT(DATE, SODate) = @TransactionDate) SD 
		ON SD.IDX_M_Valas = O.IDX_M_Valas
		
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = O.IDX_M_Branch
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = O.IDX_M_Valas
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
	LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SD.IDX_M_Partner
	--WHERE S.IDX_M_Branch = @IDX_M_Branch 
	ORDER BY MV.ValasSKU, SD.SODate
	
	UPDATE #Transaction SET ClosingQuantity = OpeningQuantity + BuyQuantity - SellQuantity
	UPDATE #Transaction SET DiffQuantity = ClosingQuantity - ClosingQuantityManual

	--SELECT * FROM #BB

    IF @IDX_M_Partner = 0
    BEGIN
        SELECT * 
        FROM #Transaction
        ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
    END
    ELSE
    BEGIN
        SELECT * 
        FROM #Transaction
        WHERE IDX_M_Partner = @IDX_M_Partner
        ORDER BY IDX_M_Branch, ValasSKU, IDX_M_TransactionType, TransactionDate, IDX_Transaction
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
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @TransactionDate AND @EndDate
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
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @TransactionDate AND @EndDate
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
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @TransactionDate AND @EndDate
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
	--	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.TransactionDate) BETWEEN @TransactionDate AND @EndDate
	--		AND MV.IDX_M_Valas = @IDX_M_Valas
	--		AND MV.IDX_M_Currency = @IDX_M_Currency
	--	ORDER BY MV.ValasSKU, S.TransactionDate, S.IDX_T_StockCardValas
	--END

END
