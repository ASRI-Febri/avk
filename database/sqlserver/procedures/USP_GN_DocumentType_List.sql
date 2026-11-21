
/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: List of Document Type

/*	
	EXEC [dbo].[USP_GN_DocumentType_List] 1,10,'RowNumber','asc','R','','',''
	EXEC [dbo].[USP_GN_DocumentType_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GN_DocumentType_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@DocumentTypeDesc		VARCHAR(50),
	@DocumentTypeID			VARCHAR(50),
	@DocumentTypeCategory	VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
	DECLARE @FromRow					AS INT
	DECLARE @ToRow						AS INT
	-------------------------------------------------------------
	DECLARE @_DocumentTypeDesc			AS VARCHAR(50)
	DECLARE @_DocumentTypeID			AS VARCHAR(50)
	DECLARE @_DocumentTypeCategory		AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1						AS VARCHAR(100)
	DECLARE @_Sort2						AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect					AS VARCHAR(5000)
	DECLARE @SqlFrom					AS VARCHAR(5000)
	DECLARE @SqlWhere					AS VARCHAR(5000)
	DECLARE @SqlLimit					AS VARCHAR(5000)
	DECLARE @SqlOrder					AS VARCHAR(5000)

	SET @_DocumentTypeDesc = '%' + RTRIM(@DocumentTypeDesc) + '%'	
	SET @_DocumentTypeID = '%' + RTRIM(@DocumentTypeID) + '%'
	SET @_DocumentTypeCategory = '%' + RTRIM(@DocumentTypeCategory) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_DocumentType ' + @SortDir
		SET @_Sort2 = ' IDX_M_DocumentType ' + @SortDir
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
								IDX_M_DocumentType, DocumentTypeCategory, DocumentTypeID, DocumentTypeDesc, InFlag, OutFlag, 
								ARAccount, ARAccountDesc = CAR.COADesc, APAccount, APAccountDesc = CAP.COADesc, 
								MDT.RecordStatus, StatusDesc = CASE MDT.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GN_M_DocumentType MDT 
					LEFT JOIN GL_M_COA CAR ON CAR.IDX_M_COA = ARAccount 
					LEFT JOIN GL_M_COA CAP ON CAP.IDX_M_COA = APAccount '

	SET @SqlWhere = 'WHERE ISNULL(DocumentTypeDesc,'''')  LIKE ''' + @_DocumentTypeDesc + 
						''' AND RTRIM(ISNULL(DocumentTypeID,'''')) LIKE ''' + @_DocumentTypeID + 
						''' AND RTRIM(DocumentTypeCategory) LIKE ''' + @_DocumentTypeCategory + ''''

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








