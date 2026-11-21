-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC USP_MC_R_Dashboard_SalesValas '2025-11-30'


CREATE PROCEDURE [dbo].[USP_MC_R_Dashboard_PurchaseValas]
	@AsOfDate           DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ============================================================
	-- TEMP TABLE 
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
		EB_Quantity					DECIMAL(18,4)
	)

    INSERT INTO #Temp 
    SELECT @AsOfDate, MV.IDX_M_Currency, MV.IDX_M_Valas, ISNULL(MC.SortPriority,1000), 
        MC.CurrencyID, MC.CurrencyName, MV.ValasSKU, MV.ValasName, VC.ValasChangeNumber,
        0, 0, 0 
    FROM MC_M_Valas MV 
    LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = MV.IDX_M_Currency
    LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = MV.IDX_M_ValasChange

    UPDATE #Temp SET IN_Quantity = A.IN_Qty, OUT_Quantity = A.OUT_Qty
    FROM (SELECT S.IDX_M_Valas, SUM(S.StockInQty) AS IN_Qty, SUM(S.StockOutQty) AS OUT_Qty 
        FROM [dbo].MC_T_StockCardValas S 
        LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
        LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = MV.IDX_M_Currency
        WHERE S.RecordStatus = 'A' AND CONVERT(DATE, S.TransactionDate) <= @AsOfDate
        GROUP BY S.IDX_M_Valas
    ) A 
    INNER JOIN #Temp ON #Temp.IDX_M_Valas = A.IDX_M_Valas

    UPDATE #Temp SET EB_Quantity = IN_Quantity - OUT_Quantity

    SELECT * FROM #Temp
    ORDER BY SortPriority, CurrencyID, ValasName

	


END
