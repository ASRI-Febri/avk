-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 30 Mei 2023
-- Description:	Search chart ofn account based on parameter
-- =============================================

-- USP_GL_COASearch_List 'piutang'

CREATE PROCEDURE [dbo].[USP_GL_COASearch_List] 
	@SearchValue		VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SearchValue				AS  VARCHAR(100)

	SET @_SearchValue	= '%' + RTRIM(@SearchValue) + '%'

    -- Insert statements for procedure here
	SELECT IDX_M_COA, COAID, COADesc, COADesc2
	FROM GL_M_COA
	WHERE RecordStatus = 'A' AND AllowJournalEntry = 'Y'  
		AND (RTRIM(ISNULL(COAID,'')) LIKE @_SearchValue OR RTRIM(ISNULL(COADesc,'')) LIKE @_SearchValue)
	ORDER BY COADesc

END
