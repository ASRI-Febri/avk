SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List template journal recurring untuk DataTables

/*
	EXEC [dbo].[USP_GL_RecurringJournal_List] 1,10,'RecurringCode','asc','R','',''
	EXEC [dbo].[USP_GL_RecurringJournal_List] 1,10,'RecurringCode','asc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_RecurringJournal_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@SearchText			VARCHAR(100),	-- Cari di RecurringCode, RecurringName
	@RecurringStatus	VARCHAR(1)
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
	SET @_Sort1 = 'RJ.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_M_RecurringJournal','Action','StatusDesc','RecurringStatusDesc','LastPeriod','AdjustLastPeriodDesc')
	BEGIN
		SET @_Sort1 = 'RJ.IDX_M_RecurringJournal ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('COADebet','COACredit','BranchName')
	BEGIN
		SET @_Sort1 = 'RJ.RecurringCode ' + @SortDir
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
			RJ.IDX_M_RecurringJournal,
			RJ.RecurringCode,
			RJ.RecurringName,
			BranchName = RTRIM(ISNULL(B.BranchName,''-'')),
			COADebet = RTRIM(ISNULL(CD.COAID,'''')) + '' - '' + RTRIM(ISNULL(CD.COADesc,'''')),
			COACredit = RTRIM(ISNULL(CC.COAID,'''')) + '' - '' + RTRIM(ISNULL(CC.COADesc,'''')),
			RJ.RecurringAmount,
			TotalAmount = ISNULL(RJ.TotalAmount, 0),
			AdjustLastPeriodDesc = CASE ISNULL(RJ.AdjustLastPeriod,''N'')
				WHEN ''Y'' THEN ''<span class="badge bg-info">Ya</span>''
				ELSE ''<span class="badge bg-secondary">Tidak</span>'' END,
			RJ.StartPeriod,
			EndPeriod = RTRIM(ISNULL(RJ.EndPeriod,''-'')),
			LastPeriod = ISNULL((
				SELECT MAX(L.RecurringPeriod) FROM GL_T_RecurringJournalLog L WITH(NOLOCK)
				WHERE L.IDX_M_RecurringJournal = RJ.IDX_M_RecurringJournal AND L.RecordStatus = ''A''
			), ''-''),
			RJ.RecurringStatus,
			RecurringStatusDesc = CASE RJ.RecurringStatus
				WHEN ''A'' THEN ''<span class="badge bg-success">Aktif</span>''
				ELSE ''<span class="badge bg-secondary">Non-Aktif</span>'' END '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM GL_M_RecurringJournal RJ WITH(NOLOCK)
					LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON RJ.IDX_M_Branch = B.IDX_M_Branch
					LEFT JOIN GL_M_COA CD WITH(NOLOCK) ON RJ.IDX_M_COA_Debet = CD.IDX_M_COA
					LEFT JOIN GL_M_COA CC WITH(NOLOCK) ON RJ.IDX_M_COA_Credit = CC.IDX_M_COA
					WHERE RJ.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(RJ.RecurringCode,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(RJ.RecurringName,'''')) LIKE ''' + @_SearchText + '''
		) '

	IF RTRIM(ISNULL(@RecurringStatus,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND RJ.RecurringStatus = ''' + RTRIM(@RecurringStatus) + ''' '

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
