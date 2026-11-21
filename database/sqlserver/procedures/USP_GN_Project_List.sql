/* =============================================
Author			: Anton
Create date		: 2021-10-05
Description		: Master Project List 
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GN_Project_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	------------------------------------------------------------	
	@ProjectID				VARCHAR(50),
    @ProjectName			VARCHAR(150),
    @ProjectDesc			VARCHAR(500)

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_ProjectID				AS VARCHAR(50)
	DECLARE @_ProjectName			AS VARCHAR(150)
	DECLARE @_ProjectDesc			AS VARCHAR(500)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_ProjectID	= '%' + RTRIM(@ProjectID) + '%'	
	SET @_ProjectName = '%' + RTRIM(@ProjectName) + '%'	
	SET @_ProjectDesc = '%' + RTRIM(@ProjectDesc) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_Project'
	BEGIN
		SET @_Sort1 = ' IDX_M_Project ' + @SortDir
		SET @_Sort2 = ' IDX_M_Project ' + @SortDir
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
								 ,IDX_M_Project
								 ,ProjectID
								 ,ProjectName
								 ,ProjectDesc
								 ,RecordStatus
								 ,StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM dbo.GN_M_Project WITH(NOLOCK)'
					
	SET @SqlWhere = 'WHERE ISNULL(ProjectID,'''')  LIKE ''' + @_ProjectID + 
						''' AND RTRIM(ISNULL(ProjectName,'''')) LIKE ''' + @_ProjectName + 
						''' AND RTRIM(ISNULL(ProjectDesc,'''')) LIKE ''' + @_ProjectDesc + ''''

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








