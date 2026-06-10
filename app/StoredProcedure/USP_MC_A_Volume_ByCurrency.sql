SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Volume transaksi per mata uang untuk satu periode.
--               Output per mata uang : nilai & qty jual/beli + jumlah transaksi.
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Volume_ByCurrency] '2026-06-01', '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Volume_ByCurrency]
	@StartDate	DATE,
	@EndDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		C.IDX_M_Currency, C.CurrencyID, C.CurrencyName, ISNULL(C.SortPriority, 1000) AS SortPriority,
		ISNULL(SL.SellBase, 0)    AS SalesBase,
		ISNULL(SL.SellForeign, 0) AS SalesForeign,
		ISNULL(SL.SellTrx, 0)     AS SalesTrx,
		ISNULL(PB.BuyBase, 0)     AS PurchaseBase,
		ISNULL(PB.BuyForeign, 0)  AS PurchaseForeign,
		ISNULL(PB.BuyTrx, 0)      AS PurchaseTrx,
		ISNULL(SL.SellBase, 0) + ISNULL(PB.BuyBase, 0) AS TotalBase
	FROM MC_M_Currency C WITH(NOLOCK)
	LEFT JOIN (
		SELECT V.IDX_M_Currency,
			SUM(SD.ForeignAmount)              AS SellForeign,
			SUM(SD.BaseCurrencyAmount)         AS SellBase,
			COUNT(DISTINCT S.IDX_T_SalesOrder) AS SellTrx
		FROM MC_T_SalesOrder S WITH(NOLOCK)
			INNER JOIN MC_T_SalesOrderDetail SD WITH(NOLOCK) ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = SD.IDX_M_Valas
		WHERE S.SOStatus = 'A' AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate
		GROUP BY V.IDX_M_Currency
	) SL ON SL.IDX_M_Currency = C.IDX_M_Currency
	LEFT JOIN (
		SELECT V.IDX_M_Currency,
			SUM(PD.ForeignAmount)                 AS BuyForeign,
			SUM(PD.BaseCurrencyAmount)            AS BuyBase,
			COUNT(DISTINCT P.IDX_T_PurchaseOrder) AS BuyTrx
		FROM MC_T_PurchaseOrder P WITH(NOLOCK)
			INNER JOIN MC_T_PurchaseOrderDetail PD WITH(NOLOCK) ON PD.IDX_T_PurchaseOrder = P.IDX_T_PurchaseOrder
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = PD.IDX_M_Valas
		WHERE P.POStatus = 'A' AND CONVERT(DATE, P.PODate) BETWEEN @StartDate AND @EndDate
		GROUP BY V.IDX_M_Currency
	) PB ON PB.IDX_M_Currency = C.IDX_M_Currency
	WHERE ISNULL(SL.SellBase, 0) <> 0 OR ISNULL(PB.BuyBase, 0) <> 0
	ORDER BY TotalBase DESC, SortPriority, C.CurrencyID;
END
GO
