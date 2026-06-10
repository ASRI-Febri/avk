SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Tren volume transaksi 12 bulan (Money Changer).
--               Output per bulan : nilai jual (IDR), nilai beli (IDR), jumlah transaksi.
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Volume_Trend] '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Volume_Trend]
	@AsOfDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_StartMonth DATE = DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1)
	DECLARE @_From       DATE = DATEADD(MONTH, -11, @_StartMonth)
	DECLARE @_To         DATE = DATEADD(MONTH, 1, @_StartMonth)

	;WITH Months AS (
		SELECT @_From AS M
		UNION ALL
		SELECT DATEADD(MONTH, 1, M) FROM Months WHERE M < @_StartMonth
	),
	SO AS (
		SELECT YEAR(S.SODate) AS Y, MONTH(S.SODate) AS Mo,
			SUM(SD.BaseCurrencyAmount) AS Base, COUNT(DISTINCT S.IDX_T_SalesOrder) AS Trx
		FROM MC_T_SalesOrder S WITH(NOLOCK)
			INNER JOIN MC_T_SalesOrderDetail SD WITH(NOLOCK) ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		WHERE S.SOStatus = 'A' AND CONVERT(DATE, S.SODate) >= @_From AND CONVERT(DATE, S.SODate) < @_To
		GROUP BY YEAR(S.SODate), MONTH(S.SODate)
	),
	PO AS (
		SELECT YEAR(P.PODate) AS Y, MONTH(P.PODate) AS Mo,
			SUM(PD.BaseCurrencyAmount) AS Base, COUNT(DISTINCT P.IDX_T_PurchaseOrder) AS Trx
		FROM MC_T_PurchaseOrder P WITH(NOLOCK)
			INNER JOIN MC_T_PurchaseOrderDetail PD WITH(NOLOCK) ON PD.IDX_T_PurchaseOrder = P.IDX_T_PurchaseOrder
		WHERE P.POStatus = 'A' AND CONVERT(DATE, P.PODate) >= @_From AND CONVERT(DATE, P.PODate) < @_To
		GROUP BY YEAR(P.PODate), MONTH(P.PODate)
	)
	SELECT
		CONVERT(VARCHAR(6), Months.M, 112) AS Period,
		FORMAT(Months.M, 'MMM yy') AS PeriodLabel,
		ISNULL(SO.Base, 0) AS SalesBase,
		ISNULL(PO.Base, 0) AS PurchaseBase,
		ISNULL(SO.Trx, 0)  AS SalesTrx,
		ISNULL(PO.Trx, 0)  AS PurchaseTrx
	FROM Months
	LEFT JOIN SO ON SO.Y = YEAR(Months.M) AND SO.Mo = MONTH(Months.M)
	LEFT JOIN PO ON PO.Y = YEAR(Months.M) AND PO.Mo = MONTH(Months.M)
	ORDER BY Months.M
	OPTION (MAXRECURSION 100);
END
GO
