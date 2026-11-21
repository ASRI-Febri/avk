/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Tax List

/*	
	EXEC [dbo].[USP_GL_Tax_List] 1,10,'RowNumber','asc','R','','','','','','',''
	EXEC [dbo].[USP_GL_Tax_List] 1,10,'RowNumber','asc','C','','','','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_Tax_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@Name					VARCHAR(50),
	@Alias					VARCHAR(50),
	@Notes					VARCHAR(50),
	@COA_ID_IN				VARCHAR(30),
	@COA_Desc_IN			VARCHAR(50),
	@COA_ID_OUT				VARCHAR(30),
	@COA_Desc_OUT			VARCHAR(50)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_Name					AS VARCHAR(50)
	DECLARE @_Alias					AS VARCHAR(50)
	DECLARE @_Notes					AS VARCHAR(50)
	DECLARE @_COA_ID_IN				AS VARCHAR(50)
	DECLARE @_COA_Desc_IN			AS VARCHAR(50)
	DECLARE @_COA_ID_OUT			AS VARCHAR(50)
	DECLARE @_COA_Desc_OUT			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_Name = '%' + RTRIM(@Name) + '%'	
	SET @_Alias = '%' + RTRIM(@Alias) + '%'
	SET @_Notes = '%' + RTRIM(@Notes) + '%'
	SET @_COA_ID_IN = '%' + RTRIM(@COA_ID_IN) + '%'	
	SET @_COA_Desc_IN = '%' + RTRIM(@COA_Desc_IN) + '%'	
	SET @_COA_ID_OUT = '%' + RTRIM(@COA_ID_OUT) + '%'	
	SET @_COA_Desc_OUT = '%' + RTRIM(@COA_Desc_OUT) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_Tax ' + @SortDir
		SET @_Sort2 = ' IDX_M_Tax ' + @SortDir
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
								IDX_M_Tax, Name, Alias, BaseAmount, Value, Notes, COAIn, C.COAID AS COAID_In, C.COADesc AS COADesc_In, 
								COAOut, D.COAID AS COAID_Out, D.COADesc AS COADesc_Out, IsWithHoldingTax, GMT.RecordStatus, 
								StatusDesc = CASE GMT.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GL_M_Tax GMT 
					LEFT JOIN GL_M_COA C ON C.IDX_M_COA = COAIn 
					LEFT JOIN GL_M_COA D ON D.IDX_M_COA = COAOut '

	SET @SqlWhere = 'WHERE ISNULL(Alias,'''')  LIKE ''' + @_Alias + 						 
						''' AND RTRIM(ISNULL(Notes,'''')) LIKE ''' + @_Notes + 
						''' AND RTRIM(ISNULL(C.COAID,'''')) LIKE ''' + @_COA_ID_IN +
						''' AND RTRIM(ISNULL(C.COADesc,'''')) LIKE ''' + @_COA_Desc_IN +
						''' AND RTRIM(ISNULL(D.COAID,'''')) LIKE ''' + @_COA_ID_OUT +
						''' AND RTRIM(ISNULL(D.COADesc,'''')) LIKE ''' + @_COA_Desc_OUT +
						''' AND RTRIM(Name) LIKE ''' + @_Name + ''''

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







