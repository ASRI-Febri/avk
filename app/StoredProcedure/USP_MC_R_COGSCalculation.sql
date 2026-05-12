SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 09 May 2026
-- Description:	Laporan perhitungan COGS
-- =============================================

-- EXEC USP_MC_R_COGSCalculation '202603'
-- EXEC USP_MC_R_COGSCalculation '202604'

CREATE PROCEDURE [dbo].[USP_MC_R_COGSCalculation]
	@COGSPeriod			VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [COGSPeriod], C.[IDX_M_Currency]
		,C.[IDX_M_Valas]
		,MC.CurrencyID
		,MC.CurrencyName
		,MV.ValasName
		,[ValasChangeNumber]
		---------------------------------------------------------------------------
		,[BB_Qty]
		,[BB_ForeignAmount]		
		,[BB_BaseAmount]
		---------------------------------------------------------------------------
		,[IN_Qty]
		,[IN_ForeignAmount]		
		,[IN_BaseAmount]		
		---------------------------------------------------------------------------
		,[AverageAmount] 
		---------------------------------------------------------------------------
		,C.[Sold_Qty]
		,C.Sold_ForeignAmount
		,C.Sold_BaseAmount
		---------------------------------------------------------------------------
		,C.COGSAmount
		,C.GrossProfitAmount
		---------------------------------------------------------------------------
		,[EB_Qty]
		,[EB_ForeignAmount]		
		,[EB_BaseAmount]
	FROM MC_T_COGSValasCalculation C
	LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = C.IDX_M_Currency
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = C.IDX_M_Valas
	WHERE COGSPeriod = @COGSPeriod
	ORDER BY MC.SortPriority, CurrencyID, MV.ValasSKU 


END
GO
