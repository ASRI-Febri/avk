USE [AVKDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_GL_Journal_List] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Paging Journal Header
--
-- Revisi 13 Agustus 2026:
--   1. Tambah filter range tanggal journal (@JournalDateFrom, @JournalDateTo).
--   2. Filter (LIKE / range / company / branch) hanya ditempel ke WHERE bila
--      diisi user. Sebelumnya semua kolom selalu dievaluasi dengan
--      RTRIM(ISNULL(kolom,'')) LIKE '%%' sehingga tidak sargable dan selalu
--      memaksa full scan walaupun user tidak mengisi filter apa pun.
--   3. Dynamic SQL dijalankan lewat sp_executesql dengan parameter (bukan
--      EXEC + literal), sehingga execution plan bisa dipakai ulang dan tidak
--      membanjiri plan cache; sekaligus menutup celah SQL injection dari
--      input filter dan @UserID.
--   4. Hak akses cabang user dicek lewat EXISTS (semi join), bukan INNER JOIN
--      ke derived table SM_M_User + SM_M_UserBranch. Selain lebih murah, ini
--      menghilangkan potensi baris journal tampil ganda kalau user punya lebih
--      dari satu baris SM_M_UserBranch untuk cabang yang sama.
--   5. Paging pakai OFFSET/FETCH pada tabel header saja; join ke GN_M_Company /
--      GN_M_Branch hanya dilakukan untuk baris pada halaman yang diminta.
--   6. @SortBy divalidasi lewat whitelist dan selalu diberi tie breaker
--      IDX_T_JournalHeader supaya urutan halaman stabil. Sort CompanyName /
--      BranchName dipetakan ke IDX_M_Company / IDX_M_Branch supaya paging tetap
--      bisa dilayani dari tabel header saja (tanpa join master dulu).
--
-- Revisi 21 Oktober 2026:
--   Tambah filter journal type (@IDX_M_JournalType). Ditaruh sebagai parameter
--   terakhir dengan default 0 supaya pemanggil lama yang mengirim parameter
--   posisional tetap jalan; 0 / kosong berarti semua tipe.
--
-- Index pendukung: SQLTable/IX_GL_T_JournalHeader_Inquiry.sql
-- =============================================

/*
	EXEC [USP_GL_Journal_List] 1,10,'RowNumber','asc','R',0,0,'','','','','','febry','',''
	EXEC [USP_GL_Journal_List] 1,10,'JournalDate','desc','R',0,0,'','','','','','febry','2026-01-01','2026-01-31'
	EXEC [USP_GL_Journal_List] 1,10,'RowNumber','asc','C',0,0,'','','','','','febry','2026-01-01','2026-01-31'
*/

IF OBJECT_ID('[dbo].[USP_GL_Journal_List]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GL_Journal_List]
GO

CREATE PROCEDURE [dbo].[USP_GL_Journal_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(50),
	@ReturnType			CHAR(1), --R = Record, C = Count
	--------------------------------
	@IDX_M_Company		BIGINT,
	@IDX_M_Branch		BIGINT,
	@ReferenceNo		VARCHAR(50),
	@VoucherNo			VARCHAR(50),
	@RemarkHeader		VARCHAR(100),
	@PostingStatus		VARCHAR(1),
	@PartnerDesc		VARCHAR(50),
	@UserID				VARCHAR(50),
	@JournalDateFrom	VARCHAR(10) = '',
	@JournalDateTo		VARCHAR(10) = '',
	@IDX_M_JournalType	BIGINT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Offset				AS INT
	DECLARE @Sort				AS NVARCHAR(200)
	DECLARE @SortColumn			AS NVARCHAR(100)
	DECLARE @SortDirection		AS NVARCHAR(4)

	DECLARE @_ReferenceNo		AS VARCHAR(52)
	DECLARE @_VoucherNo			AS VARCHAR(52)
	DECLARE @_RemarkHeader		AS VARCHAR(102)
	DECLARE @_PartnerDesc		AS VARCHAR(52)
	DECLARE @_PostingStatus		AS VARCHAR(1)
	DECLARE @_UserID			AS VARCHAR(50)
	DECLARE @_DateFrom			AS DATETIME
	DECLARE @_DateTo			AS DATETIME

	DECLARE @Sql				AS NVARCHAR(MAX)
	DECLARE @SqlWhere			AS NVARCHAR(MAX)
	DECLARE @SqlParam			AS NVARCHAR(MAX)

	-- Nilai filter
	SET @_ReferenceNo	= '%' + RTRIM(ISNULL(@ReferenceNo,'')) + '%'
	SET @_VoucherNo		= '%' + RTRIM(ISNULL(@VoucherNo,'')) + '%'
	SET @_RemarkHeader	= '%' + RTRIM(ISNULL(@RemarkHeader,'')) + '%'
	SET @_PartnerDesc	= '%' + RTRIM(ISNULL(@PartnerDesc,'')) + '%'
	SET @_PostingStatus	= RTRIM(ISNULL(@PostingStatus,''))
	SET @_UserID		= RTRIM(ISNULL(@UserID,''))

	-- Tanggal diterima dalam format yyyy-mm-dd (datepicker), tidak valid = diabaikan
	SET @_DateFrom = TRY_CONVERT(DATETIME, NULLIF(RTRIM(ISNULL(@JournalDateFrom,'')),''), 120)
	SET @_DateTo   = TRY_CONVERT(DATETIME, NULLIF(RTRIM(ISNULL(@JournalDateTo,'')),''), 120)

	-- Kalau user membalik urutan tanggal, tukar supaya tetap dapat hasil
	IF @_DateFrom IS NOT NULL AND @_DateTo IS NOT NULL AND @_DateFrom > @_DateTo
	BEGIN
		DECLARE @SwapDate AS DATETIME
		SET @SwapDate = @_DateFrom
		SET @_DateFrom = @_DateTo
		SET @_DateTo = @SwapDate
	END

	-- SORTING (whitelist, kolom di luar daftar jatuh ke IDX_T_JournalHeader)
	SET @SortDirection = CASE WHEN RTRIM(ISNULL(@SortDir,'')) = 'asc' THEN N'ASC' ELSE N'DESC' END

	SET @SortColumn =
		CASE RTRIM(ISNULL(@SortBy,''))
			WHEN 'PartnerDesc'			THEN N'JH.PartnerDesc'
			WHEN 'ReferenceNo'			THEN N'JH.ReferenceNo'
			WHEN 'VoucherNo'			THEN N'JH.VoucherNo'
			WHEN 'JournalDate'			THEN N'JH.JournalDate'
			WHEN 'RemarkHeader'			THEN N'JH.RemarkHeader'
			WHEN 'PostingStatus'		THEN N'JH.PostingStatus'
			WHEN 'PostingStatusDesc'	THEN N'JH.PostingStatus'
			WHEN 'CompanyName'			THEN N'JH.IDX_M_Company'
			WHEN 'BranchName'			THEN N'JH.IDX_M_Branch'
			ELSE N'JH.IDX_T_JournalHeader'
		END

	SET @Sort = @SortColumn + N' ' + @SortDirection

	-- Tie breaker supaya paging tidak menampilkan baris ganda/terlewat
	IF @SortColumn <> N'JH.IDX_T_JournalHeader'
		SET @Sort = @Sort + N', JH.IDX_T_JournalHeader ' + @SortDirection

	-- PAGING
	IF ISNULL(@Page,1) < 1 SET @Page = 1
	IF ISNULL(@Row,10) < 1 SET @Row = 10

	SET @Offset = (@Page - 1) * @Row

	-- WHERE, hanya filter yang benar benar diisi yang ditempel.
	-- Pembatasan hak akses cabang user pakai EXISTS (semi join): tidak bisa
	-- menggandakan baris journal dan tidak perlu materialisasi tabel bantu.
	SET @SqlWhere = N'
		WHERE EXISTS (SELECT 1
			FROM SM_M_User A WITH(NOLOCK)
				INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
			WHERE B.RecordStatus = ''A''
				AND B.IDX_M_Branch = JH.IDX_M_Branch
				AND RTRIM(A.LoginID) = @p_UserID) '

	IF ISNULL(@IDX_M_Company,0) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.IDX_M_Company = @p_Company '

	IF ISNULL(@IDX_M_Branch,0) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.IDX_M_Branch = @p_Branch '

	IF LEN(RTRIM(ISNULL(@ReferenceNo,''))) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.ReferenceNo LIKE @p_ReferenceNo '

	IF LEN(RTRIM(ISNULL(@VoucherNo,''))) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.VoucherNo LIKE @p_VoucherNo '

	IF LEN(RTRIM(ISNULL(@RemarkHeader,''))) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.RemarkHeader LIKE @p_RemarkHeader '

	IF LEN(RTRIM(ISNULL(@PartnerDesc,''))) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.PartnerDesc LIKE @p_PartnerDesc '

	IF LEN(@_PostingStatus) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.PostingStatus = @p_PostingStatus '

	IF ISNULL(@IDX_M_JournalType,0) > 0
		SET @SqlWhere = @SqlWhere + N' AND JH.IDX_M_JournalType = @p_JournalType '

	IF @_DateFrom IS NOT NULL
		SET @SqlWhere = @SqlWhere + N' AND JH.JournalDate >= @p_DateFrom '

	-- < DateTo + 1 hari, supaya baris dengan jam <> 00:00:00 tetap ikut
	IF @_DateTo IS NOT NULL
		SET @SqlWhere = @SqlWhere + N' AND JH.JournalDate < DATEADD(DAY, 1, @p_DateTo) '

	SET @SqlParam = N'
		@p_Company			BIGINT,
		@p_Branch			BIGINT,
		@p_ReferenceNo		VARCHAR(52),
		@p_VoucherNo		VARCHAR(52),
		@p_RemarkHeader		VARCHAR(102),
		@p_PartnerDesc		VARCHAR(52),
		@p_PostingStatus	VARCHAR(1),
		@p_DateFrom			DATETIME,
		@p_DateTo			DATETIME,
		@p_JournalType		BIGINT,
		@p_UserID			VARCHAR(50),
		@p_Offset			INT,
		@p_Row				INT'

	IF @ReturnType = 'R'
	BEGIN
		SET @Sql = N'
		;WITH Paged AS
		(
			SELECT JH.IDX_T_JournalHeader, JH.IDX_M_Company, JH.IDX_M_Branch, JH.IDX_M_Partner,
				JH.PartnerDesc, JH.ReferenceNo, JH.VoucherNo, JH.JournalDate, JH.RemarkHeader, JH.PostingStatus
			FROM GL_T_JournalHeader JH WITH(NOLOCK) '
			+ @SqlWhere + N'
			ORDER BY ' + @Sort + N'
			OFFSET @p_Offset ROWS FETCH NEXT @p_Row ROWS ONLY
		)
		SELECT ROW_NUMBER() OVER (ORDER BY ' + @Sort + N') + @p_Offset AS RowNumber,
			JH.IDX_M_Company, MC.CompanyName, JH.IDX_M_Branch, MB.BranchName,
			JH.IDX_T_JournalHeader, JH.IDX_M_Partner, JH.PartnerDesc,
			JH.ReferenceNo, JH.VoucherNo, CONVERT(VARCHAR, JH.JournalDate, 106) AS JournalDate,
			JH.RemarkHeader, JH.PostingStatus,
			PostingStatusDesc = CASE JH.PostingStatus WHEN ''P'' THEN ''Posted'' WHEN ''U'' THEN ''Unposted'' END
		FROM Paged JH
			LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON JH.IDX_M_Company = MC.IDX_M_Company
			LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON JH.IDX_M_Branch = MB.IDX_M_Branch
		ORDER BY ' + @Sort

		--PRINT (@Sql)

		EXEC sp_executesql @Sql, @SqlParam,
			@p_Company			= @IDX_M_Company,
			@p_Branch			= @IDX_M_Branch,
			@p_ReferenceNo		= @_ReferenceNo,
			@p_VoucherNo		= @_VoucherNo,
			@p_RemarkHeader		= @_RemarkHeader,
			@p_PartnerDesc		= @_PartnerDesc,
			@p_PostingStatus	= @_PostingStatus,
			@p_DateFrom			= @_DateFrom,
			@p_DateTo			= @_DateTo,
			@p_JournalType		= @IDX_M_JournalType,
			@p_UserID			= @_UserID,
			@p_Offset			= @Offset,
			@p_Row				= @Row
	END

	IF @ReturnType = 'C'
	BEGIN
		SET @Sql = N'
		SELECT COUNT(*) AS TotalRows
		FROM GL_T_JournalHeader JH WITH(NOLOCK) '
			+ @SqlWhere

		--PRINT (@Sql)

		EXEC sp_executesql @Sql, @SqlParam,
			@p_Company			= @IDX_M_Company,
			@p_Branch			= @IDX_M_Branch,
			@p_ReferenceNo		= @_ReferenceNo,
			@p_VoucherNo		= @_VoucherNo,
			@p_RemarkHeader		= @_RemarkHeader,
			@p_PartnerDesc		= @_PartnerDesc,
			@p_PostingStatus	= @_PostingStatus,
			@p_DateFrom			= @_DateFrom,
			@p_DateTo			= @_DateTo,
			@p_JournalType		= @IDX_M_JournalType,
			@p_UserID			= @_UserID,
			@p_Offset			= @Offset,
			@p_Row				= @Row
	END

END
GO
