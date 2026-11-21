-- =============================================
-- Author:		Jonathan
-- Create date: 2023-04-24
-- Description:	Search COA Account by value (for ajax searching)
-- =============================================

-- USP_CM_COAAccountSearchByValue_List ''

CREATE PROCEDURE [dbo].[USP_CM_COAAccountSearchByValue_List] 
	@SearchValue		VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SqlSelect			VARCHAR(1000)
	DECLARE @_SqlFrom			VARCHAR(1000)
	DECLARE @_SqlWhere			VARCHAR(1000)

	SET @SearchValue = '%' + RTRIM(@SearchValue) + '%'

    SET @_SqlSelect = '	SELECT TOP 200 COA.IDX_M_COA, COA.COAID, COA.COADesc  ' 							
	
	SET @_SqlFrom = 'FROM GL_M_COA COA '

	SET @_SqlWhere = 'WHERE COA.RecordStatus = ''A'' AND COA.AllowJournalEntry = ''Y'' AND (
						RTRIM(ISNULL(COA.COAID,''''))  LIKE ''' + @SearchValue + ''' 
						OR RTRIM(ISNULL(COA.COADesc,'''')) LIKE ''' + @SearchValue + ''')' 

	PRINT(@_SqlSelect + @_SqlFrom + @_SqlWhere)
	EXEC(@_SqlSelect + @_SqlFrom + @_SqlWhere)
END
