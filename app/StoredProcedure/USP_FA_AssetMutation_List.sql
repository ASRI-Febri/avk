SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: List riwayat mutasi aset tetap untuk DataTables

/*
	EXEC [dbo].[USP_FA_AssetMutation_List] 1,10,'MutationDate','desc','R',''
	EXEC [dbo].[USP_FA_AssetMutation_List] 1,10,'MutationDate','desc','C',''
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_AssetMutation_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1),		-- R = Record, C = Count
	---------------------------------------------------------------------
	@SearchText			VARCHAR(100)	-- Cari di AssetCode, AssetName, MutationNotes
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
	SET @_Sort1 = 'M.' + @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) IN ('RowNumber','IDX_T_AssetMutation','Action')
	BEGIN
		SET @_Sort1 = 'M.IDX_T_AssetMutation ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('AssetCode','AssetName')
	BEGIN
		SET @_Sort1 = 'A.' + RTRIM(@SortBy) + ' ' + @SortDir
	END

	IF RTRIM(@SortBy) IN ('BranchFrom','BranchTo','DeptFrom','DeptTo')
	BEGIN
		SET @_Sort1 = 'M.MutationDate ' + @SortDir
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
			M.IDX_T_AssetMutation,
			M.IDX_M_Asset,
			AssetCode = RTRIM(ISNULL(A.AssetCode,'''')),
			AssetName = RTRIM(ISNULL(A.AssetName,'''')),
			M.MutationDate,
			BranchFrom = RTRIM(ISNULL(BF.BranchName,''-'')),
			BranchTo = RTRIM(ISNULL(BT.BranchName,''-'')),
			DeptFrom = RTRIM(ISNULL(DF.DepartmentName,''-'')),
			DeptTo = RTRIM(ISNULL(DT.DepartmentName,''-'')),
			M.MutationNotes,
			M.UCreate '

	-- ==================================================
	-- FROM + WHERE dasar
	-- ==================================================
	SET @SqlFrom = N'FROM FA_T_AssetMutation M WITH(NOLOCK)
					LEFT JOIN FA_M_Asset A WITH(NOLOCK) ON M.IDX_M_Asset = A.IDX_M_Asset
					LEFT JOIN GN_M_Branch BF WITH(NOLOCK) ON M.IDX_M_Branch_From = BF.IDX_M_Branch
					LEFT JOIN GN_M_Branch BT WITH(NOLOCK) ON M.IDX_M_Branch_To = BT.IDX_M_Branch
					LEFT JOIN GN_M_Department DF WITH(NOLOCK) ON M.IDX_M_Department_From = DF.IDX_M_Department
					LEFT JOIN GN_M_Department DT WITH(NOLOCK) ON M.IDX_M_Department_To = DT.IDX_M_Department
					WHERE M.RecordStatus = ''A'' '

	-- ==================================================
	-- WHERE dinamis
	-- ==================================================
	SET @SqlWhere = N''

	IF RTRIM(ISNULL(@SearchText,'')) <> ''
		SET @SqlWhere = @SqlWhere + N'AND (
			RTRIM(ISNULL(A.AssetCode,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(A.AssetName,'''')) LIKE ''' + @_SearchText + '''
			OR RTRIM(ISNULL(M.MutationNotes,'''')) LIKE ''' + @_SearchText + '''
		) '

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
