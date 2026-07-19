SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List run penyusutan per periode untuk DataTables

/*
	EXEC [dbo].[USP_FA_Depreciation_List] 1,10,'DeprPeriod','desc','R','',''
	EXEC [dbo].[USP_FA_Depreciation_List] 1,10,'DeprPeriod','desc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_Depreciation_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@IDX_M_Company		VARCHAR(20),
	@DeprPeriod			VARCHAR(6)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT
	-------------------------------------------------------------
	DECLARE @_Sort1				AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect			AS NVARCHAR(MAX)
	DECLARE @SqlFrom			AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlLimit			AS NVARCHAR(MAX)

	-- Sort
	SET @_Sort1 = 'D.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_T_Depreciation','Action','PeriodDesc','TotalAsset','TotalDepr','TotalFiscalDepr','JournalRef','DeprStatusDesc')
	BEGIN
		SET @_Sort1 = 'D.DeprPeriod ' + @SortDir
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
			D.IDX_T_Depreciation,
			D.IDX_M_Company,
			D.DeprPeriod,
			PeriodDesc = CASE RIGHT(D.DeprPeriod,2)
							WHEN ''01'' THEN ''Januari'' WHEN ''02'' THEN ''Februari''
							WHEN ''03'' THEN ''Maret'' WHEN ''04'' THEN ''April''
							WHEN ''05'' THEN ''Mei'' WHEN ''06'' THEN ''Juni''
							WHEN ''07'' THEN ''Juli'' WHEN ''08'' THEN ''Agustus''
							WHEN ''09'' THEN ''September'' WHEN ''10'' THEN ''Oktober''
							WHEN ''11'' THEN ''November'' WHEN ''12'' THEN ''Desember''
							ELSE '''' END + '' '' + LEFT(D.DeprPeriod,4),
			TotalAsset = ISNULL(DT.TotalAsset,0),
			TotalDepr = ISNULL(DT.TotalDepr,0),
			TotalFiscalDepr = ISNULL(DT.TotalFiscalDepr,0),
			D.DeprStatus,
			DeprStatusDesc = CASE D.DeprStatus
							WHEN ''C'' THEN ''<span class="badge bg-warning text-dark">Calculated</span>''
							WHEN ''P'' THEN ''<span class="badge bg-success">Journal Posted</span>''
							ELSE ''-'' END,
			D.IDX_T_JournalHeader,
			JournalRef = RTRIM(ISNULL(JH.VoucherNo,''-'')),
			D.RecordStatus '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM FA_T_Depreciation D WITH(NOLOCK)
					LEFT JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON D.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
					LEFT JOIN (
						SELECT DD.IDX_T_Depreciation,
							TotalAsset = COUNT(*),
							TotalDepr = SUM(ISNULL(DD.DeprAmount,0)),
							TotalFiscalDepr = SUM(ISNULL(DD.FiscalDeprAmount,0))
						FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
						WHERE DD.RecordStatus = ''A''
						GROUP BY DD.IDX_T_Depreciation
					) DT ON D.IDX_T_Depreciation = DT.IDX_T_Depreciation
					WHERE D.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@IDX_M_Company,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND D.IDX_M_Company = ' + RTRIM(@IDX_M_Company) + ' '

	IF RTRIM(ISNULL(@DeprPeriod,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND D.DeprPeriod = ''' + RTRIM(@DeprPeriod) + ''' '

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
