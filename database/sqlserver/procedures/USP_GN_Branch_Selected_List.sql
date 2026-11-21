
/* =============================================
Author			: Samuel Febrianto
Create date		: 03 June 2023
Description		: Branch List

/*	
	EXEC [dbo].[USP_GN_Branch_List] 1,10,'IDX_M_Branch','asc','R','','','',''
	EXEC [dbo].[USP_GN_Branch_List] 1,10,'RowNumber','asc','R','','','','1406069'
	EXEC [dbo].[USP_GN_Branch_List] 1,10,'RowNumber','asc','C','','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GN_Branch_Selected_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	--------------------------------------------------------------------
	@BranchID				VARCHAR(50),
	@BranchName				VARCHAR(50),
	@BranchAlias			VARCHAR(50),
	@UserID					VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_BranchID				AS VARCHAR(50)
	DECLARE @_BranchName			AS VARCHAR(50)
	DECLARE @_BranchAlias			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_BranchID = '%' + RTRIM(@BranchID) + '%'	
	SET @_BranchName = '%' + RTRIM(@BranchName) + '%'
	SET @_BranchAlias = '%' + RTRIM(@BranchAlias) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_Branch'
	BEGIN
		SET @_Sort1 = ' B.IDX_M_Branch ' + @SortDir
		SET @_Sort2 = ' B.IDX_M_Branch ' + @SortDir
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
								B.IDX_M_Branch, BranchID, BranchName, BranchAlias, BranchRemark, COASales, 
								COA.COAID, COA.COADesc, 
								B.RecordStatus, 
								StatusDesc = CASE B.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM GN_M_Branch B 
					LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = B.COASales 
					LEFT JOIN (	SELECT UG.IDX_M_UserBranch, UG.IDX_M_Branch, U.IDX_M_User, U.LoginID 
								FROM SM_M_UserBranch UG
								LEFT JOIN SM_M_User U ON U.IDX_M_User = UG.IDX_M_User
								WHERE UG.RecordStatus = ''A'' AND RTRIM(U.LoginID) = ''' + RTRIM(@UserID) + ''') UC 
						ON B.IDX_M_Branch = UC.IDX_M_Branch '

	SET @SqlWhere = 'WHERE B.RecordStatus = ''A'' AND ISNULL(UC.LoginID,'''') = '''' AND ISNULL(BranchName,'''')  LIKE ''' + @_BranchName + 
						''' AND RTRIM(ISNULL(BranchAlias,'''')) LIKE ''' + @_BranchAlias + 
						''' AND RTRIM(BranchID) LIKE ''' + @_BranchID + ''''

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







