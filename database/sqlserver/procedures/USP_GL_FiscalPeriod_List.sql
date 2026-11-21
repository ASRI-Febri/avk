/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: FiscalPeriod List for Financial Application

/*	
	EXEC [dbo].[USP_GL_FiscalPeriod_List] 1,15,'RowNumber','asc','R','','','','',''
	EXEC [dbo].[USP_GL_FiscalPeriod_List] 1,10,'RowNumber','asc','C','','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_FiscalPeriod_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@FiscalPeriod			VARCHAR(50),
	@CompanyName			VARCHAR(50),
	@BranchName				VARCHAR(50),
	@StartDate				VARCHAR(10),
	@EndDate				VARCHAR(10)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_FiscalPeriod			AS VARCHAR(50)
	DECLARE @_CompanyName			AS VARCHAR(50)
	DECLARE @_BranchName			AS VARCHAR(50)
	DECLARE @_StartDate				AS VARCHAR(50)
	DECLARE @_EndDate				AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_FiscalPeriod = '%' + RTRIM(@FiscalPeriod) + '%'	
	SET @_CompanyName = '%' + RTRIM(@CompanyName) + '%'
	SET @_BranchName = '%' + RTRIM(@BranchName) + '%'
	SET @_StartDate = '%' + RTRIM(@StartDate) + '%'
	SET @_EndDate = '%' + RTRIM(@EndDate) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_FiscalPeriod ' + @SortDir		
	END	
	
	IF RTRIM(@SortBy) = 'CompanyName' 
	BEGIN
		SET @_Sort1 = ' GC.Name ' + @SortDir		
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
								IDX_M_FiscalPeriod, GC.Code AS CompanyID, GC.Name AS CompanyName, MB.BranchID, MB.BranchName, FP.FiscalPeriod, 
								CONVERT(VARCHAR,FP.StartDate,106) AS StartDate, CONVERT(VARCHAR,FP.EndDate,106) AS EndDate, FP.GLStatus, 
								FP.RecordStatus, StatusDesc = CASE FP.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_FiscalPeriod FP 
					LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = FP.IDX_M_Company
					LEFT JOIN GN_M_Branch MB ON MB.IDX_M_Branch = FP.IDX_M_Branch '

	SET @SqlWhere = 'WHERE ISNULL(FiscalPeriod,'''')  LIKE ''' + @_FiscalPeriod + 
						''' AND RTRIM(ISNULL(Name,'''')) LIKE ''' + @_CompanyName + 
						''' AND CONVERT(VARCHAR,FP.StartDate,106) LIKE ''' + @_StartDate + 
						''' AND CONVERT(VARCHAR,FP.EndDate,106) LIKE ''' + @_EndDate + 
						''' AND RTRIM(ISNULL(BranchName,'''')) LIKE ''' + @_BranchName + ''''

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







