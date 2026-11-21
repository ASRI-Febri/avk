
/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Financial Account List

/*	
	EXEC [dbo].[USP_CM_FinancialAccount_List] 1,10,'RowNumber','asc','R','','','',''
	EXEC [dbo].[USP_CM_FinancialAccount_List] 1,10,'RowNumber','asc','C','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_FinancialAccount_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@FinancialAccountID		VARCHAR(50),
	@FinancialAccountDesc	VARCHAR(50),
	@AccountNo				VARCHAR(50),
	@AccountName			VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_FinancialAccountID	AS VARCHAR(50)
	DECLARE @_FinancialAccountDesc	AS VARCHAR(50)
	DECLARE @_AccountNo				AS VARCHAR(50)
	DECLARE @_AccountName			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_FinancialAccountID = '%' + RTRIM(@FinancialAccountID) + '%'	
	SET @_FinancialAccountDesc = '%' + RTRIM(@FinancialAccountDesc) + '%'
	SET @_AccountNo = '%' + RTRIM(@AccountNo) + '%'
	SET @_AccountName = '%' + RTRIM(@AccountName) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_M_FinancialAccount ' + @SortDir
		SET @_Sort2 = ' IDX_M_FinancialAccount ' + @SortDir
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
								IDX_M_FinancialAccount, FinancialAccountID, FinancialAccountDesc, AccountNo, AccountName, RecordStatus, 
								StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM CM_M_FinancialAccount '

	SET @SqlWhere = 'WHERE ISNULL(FinancialAccountDesc,'''')  LIKE ''' + @_FinancialAccountDesc + 
						''' AND RTRIM(ISNULL(AccountNo,'''')) LIKE ''' + @_AccountNo +
						''' AND RTRIM(ISNULL(AccountName,'''')) LIKE ''' + @_AccountName + 
						''' AND RTRIM(FinancialAccountID) LIKE ''' + @_FinancialAccountID + ''''

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







