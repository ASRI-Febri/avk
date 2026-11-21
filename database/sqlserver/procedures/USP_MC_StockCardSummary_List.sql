
-- =============================================================
-- Author		: Febry
-- Create date	: 2025-06-20
-- Description	: Transaction stock card list
-- =============================================================

-- [USP_MC_StockCardSummary_List] 1, 10, ValasSKU, 'ASC', 'R', '', '',''

CREATE PROCEDURE [dbo].[USP_MC_StockCardSummary_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count			
	-------------------------------------------------------------
	@BranchName				VARCHAR(500),
	@ValasSKU				VARCHAR(255),
	@ValasName				VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_BranchName			AS VARCHAR(500)	
	DECLARE @_ValasSKU				AS VARCHAR(500)	
	DECLARE @_ValasName				AS VARCHAR(500)	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)
	DECLARE @SqlGroup				AS VARCHAR(5000)
	-------------------------------------------------------------
	DECLARE @_FilterStatus			AS VARCHAR(5000) --FOR SPECIFIC RECEIVE STATUS

	SET @_BranchName = '%' + RTRIM(@BranchName) + '%' 	
	SET @_ValasSKU = '%' + RTRIM(@ValasSKU) + '%' 
	SET @_ValasName = '%' + RTRIM(@ValasName) + '%' 
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir
	


	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID' OR RTRIM(@SortBy) = 'IDX_M_Valas'
	BEGIN
		SET @_Sort1 = ' S.[IDX_M_Valas] ' + @SortDir
		SET @_Sort2 = ' S.[IDX_M_Valas] ' + @SortDir
	END	
		
	IF RTRIM(@SortBy) = 'BranchName'
	BEGIN
		SET @_Sort1 = ' L.BranchName ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'ValasName'
	BEGIN
		SET @_Sort1 = ' MV.ValasName ' + @SortDir
	END		

	IF RTRIM(@SortBy) = 'ValasSKU'
	BEGIN
		SET @_Sort1 = ' MV.ValasSKU ' + @SortDir
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
								S.IDX_M_Valas, L.BranchID, L.BranchName, MV.ValasSKU, MV.ValasName, 
								SUM(StockInQty) AS StockInQty, SUM(S.StockInForeignAmount) AS StockInForeignAmount, 
								SUM(StockOutQty) AS StockOutQty, SUM(S.StockOutForeignAmount) AS StockOutForeignAmount,
								BalanceQty = SUM(StockInQty) - SUM(StockOutQty),
								BalanceForeignAmount = SUM(S.StockInForeignAmount) - SUM(S.StockOutForeignAmount) ' 	
								 							
	SET @SqlFrom = 'FROM [dbo].MC_T_StockCardValas S 
					LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch
					LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange '

	SET @SqlWhere = 'WHERE ISNULL(L.[BranchName],'''') LIKE ''' + @_BranchName + 
						''' AND ISNULL(RTRIM(MV.ValasName),'''') LIKE ''' + @_ValasName + 
						''' AND ISNULL(RTRIM(MV.ValasSKU),'''') LIKE ''' + @_ValasSKU + ''''

	SET @SqlGroup = 'GROUP BY L.BranchID, L.BranchName, S.IDX_M_Valas, MV.ValasSKU, MV.ValasName '

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	--SET @SqlOrder = ' ORDER BY ' + @_Sort2

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlGroup + @SqlLimit)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere + @SqlGroup)		
	END

END








