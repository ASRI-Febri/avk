-- =============================================
-- Author:		Jonathan
-- Create date: 2023-06-02
-- Description:	Search Sales Order by value (for ajax searching)
-- =============================================

-- USP_CM_SalesOrderSearchByValue_List ''

CREATE PROCEDURE [dbo].[USP_CM_SalesOrderSearchByValue_List] 
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

    SET @_SqlSelect = '	SELECT
							a.OrderNo ' 							
	
	SET @_SqlFrom = 'FROM SA_T_SalesOrder a '

	SET @_SqlWhere = 'WHERE a.RecordStatus = ''A'' AND (
						RTRIM(ISNULL(a.OrderNo,''''))  LIKE ''' + @SearchValue + ''')' 

	PRINT(@_SqlSelect + @_SqlFrom + @_SqlWhere)
	EXEC(@_SqlSelect + @_SqlFrom + @_SqlWhere)
END
