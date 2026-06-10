SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author			: Samuel Febrianto
Create date		: 5 Jun 2025
Description		: Sales order list for money changer


/*
	EXEC [dbo].[USP_MC_SalesOrder_List] 1,10,'CompanyName','asc','R','','','','','','it_febry'
	EXEC [dbo].[USP_MC_SalesOrder_List] 1,100,'CompanyName','asc','R','','','','','','it_febry'
*/
-- ============================================= */

ALTER PROCEDURE [dbo].[USP_MC_SalesOrder_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	---------------------------------------------------------------------
	@CompanyName			VARCHAR(50),
	@BranchName				VARCHAR(50),
	@SONumber				VARCHAR(50),
	@SONotes				VARCHAR(50),
	@PartnerName			VARCHAR(50),
	@UserID					VARCHAR(50),
	@ReferenceNo			VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_CompanyName			AS VARCHAR(50)
	DECLARE @_BranchName			AS VARCHAR(50)
	DECLARE @_SONumber				AS VARCHAR(50)
	DECLARE @_SONotes				AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_ReferenceNo			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_CompanyName = '%' + RTRIM(@CompanyName) + '%'
	SET @_BranchName = '%' + RTRIM(@BranchName) + '%'
	SET @_SONumber = '%' + RTRIM(@SONumber) + '%'	
	SET @_SONotes = '%' + RTRIM(@SONotes) + '%'
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'	
	SET @_ReferenceNo = '%' + RTRIM(@ReferenceNo) + '%'

	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID' OR RTRIM(@SortBy) = 'IDX_T_SalesOrder'
	BEGIN
		SET @_Sort1 = ' SO.IDX_T_SalesOrder ' + @SortDir
		SET @_Sort2 = ' SO.IDX_T_SalesOrder ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'PartnerName'
	BEGIN
		SET @_Sort1 = ' GMP.PartnerName ' + @SortDir
		SET @_Sort2 = ' GMP.PartnerName ' + @SortDir
	END		

	IF RTRIM(@SortBy) = 'CompanyName'
	BEGIN
		SET @_Sort1 = ' CompanyName ' + @SortDir
		SET @_Sort2 = ' CompanyName ' + @SortDir
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
								SO.IDX_T_SalesOrder, C.CompanyName, B.BranchName,
								SO.ReferenceNo,
								SO.SONumber, SODate, PartnerName, SONotes, SOStatus,
								StatusDesc = CASE SOStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void''
								WHEN ''C'' THEN ''Cancel'' WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END,
								TotalAmount = ISNULL(SOD.TotalAmount, 0) '

	SET @SqlFrom = 'FROM MC_T_SalesOrder SO
					LEFT JOIN GN_M_Company C ON C.IDX_M_Company = SO.IDX_M_Company
					LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = SO.IDX_M_Branch
					LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = SO.IDX_M_Partner
					LEFT JOIN ( SELECT IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS TotalAmount
								FROM MC_T_SalesOrderDetail WITH(NOLOCK)
								WHERE RecordStatus = ''A''
								GROUP BY IDX_T_SalesOrder ) SOD ON SOD.IDX_T_SalesOrder = SO.IDX_T_SalesOrder
					INNER JOIN ( SELECT B.IDX_M_Branch
								FROM SM_M_User A WITH(NOLOCK)
								INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
								WHERE B.RecordStatus = ''A'' AND RTRIM(A.LoginID) = ''' + @UserID + ''') UB ON SO.IDX_M_Branch = UB.IDX_M_Branch '

	SET @SqlWhere = 'WHERE ISNULL(C.CompanyName,'''')  LIKE ''' + @_CompanyName + 
						''' AND RTRIM(ISNULL(B.BranchName,'''')) LIKE ''' + @_BranchName +		
						''' AND RTRIM(ISNULL(SONumber,'''')) LIKE ''' + @_SONumber +	
						''' AND RTRIM(ISNULL(SONotes,'''')) LIKE ''' + @_SONotes +	
						''' AND RTRIM(ISNULL(SO.ReferenceNo,'''')) LIKE ''' + @_ReferenceNo + 
						''' AND RTRIM(ISNULL(PartnerName,'''')) LIKE ''' + @_PartnerName + ''''

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
GO
