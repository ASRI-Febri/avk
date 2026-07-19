SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List register aset tetap untuk DataTables
			  Nilai buku = AcquisitionCost - (OpeningAccumDepr + akumulasi penyusutan posted)

/*
	EXEC [dbo].[USP_FA_Asset_List] 1,10,'AssetCode','asc','R','','','','',''
	EXEC [dbo].[USP_FA_Asset_List] 1,10,'AssetCode','asc','C','','','','',''
	EXEC [dbo].[USP_FA_Asset_List] 1,10,'AssetCode','asc','R','1','2','Mobil','1','A'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_Asset_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@IDX_M_Company		VARCHAR(20),
	@IDX_M_Branch		VARCHAR(20),
	@SearchText			VARCHAR(100),	-- Cari di AssetCode, AssetName, ReferenceNo
	@IDX_M_AssetCategory VARCHAR(20),
	@AssetStatus		VARCHAR(1)
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
	SET @_Sort1 = 'A.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_M_Asset','Action','StatusDesc','BookValue','AccumDepr')
	BEGIN
		SET @_Sort1 = 'A.IDX_M_Asset ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('CategoryName')
	BEGIN
		SET @_Sort1 = 'AC.CategoryName ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('BranchName')
	BEGIN
		SET @_Sort1 = 'B.BranchName ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('DeprMethodDesc')
	BEGIN
		SET @_Sort1 = 'A.DeprMethod ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('AssetStatusDesc')
	BEGIN
		SET @_Sort1 = 'A.AssetStatus ' + @SortDir
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
			A.IDX_M_Asset,
			A.IDX_M_Company,
			A.IDX_M_Branch,
			BranchName = RTRIM(ISNULL(B.BranchName,''-'')),
			A.IDX_M_AssetCategory,
			CategoryName = RTRIM(ISNULL(AC.CategoryName,''-'')),
			A.AssetCode,
			A.AssetName,
			A.AcquisitionDate,
			A.UsageStartDate,
			A.AcquisitionCost,
			A.ResidualValue,
			A.UsefulLifeMonth,
			A.DeprMethod,
			DeprMethodDesc = CASE A.DeprMethod WHEN ''SL'' THEN ''Garis Lurus''
								WHEN ''DB'' THEN ''Saldo Menurun'' ELSE ''-'' END,
			AccumDepr = ISNULL(A.OpeningAccumDepr,0) + ISNULL(DP.TotalDepr,0),
			BookValue = ISNULL(A.AcquisitionCost,0) - (ISNULL(A.OpeningAccumDepr,0) + ISNULL(DP.TotalDepr,0)),
			A.AssetStatus,
			AssetStatusDesc = CASE A.AssetStatus
								WHEN ''D'' THEN ''<span class="badge bg-secondary">Draft</span>''
								WHEN ''A'' THEN ''<span class="badge bg-success">Aktif</span>''
								WHEN ''S'' THEN ''<span class="badge bg-warning text-dark">Dijual</span>''
								WHEN ''W'' THEN ''<span class="badge bg-danger">Hapus Buku</span>''
								WHEN ''H'' THEN ''<span class="badge bg-info">Hibah</span>''
								ELSE ''-'' END,
			A.RecordStatus,
			StatusDesc = CASE A.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''In-Active'' END '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM FA_M_Asset A WITH(NOLOCK)
					LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
					LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON A.IDX_M_Branch = B.IDX_M_Branch
					LEFT JOIN (
						SELECT DD.IDX_M_Asset, TotalDepr = SUM(ISNULL(DD.DeprAmount,0))
						FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
							INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
						WHERE D.DeprStatus = ''P'' AND DD.RecordStatus = ''A''
						GROUP BY DD.IDX_M_Asset
					) DP ON A.IDX_M_Asset = DP.IDX_M_Asset
					WHERE A.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@IDX_M_Company,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND A.IDX_M_Company = ' + RTRIM(@IDX_M_Company) + ' '

	IF RTRIM(ISNULL(@IDX_M_Branch,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND A.IDX_M_Branch = ' + RTRIM(@IDX_M_Branch) + ' '

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(A.AssetCode,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(A.AssetName,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(A.ReferenceNo,'''')) LIKE ''' + @_SearchText + '''
		) '

	IF RTRIM(ISNULL(@IDX_M_AssetCategory,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND A.IDX_M_AssetCategory = ' + RTRIM(@IDX_M_AssetCategory) + ' '

	IF RTRIM(ISNULL(@AssetStatus,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND A.AssetStatus = ''' + RTRIM(@AssetStatus) + ''' '

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
