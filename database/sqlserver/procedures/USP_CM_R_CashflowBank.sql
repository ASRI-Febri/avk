-- =============================================
-- Author		: Anton
-- Create date	: 2020-04-16
-- Description	: Report Mutasi Bank Harian
-- EXEC [dbo].[USP_CM_R_CashflowBank] 1, 1, '2020-01-01'
-- EXEC [dbo].[USP_CM_R_CashflowBank] 1, 0, '2020-01-01'
-- EXEC [dbo].[USP_CM_R_CashflowBank] 1, 0,	'2019-11-30'
-- =============================================

CREATE PROCEDURE [dbo].[USP_CM_R_CashflowBank]
	@IDX_M_Company		BIGINT,
	@IDX_M_Branch		BIGINT,
	@Tanggal			DATETIME
AS
BEGIN


	SET NOCOUNT ON;

	DECLARE @Sdate DATETIME			= @Tanggal
	DECLARE @Edate DATETIME			= DATEADD(s,-1,DATEADD(d,1,@Sdate))
	DECLARE @Edateadd DATETIME		= DATEADD(DAY,1,@Sdate)
	DECLARE @Periode VARCHAR(6)		= LEFT(CONVERT(VARCHAR,@Sdate,112),6)
	DECLARE @BPeriode VARCHAR(6)	= LEFT(CONVERT(VARCHAR,DATEADD(m,-1,@Sdate),112),6)
	DECLARE @SmsDate DATETIME		= CONVERT(DATETIME,@Periode+'01')
	DECLARE @BsDate DATETIME		= DATEADD(s,-1,@Sdate)
	DECLARE @LSPeriode VARCHAR(6)	= (SELECT MAX(JournalPeriod) FROM GL_T_AccountBalance WITH(NOLOCK))

	-- Logic dynamic Account Balance Move --
	IF @Periode > @LSPeriode
	BEGIN
		SET @BPeriode = @LSPeriode
		SET @SmsDate = DATEADD(s,-1,DATEADD(m,1,Convert(DATETIME,@LSPeriode+'01')))
	END

	----------------------------------------

	--------------------------------- 1. Buat Temporary Table -------------------------------------------
	DECLARE @TempFA TABLE(IDX_M_COA BIGINT, COADescription VARCHAR(500), Bank VARCHAR(100), AccountDescription VARCHAR(100), IDX_M_FinancialAccount BIGINT, IDX_M_Branch BIGINT)
	DECLARE @TempMovCOA TABLE (IDX_M_Branch BIGINT, IDX_M_COA BIGINT, BDebetAmount DECIMAL(18,2), BCreditAmount DECIMAL(18,2))
	DECLARE @TempBBCOA TABLE (IDX_M_Branch BIGINT, IDX_M_COA BIGINT, BDebetAmount DECIMAL(18,2), BCreditAmount DECIMAL(18,2))
	DECLARE @TempGiro TABLE (IDX_M_Organization BIGINT, IDX_M_FInancialAccount BIGINT, IDX_M_COA BIGINT, GiroAmount DECIMAL(18,2))
	DECLARE @TempFP TABLE (IDX_M_Organization BIGINT, IDX_M_FInancialAccount BIGINT, IDX_M_COA BIGINT, FPAmount DECIMAL(18,2))
	DECLARE @TempOB TABLE (IDX_M_Organization BIGINT, IDX_M_FInancialAccount BIGINT, IDX_M_COA BIGINT, OBAmount DECIMAL(18,2))

	--------------------------------- 2. Cari varian FA dan COA nya -------------------------------------------
	INSERT INTO @TempFA (IDX_M_COA, COADescription, Bank, AccountDescription, IDX_M_FinancialAccount, IDX_M_Branch)
		SELECT FA.IDX_M_COA AS IDX_M_COA, GL_M_COA.COADesc, FA.AccountName, FA.FinancialAccountDesc, FA.IDX_M_FinancialAccount, FA.IDX_M_Branch
		FROM CM_M_FinancialAccount FA WITH(NOLOCK)
			LEFT JOIN GL_M_COA WITH(NOLOCK) on GL_M_COA.IDX_M_COA = FA.IDX_M_COA 
		WHERE FA.IDX_M_Company = @IDX_M_Company

	--------------------------------- 3. Hitung Movement -------------------------------------------
	INSERT INTO @TempMovCOA (IDX_M_Branch, IDX_M_COA, BDebetAmount, BCreditAmount)
		SELECT JH.IDX_M_Branch, JD.IDX_M_COA, SUM(BDebetAmount) AS BDebetAmount, SUM(BCreditAmount) AS BCreditAmount
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN @TempFA TFA ON JD.IDX_M_COA = TFA.IDX_M_COA AND JH.IDX_M_Branch = TFA.IDX_M_Branch
		WHERE	JD.RecordStatus = 'A' and JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' 
				AND JH.IDX_M_Company = @IDX_M_Company 
				AND JH.PostingDate BETWEEN @Sdate AND @Edate AND TFA.IDX_M_COA IS NOT NULL
		GROUP BY JH.IDX_M_Branch, JD.IDX_M_COA

	--------------------------------- 4. Hitung BB -------------------------------------------
	INSERT INTO @TempBBCOA (IDX_M_Branch, IDX_M_COA, BDebetAmount, BCreditAmount)
		SELECT JH.IDX_M_Branch, JD.IDX_M_COA , SUM(BDebetAmount) AS BDebetAmount, SUM(BCreditAmount) AS BCreditAmount
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN @TempFA TFA ON JD.IDX_M_COA = TFA.IDX_M_COA AND JH.IDX_M_Branch = TFA.IDX_M_Branch
		WHERE	JD.RecordStatus = 'A' AND JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' 
				AND JH.IDX_M_Company = @IDX_M_Company 
				AND JH.PostingDate BETWEEN @SmsDate AND @BsDate AND TFA.IDX_M_COA IS NOT NULL
		GROUP BY JH.IDX_M_Branch, JD.IDX_M_COA

	--------------------------------- 5. Outstanding Giro -------------------------------------------
	INSERT INTO @TempGiro (IDX_M_Organization, IDX_M_FInancialAccount, IDX_M_COA, GiroAmount)
		SELECT PDCD.IDX_M_Company AS IDX_M_Organization, PDCD.IDX_M_FinancialAccount, TFA.IDX_M_COA, SUM(PDCD.PaymentAmount) AS GiroAmount
		FROM CM_T_FinancialPaymentHeader PDCD WITH(NOLOCK)
			LEFT JOIN CM_T_FinancialPaymentDetail PDCH WITH(NOLOCK) ON PDCH.IDX_T_FinancialPaymentHeader = PDCD.IDX_T_FinancialPaymentHeader
			INNER JOIN @TempFA TFA ON TFA.IDX_M_FinancialAccount = PDCD.IDX_M_FinancialAccount
		WHERE	PDCD.RecordStatus = 'A' AND PDCH.RecordStatus = 'A' AND PDCD.IDX_M_PaymentType IN (5,6)
				AND CONVERT(DATE,PDCD.DCreate) <= @Edate AND (PDCD.VoidDate IS NULL OR CONVERT(DATE,PDCD.VoidDate) > @Edate)
				AND (ISNULL(PDCD.PaymentStatus,'D') = 'D' OR CONVERT(DATE,ISNULL(PDCD.ValidationDate,@Edateadd)) > @Edate)
		GROUP BY PDCD.IDX_M_FinancialAccount, TFA.IDX_M_COA, PDCD.IDX_M_Company

	--------------------------------- 5.B Outstanding OverBook (Pindah Buku) -----------------------
	--INSERT INTO @TempOB (IDX_M_Organization, IDX_M_FInancialAccount, IDX_M_COA, OBAmount)
	--SELECT FRH.IDX_M_GroupsCompany, FRH.IDX_M_FinancialAccount, FRH.IDX_M_COAHeader, SUM(FRD.PaymentAmount) AS Amount
	--FROM T_FinancialReceiveDetail FRD
	--INNER JOIN T_FinancialReceiveHeader FRH ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialTransactionHeader AND IDX_M_GroupsCompany = @IDX_M_Company AND IDX_M_JournalType = 19 AND JournalStatus = 'D' --AND ApprovalStatus = 'F'
	--WHERE FRD.RecordStatus = 'A' AND FRH.RecordStatus = 'A'
	--		AND FRH.JournalStatus = 'D'
	--GROUP BY FRH.IDX_M_GroupsCompany, FRH.IDX_M_FinancialAccount, FRH.IDX_M_COAHeader

		--------------------------------- 5.C Outstanding FP Type TRANS -------------------------------------------
	INSERT INTO @TempFP (IDX_M_Organization, IDX_M_FInancialAccount, IDX_M_COA, FPAmount)
		SELECT FPH.IDX_M_Company AS IDX_M_Organization, FPH.IDX_M_FinancialAccount, TFA.IDX_M_COA, SUM(FPD.PaymentAmount) AS GiroAmount
		FROM CM_T_FinancialPaymentDetail FPD WITH(NOLOCK)
			LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) on FPD.IDX_T_FinancialPaymentHeader = FPH.IDX_T_FinancialPaymentHeader
			INNER JOIN @TempFA TFA ON TFA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		WHERE FPH.IDX_M_PaymentType IN (1,2,3,4) and FPD.RecordStatus = 'A' AND FPH.RecordStatus = 'A'
			AND CONVERT(DATE,FPH.PaymentDate) <= @Edate AND (FPH.VoidDate IS NULL OR FPH.VoidDate = '1900-01-01 00:00:00.000' OR CONVERT(DATE,FPH.VoidDate) > @Edate)
			AND (ISNULL(FPH.PaymentStatus,'D') <> 'F' OR CONVERT(DATE,ISNULL(FPH.ValidationDate,@Edateadd)) > @Edate)
		GROUP BY FPH.IDX_M_FinancialAccount, TFA.IDX_M_COA, FPH.IDX_M_Company

	--------------------------------- 6. Final------------------------------------------------------
	select TFA.Bank,
			TFA.AccountDescription, 
			ISNULL(AB.BEndingBalance,0) + ISNULL(BBCOA.BDebetAmount,0) - ISNULL(BBCOA.BCreditAmount,0) AS BBAmount, 
			ISNULL(MovCOA.BDebetAmount,0) AS BDebetAmount, 
			ISNULL(MovCOA.BCreditAmount,0) AS BCreditAmount, 
			ISNULL(AB.BEndingBalance,0) + ISNULL(BBCOA.BDebetAmount,0) - ISNULL(BBCOA.BCreditAmount,0) + ISNULL(MovCOA.BDebetAmount,0) - ISNULL(MovCOA.BCreditAmount,0) AS EBAmount,
			ISNULL(TG.GiroAmount,0) AS OutstandingPDC,
			ISNULL(FP.FPAmount,0) AS OutstandingFP,
			--isnull(OB.OBAmount, 0) AS OutstandingIn,
			isnull(AB.BEndingBalance,0) + isnull(BBCOA.BDebetAmount,0) - ISNULL(BBCOA.BCreditAmount,0) + ISNULL(MovCOA.BDebetAmount,0) - ISNULL(MovCOA.BCreditAmount,0) - ISNULL(TG.GiroAmount,0) - ISNULL(FP.FPAmount,0) AS SaldoAktual
	FROM @TempFA TFA
		LEFT JOIN @TempBBCOA BBCOA ON TFA.IDX_M_COA = BBCOA.IDX_M_COA and TFA.IDX_M_Branch = BBCOA.IDX_M_Branch
		LEFT JOIN @TempMovCOA MovCOA ON TFA.IDX_M_COA = MovCOA.IDX_M_COA and TFA.IDX_M_Branch = MovCOA.IDX_M_Branch
		LEFT JOIN GL_T_AccountBalance AB WITH(NOLOCK) ON TFA.IDX_M_COA = AB.IDX_M_COA and AB.JournalPeriod = @BPeriode and AB.IDX_M_Company = @IDX_M_Company and AB.IDX_M_Branch = TFA.IDX_M_Branch
		LEFT JOIN @TempGiro TG ON TFA.IDX_M_COA = TG.IDX_M_COA
		LEFT JOIN @TempFP FP ON TFA.IDX_M_COA = FP.IDX_M_COA
	--left join @TempOB OB on TFA.IDX_M_COA = OB.IDX_M_COA

	
END
