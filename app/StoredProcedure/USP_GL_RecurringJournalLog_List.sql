SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Log/riwayat generate journal recurring untuk DataTables

/*
	EXEC [dbo].[USP_GL_RecurringJournalLog_List] 1,10,'RecurringPeriod','desc','R','',''
	EXEC [dbo].[USP_GL_RecurringJournalLog_List] 1,10,'RecurringPeriod','desc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_RecurringJournalLog_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@SearchText			VARCHAR(100),	-- Cari di RecurringCode, RecurringName, VoucherNo
	@RecurringPeriod	VARCHAR(6)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT
	-------------------------------------------------------------
	DECLARE @_SearchText		AS VARCHAR(102)
	-------------------------------------------------------------
	DECLARE @_Sort1				AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect			AS NVARCHAR(MAX)
	DECLARE @SqlFrom			AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlLimit			AS NVARCHAR(MAX)

	SET @_SearchText = '%' + RTRIM(ISNULL(@SearchText,'')) + '%'

	-- Sort
	SET @_Sort1 = 'L.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_T_RecurringJournalLog','Action','JournalRef','PostingStatusDesc')
	BEGIN
		SET @_Sort1 = 'L.IDX_T_RecurringJournalLog ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('RecurringCode','RecurringName')
	BEGIN
		SET @_Sort1 = 'RJ.' + RTRIM(@SortBy) + ' ' + @SortDir
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
			L.IDX_T_RecurringJournalLog,
			L.IDX_M_RecurringJournal,
			RecurringCode = RTRIM(ISNULL(RJ.RecurringCode,'''')),
			RecurringName = RTRIM(ISNULL(RJ.RecurringName,'''')),
			L.RecurringPeriod,
			L.GeneratedAmount,
			JournalRef = RTRIM(ISNULL(JH.VoucherNo,''-'')),
			JournalDate = JH.JournalDate,
			PostingStatusDesc = CASE ISNULL(JH.PostingStatus,'''')
				WHEN ''P'' THEN ''<span class="badge bg-success">Posted</span>''
				WHEN ''U'' THEN ''<span class="badge bg-danger">UnPosted</span>''
				ELSE ''-'' END,
			GeneratedBy = RTRIM(ISNULL(L.UCreate,'''')),
			GeneratedDate = L.DCreate '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM GL_T_RecurringJournalLog L WITH(NOLOCK)
					LEFT JOIN GL_M_RecurringJournal RJ WITH(NOLOCK) ON L.IDX_M_RecurringJournal = RJ.IDX_M_RecurringJournal
					LEFT JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON L.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
					WHERE L.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(RJ.RecurringCode,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(RJ.RecurringName,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(JH.VoucherNo,'''')) LIKE ''' + @_SearchText + '''
		) '

	IF RTRIM(ISNULL(@RecurringPeriod,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND L.RecurringPeriod = ''' + RTRIM(@RecurringPeriod) + ''' '

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
