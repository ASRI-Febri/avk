SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List pelepasan aset tetap untuk DataTables

/*
	EXEC [dbo].[USP_FA_AssetDisposal_List] 1,10,'DisposalDate','desc','R','',''
	EXEC [dbo].[USP_FA_AssetDisposal_List] 1,10,'DisposalDate','desc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_AssetDisposal_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@SearchText			VARCHAR(100),	-- Cari di AssetCode, AssetName, DisposalNotes
	@DisposalType		VARCHAR(1)		-- S / W / H
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
	SET @_Sort1 = 'D.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_T_AssetDisposal','Action','DisposalTypeDesc','JournalRef')
	BEGIN
		SET @_Sort1 = 'D.IDX_T_AssetDisposal ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('AssetCode','AssetName')
	BEGIN
		SET @_Sort1 = 'A.' + RTRIM(@SortBy) + ' ' + @SortDir
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
			D.IDX_T_AssetDisposal,
			D.IDX_M_Asset,
			AssetCode = RTRIM(ISNULL(A.AssetCode,'''')),
			AssetName = RTRIM(ISNULL(A.AssetName,'''')),
			D.DisposalDate,
			D.DisposalType,
			DisposalTypeDesc = CASE D.DisposalType
								WHEN ''S'' THEN ''<span class="badge bg-warning text-dark">Dijual</span>''
								WHEN ''W'' THEN ''<span class="badge bg-danger">Hapus Buku</span>''
								WHEN ''H'' THEN ''<span class="badge bg-info">Hibah</span>''
								ELSE ''-'' END,
			D.DisposalProceed,
			D.AccumDeprAtDisposal,
			D.BookValueAtDisposal,
			D.GainLossAmount,
			JournalRef = RTRIM(ISNULL(JH.VoucherNo,''-'')),
			D.DisposalNotes '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM FA_T_AssetDisposal D WITH(NOLOCK)
					LEFT JOIN FA_M_Asset A WITH(NOLOCK) ON D.IDX_M_Asset = A.IDX_M_Asset
					LEFT JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON D.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
					WHERE D.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(A.AssetCode,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(A.AssetName,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(D.DisposalNotes,'''')) LIKE ''' + @_SearchText + '''
		) '

	IF RTRIM(ISNULL(@DisposalType,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND D.DisposalType = ''' + RTRIM(@DisposalType) + ''' '

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
