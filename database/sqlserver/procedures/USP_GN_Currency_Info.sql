
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get currency information
-- =============================================

-- EXEC [USP_GN_Currency_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Currency_Info]	
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
      ,CU.RecordStatus
      ,CU.[DCreate]
      ,CU.[UCreate]
      ,CU.[DModified]
      ,CU.[UModified]
      ,CU.[Recordstatus]
	  ,CO.CountryID
	  ,CO.CountryName		
	FROM GN_M_Currency CU
	LEFT JOIN GN_M_Country CO ON CO.IDX_M_Country = CU.IDX_M_Country	
	WHERE IDX_M_Currency = @IDX_M_Currency
	
END



