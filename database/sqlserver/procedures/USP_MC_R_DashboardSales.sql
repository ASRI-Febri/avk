-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026-01-12
-- Description:	Laporan dashboard penjualan dan pembelian
-- =============================================

-- [USP_MC_R_DashboardSales] '2026-03-26'

CREATE PROCEDURE [dbo].[USP_MC_R_DashboardSales]
	@CurrentDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- TEMP TABLE 
	-- ============================================================
	CREATE TABLE #Temp (
		CurrentDate                 DATE,		
		-----------------------------------------------------------
		Sales_Today					DECIMAL(22,4),
		Sales_ThisMonth				DECIMAL(22,4),
		Sales_ThisYear				DECIMAL(22,4),
		-----------------------------------------------------------
		Purchase_Today				DECIMAL(22,4),
		Purchase_ThisMonth			DECIMAL(22,4),
		Purchase_ThisYear			DECIMAL(22,4)
	)

	INSERT INTO #Temp 
	SELECT @CurrentDate, 0, 0, 0, 0, 0, 0

	-- ==============================================================
	-- UPDATE SALES
	-- ==============================================================
	UPDATE #Temp SET Sales_Today = SD.SalesAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS SalesAmount
		FROM [dbo].MC_T_SalesOrder S 
		LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE CONVERT(DATE, SODate) = @CurrentDate AND S.SOStatus = 'A'		
	) SD
	
	UPDATE #Temp SET Sales_ThisMonth = SD.SalesAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS SalesAmount
		FROM [dbo].MC_T_SalesOrder S 
		LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE YEAR(SODate) = YEAR(@CurrentDate) AND MONTH(SODate) = MONTH(@CurrentDate) AND S.SOStatus = 'A'		
	) SD
	
	UPDATE #Temp SET Sales_ThisYear = SD.SalesAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS SalesAmount
		FROM [dbo].MC_T_SalesOrder S 
		LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN MC_M_TransactionType TT ON TT.IDX_M_TransactionType = SD.IDX_M_TransactionType
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
		WHERE YEAR(SODate) = YEAR(@CurrentDate) AND S.SOStatus = 'A'		
	) SD



	-- ==============================================================
	-- UPDATE PURCHASE
	-- ==============================================================
	UPDATE #Temp SET Purchase_Today = SD.PurchaseAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS PurchaseAmount
		FROM MC_T_PurchaseOrder S
		LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
		LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
		WHERE CONVERT(DATE, PODate) = @CurrentDate AND S.POStatus = 'A'		
	) SD
	
	UPDATE #Temp SET Purchase_ThisMonth = SD.PurchaseAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS PurchaseAmount
		FROM MC_T_PurchaseOrder S
		LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
		LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
		WHERE YEAR(PODate) = YEAR(@CurrentDate) AND MONTH(PODate) = MONTH(@CurrentDate) AND S.POStatus = 'A'		
	) SD

	UPDATE #Temp SET Purchase_ThisYear = SD.PurchaseAmount
	FROM (
		SELECT 			
			SUM(SD.BaseCurrencyAmount) AS PurchaseAmount
		FROM MC_T_PurchaseOrder S
		LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
		LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
		LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
		LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
		WHERE YEAR(PODate) = YEAR(@CurrentDate) AND S.POStatus = 'A'		
	) SD

	-- ==============================================================
	-- OUTPUT
	-- ==============================================================
	SELECT * FROM #Temp 

END
