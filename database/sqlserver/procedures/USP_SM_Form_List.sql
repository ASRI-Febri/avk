/* =============================================
Author			: Samuel Febrianto
Create date		: 17 Mei 2018
Description		: Group user List for Financial Application

/*	
	EXEC [dbo].[USP_SM_Form_List] 1,100,'RowNumber','asc','R','','','','',''
	EXEC [dbo].[USP_SM_Form_List] 1,10,'RowNumber','asc','C','','','','',''
	EXEC dbo.[USP_SM_Form_List] 1,50,'IDX_M_Form','desc','R','','','','','ADMIN'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_SM_Form_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@ApplicationID			VARCHAR(50),
	@FormID					VARCHAR(50),
	@FormName				VARCHAR(50),
	@FormDescription		VARCHAR(50),
	@FormURL				VARCHAR(50),
	@GroupID				VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_ApplicationID			AS VARCHAR(50)
	DECLARE @_FormID				AS VARCHAR(50)
	DECLARE @_FormName				AS VARCHAR(50)
	DECLARE @_FormDescription		AS VARCHAR(50)
	DECLARE @_FormURL				AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_ApplicationID = '%' + RTRIM(@ApplicationID) + '%'	
	SET @_FormID = '%' + RTRIM(@FormID) + '%'	
	SET @_FormName = '%' + RTRIM(@FormName) + '%'
	SET @_FormDescription = '%' + RTRIM(@FormDescription) + '%'
	SET @_FormURL = '%' + RTRIM(@FormURL) + '%'	
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_Form'
	BEGIN
		SET @_Sort1 = ' MF.IDX_M_Form ' + @SortDir
		SET @_Sort2 = ' MF.IDX_M_Form ' + @SortDir
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
								MF.IDX_M_Form, MA.ApplicationName, MF.FormID, MF.FormName, MF.FormURL, 
								MF.FormDescription, 
								ISNULL(GF.GroupID,'''') AS GroupID, MF.RecordStatus, 
								StatusDesc = CASE MF.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Inactive'' END ' 							
	
	SET @SqlFrom = 'FROM SM_M_Form MF
					LEFT JOIN SM_M_Application MA ON MA.IDX_M_Application = MF.IDX_M_Application
					LEFT JOIN (	SELECT GF.IDX_M_GroupForm, GF.IDX_M_Form, GF.IDX_M_Group, G.GroupID, G.GroupName
								FROM SM_M_GroupForm GF
								LEFT JOIN SM_M_Group G ON G.IDX_M_Group = GF.IDX_M_Group
								WHERE GF.RecordStatus = ''A'' AND RTRIM(G.GroupID) = ''' + RTRIM(@GroupID) + ''') GF 
						ON MF.IDX_M_Form = GF.IDX_M_Form '

	SET @SqlWhere = 'WHERE ISNULL(GF.GroupID,'''') = '''' AND ISNULL(MF.FormID,'''')  LIKE ''' + @_FormID + 
						''' AND RTRIM(ISNULL(MF.FormName,'''')) LIKE ''' + @_FormName + 
						''' AND RTRIM(ISNULL(MF.FormDescription,'''')) LIKE ''' + @_FormDescription + 
						''' AND RTRIM(ISNULL(MA.ApplicationName,'''')) LIKE ''' + @_ApplicationID + 
						''' AND RTRIM(ISNULL(FormURL,'''')) LIKE ''' + @_FormURL + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ''

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END

END







