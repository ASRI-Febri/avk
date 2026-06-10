SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description  : Laporan Arus Kas / Statement of Cash Flows - Metode Tidak Langsung
--                (Indirect Method) sesuai PSAK 2 (IAS 7).
--
--   METODE
--   ------
--   Laporan disusun dengan "movement approach". Untuk setiap akun NON-KAS, efek
--   terhadap kas pada periode berjalan dihitung sebagai (Kredit - Debet).
--   Karena pada seluruh jurnal Total Debet = Total Kredit, maka:
--
--        Perubahan Kas = - SUM(Debet - Kredit) seluruh akun non-kas
--                      =   SUM(Kredit - Debet) seluruh akun non-kas
--
--   Sehingga TOTAL seluruh baris arus kas SELALU sama dengan perubahan saldo kas
--   (Kas Akhir - Kas Awal). Hal ini menjamin laporan selalu balance.
--
--   KLASIFIKASI (PSAK 2)
--   --------------------
--   - Kas & setara kas    : 1110 (Kas), 1111 (Bank)
--   - Aktivitas Operasi   : akun laba-rugi (4xxx, 5xxx, 6xxx, 7xxx, 8xxx) +
--                           perubahan modal kerja (piutang, persediaan, beban dibayar
--                           dimuka, uang muka, hutang usaha, hutang pajak, titipan, dll)
--                           + penyusutan (akumulasi penyusutan).
--   - Aktivitas Investasi : aset tetap (1410 Tanah, dst).
--   - Aktivitas Pendanaan : hutang jk panjang/bank (2114, 2116), modal saham (3110),
--                           laba ditahan / dividen (3180), laba tahun berjalan (3190).
--
--   Catatan: Beban Penyusutan otomatis ter-"add back" di seksi operasi karena pergerakan
--   akun Akumulasi Penyusutan (kredit) meng-offset Beban Penyusutan (debet).
-- ==========================================================================================
-- EXEC [dbo].[USP_GL_R_CashflowStatement] '202604', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_CashflowStatement] '202605', 1, 1, 0
-- ==========================================================================================

-- Catatan: gunakan CREATE OR ALTER karena procedure ini baru (belum ada di database).
CREATE OR ALTER PROCEDURE [dbo].[USP_GL_R_CashflowStatement]
	@Period				VARCHAR(6),
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@IDX_M_Project		BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_CurrentYear	CHAR(4) = LEFT(@Period,4)
	DECLARE @_CurrentMonth	CHAR(2) = RIGHT(@Period,2)
	DECLARE @_StartDate		DATE    = @_CurrentYear + '-' + @_CurrentMonth + '-01'
	DECLARE @_EndDate		DATE    = EOMONTH(@_StartDate)

	DECLARE @_IDX_M_Company	INT    = @IDX_M_Company
	DECLARE @_IDX_M_Branch	INT    = @IDX_M_Branch
	DECLARE @_IDX_M_Project	BIGINT

	IF RTRIM(@IDX_M_Project) = 'ALL' OR RTRIM(@IDX_M_Project) = '0'
		SET @_IDX_M_Project = 0
	ELSE
		SET @_IDX_M_Project = @IDX_M_Project

	-- ======================================================================================
	-- 1. Working table : satu baris per akun non-kas + nilai pergerakan periode berjalan
	-- ======================================================================================
	CREATE TABLE #CF (
		Period				CHAR(6),
		IDX_M_COA			BIGINT,
		COA					VARCHAR(50),
		COADesc				VARCHAR(250),
		COAPrefix			CHAR(4),
		Section				INT,			-- 1=Operasi, 2=Investasi, 3=Pendanaan
		SectionDesc			VARCHAR(100),
		SubGroup			INT,
		SubGroupDesc		VARCHAR(100),
		BDebetAmount		DECIMAL(22,2),
		BCreditAmount		DECIMAL(22,2),
		CashFlowAmount		DECIMAL(22,2),	-- (Kredit - Debet) periode berjalan
		RowType				VARCHAR(10),
		SEQ					INT
	)

	-- Insert seluruh akun kecuali kas & setara kas (1110 Kas, 1111 Bank)
	INSERT INTO #CF (Period, IDX_M_COA, COA, COADesc, COAPrefix, BDebetAmount, BCreditAmount, CashFlowAmount, RowType, SEQ)
	SELECT @Period, A.IDX_M_COA, A.COAID, A.COADesc, LEFT(A.COAID,4), 0, 0, 0, 'DETAIL', 9999
	FROM GL_M_COA A WITH(NOLOCK)
	WHERE LEFT(A.COAID,4) NOT IN ('1110','1111')

	-- Update pergerakan jurnal periode berjalan (hanya jurnal terposting)
	UPDATE #CF SET
		 BDebetAmount   = _J.BDebet
		,BCreditAmount  = _J.BCredit
		,CashFlowAmount = (_J.BCredit - _J.BDebet)
	FROM (
		SELECT JD.IDX_M_COA, BDebet = SUM(JD.BDebetAmount), BCredit = SUM(JD.BCreditAmount)
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		WHERE JH.IDX_M_Company = @_IDX_M_Company
			AND JH.IDX_M_Branch = @_IDX_M_Branch
			AND JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND YEAR(JH.JournalDate) = @_CurrentYear AND MONTH(JH.JournalDate) = @_CurrentMonth
			AND (@_IDX_M_Project = 0 OR JD.IDX_M_Project = @_IDX_M_Project)
		GROUP BY JD.IDX_M_COA
	) _J
	INNER JOIN #CF ON #CF.IDX_M_COA = _J.IDX_M_COA

	-- ======================================================================================
	-- 2. Klasifikasi PSAK
	-- ======================================================================================
	-- Default : Operasi - perubahan modal kerja (akun neraca selain kas/investasi/pendanaan)
	UPDATE #CF SET Section = 1, SectionDesc = 'ARUS KAS DARI AKTIVITAS OPERASI',
		SubGroup = 12, SubGroupDesc = 'Perubahan Modal Kerja & Penyesuaian', SEQ = 120

	-- Operasi - hasil usaha (akun laba-rugi)
	UPDATE #CF SET SubGroup = 11, SubGroupDesc = 'Laba/(Rugi) Bersih', SEQ = 110
	WHERE COAPrefix IN ('4100','4200','7110','5110','5113','6110','6111','6112','6113','8110','8111')

	-- Investasi : aset tetap
	UPDATE #CF SET Section = 2, SectionDesc = 'ARUS KAS DARI AKTIVITAS INVESTASI',
		SubGroup = 21, SubGroupDesc = 'Aktivitas Investasi', SEQ = 210
	WHERE COAPrefix IN ('1410')

	-- Pendanaan : pinjaman jk panjang/bank, modal, laba ditahan, laba tahun berjalan
	UPDATE #CF SET Section = 3, SectionDesc = 'ARUS KAS DARI AKTIVITAS PENDANAAN',
		SubGroup = 31, SubGroupDesc = 'Aktivitas Pendanaan', SEQ = 310
	WHERE COAPrefix IN ('2114','2116','3110','3180','3190')

	-- ======================================================================================
	-- 3. Saldo kas awal & mutasi kas periode berjalan (Kas + Bank)
	-- ======================================================================================
	DECLARE @_BeginningCash DECIMAL(22,2) = 0
	DECLARE @_CashMovement  DECIMAL(22,2) = 0

	-- Saldo awal = seluruh mutasi kas SEBELUM tanggal awal periode (termasuk jurnal saldo awal)
	SELECT @_BeginningCash = ISNULL(SUM(JD.BDebetAmount - JD.BCreditAmount),0)
	FROM GL_T_JournalDetail JD WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
	WHERE JH.IDX_M_Company = @_IDX_M_Company
		AND JH.IDX_M_Branch = @_IDX_M_Branch
		AND JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
		AND CONVERT(DATE, JH.JournalDate) < @_StartDate
		AND LEFT(A.COAID,4) IN ('1110','1111')
		AND (@_IDX_M_Project = 0 OR JD.IDX_M_Project = @_IDX_M_Project)

	-- Mutasi kas periode berjalan (untuk cross-check; nilainya = SUM(CashFlowAmount) #CF)
	SELECT @_CashMovement = ISNULL(SUM(JD.BDebetAmount - JD.BCreditAmount),0)
	FROM GL_T_JournalDetail JD WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
	WHERE JH.IDX_M_Company = @_IDX_M_Company
		AND JH.IDX_M_Branch = @_IDX_M_Branch
		AND JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
		AND YEAR(JH.JournalDate) = @_CurrentYear AND MONTH(JH.JournalDate) = @_CurrentMonth
		AND LEFT(A.COAID,4) IN ('1110','1111')
		AND (@_IDX_M_Project = 0 OR JD.IDX_M_Project = @_IDX_M_Project)

	-- ======================================================================================
	-- 4. Output : baris detail (akun yg bergerak) + baris ringkasan kas (BEGINCASH/ENDCASH)
	-- ======================================================================================
	;WITH Result AS (
		SELECT Period, IDX_M_COA, COA, COADesc, Section, SectionDesc, SubGroup, SubGroupDesc,
			CashFlowAmount, RowType, SEQ
		FROM #CF
		WHERE CashFlowAmount <> 0

		UNION ALL
		SELECT @Period, 0, '', 'Kas dan Setara Kas Awal Periode', 9, 'RINGKASAN KAS', 90, 'Ringkasan Kas',
			@_BeginningCash, 'BEGINCASH', 900

		UNION ALL
		SELECT @Period, 0, '', 'Kas dan Setara Kas Akhir Periode', 9, 'RINGKASAN KAS', 91, 'Ringkasan Kas',
			@_BeginningCash + @_CashMovement, 'ENDCASH', 910
	)
	SELECT * FROM Result
	ORDER BY Section, SubGroup, SEQ, COA

	DROP TABLE #CF
END
GO
