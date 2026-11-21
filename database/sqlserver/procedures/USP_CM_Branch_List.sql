/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: Branch List for Financial Application

/*	
	EXEC [dbo].[USP_CM_Branch_List] 1,10,'RowNumber','asc','R','','',''
	EXEC [dbo].[USP_CM_Branch_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_Branch_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@BranchName				VARCHAR(50),
	@BranchAlias			VARCHAR(50),
	@BranchAddress			VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_BranchName			AS VARCHAR(50)
	DECLARE @_BranchAlias			AS VARCHAR(50)
	DECLARE @_BranchAddress		AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_BranchName = '%' + RTRIM(@BranchName) + '%'	
	SET @_BranchAlias = '%' + RTRIM(@BranchAlias) + '%'
	SET @_BranchAddress = '%' + RTRIM(@BranchAddress) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_Branch ' + @SortDir
		SET @_Sort2 = ' IDX_M_Branch ' + @SortDir
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
								IDX_M_Branch, BranchID, BranchName, BranchAlias, BranchAddress, 
								RecordStatus, StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GN_M_Branch '

	SET @SqlWhere = 'WHERE ISNULL(BranchName,'''')  LIKE ''' + @_BranchName + 
						''' AND RTRIM(ISNULL(BranchAlias,'''')) LIKE ''' + @_BranchAlias + 
						''' AND RTRIM(BranchAddress) LIKE ''' + @_BranchAddress + ''''

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







