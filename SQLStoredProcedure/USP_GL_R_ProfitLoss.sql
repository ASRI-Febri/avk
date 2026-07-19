SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 04 Sep 2018
-- Description	: Profit and Loss By Period
-- ==========================================================================================
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202511', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202512', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202601', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202602', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202603', 1, 1, 0
-- EXEC [dbo].[USP_GL_R_ProfitLoss] '202604', 1, 1, 0
-- ==========================================================================================

ALTER PROCEDURE [dbo].[USP_GL_R_ProfitLoss]
	@Period				VARCHAR(6),
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@IDX_M_Project		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @_CurrentPeriod			CHAR(6)
	DECLARE @_CurrentMonth			CHAR(2)
	DECLARE @_CurrentYear			CHAR(4)

	DECLARE @_PreviousPeriod		CHAR(6)
	DECLARE @_PreviousMonth			CHAR(2)
	DECLARE @_PreviousYear			CHAR(4)

	DECLARE @_IDX_M_Company			BIGINT
	DECLARE @_IDX_M_Branch			BIGINT
	DECLARE @_IDX_M_Project			BIGINT
	---------------------------------------------------------------
	
	SET @_CurrentPeriod = @Period
	SET @_CurrentMonth = RIGHT(@Period,2)
	SET @_CurrentYear = LEFT(@Period,4)

	DECLARE @_StartDateCurrentYear DATE = @_CurrentYear + '-01-01' 
	DECLARE @_EndDatePreviousYear DATE = DATEADD(d,-1,@_StartDateCurrentYear)

	SET @_PreviousPeriod = CONVERT(CHAR(4),YEAR(@_EndDatePreviousYear)) + CONVERT(CHAR(2),MONTH(@_EndDatePreviousYear))
	SET @_PreviousMonth = RIGHT(@_PreviousPeriod,2)
	SET @_PreviousYear = LEFT(@_PreviousPeriod,4)	

	DECLARE @_StartDate DATE = LEFT(@Period,4) + '-' + RIGHT(@Period,2) + '-01'

	PRINT 'Previous Period: ' + @_PreviousPeriod
	PRINT 'Current Period: ' + @_CurrentPeriod
	PRINT 'Start Date: ' + CAST(@_StartDate AS VARCHAR)
	PRINT 'End Date of Previous Year: ' + CAST(@_EndDatePreviousYear AS VARCHAR)


	---------------------------------------------------------------
	-- Company and Branch
	IF RTRIM(@IDX_M_Company) = 'ALL'
		SET @_IDX_M_Company = 0
	ELSE
		SET @_IDX_M_Company = @IDX_M_Company

	IF RTRIM(@IDX_M_Branch) = 'ALL'
		SET @_IDX_M_Branch = 0
	ELSE
		SET @_IDX_M_Branch = @IDX_M_Branch

	IF RTRIM(@IDX_M_Project) = 'ALL' OR RTRIM(@IDX_M_Project) = '0'
		SET @_IDX_M_Project = 0
	ELSE
		SET @_IDX_M_Project = @IDX_M_Project
	-------------------------------------------------------------------------	

	-- ============================================================================================
    -- Table Trial Balance
	-- ============================================================================================
	CREATE TABLE #PL (
		Period							CHAR(6),
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_Project					BIGINT,
		IDX_M_COA						BIGINT,		
		---------------------------------------------------------------------
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(100),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(100),
		ProjectID						VARCHAR(50),
		ProjectName						VARCHAR(100),
		COA								VARCHAR(250),
		COADesc							VARCHAR(250),
		AccountType						CHAR(2),
		AccountTypeDesc					VARCHAR(100),
		---------------------------------------------------------------------
		COAGroupID						VARCHAR(50),	
		COAGroupDesc					VARCHAR(100),
		---------------------------------------------------------------------
		--OBBalanceAmount				DECIMAL(22,2),
		--ODebetAmount					DECIMAL(22,2),
		--OCreditAmount					DECIMAL(22,2),
		--OMovementAmount				DECIMAL(22,2),
		--OEBalanceAmount				DECIMAL(22,2),
		---------------------------------------------------------------------
		BBBalanceAmount					DECIMAL(22,2),
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2),
		BMovementAmount					DECIMAL(22,2),
		BEBalanceAmount					DECIMAL(22,2),
		SEQ								INT
	)



	IF @_IDX_M_Project <> 0 
	BEGIN
		-- Insert Chart of Account - Income and Expense
		INSERT INTO #PL
		SELECT @Period, @_IDX_M_Company, @_IDX_M_Branch, @_IDX_M_Project, IDX_M_COA, 
			'','','', '', '', '', COAID, COADesc, B.COATypeID, B.COATypeDesc,
			G1.COAGroup1ID, G1.COAGroup1Name1,
			--0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0 , 1
		FROM GL_M_COA A WITH(NOLOCK)
		LEFT JOIN GL_M_COAType B WITH(NOLOCK) ON B.IDX_M_COAType = A.IDX_M_COAType 
		LEFT JOIN GL_M_COAGroup1 G1 ON G1.IDX_M_COAGroup1 = A.COAGroup1
		WHERE A.IDX_M_COAType IN (3,4)
		ORDER BY A.COAID

		-- Update Company and Branch
		UPDATE #PL SET CompanyID = GC.CompanyAlias, CompanyDesc = GC.CompanyName
		FROM (
			SELECT CompanyAlias, CompanyName FROM GN_M_Company WITH(NOLOCK) WHERE IDX_M_Company = @IDX_M_Company
			) GC
		
		UPDATE #PL SET BranchID = MB.BranchID, BranchDesc = MB.BranchName
		FROM (
			SELECT BranchID, BranchName FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @_IDX_M_Branch
			) MB

		UPDATE #PL SET ProjectID = MP.ProjectID, ProjectName = MP.ProjectName
		FROM (
			SELECT ProjectID, ProjectName FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @_IDX_M_Project
			) MP
	END
	ELSE
	BEGIN

		DECLARE @IDX_GC			AS BIGINT = 1
		DECLARE @IDX_BRANCH		AS BIGINT = 1
		DECLARE @IDX_PROJECT	AS BIGINT
		DECLARE @GC_ID			AS VARCHAR(50)
		DECLARE @GC_NAME		AS VARCHAR(200)
		DECLARE @BRANCH_ID		AS VARCHAR(50)
		DECLARE @BRANCH_NAME	AS VARCHAR(200)
		DECLARE @PROJECT_ID		AS VARCHAR(50)
		DECLARE @PROJECT_NAME	AS VARCHAR(200)
	
		DECLARE Cursor_ProjectBranchCompany CURSOR LOCAL FOR 
		SELECT MC.IDX_M_Company, MB.IDX_M_Branch, MP.IDX_M_Project, MC.CompanyID, MC.CompanyName, 
			MB.BranchID, MB.BranchName, 
			MP.ProjectID, MP.ProjectName
		FROM GN_M_Project MP WITH(NOLOCK)
			INNER JOIN GN_M_Branch MB WITH(NOLOCK) ON MP.IDX_M_Branch = MB.IDX_M_Branch
			INNER JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
		WHERE MP.RecordStatus = 'A' AND MB.RecordStatus = 'A' AND MC.RecordStatus = 'A' AND MB.IDX_M_Branch = @IDX_M_Branch AND MC.IDX_M_Company = @IDX_M_Company

		OPEN Cursor_ProjectBranchCompany
		FETCH NEXT FROM Cursor_ProjectBranchCompany INTO @IDX_GC, @IDX_BRANCH, @IDX_PROJECT, @GC_ID, @GC_NAME, @BRANCH_ID, @BRANCH_NAME, @PROJECT_ID, @PROJECT_NAME
		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT INTO #PL
			SELECT	@Period, @IDX_GC, @IDX_BRANCH, @IDX_PROJECT, IDX_M_COA, 
					@GC_ID, @GC_NAME, @BRANCH_ID, @BRANCH_NAME, @PROJECT_ID, @PROJECT_NAME, 
					COAID, COADesc, B.COATypeID, B.COATypeDesc,
					G1.COAGroup1ID, G1.COAGroup1Name1,
					0, 0, 0, 0, 0, 1
			FROM GL_M_COA A WITH(NOLOCK)
			LEFT JOIN GL_M_COAType B WITH(NOLOCK) ON B.IDX_M_COAType = A.IDX_M_COAType 
			LEFT JOIN GL_M_COAGroup1 G1 ON G1.IDX_M_COAGroup1 = A.COAGroup1
			WHERE A.IDX_M_COAType IN (3,4)
			ORDER BY A.COAID

			FETCH NEXT FROM Cursor_ProjectBranchCompany INTO @IDX_GC, @IDX_BRANCH, @IDX_PROJECT, @GC_ID, @GC_NAME, @BRANCH_ID, @BRANCH_NAME, @PROJECT_ID, @PROJECT_NAME
		END
		CLOSE Cursor_ProjectBranchCompany;
		DEALLOCATE Cursor_ProjectBranchCompany;

		-- Insert Chart of Account - Income and Expense
		--INSERT INTO #PL
		--SELECT @Period, @_IDX_M_Company, @_IDX_M_Branch, @_IDX_M_Project, IDX_M_COA, 
		--	'','','', '', 'ALL PROJECT', 'ALL PROJECT', COAID, COADesc, B.COATypeID, 
		--	--0, 0, 0, 0, 0, 
		--	0, 0, 0, 0, 0, 2
		--FROM GL_M_COA A WITH(NOLOCK)
		--LEFT JOIN GL_M_COAType B WITH(NOLOCK) ON B.IDX_M_COAType = A.IDX_M_COAType 
		--WHERE A.IDX_M_COAType IN (3,4)
		--ORDER BY A.COAID

		-- Update Company and Branch
		UPDATE #PL SET CompanyID = GC.CompanyAlias, CompanyDesc = GC.CompanyName
		FROM (
			SELECT CompanyAlias, CompanyName FROM GN_M_Company WITH(NOLOCK) WHERE IDX_M_Company = @IDX_M_Company
			) GC
		WHERE IDX_M_Project = 0
		
		UPDATE #PL SET BranchID = MB.BranchID, BranchDesc = MB.BranchName
		FROM (
			SELECT BranchID, BranchName FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @_IDX_M_Branch
			) MB
		WHERE IDX_M_Project = 0

	END

	IF @_IDX_M_Project <> 0 
	BEGIN
		-- ============================================================================================================================================
		-- Update Movement From Journal Detail in current period
		-- not include account Current earning / Laba tahun berjalan
		-- ============================================================================================================================================
		UPDATE #PL SET
			 BDebetAmount = _Journal.BDebetAmount
			,BCreditAmount = _Journal.BCreditAmount		
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA, BDebetAmount = SUM(JD.BDebetAmount), BCreditAmount = SUM(JD.BCreditAmount)
			FROM GL_T_JournalDetail JD WITH(NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch AND JH.PostingStatus = 'P'
				AND YEAR(JH.JournalDate) = LEFT(@Period,4) AND MONTH(JH.JournalDate) = RIGHT(@Period,2) AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA
			) _Journal
		INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch AND 
				   #PL.IDX_M_Project = _Journal.IDX_M_Project AND #PL.IDX_M_COA = _Journal.IDX_M_COA	
		--WHERE RTRIM(#PL.COA) <> '304.01.01.003'

		-- ============================================================================================================================================
		-- Update Base Beginning Balance From Journal Detail
		-- Beginning Balance = (Opening Balance + Movement Before Current Period)

		-- Update all account except account Current Earning / Laba Tahun Berjalan (304.01.01.003)
		-- karena account ini akan diupdate dengan perhitungan profit and loss (Income - Expense) dan
		-- journal memorial yang menggunakan account tersebut
		-- ============================================================================================================================================
		UPDATE #PL SET
			 BBBalanceAmount = BBBalanceAmount + (_Journal.BDebetAmount - _Journal.BCreditAmount)		
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA, BDebetAmount = SUM(JD.BDebetAmount), BCreditAmount = SUM(JD.BCreditAmount)
			FROM GL_T_JournalDetail JD WITH(NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch AND JH.PostingStatus = 'P'
				AND CONVERT(DATE,JH.JournalDate) < @_StartDate AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
				AND YEAR(JH.JournalDate) = @_CurrentYear
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA
			) _Journal
		INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch AND
				   #PL.IDX_M_Project = _Journal.IDX_M_Project AND #PL.IDX_M_COA = _Journal.IDX_M_COA
	END
	ELSE
	BEGIN
		-- ============================================================================================================================================
		-- Update Movement From Journal Detail in current period
		-- not include account Current earning / Laba tahun berjalan
		-- ============================================================================================================================================
		-- UPDATE #PL SET
		-- 	 BDebetAmount = _Journal.BDebetAmount
		-- 	,BCreditAmount = _Journal.BCreditAmount		
		-- FROM (
		-- 	SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA, BDebetAmount = SUM(JD.BDebetAmount), BCreditAmount = SUM(JD.BCreditAmount)
		-- 	FROM GL_T_JournalDetail JD WITH(NOLOCK)
		-- 		INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		-- 	WHERE JH.IDX_M_Company = @IDX_GC AND JH.IDX_M_Branch = @IDX_BRANCH AND JH.PostingStatus = 'P'
		-- 		AND YEAR(JH.JournalDate) = LEFT(@Period,4) AND MONTH(JH.JournalDate) = RIGHT(@Period,2) AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
		-- 	GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA
		-- 	) _Journal
		-- INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch AND 
		-- 		   #PL.IDX_M_Project = ISNULL(_Journal.IDX_M_Project,0) AND #PL.IDX_M_COA = _Journal.IDX_M_COA	
		-- WHERE #PL.IDX_M_Project <> 0

		UPDATE #PL SET
			 BDebetAmount = _Journal.BDebetAmount
			,BCreditAmount = _Journal.BCreditAmount		
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA, BDebetAmount = SUM(JD.BDebetAmount), BCreditAmount = SUM(JD.BCreditAmount)
			FROM GL_T_JournalDetail JD WITH(NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch AND JH.PostingStatus = 'P'
				AND YEAR(JH.JournalDate) = LEFT(@Period,4) AND MONTH(JH.JournalDate) = RIGHT(@Period,2) AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA
			) _Journal
		INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch AND #PL.IDX_M_COA = _Journal.IDX_M_COA	
		--WHERE #PL.IDX_M_Project = 0
		--WHERE RTRIM(#PL.COA) <> '304.01.01.003'

		-- ============================================================================================================================================
		-- Update Base Beginning Balance From Journal Detail
		-- Beginning Balance = (Opening Balance + Movement Before Current Period)

		-- Update all account except account Current Earning / Laba Tahun Berjalan (304.01.01.003)
		-- karena account ini akan diupdate dengan perhitungan profit and loss (Income - Expense) dan
		-- journal memorial yang menggunakan account tersebut
		-- ============================================================================================================================================
		UPDATE #PL SET
			 BBBalanceAmount = BBBalanceAmount + (_Journal.BDebetAmount - _Journal.BCreditAmount)		
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA, 
				BDebetAmount = SUM(JD.BDebetAmount), 
				BCreditAmount = SUM(JD.BCreditAmount)
			FROM GL_T_JournalDetail JD WITH(NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.IDX_M_Company = @IDX_GC AND JH.IDX_M_Branch = @IDX_BRANCH AND JH.PostingStatus = 'P'
				AND CONVERT(DATE,JH.JournalDate) < @_StartDate AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
				AND YEAR(JH.JournalDate) = @_CurrentYear
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_Project, JD.IDX_M_COA
			) _Journal
		INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company 
				AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch 
				AND #PL.IDX_M_Project = _Journal.IDX_M_Project 
				AND #PL.IDX_M_COA = _Journal.IDX_M_COA
		WHERE #PL.IDX_M_Project <> 0

		UPDATE #PL SET
			 BBBalanceAmount = BBBalanceAmount + (_Journal.BDebetAmount - _Journal.BCreditAmount)		
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA, BDebetAmount = SUM(JD.BDebetAmount), BCreditAmount = SUM(JD.BCreditAmount)
			FROM GL_T_JournalDetail JD WITH(NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch AND JH.PostingStatus = 'P'
				AND CONVERT(DATE,JH.JournalDate) < @_StartDate AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
				AND YEAR(JH.JournalDate) = @_CurrentYear
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA
			) _Journal
		INNER JOIN #PL ON #PL.IDX_M_Company = _Journal.IDX_M_Company 
			AND #PL.IDX_M_Branch = _Journal.IDX_M_Branch 
			AND #PL.IDX_M_COA = _Journal.IDX_M_COA
		WHERE #PL.IDX_M_Project = 0
	END

	--UPDATE #PL SET BBBalanceAmount = (BBBalanceAmount * -1) 
	--WHERE AccountType = 'IC'

	-- Update Ending Balance
	UPDATE #PL SET BEBalanceAmount = BBBalanceAmount + BDebetAmount - BCreditAmount

	-- Khusus untuk bulan 01
	-- Saldo awal account income dan expense = 0
	-- Saldo awal Current Earning = 0
	-- Saldo Laba Ditahan = (Retained Earning + Current Earning) Periode Sebelumnya

	DECLARE @_RetainedEarningAccount		INT
	DECLARE @_CurrentEarningAccount			INT

	SELECT @_RetainedEarningAccount = RetainedEarningAccount, @_CurrentEarningAccount = CurrentEarningAccount
	FROM GN_M_Company 
	WHERE IDX_M_Company = @IDX_M_Company

	IF @_CurrentMonth = '01'
	BEGIN
		-- Current Earning
		--SELECT BBBalanceAmount, BDebetAmount, BCreditAmount, BEBalanceAmount FROM #PL WHERE RTRIM(COA) = '304.01.01.003'		

		-- Retained Earning
		--SELECT BBBalanceAmount, BDebetAmount, BCreditAmount, BEBalanceAmount FROM #PL WHERE RTRIM(COA) = '304.01.01.002'

		DECLARE @_PrevRetainedEarningAmount		DECIMAL(22,2) -- Previous Retained Earning
		DECLARE @_PrevCurrentEarningAmount		DECIMAL(22,2) -- Previous Current Earning

		-- Current Earning Tahun Sebelumnya
		SELECT @_PrevCurrentEarningAmount = ISNULL(BBBalanceAmount,0) 
		FROM #PL 
		WHERE IDX_M_COA = @_CurrentEarningAccount

		-- Update account income and expense
		UPDATE #PL SET BBBalanceAmount = 0 WHERE AccountType IN ('IC','EX')

		-- Update account laba tahun berjalan 
		UPDATE #PL SET BBBalanceAmount = 0 WHERE IDX_M_COA = @_CurrentEarningAccount

	END

	-- Retained Earning Tahun Sebelumnya
	SELECT @_PrevRetainedEarningAmount = ISNULL(BBBalanceAmount,0) 
	FROM #PL 
	WHERE IDX_M_COA = @_CurrentEarningAccount

	IF @_PrevRetainedEarningAmount IS NULL 
		SET @_PrevRetainedEarningAmount = 0

	--PRINT 'Current Earning PL ' + CONVERT(VARCHAR,@_CE_PL)
	--PRINT 'Current Earning JM ' + CONVERT(VARCHAR,@_CE_JM)

	--PRINT 'Prev CE ' + CONVERT(VARCHAR,@_PrevCE)
	--PRINT 'Prev RE ' + CONVERT(VARCHAR,@_PrevRE)

	-- Update account saldo laba tidak dicadangkan / retained earning
	--UPDATE #PL SET BBBalanceAmount = (@_CE_PL + @_CE_JM + @_PrevRE) WHERE RTRIM(COA) = '304.01.01.002'


	--SELECT 'before update ending balance',* FROM #PL WHERE RTRIM(#PL.COA) = '304.01.01.003'

	-- Update Ending Balance
	UPDATE #PL SET BEBalanceAmount = BBBalanceAmount + BDebetAmount - BCreditAmount

	--SELECT 'last code',* FROM #PL WHERE RTRIM(#PL.COA) = '304.01.01.003'

	--SELECT * FROM #PL ORDER BY IDX_M_Company, IDX_M_Branch, Period

	-- Account type income x -1 supaya hasilnya saat ditampilkan di laporan bisa  angka positif
	--UPDATE #PL SET BEBalanceAmount = BEBalanceAmount * -1 WHERE AccountType = 'IC'

	UPDATE #PL SET SEQ = 2 WHERE COAGroupID = '5000'
	-- SEQ 3 untuk account income dan expense, supaya tampil setelah account asset, liability, dan equity

	UPDATE #PL SET SEQ = 4 WHERE COAGroupID = '4100'
	UPDATE #PL SET SEQ = 4 WHERE COAGroupID = '7100'

	UPDATE #PL SET SEQ = 5 WHERE COAGroupID = '5100'
	UPDATE #PL SET SEQ = 5 WHERE COAGroupID = '6100'
	UPDATE #PL SET SEQ = 5 WHERE COAGroupID = '6200'
	UPDATE #PL SET SEQ = 5 WHERE COAGroupID = '8000'

	-- SEQ 6 untuk account lain-lain, supaya tampil paling bawah


	-- Output
	SELECT * 
	FROM #PL
	WHERE BEBalanceAmount <> 0
	ORDER BY IDX_M_Company, SEQ, ProjectID, AccountType DESC, COA

	DROP TABLE #PL
	--DROP TABLE #PL_Previous
	--DROP TABLE #PL_Current

END


GO
