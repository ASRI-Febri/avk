
/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Chart of Account List

/*	
	EXEC [dbo].[USP_GL_COA_List] 1,10,'RowNumber','asc','R','','','kas'
	EXEC [dbo].[USP_GL_COA_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_COA_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@COA					VARCHAR(50),
	@COADesc				VARCHAR(50),
	@COADesc2				VARCHAR(50),
	@COAGroup1Name1			VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_COA					AS VARCHAR(50)
	DECLARE @_COADesc				AS VARCHAR(50)
	DECLARE @_COADesc2				AS VARCHAR(50)
	DECLARE @_COAGroup1Name1		AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_COA = '%' + RTRIM(@COA) + '%'	
	SET @_COADesc = '%' + RTRIM(@COADesc) + '%'
	SET @_COADesc2 = '%' + RTRIM(@COADesc2) + '%'
	SET @_COAGroup1Name1 = '%' + RTRIM(@COAGroup1Name1) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_COA ' + @SortDir
		SET @_Sort2 = ' IDX_M_COA ' + @SortDir
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
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, 
								IDX_M_COA, COAID, COADesc, COADesc2, 
								C1.COAGroup1ID, C1.COAGroup1Name1,
								C.RecordStatus, 
								StatusDesc = CASE C.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_COA C
					LEFT JOIN GL_M_COAGroup1 C1 ON C1.IDX_M_COAGroup1 = ISNULL(C.COAGroup1, 0) '

	SET @SqlWhere = 'WHERE ISNULL(COADesc,'''')  LIKE ''' + @_COADesc + 
						''' AND RTRIM(ISNULL(COADesc2,'''')) LIKE ''' + @_COADesc2 + 
						''' AND RTRIM(ISNULL(COAGroup1Name1,'''')) LIKE ''' + @_COAGroup1Name1 + 
						''' AND RTRIM(COAID) LIKE ''' + @_COA + ''''

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







