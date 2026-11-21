/* =============================================
Author			: ANGGI ROSLIANA	
Create date		: 9 JANUARI 2019
Description		: Master COA GROUP 1 List 

/*	
	EXEC [dbo].[USP_GL_COAGroup1_List] 1,10,'RowNumber','asc','R','','','',''	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_COAGroup1_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	------------------------------------------------------------	
	@COATypeDesc			VARCHAR(256),
	@COAGroup1ID			VARCHAR(50),
	@COAGroup1Name1			VARCHAR(150),
	@COAGroup1Name2			VARCHAR(150)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_COATypeDesc			AS VARCHAR(256)
	DECLARE @_COAGroup1ID			AS VARCHAR(50)
	DECLARE @_COAGroup1Name1		AS VARCHAR(150)
	DECLARE @_COAGroup1Name2		AS VARCHAR(150)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_COATypeDesc = '%' + RTRIM(@COATypeDesc) + '%'	
	SET @_COAGroup1ID = '%' + RTRIM(@COAGroup1ID) + '%'	
	SET @_COAGroup1Name1 = '%' + RTRIM(@COAGroup1Name1) + '%'
	SET @_COAGroup1Name2 = '%' + RTRIM(@COAGroup1Name2) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_COAGroup1 ' + @SortDir
		SET @_Sort2 = ' IDX_M_COAGroup1 ' + @SortDir
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
								,IDX_M_COAGroup1
								,CG1.IDX_M_COAType
								,CT.COATypeDesc
								,COAGroup1ID
								,COAGroup1Name1
								,COAGroup1Name2
								,CG1.RecordStatus
								,StatusDesc = CASE CG1.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_COAGroup1 CG1
					LEFT JOIN GL_M_COAType CT ON CT.IDX_M_COAType = CG1.IDX_M_COAType '
	

	SET @SqlWhere = 'WHERE ISNULL(CT.COATypeDesc,'''')  LIKE ''' + @_COATypeDesc + 
						''' AND RTRIM(ISNULL(COAGroup1ID,'''')) LIKE ''' + @_COAGroup1ID + 
						''' AND RTRIM(ISNULL(COAGroup1Name1,'''')) LIKE ''' + @_COAGroup1Name1 + 
						''' AND RTRIM(COAGroup1Name2) LIKE ''' + @_COAGroup1Name2 + ''''

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








