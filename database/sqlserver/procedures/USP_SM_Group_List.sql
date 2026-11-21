/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: Group user List for Financial Application

/*	
	EXEC [dbo].[USP_SM_Group_List] 1,100,'RowNumber','asc','R','','',''
	EXEC [dbo].[USP_SM_Group_List] 1,10,'RowNumber','asc','C','','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_SM_Group_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@GroupID				VARCHAR(50),
	@GroupName				VARCHAR(50),
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
	DECLARE @_GroupID				AS VARCHAR(50)
	DECLARE @_GroupName				AS VARCHAR(50)
	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_GroupID = '%' + RTRIM(@GroupID) + '%'	
	SET @_GroupName = '%' + RTRIM(@GroupName) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_Group'
	BEGIN
		SET @_Sort1 = ' G.IDX_M_Group ' + @SortDir
		SET @_Sort2 = ' G.IDX_M_Group ' + @SortDir
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
								G.IDX_M_Group, G.GroupID, G.GroupName, G.Notes, ISNULL(UC.LoginID,'''') AS UserID, G.RecordStatus, 
								StatusDesc = CASE RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM SM_M_Group G 
					LEFT JOIN (	SELECT UG.IDX_M_UserGroup, UG.IDX_M_Group, U.IDX_M_User, U.LoginID 
								FROM SM_M_UserGroup UG
								LEFT JOIN SM_M_User U ON U.IDX_M_User = UG.IDX_M_User
								WHERE UG.RecordStatus = ''A'' AND RTRIM(U.LoginID) = ''' + RTRIM(@UserID) + ''') UC 
						ON G.IDX_M_Group = UC.IDX_M_Group '

	SET @SqlWhere = 'WHERE ISNULL(UC.LoginID,'''') = '''' AND ISNULL(G.GroupID,'''')  LIKE ''' + @_GroupID + 
						''' AND RTRIM(ISNULL(G.GroupName,'''')) LIKE ''' + @_GroupName + ''''

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







