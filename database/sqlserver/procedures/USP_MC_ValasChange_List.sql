
/* =============================================
Author			: Samuel Febrianto
Create date		: 04 Jun 2025
Description		: Valas change list (pecahan uang valas)

/*	
	EXEC [dbo].[USP_MC_ValasChange_List] 1,10,'RowNumber','asc','R','','',''
	EXEC [dbo].[USP_MC_ValasChange_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_MC_ValasChange_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
    ---------------------------------------------------------------
	@ValasChangeID		    VARCHAR(50),
	@ValasChangeName	    VARCHAR(50),
	@ValasChangeNumber		VARCHAR(50)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_ValasChangeID	        AS VARCHAR(50)
    DECLARE @_ValasChangeName	    AS VARCHAR(50)
	DECLARE @_ValasChangeNumber		AS VARCHAR(50)	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_ValasChangeID = '%' + RTRIM(@ValasChangeID) + '%'	
	SET @_ValasChangeName = '%' + RTRIM(@ValasChangeName) + '%'
	SET @_ValasChangeNumber = '%' + RTRIM(@ValasChangeNumber) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_ValasChange ' + @SortDir
		SET @_Sort2 = ' IDX_M_ValasChange ' + @SortDir
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
								IDX_M_ValasChange, ValasChangeID, ValasChangeName, ValasChangeNumber, RecordStatus, 
								StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM MC_M_ValasChange '

	SET @SqlWhere = 'WHERE ISNULL(ValasChangeName,'''')  LIKE ''' + @_ValasChangeName + 
						''' AND RTRIM(ISNULL(ValasChangeNumber,'''')) LIKE ''' + @_ValasChangeNumber +						
						''' AND RTRIM(ValasChangeID) LIKE ''' + @_ValasChangeID + ''''

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







