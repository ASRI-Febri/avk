SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List kategori aset tetap untuk DataTables

/*
	EXEC [dbo].[USP_FA_AssetCategory_List] 1,10,'CategoryCode','asc','R','',''
	EXEC [dbo].[USP_FA_AssetCategory_List] 1,10,'CategoryCode','asc','C','',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_AssetCategory_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@CategoryCode		VARCHAR(20),
	@CategoryName		VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT
	-------------------------------------------------------------
	DECLARE @_CategoryCode		AS VARCHAR(22)
	DECLARE @_CategoryName		AS VARCHAR(102)
	-------------------------------------------------------------
	DECLARE @_Sort1				AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect			AS NVARCHAR(MAX)
	DECLARE @SqlFrom			AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlLimit			AS NVARCHAR(MAX)

	SET @_CategoryCode = '%' + RTRIM(ISNULL(@CategoryCode,'')) + '%'
	SET @_CategoryName = '%' + RTRIM(ISNULL(@CategoryName,'')) + '%'

	-- Sort
	SET @_Sort1 = 'AC.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_M_AssetCategory','Action','StatusDesc')
	BEGIN
		SET @_Sort1 = 'AC.IDX_M_AssetCategory ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('DeprMethodDesc')
	BEGIN
		SET @_Sort1 = 'AC.DefaultDeprMethod ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('FiscalGroupDesc')
	BEGIN
		SET @_Sort1 = 'AC.FiscalGroup ' + @SortDir
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
			AC.IDX_M_AssetCategory,
			AC.CategoryCode,
			AC.CategoryName,
			COAAsset = RTRIM(ISNULL(CA.COAID,'''')) + '' - '' + RTRIM(ISNULL(CA.COADesc,'''')),
			COAAccumDepr = RTRIM(ISNULL(CD.COAID,'''')) + '' - '' + RTRIM(ISNULL(CD.COADesc,'''')),
			COADeprExpense = RTRIM(ISNULL(CE.COAID,'''')) + '' - '' + RTRIM(ISNULL(CE.COADesc,'''')),
			AC.DefaultUsefulLifeMonth,
			AC.DefaultDeprMethod,
			DeprMethodDesc = CASE AC.DefaultDeprMethod WHEN ''SL'' THEN ''Garis Lurus''
								WHEN ''DB'' THEN ''Saldo Menurun'' ELSE ''-'' END,
			AC.FiscalGroup,
			FiscalGroupDesc = CASE AC.FiscalGroup
								WHEN ''1'' THEN ''Kelompok 1 (4 th)''
								WHEN ''2'' THEN ''Kelompok 2 (8 th)''
								WHEN ''3'' THEN ''Kelompok 3 (16 th)''
								WHEN ''4'' THEN ''Kelompok 4 (20 th)''
								WHEN ''BP'' THEN ''Bangunan Permanen (20 th)''
								WHEN ''BN'' THEN ''Bangunan Non-Permanen (10 th)''
								ELSE ''-'' END,
			AC.RecordStatus,
			StatusDesc = CASE AC.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''In-Active'' END '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM FA_M_AssetCategory AC WITH(NOLOCK)
					LEFT JOIN GL_M_COA CA WITH(NOLOCK) ON AC.IDX_M_COA_Asset = CA.IDX_M_COA
					LEFT JOIN GL_M_COA CD WITH(NOLOCK) ON AC.IDX_M_COA_AccumDepr = CD.IDX_M_COA
					LEFT JOIN GL_M_COA CE WITH(NOLOCK) ON AC.IDX_M_COA_DeprExpense = CE.IDX_M_COA
					WHERE AC.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@CategoryCode,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND RTRIM(ISNULL(AC.CategoryCode,'''')) LIKE ''' + @_CategoryCode + ''' '

	IF RTRIM(ISNULL(@CategoryName,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND RTRIM(ISNULL(AC.CategoryName,'''')) LIKE ''' + @_CategoryName + ''' '

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
