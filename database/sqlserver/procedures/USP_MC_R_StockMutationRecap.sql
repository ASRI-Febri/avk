
CREATE PROCEDURE [dbo].[USP_MC_R_StockMutationRecap]
	@Period		VARCHAR(6)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		RTRIM(MC.CurrencyID)		AS CurrencyID,
		RTRIM(MC.CurrencyName)		AS CurrencyName,
		SUM(C.BB_ForeignAmount)		AS BB_ForeignAmount,
		SUM(C.BB_BaseAmount)		AS BB_BaseAmount,
		SUM(C.IN_ForeignAmount)		AS IN_ForeignAmount,
		SUM(C.IN_BaseAmount)		AS IN_BaseAmount,
		SUM(C.Sold_ForeignAmount)	AS Sold_ForeignAmount,
		SUM(C.Sold_BaseAmount)		AS Sold_BaseAmount,
		SUM(C.EB_ForeignAmount)		AS EB_ForeignAmount,
		SUM(C.EB_BaseAmount)		AS EB_BaseAmount,
		CASE WHEN SUM(C.EB_ForeignAmount) <> 0
			 THEN SUM(C.EB_BaseAmount) / SUM(C.EB_ForeignAmount) ELSE 0 END AS EB_AverageRate
	FROM MC_T_COGSValasCalculation C WITH(NOLOCK)
		INNER JOIN MC_M_Currency MC WITH(NOLOCK) ON MC.IDX_M_Currency = C.IDX_M_Currency
	WHERE C.COGSPeriod = @Period
	GROUP BY MC.IDX_M_Currency, MC.CurrencyID, MC.CurrencyName, MC.SortPriority
	HAVING SUM(ABS(C.BB_ForeignAmount)) + SUM(ABS(C.IN_ForeignAmount))
		 + SUM(ABS(C.Sold_ForeignAmount)) + SUM(ABS(C.EB_ForeignAmount)) <> 0
	ORDER BY MC.SortPriority, MC.CurrencyID
END
