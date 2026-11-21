
/* =============================================
Author			: Samuel Febrianto
Create date		: 04 Jun 2025
Description		: Valas list (uang valas)

/*	
	EXEC [dbo].[USP_MC_Valas_List] 1,10,'RowNumber','asc','R','','','','',''
	EXEC [dbo].[USP_MC_Valas_List] 1,10,'RowNumber','asc','C','','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_MC_Valas_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
    ---------------------------------------------------------------
	@CurrencyID				VARCHAR(50),
	@CurrencyName		    VARCHAR(50),
	@ValasName				VARCHAR(50),
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
	DECLARE @_CurrencyID	        AS VARCHAR(50)
	DECLARE @_CurrencyName	        AS VARCHAR(50)
	DECLARE @_ValasName				AS VARCHAR(50)
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

	SET @_CurrencyID = '%' + RTRIM(@CurrencyID) + '%'
	SET @_CurrencyName = '%' + RTRIM(@CurrencyName) + '%'	
	SET @_ValasName = '%' + RTRIM(@ValasName) + '%'
	SET @_ValasChangeName = '%' + RTRIM(@ValasChangeName) + '%'
	SET @_ValasChangeNumber = '%' + RTRIM(@ValasChangeNumber) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_Valas ' + @SortDir
		SET @_Sort2 = ' IDX_M_Valas ' + @SortDir
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
								MV.IDX_M_Valas, MV.ValasSKU, EffectiveDate,
								C.CurrencyID, C.CurrencyName, MV.ValasName, 
								MVC.ValasChangeName, MVC.ValasChangeNumber,
								BuyValue, SellValue, MV.RecordStatus,
								StatusDesc = CASE MV.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM MC_M_Valas MV 
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
					LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange '

	SET @SqlWhere = 'WHERE ISNULL(ValasChangeName,'''')  LIKE ''' + @_ValasChangeName + 
						''' AND RTRIM(ISNULL(ValasChangeNumber,'''')) LIKE ''' + @_ValasChangeNumber +	
						''' AND RTRIM(ISNULL(C.CurrencyID,'''')) LIKE ''' + @_CurrencyID +	
						''' AND RTRIM(ISNULL(MV.ValasName,'''')) LIKE ''' + @_ValasName +						
						''' AND RTRIM(CurrencyName) LIKE ''' + @_CurrencyName + ''''

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







