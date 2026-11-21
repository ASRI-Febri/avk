/* =============================================
Author			: ANGGI ROSLIANA	
Create date		: 9 JANUARI 2019
Description		: Master COA GROUP 2 List 

/*	
	EXEC [dbo].[USP_GL_M_COAGroup2_List] 1,10,'RowNumber','asc','R','','','',''
	EXEC [dbo].[USP_GL_M_COAGroup2_List] 1,10,'RowNumber','asc','C','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_COAGroup2_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	------------------------------------------------------------	
	@COAGroup1Name1			VARCHAR(150),
	@COAGroup2ID			VARCHAR(50),
	@COAGroup2Name1			VARCHAR(150),
	@COAGroup2Name2			VARCHAR(150)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_COAGroup1Name1		AS VARCHAR(150)
	DECLARE @_COAGroup2ID			AS VARCHAR(50)
	DECLARE @_COAGroup2Name1		AS VARCHAR(150)
	DECLARE @_COAGroup2Name2		AS VARCHAR(150)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_COAGroup1Name1 = '%' + RTRIM(@COAGroup1Name1) + '%'	
	SET @_COAGroup2ID = '%' + RTRIM(@COAGroup2ID) + '%'	
	SET @_COAGroup2Name1 = '%' + RTRIM(@COAGroup2Name1) + '%'
	SET @_COAGroup2Name2 = '%' + RTRIM(@COAGroup2Name2) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_COAGroup2 ' + @SortDir
		SET @_Sort2 = ' IDX_M_COAGroup2 ' + @SortDir
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
								,IDX_M_COAGroup2
								,CG2.IDX_M_COAGroup1
								,CG1.COAGroup1Name1
								,COAGroup2ID
								,COAGroup2Name1
								,COAGroup2Name2
								,CG2.RecordStatus
								,StatusDesc = CASE CG2.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_COAGroup2 CG2
					LEFT JOIN GL_M_COAGroup1 CG1 ON CG1.IDX_M_COAGroup1 = CG2.IDX_M_COAGroup1 '

	SET @SqlWhere = 'WHERE ISNULL(CG1.COAGroup1Name1,'''')  LIKE ''' + @_COAGroup1Name1 + 
					''' AND RTRIM(ISNULL(COAGroup2ID,'''')) LIKE ''' + @_COAGroup2ID + 
					''' AND RTRIM(ISNULL(COAGroup2Name1,'''')) LIKE ''' + @_COAGroup2Name1 + 
					''' AND RTRIM(COAGroup2Name2) LIKE ''' + @_COAGroup2Name2 + ''''

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








