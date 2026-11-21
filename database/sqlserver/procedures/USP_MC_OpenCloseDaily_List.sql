/* =============================================
Author			: Samuel Febrianto
Create date		: 10 Dec 2025
Description		: Opening and Closing Daily

/*
	EXEC [dbo].[USP_MC_OpenCloseDaily_List] 1,10,'IDX_T_OpenCloseDaily','asc','R','','','it_febry'	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDaily_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	---------------------------------------------------------------------
	@TransactionDate   	    VARCHAR(50),
	@TellerName				VARCHAR(50),
	@UserID                 VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_TransactionDate		AS VARCHAR(50)
	DECLARE @_TellerName			AS VARCHAR(50)	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_TransactionDate = '%' + RTRIM(@TransactionDate) + '%'
	SET @_TellerName = '%' + RTRIM(@TellerName) + '%'
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID' OR RTRIM(@SortBy) = 'IDX_T_OpenCloseDaily'
	BEGIN
		SET @_Sort1 = ' OC.IDX_T_OpenCloseDaily ' + @SortDir
		SET @_Sort2 = ' IDX_T_OpenCloseDaily ' + @SortDir
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
								OC.IDX_T_OpenCloseDaily, CONVERT(VARCHAR, OC.TransactionDate, 106) AS TransactionDate, 
                                OC.TransactionStatus, StatusDesc = CASE OC.TransactionStatus WHEN ''O'' THEN ''Open'' ELSE ''Close'' END,
                                OC.TellerID, OC.RecordStatus,
                                U.Name AS TellerName ' 	

	SET @SqlFrom = 'FROM MC_T_OpenCloseDaily OC
                    LEFT JOIN SM_M_User U ON RTRIM(U.LoginID) = RTRIM(OC.TellerID) '

	SET @SqlWhere = 'WHERE ISNULL(CONVERT(VARCHAR, OC.TransactionDate, 106),'''')  LIKE ''' + @_TransactionDate + 
						''' AND RTRIM(ISNULL(U.Name,'''')) LIKE ''' + @_TellerName + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ' ORDER BY ' + @_Sort2

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END

END
