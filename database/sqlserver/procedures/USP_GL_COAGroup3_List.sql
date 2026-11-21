/* =============================================
Author			: Anton
Create date		: 11 JANUARI 2019
Description		: Master COA GROUP 3 List 

/*	
	EXEC [dbo].[USP_GL_M_COAGroup3_List] 1,10,'RowNumber','asc','R','','','',''
	EXEC [dbo].[USP_GL_M_COAGroup3_List] 1,10,'RowNumber','asc','C','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_COAGroup3_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	------------------------------------------------------------	
	@COAGroup2Name1			VARCHAR(150),
	@COAGroup3ID			VARCHAR(50),
	@COAGroup3Name1			VARCHAR(150),
	@COAGroup3Name2			VARCHAR(150)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_COAGroup2Name1		AS VARCHAR(150)
	DECLARE @_COAGroup3ID			AS VARCHAR(50)
	DECLARE @_COAGroup3Name1		AS VARCHAR(150)
	DECLARE @_COAGroup3Name2		AS VARCHAR(150)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_COAGroup2Name1 = '%' + RTRIM(@COAGroup2Name1) + '%'	
	SET @_COAGroup3ID = '%' + RTRIM(@COAGroup3ID) + '%'	
	SET @_COAGroup3Name1 = '%' + RTRIM(@COAGroup3Name1) + '%'
	SET @_COAGroup3Name2 = '%' + RTRIM(@COAGroup3Name2) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_COAGroup3 ' + @SortDir
		SET @_Sort2 = ' IDX_M_COAGroup3 ' + @SortDir
	END		

	-- SET Paging and Row Number
	IF @Page = 1
	BEGIN
		SET @FromRow = 1
		SET @ToRow = @Row
	END

	IF @Page > 1
	BEGIN
		SET @FromRow = ((@Page * @Row) - @Row) + 1
		SET @ToRow = @FromRow + @Row - 1		
	END

	SET @SqlSelect = '	SELECT * FROM (
							SELECT 
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber
								,IDX_M_COAGroup3
								,CG3.IDX_M_COAGroup2
								,CG2.COAGroup2Name1
								,COAGroup3ID
								,COAGroup3Name1
								,COAGroup3Name2
								,CG2.RecordStatus
								,StatusDesc = CASE CG3.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_COAGroup3 CG3
					LEFT JOIN GL_M_COAGroup2 CG2 ON CG2.IDX_M_COAGroup2 = CG3.IDX_M_COAGroup2 '

	SET @SqlWhere = 'WHERE ISNULL(CG2.COAGroup2Name1,'''')  LIKE ''' + @_COAGroup2Name1 + 
					''' AND RTRIM(ISNULL(COAGroup3ID,'''')) LIKE ''' + @_COAGroup3ID + 
					''' AND RTRIM(ISNULL(COAGroup3Name1,'''')) LIKE ''' + @_COAGroup3Name1 + 
					''' AND RTRIM(COAGroup3Name2) LIKE ''' + @_COAGroup3Name2 + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ''

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END

END








