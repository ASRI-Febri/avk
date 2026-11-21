

/* =============================================
Author			: Samuel Febrianto
Create date		: 30 Oct 2025
Description		: Currency List

/*	
	EXEC [dbo].[USP_MC_Currency_List] 1,10,'RowNumber','asc','R','','',''
	EXEC [dbo].[USP_MC_Currency_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_MC_Currency_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	--------------------------------------------------------------------
	@CurrencyName			VARCHAR(50),
	@CurrencyID				VARCHAR(50),
	@CountryName			VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_CurrencyName			AS VARCHAR(50)
	DECLARE @_CurrencyID			AS VARCHAR(50)
	DECLARE @_CountryName			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_CurrencyName = '%' + RTRIM(@CurrencyName) + '%'	
	SET @_CurrencyID = '%' + RTRIM(@CurrencyID) + '%'
	SET @_CountryName = '%' + RTRIM(@CountryName) + '%'
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_Currency ' + @SortDir
		SET @_Sort2 = ' IDX_M_Currency ' + @SortDir
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
								CU.IDX_M_Currency, [CurrencyID],[CurrencyName],
								CountryID, IconFlag, CountryName, 
								CU.BuyRate, CU.SellRate, 	
								CU.RecordStatus, 
								StatusDesc = CASE CU.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM MC_M_Currency CU
					LEFT JOIN GN_M_Country CO ON CO.IDX_M_Country = CU.IDX_M_Country '

	SET @SqlWhere = 'WHERE ISNULL(CurrencyName,'''')  LIKE ''' + @_CurrencyName +  
						''' AND RTRIM(ISNULL(CurrencyID,'''')) LIKE ''' + @_CurrencyID +
						''' AND RTRIM(ISNULL(CountryName,'''')) LIKE ''' + @_CountryName + ''''

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








