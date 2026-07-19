SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		:	Anton
-- Create date	:	2019-10-09
-- Description	:	Trial Balance Report
--
-- Modified		:	19 Jul 2026 - Samuel Febrianto
--	Perbaikan agar total BEGIN = 0, total DEBET = total CREDIT, dan total ENDING = 0:
--	1. Saldo awal akun Pendapatan (IC) & Beban (EX) di-nol-kan untuk SEMUA periode
--	   (sebelumnya hanya periode Januari), karena akumulasinya sudah diwakili baris
--	   Laba Ditahan & Laba Tahun Berjalan. Ini menghilangkan dobel hitung di kolom BEGIN.
--	2. Simulasi Laba Ditahan (L/R tahun-tahun sebelumnya) dan Laba Tahun Berjalan
--	   (L/R tahun berjalan s/d sebelum StartDate) DITAMBAHKAN ke saldo riil akun,
--	   bukan menimpa, sehingga posting manual ke akun tsb tidak hilang.
--	3. Mutasi sintetis (BDebet = ABS(beban), BCredit = ABS(pendapatan)) pada baris
--	   Laba Tahun Berjalan DIHAPUS - mutasi asli akun pendapatan/beban sudah tampil
--	   di barisnya masing-masing. Ini menghilangkan selisih kolom DEBET vs CREDIT.
--	4. Akun Laba Ditahan & Laba Tahun Berjalan tidak lagi dikecualikan dari update
--	   mutasi periode, supaya posting riil ke akun tsb tetap tampil.
--	5. Filter branch pada simulasi laba mendukung @IDX_M_Branch = 0 (ALL) + ISNULL
--	   (sebelumnya menghasilkan NULL bila branch = 0 / tidak ada data).
--	6. Blok khusus bulan Januari dihapus karena sudah tercakup logika umum
--	   (di bulan Januari, L/R tahun berjalan sebelum StartDate otomatis = 0).
-- =============================================

/*
	IDX 115 --> 308.11.105 (RE - Prior Years) = Laba Ditahan
	IDX 117 --> 308.11.106 (Retained Earning-Current Y.T.D) = Laba Tahun Berjalan
*/
-- EXEC [dbo].[USP_GL_R_TrialBalance] 1, 1, '2026-06-01', '2026-06-30'
-- EXEC [dbo].[USP_GL_R_TrialBalance] 1, 1, '2026-01-01', '2026-01-31'
-- EXEC [dbo].[USP_GL_R_TrialBalance] 1, 0, '2026-01-01', '2026-12-31'

ALTER PROCEDURE [dbo].[USP_GL_R_TrialBalance]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- ============================================================================================
-- Table Trial Balance
-- ============================================================================================
	CREATE TABLE #TB
	(
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_COA						BIGINT,
		---------------------------------------------------------------------
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(50),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(50),
		COA								VARCHAR(250),
		COADesc							VARCHAR(250),
		AccountType						CHAR(2),
		---------------------------------------------------------------------
		BBBalanceAmount					DECIMAL(22,2),
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2),
		BMovementAmount					DECIMAL(22,2),
		BEBalanceAmount					DECIMAL(22,2)
	)

	DECLARE @StartPeriod VARCHAR(6) = LEFT(CONVERT(VARCHAR,@StartDate,112),6)
	DECLARE @MonthPeriod VARCHAR(2) = RIGHT(@StartPeriod,2)
	DECLARE @BeforeStartPeriod VARCHAR(6) = LEFT(CONVERT(VARCHAR,DATEADD(M,-1,@StartDate),112),6)

	DECLARE @_CompanyID		VARCHAR(50)
	DECLARE @_CompanyName	VARCHAR(150)
	DECLARE @_BranchID		VARCHAR(50)
	DECLARE @_BranchName	VARCHAR(150)

	SELECT @_CompanyID = CompanyAlias, @_CompanyName = CompanyName
	FROM GN_M_Company WHERE IDX_M_Company = @IDX_M_Company

	SELECT @_BranchID = BranchID, @_BranchName = BranchName
	FROM GN_M_Branch WHERE IDX_M_Branch = @IDX_M_Branch

	INSERT INTO #TB
	SELECT
		@IDX_M_Company, @IDX_M_Branch, COA.IDX_M_COA, @_CompanyID, @_CompanyName,
		CASE WHEN @IDX_M_Branch > 0 THEN @_BranchID ELSE 'ALL' END,
		CASE WHEN @IDX_M_Branch > 0 THEN @_BranchName ELSE 'ALL' END,
		COA.COAID, COA.COADesc, COATYPE.COATypeID,
		0.00, 0.00, 0.00, 0.00, 0.00
	FROM GL_M_COA COA
		INNER JOIN GL_M_COAType COATYPE ON COA.IDX_M_COAType = COATYPE.IDX_M_COAType
	WHERE COA.RecordStatus = 'A'


	-- =================================================================================================
	-- PERHITUNGAN BEGINNING BALANCE (SALDO AWAL)
	-- =================================================================================================
	IF @IDX_M_Branch = 0 -- (ALL BRANCH)
	BEGIN

		IF EXISTS (
			SELECT IDX_GL_T_AccountBalance, JournalPeriod
			FROM GL_T_AccountBalance AB
			WHERE AB.IDX_M_Company = @IDX_M_Company AND AB.JournalPeriod = @BeforeStartPeriod
		)
		BEGIN
			-- UPDATE FROM TABLE ACCOUNT BALANCE
			-- SET BEGINNING BALANCE = ENDING BALANCE PERIODE SEBELUMNYA
			UPDATE #TB SET
				BBBalanceAmount = ISNULL(BEndingBalance,0)
			FROM #TB
				LEFT JOIN
			(
				SELECT IDX_M_COA, SUM(BEndingBalance) AS BEndingBalance
				FROM GL_T_AccountBalance AB
				WHERE AB.IDX_M_Company = @IDX_M_Company AND AB.JournalPeriod = @BeforeStartPeriod
				GROUP BY IDX_M_COA
			) AB ON #TB.IDX_M_COA = AB.IDX_M_COA

		END
		ELSE
		BEGIN

			-- UPDATE BEGINING BALANCE FROM JOURNAL TRANSACTION (ENDING BALANCE FROM PREVIOUS PERIOD)
			UPDATE #TB SET
				BBBalanceAmount = ISNULL(DebetAmount - CreditAmount,0)
			FROM #TB
				LEFT JOIN
			(
				SELECT JD.IDX_M_COA, SUM(JD.BDebetAmount) AS DebetAmount, SUM(JD.BCreditAmount) AS CreditAmount
				FROM GL_T_JournalHeader JH WITH(NOLOCK)
					 LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
				WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
						AND CONVERT(DATE,JH.JournalDate) < @StartDate
						AND JH.IDX_M_Company = @IDX_M_Company
				GROUP BY JD.IDX_M_COA
			) Temp ON #TB.IDX_M_COA = Temp.IDX_M_COA

		END
	END
	ELSE
	BEGIN -- (SPECIFIC BRANCH)

		IF EXISTS (
			SELECT IDX_GL_T_AccountBalance, JournalPeriod
			FROM GL_T_AccountBalance AB
			WHERE AB.IDX_M_Company = @IDX_M_Company AND AB.JournalPeriod = @BeforeStartPeriod
		)
		BEGIN
			-- UPDATE FROM TABLE ACCOUNT BALANCE
			-- SET BEGINNING BALANCE = ENDING BALANCE PERIODE SEBELUMNYA
			UPDATE #TB SET
				BBBalanceAmount = ISNULL(BEndingBalance,0)
			FROM #TB
				LEFT JOIN
			(
				SELECT IDX_M_COA, SUM(BEndingBalance) AS BEndingBalance
				FROM GL_T_AccountBalance AB
				WHERE AB.IDX_M_Company = @IDX_M_Company
					AND IDX_M_Branch = @IDX_M_Branch
					AND AB.JournalPeriod = @BeforeStartPeriod
				GROUP BY IDX_M_COA
			) AB ON #TB.IDX_M_COA = AB.IDX_M_COA
		END
		ELSE
		BEGIN
			-- UPDATE BEGINING BALANCE FROM JOURNAL TRANSACTION (ENDING BALANCE FROM PREVIOUS PERIOD)
			UPDATE #TB SET
				BBBalanceAmount = ISNULL(DebetAmount - CreditAmount,0)
			FROM #TB
				LEFT JOIN
			(
				SELECT JD.IDX_M_COA, SUM(JD.BDebetAmount) AS DebetAmount, SUM(JD.BCreditAmount) AS CreditAmount
				FROM GL_T_JournalHeader JH WITH(NOLOCK)
					 LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
				WHERE JH.PostingStatus = 'P'
					AND JH.RecordStatus = 'A'
					AND JD.RecordStatus = 'A'
					AND CONVERT(DATE,JH.JournalDate) < @StartDate
					AND JH.IDX_M_Company = @IDX_M_Company
					AND JH.IDX_M_Branch = @IDX_M_Branch
				GROUP BY JD.IDX_M_COA
			) Temp ON #TB.IDX_M_COA = Temp.IDX_M_COA
		END
	END

	-- ======================================================================
	-- SIMULASI LABA DITAHAN (TAHUN-TAHUN SEBELUMNYA) & LABA TAHUN BERJALAN
	-- ======================================================================

	DECLARE @_RetainedEarningAccount		INT
	DECLARE @_CurrentEarningAccount			INT

	DECLARE @_TotalRetainedEarning			DECIMAL(22,2)
	DECLARE @_Total_BB_CurrentEarning		DECIMAL(22,2)

	-- GET COA FOR RETAINED EARNING (LABA DITAHAN) & CURRENT EARNING (LABA TAHUN BERJALAN)
	SELECT @_RetainedEarningAccount = RetainedEarningAccount, @_CurrentEarningAccount = CurrentEarningAccount
	FROM GN_M_Company
	WHERE IDX_M_Company = @IDX_M_Company

	-- LABA DITAHAN: akumulasi L/R (pendapatan & beban) tahun-tahun SEBELUM tahun berjalan
	SELECT @_TotalRetainedEarning = ISNULL(SUM(JD.BDebetAmount) - SUM(JD.BCreditAmount), 0)
	FROM GL_T_JournalHeader JH WITH(NOLOCK)
	LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
	LEFT JOIN GL_M_COA C ON C.IDX_M_COA = JD.IDX_M_COA
	WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND YEAR(JH.JournalDate) < YEAR(@StartDate)
			AND JH.IDX_M_Company = @IDX_M_Company
			AND (@IDX_M_Branch = 0 OR JH.IDX_M_Branch = @IDX_M_Branch)
			AND C.IDX_M_COAType IN (3,4)

	SET @_TotalRetainedEarning = ISNULL(@_TotalRetainedEarning, 0)

	-- LABA TAHUN BERJALAN: L/R tahun berjalan s/d sehari sebelum StartDate
	-- (untuk periode Januari otomatis = 0)
	SELECT @_Total_BB_CurrentEarning = ISNULL(SUM(JD.BDebetAmount) - SUM(JD.BCreditAmount), 0)
	FROM GL_T_JournalHeader JH WITH(NOLOCK)
	LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
	LEFT JOIN GL_M_COA C ON C.IDX_M_COA = JD.IDX_M_COA
	WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND CONVERT(DATE, JH.JournalDate) < @StartDate
			AND YEAR(JH.JournalDate) = YEAR(@StartDate)
			AND JH.IDX_M_Company = @IDX_M_Company
			AND (@IDX_M_Branch = 0 OR JH.IDX_M_Branch = @IDX_M_Branch)
			AND C.IDX_M_COAType IN (3,4)

	SET @_Total_BB_CurrentEarning = ISNULL(@_Total_BB_CurrentEarning, 0)

	-- =============================================================================================================================================
	-- Saldo awal akun Pendapatan (IC) & Beban (EX) di-nol-kan untuk SEMUA periode.
	-- Akumulasinya diwakili baris Laba Ditahan & Laba Tahun Berjalan di bawah,
	-- sehingga total kolom BEGIN tetap 0 (seimbang).
	-- =============================================================================================================================================
	UPDATE #TB SET BBBalanceAmount = 0 WHERE AccountType IN ('IC','EX')

	-- Simulasi DITAMBAHKAN ke saldo riil akun (bukan menimpa),
	-- supaya posting manual ke akun laba ditahan / laba tahun berjalan tidak hilang.
	UPDATE #TB SET
		BBBalanceAmount = BBBalanceAmount + @_TotalRetainedEarning
	WHERE IDX_M_COA = @_RetainedEarningAccount

	UPDATE #TB SET
		BBBalanceAmount = BBBalanceAmount + @_Total_BB_CurrentEarning
	WHERE IDX_M_COA = @_CurrentEarningAccount

	-- CATATAN: mutasi sintetis (BDebet = ABS(total beban), BCredit = ABS(total pendapatan))
	-- pada akun Laba Tahun Berjalan DIHAPUS. Mutasi periode berjalan akun pendapatan/beban
	-- sudah tampil di barisnya masing-masing; menambahkannya lagi di baris LTB membuat
	-- laba periode terhitung dua kali dan total DEBET <> total CREDIT.

	-- ==================================================================================================================================================
	-- UPDATE ACCOUNT MOVEMENT (DEBET, CREDIT, AND MOVEMENT AMOUNT) IN TEMPLATE TB
	-- Akun Laba Ditahan & Laba Tahun Berjalan TIDAK dikecualikan lagi,
	-- supaya posting riil ke akun tersebut (bila ada) tetap tampil.
	-- ==================================================================================================================================================
	IF @IDX_M_Branch = 0
	BEGIN

		UPDATE #TB SET
			BDebetAmount = ISNULL(DebetAmount,0),
			BCreditAmount = ISNULL(CreditAmount,0),
			BMovementAmount = ISNULL(DebetAmount,0) - ISNULL(CreditAmount,0)
		FROM #TB
		LEFT JOIN
		(
			SELECT JD.IDX_M_COA, SUM(JD.BDebetAmount) AS DebetAmount, SUM(JD.BCreditAmount) AS CreditAmount
			FROM GL_T_JournalHeader JH WITH(NOLOCK)
					LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
			WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
					AND (CONVERT(DATE,JH.JournalDate) BETWEEN @StartDate AND @EndDate)
					AND JH.IDX_M_Company = @IDX_M_Company
			GROUP BY JD.IDX_M_COA
		)	Temp ON #TB.IDX_M_COA = Temp.IDX_M_COA
	END
	ELSE
	BEGIN

		UPDATE #TB SET
			BDebetAmount = ISNULL(DebetAmount,0),
			BCreditAmount = ISNULL(CreditAmount,0),
			BMovementAmount = ISNULL(DebetAmount,0) - ISNULL(CreditAmount,0)
		FROM #TB
			LEFT JOIN
			(
				SELECT JH.IDX_M_Branch, JD.IDX_M_COA, SUM(JD.BDebetAmount) AS DebetAmount, SUM(JD.BCreditAmount) AS CreditAmount
				FROM GL_T_JournalHeader JH WITH(NOLOCK)
					 LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
				WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
						AND (CONVERT(DATE,JH.JournalDate) BETWEEN @StartDate AND @EndDate)
						AND JH.IDX_M_Company = @IDX_M_Company
						AND JH.IDX_M_Branch = @IDX_M_Branch
				GROUP BY JH.IDX_M_Branch, JD.IDX_M_COA
			)	Temp ON #TB.IDX_M_COA = Temp.IDX_M_COA AND #TB.IDX_M_Branch = Temp.IDX_M_Branch
	END
	-- ==========================================================================================================================================================

	UPDATE #TB SET
		BEBalanceAmount = BBBalanceAmount + BMovementAmount


	-- QUERY RESULT
	SELECT * FROM #TB ORDER BY COA

	-- DROP TEMP TABLE
	DROP TABLE #TB

END
GO
