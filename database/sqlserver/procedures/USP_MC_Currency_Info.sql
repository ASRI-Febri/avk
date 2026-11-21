

-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	30 Oct 2025
-- Description	:	Get currency information
-- =============================================

-- EXEC [USP_MC_Currency_Info] 1

CREATE PROCEDURE [dbo].[USP_MC_Currency_Info]	
	@IDX_M_Currency			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	   CU.IDX_M_Currency
	  ,CU.[IDX_M_Country]
      ,[CurrencyID]
      ,[CurrencyName]
      ,[Symbol]
      ,[Remarks]
      ,[Rounding]
      ,[Accuracy]
	  ,CU.BuyRate 
	  ,CU.SellRate
      ,CU.RecordStatus
	  ,CU.IconFlag
	  ,CU.SortPriority
      ,CU.[DCreate]
      ,CU.[UCreate]
      ,CU.[DModified]
      ,CU.[UModified]
      ,CU.[Recordstatus]
	  ,CO.CountryID
	  ,CO.CountryName, 
	  CU.PurchaseAccount, CU.SalesAccount, CU.COGSAccount,
	  SalesAccountDesc = AR.COAID + ' - ' + AR.COADesc,
	PurchaseAccountDesc = AP.COAID + ' - ' + AP.COADesc,
	COGSAccountDesc = COGS.COAID + ' - ' + COGS.COADesc		
	FROM MC_M_Currency CU
	LEFT JOIN GN_M_Country CO ON CO.IDX_M_Country = CU.IDX_M_Country	
	LEFT JOIN GL_M_COA AR ON CU.SalesAccount = AR.IDX_M_COA
	LEFT JOIN GL_M_COA AP ON CU.PurchaseAccount = AP.IDX_M_COA
	LEFT JOIN GL_M_COA COGS ON CU.COGSAccount = COGS.IDX_M_COA
	WHERE IDX_M_Currency = @IDX_M_Currency
	
END




