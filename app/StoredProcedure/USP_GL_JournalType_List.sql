SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List journal type untuk DataTables

/*
	EXEC [dbo].[USP_GL_JournalType_List] 1,10,'JournalTypeID','asc','R','',''
	EXEC [dbo].[USP_GL_JournalType_List] 1,10,'JournalTypeID','asc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_JournalType_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@JournalTypeID		VARCHAR(32),
	@JournalTypeDesc	VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT
	-------------------------------------------------------------
	DECLARE @_JournalTypeID		AS VARCHAR(34)
	DECLARE @_JournalTypeDesc	AS VARCHAR(66)
	-------------------------------------------------------------
	DECLARE @_Sort1				AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect			AS NVARCHAR(MAX)
	DECLARE @SqlFrom			AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlLimit			AS NVARCHAR(MAX)

	SET @_JournalTypeID = '%' + RTRIM(ISNULL(@JournalTypeID,'')) + '%'
	SET @_JournalTypeDesc = '%' + RTRIM(ISNULL(@JournalTypeDesc,'')) + '%'

	-- Sort
	SET @_Sort1 = 'JT.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_M_JournalType','Action','StatusDesc')
	BEGIN
		SET @_Sort1 = 'JT.IDX_M_JournalType ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('AllowJournalEntryDesc')
	BEGIN
		SET @_Sort1 = 'JT.AllowJournalEntry ' + @SortDir
	END

	-- Paging
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

	-- ==================================================
	-- SELECT
	-- ==================================================
	SET @SqlSelect = N'SELECT * FROM (
		SELECT
			ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + N') AS RowNumber,
			JT.IDX_M_JournalType,
			JT.JournalTypeID,
			JT.JournalTypeDesc,
			JT.AllowJournalEntry,
			AllowJournalEntryDesc = CASE JT.AllowJournalEntry WHEN ''Y'' THEN ''Yes'' ELSE ''No'' END,
			JT.JournalLabel,
			JT.RecordStatus,
			StatusDesc = CASE JT.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''In-Active'' END '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM GL_M_JournalType JT WITH(NOLOCK)
					WHERE JT.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@JournalTypeID,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND RTRIM(ISNULL(JT.JournalTypeID,'''')) LIKE ''' + @_JournalTypeID + ''' '

	IF RTRIM(ISNULL(@JournalTypeDesc,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND RTRIM(ISNULL(JT.JournalTypeDesc,'''')) LIKE ''' + @_JournalTypeDesc + ''' '

	-- ==================================================
	-- LIMIT
	-- ==================================================
	SET @SqlLimit = N') AS DerivedTable WHERE RowNumber BETWEEN '
					+ CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow)

	-- ==================================================
	-- Output
	-- ==================================================
	IF @ReturnType = 'R'
	BEGIN
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
	END

	IF @ReturnType = 'C'
	BEGIN
		EXEC(N'SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
	END

END
GO
