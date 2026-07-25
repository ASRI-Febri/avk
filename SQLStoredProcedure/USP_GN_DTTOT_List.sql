SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Daftar DTTOT untuk DataTable (server side paging).
-- =============================================

-- EXEC [dbo].[USP_GN_DTTOT_List] 1,10,'RowNumber','asc','R','',''
-- EXEC [dbo].[USP_GN_DTTOT_List] 1,10,'RowNumber','asc','C','',''

CREATE PROCEDURE [dbo].[USP_GN_DTTOT_List]
	@Page					INT,
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	------------------------------------------------------------------------------
	@FullName				VARCHAR(256),
	@DensusCode				VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FromRow					AS INT
	DECLARE @ToRow						AS INT
	DECLARE @_Sort1						AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect					AS VARCHAR(5000)
	DECLARE @SqlFrom					AS VARCHAR(5000)
	DECLARE @SqlWhere					AS VARCHAR(5000)
	DECLARE @SqlLimit					AS VARCHAR(5000)
	--------------------------------------------------------------
	DECLARE @_FullName					AS VARCHAR(256)
	DECLARE @_DensusCode				AS VARCHAR(50)

	SET @_Sort1 = @SortBy + ' ' + @SortDir

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

	-- =================================================================================
	-- SET INPUT PARAMETER INTO SEARCH PARAMETER
	-- =================================================================================
	SET @_FullName = '%' + RTRIM(@FullName) + '%'
	SET @_DensusCode = '%' + RTRIM(@DensusCode) + '%'

	-- =================================================================================
	-- CUSTOM SORT
	-- =================================================================================
	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'IDX_M_DTTOT'
	BEGIN
		SET @_Sort1 = ' D.FullName ' + @SortDir
	END

	-- =================================================================================
	-- SET SQL QUERY
	-- =================================================================================
	SET @SqlSelect = '	SELECT * FROM (
							SELECT
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber,
								D.IDX_M_DTTOT, RTRIM(ISNULL(D.FullName,'''')) AS FullName,
								ISNULL(D.[Description],'''') AS [Description],
								RTRIM(ISNULL(D.SuspectType,'''')) AS SuspectType,
								RTRIM(ISNULL(D.DensusCode,'''')) AS DensusCode,
								RTRIM(ISNULL(D.PlaceOfBirth,'''')) AS PlaceOfBirth,
								RTRIM(ISNULL(D.DateOfBirth,'''')) AS DateOfBirth,
								RTRIM(ISNULL(D.Nationality,'''')) AS Nationality,
								RTRIM(ISNULL(D.[Address],'''')) AS [Address],
								RTRIM(ISNULL(D.[FileName],'''')) AS [FileName],
								CONVERT(VARCHAR(10), D.DCreate, 120) AS UploadDate '

	SET @SqlFrom = '		FROM GN_M_DTTOT D '

	SET @SqlWhere = '		WHERE RTRIM(ISNULL(D.RecordStatus,'''')) = ''A''
								AND ISNULL(D.FullName,'''') LIKE ''' + @_FullName + '''
								AND ISNULL(D.DensusCode,'''') LIKE ''' + @_DensusCode + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow)

	-- ==================================================
	-- Output
	-- ==================================================
	IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
	END

	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
	END
END
GO
