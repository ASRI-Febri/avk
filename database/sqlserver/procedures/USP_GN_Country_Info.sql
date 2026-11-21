
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get country information
-- =============================================

-- EXEC [USP_GN_Country_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Country_Info]	
	@IDX_M_Country			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IDX_M_Country, CountryID, CountryName, 
		DCreate, UCreate, DModified, UModified, Recordstatus		
	FROM GN_M_Country	
	WHERE IDX_M_Country = @IDX_M_Country
	
END



