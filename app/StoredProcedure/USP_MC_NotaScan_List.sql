SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 17 Apr 2026
Description	: List nota scan OCR untuk DataTables (money changer)

/*
	EXEC [dbo].[USP_MC_NotaScan_List] 1,10,'TanggalNota','desc','R','','','',''
	EXEC [dbo].[USP_MC_NotaScan_List] 1,10,'TanggalNota','desc','C','','','',''
	EXEC [dbo].[USP_MC_NotaScan_List] 1,10,'TanggalNota','desc','R','Albert','J','2026-01-01','2026-12-31'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_MC_NotaScan_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@SearchText			VARCHAR(100),	-- Cari di NoNota, NamaKonsumen, Keterangan
	@TipeTransaksi		VARCHAR(1),
	@DateFrom			VARCHAR(20),
	@DateTo				VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT
	-------------------------------------------------------------
	DECLARE @_SearchText		AS VARCHAR(102)
	-------------------------------------------------------------
	DECLARE @_Sort1				AS VARCHAR(100)
	DECLARE @_Sort2				AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect			AS NVARCHAR(MAX)
	DECLARE @SqlFrom			AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlLimit			AS NVARCHAR(MAX)

	SET @_SearchText = '%' + RTRIM(ISNULL(@SearchText,'')) + '%'

	-- Sort
	SET @_Sort1 = 'NS.' + @SortBy + ' ' + @SortDir
	SET @_Sort2 = 'NS.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_T_MC_NotaScan')
	BEGIN
		SET @_Sort1 = 'NS.IDX_T_MC_NotaScan ' + @SortDir
		SET @_Sort2 = 'NS.IDX_T_MC_NotaScan ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('TanggalNota')
	BEGIN
		SET @_Sort1 = 'NS.TanggalNota ' + @SortDir
		SET @_Sort2 = 'NS.TanggalNota ' + @SortDir
	END

	-- Alias columns → map ke kolom fisik
	IF RTRIM(@SortBy) IN ('TipeTransaksi','TipeTransaksiDesc')
	BEGIN
		SET @_Sort1 = 'NS.TipeTransaksi ' + @SortDir
		SET @_Sort2 = 'NS.TipeTransaksi ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('Status','StatusDesc')
	BEGIN
		SET @_Sort1 = 'NS.Status ' + @SortDir
		SET @_Sort2 = 'NS.Status ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('Action')
	BEGIN
		SET @_Sort1 = 'NS.IDX_T_MC_NotaScan ' + @SortDir
		SET @_Sort2 = 'NS.IDX_T_MC_NotaScan ' + @SortDir
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
			NS.IDX_T_MC_NotaScan,
			NS.TipeTransaksi,
			TipeTransaksiDesc = CASE NS.TipeTransaksi WHEN ''J'' THEN ''<span class="badge bg-info">Jual</span>''
								WHEN ''B'' THEN ''<span class="badge bg-warning text-dark">Beli</span>''
								ELSE ''-'' END,
			NS.TanggalNota,
			NS.NoNota,
			NS.NamaKonsumen,
			NS.Keterangan,
			NS.FileName,
			NS.Status,
			StatusDesc = CASE NS.Status WHEN ''D'' THEN ''<span class="badge bg-secondary">Draft</span>''
							ELSE ''<span class="badge bg-success">Aktif</span>'' END,
			Action = ''<a href="/mc-nota-scan/update/'' + RTRIM(CONVERT(VARCHAR,NS.IDX_T_MC_NotaScan)) + ''">
						<button class="btn btn-sm btn-outline-primary" title="Edit"><i class="fas fa-edit"></i></button>
					</a>'' '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM MC_T_NotaScan NS
					WHERE NS.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(NS.NoNota,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(NS.NamaKonsumen,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(NS.Keterangan,'''')) LIKE ''' + @_SearchText + '''
		) '

	IF RTRIM(ISNULL(@TipeTransaksi,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND NS.TipeTransaksi = ''' + RTRIM(@TipeTransaksi) + ''' '

	IF RTRIM(ISNULL(@DateFrom,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND NS.TanggalNota >= ''' + RTRIM(@DateFrom) + ''' '

	IF RTRIM(ISNULL(@DateTo,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND NS.TanggalNota <= ''' + RTRIM(@DateTo) + ''' '

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
