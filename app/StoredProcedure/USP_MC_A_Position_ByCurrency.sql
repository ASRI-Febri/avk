SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Posisi (net open position) valas per mata uang per tanggal.
--               Inti dashboard risiko money changer.
--
--   PositionForeign : saldo valas (dalam satuan mata uang asing) s/d @AsOfDate,
--                     dari MC_T_StockCardValas = SUM((StockIn - StockOut) * ValasChangeNumber).
--   AvgRate         : kurs beli rata-rata kumulatif (SUM BeliBase / SUM BeliForeign).
--   PositionValueIDR= PositionForeign * AvgRate  (nilai eksposur dalam IDR).
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Position_ByCurrency] '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Position_ByCurrency]
	@AsOfDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		C.IDX_M_Currency, C.CurrencyID, C.CurrencyName, ISNULL(C.SortPriority, 1000) AS SortPriority,
		ISNULL(ST.ForeignUnits, 0) AS PositionForeign,
		ISNULL(AV.AvgRate, 0)      AS AvgRate,
		ISNULL(ST.ForeignUnits, 0) * ISNULL(AV.AvgRate, 0) AS PositionValueIDR
	FROM MC_M_Currency C WITH(NOLOCK)
	LEFT JOIN (
		SELECT V.IDX_M_Currency,
			SUM((S.StockInQty - S.StockOutQty) * VC.ValasChangeNumber) AS ForeignUnits
		FROM MC_T_StockCardValas S WITH(NOLOCK)
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = S.IDX_M_Valas
			INNER JOIN MC_M_ValasChange VC WITH(NOLOCK) ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
		WHERE S.RecordStatus = 'A' AND CONVERT(DATE, S.TransactionDate) <= @AsOfDate
		GROUP BY V.IDX_M_Currency
	) ST ON ST.IDX_M_Currency = C.IDX_M_Currency
	LEFT JOIN (
		SELECT V.IDX_M_Currency,
			SUM(PD.BaseCurrencyAmount) / NULLIF(SUM(PD.ForeignAmount), 0) AS AvgRate
		FROM MC_T_PurchaseOrder P WITH(NOLOCK)
			INNER JOIN MC_T_PurchaseOrderDetail PD WITH(NOLOCK) ON PD.IDX_T_PurchaseOrder = P.IDX_T_PurchaseOrder
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = PD.IDX_M_Valas
		WHERE P.POStatus = 'A' AND CONVERT(DATE, P.PODate) <= @AsOfDate
		GROUP BY V.IDX_M_Currency
	) AV ON AV.IDX_M_Currency = C.IDX_M_Currency
	WHERE ISNULL(ST.ForeignUnits, 0) <> 0
	ORDER BY PositionValueIDR DESC, SortPriority, C.CurrencyID;
END
GO
