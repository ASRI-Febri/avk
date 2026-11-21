-- ====================================================================================================================================
-- Author			: Samuel Febrianto
-- Create date		: 6 Sep 2018
-- ====================================================================================================================================

/*
	IDX 115 --> 308.11.105 (RE - Prior Years) = Saldo Laba Tidak Dicadangkan
	IDX 117 --> 308.11.106 (Retained Earning-Current Y.T.D) = Saldo Laba Tahun Berjalan
*/

-- EXEC [dbo].[USP_GL_R_GeneralLedger] 1, 1, '2026-03-01', '2026-03-31','102'

CREATE PROCEDURE [dbo].[USP_GL_R_GeneralLedger]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE,
	@COA				VARCHAR(5000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @_EndDate_Balance		DATE

	SET @_EndDate_Balance = DATEADD(d,-1,@StartDate)

	-- ============================================================================================
    -- COA
	-- ============================================================================================
	CREATE TABLE #COA (IDX_M_COA BIGINT, COAID VARCHAR(50), COADesc VARCHAR(100))

	IF @COA = '0' OR @COA = ''
	BEGIN
		INSERT INTO #COA (IDX_M_COA, COAID, COADesc)
		SELECT IDX_M_COA, COAID, COADesc 
			FROM GL_M_COA WITH(NOLOCK)
		--WHERE COAFlag <> 'H'
	END
	ELSE
	BEGIN
		INSERT INTO #COA (IDX_M_COA, COAID, COADesc)
		EXEC ('SELECT IDX_M_COA, COAID, COADesc 
				FROM GL_M_COA 
			   WHERE IDX_M_COA in ('+ @COA +')')
			   --WHERE COAFlag <> ''H'' AND IDX_M_COA in ('+ @COA +')')
	END

	--INSERT INTO #COA (IDX_M_COA, COAID, COADesc)
	--EXEC ('SELECT IDX_M_COA, COAID, COADesc 
	--		FROM GL_M_COA 
	--		WHERE IDX_M_COA in ('+ @COA +')')

	-- ============================================================================================
    -- Ledger Detail
	-- ============================================================================================
	CREATE TABLE #Ledger (		
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_COA						BIGINT,	
		COA_Count						INT, -- 0 = Saldo Awal, 1 = Transaction 	
		---------------------------------------------------------------------
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(50),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(50),
		ProjectID						VARCHAR(50),
		ProjectDesc						VARCHAR(250),
		COA								VARCHAR(250),
		COADesc							VARCHAR(250),		
		---------------------------------------------------------------------
		PartnerName						VARCHAR(300),
		VoucherNo						VARCHAR(50),
		ReferenceNo						VARCHAR(50),
		NotaManual						VARCHAR(50),
		JournalDate						DATE,
		JournalDesc						VARCHAR(5000),
		---------------------------------------------------------------------
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2),		
		BBalanceAmount					DECIMAL(22,2),
		----------------------------------------------------------------------
		IDX_M_JournalType				SMALLINT, 
		URLTransaction					VARCHAR(500)
	)
	
	-- ===============================================
	-- Insert movement from journal detail
	-- ===============================================
	IF @IDX_M_Branch <> '0'
	BEGIN
		INSERT INTO #Ledger
		SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA, 1, GC.CompanyAlias, GC.CompanyName, MB.BranchID, MB.BranchName, 
			ISNULL(PJ.ProjectID,''), ISNULL(PJ.ProjectName,''), COA.COAID, COA.COADesc, UPPER(MP.PartnerName), JH.VoucherNo, 
			CASE WHEN JH.IDX_M_JournalType <> 5 THEN JH.ReferenceNo ELSE JH.VoucherNo + ' / ' + JH.ReferenceNo END, 
			'',
			JH.JournalDate, 
			CASE WHEN JH.VoucherNoManual IS NOT NULL THEN JD.RemarkDetail + ' - ' + JH.VoucherNoManual ELSE JD.RemarkDetail END AS RemarkDetail,  		
			JD.BDebetAmount, JD.BCreditAmount, 0, 
			JH.IDX_M_JournalType, 
			URLTransaction = CASE JH.IDX_M_JournalType 
				WHEN 5 THEN 'mc-sales-order/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- SALES INVOICE
				WHEN 2 THEN 'mc-purchase-order/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- PURCHASE INVOICE
				WHEN 3 THEN 'fm-financial-receive/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- FINANCIAL RECEIVE
				WHEN 4 THEN 'fm-financial-payment/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- FINANCIAL PAYMENT
				WHEN 1 THEN 'ac-journal/update/' + CONVERT(VARCHAR, JH.IDX_T_JournalHeader) -- JOURNAL MEMORIAL
				END
		FROM GL_T_JournalHeader JH WITH(NOLOCK)
		LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		INNER JOIN #COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
		--LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA
		LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON JH.IDX_M_Partner = MP.IDX_M_Partner
		LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = JH.IDX_M_Company
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON MB.IDX_M_Branch = JH.IDX_M_Branch
		LEFT JOIN GN_M_Project PJ WITH(NOLOCK) ON JD.IDX_M_Project = PJ.IDX_M_Project
		WHERE JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' AND JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch 
			AND CONVERT(DATE,JH.JournalDate) BETWEEN @StartDate AND @EndDate
			--AND JH.IDX_T_JournalHeader NOT IN (391,426,427,429,430,457)
	END
	ELSE
	BEGIN
		INSERT INTO #Ledger
		--SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA, 1, GC.Alias, GC.Name, MB.BranchID, MB.BranchName, 
		SELECT JH.IDX_M_Company, 0, JD.IDX_M_COA, 1, GC.CompanyAlias, GC.CompanyName, MB.BranchID, MB.BranchName, 
			ISNULL(PJ.ProjectID,''), ISNULL(PJ.ProjectName,''), COA.COAID, COA.COADesc, UPPER(MP.PartnerName), JH.VoucherNo, 
			CASE WHEN JH.IDX_M_JournalType <> 5 THEN JH.ReferenceNo ELSE JH.VoucherNo + ' / ' + JH.ReferenceNo END, 
			'',
			JH.JournalDate, 
			CASE WHEN JH.VoucherNoManual IS NOT NULL THEN JD.RemarkDetail + ' - ' + JH.VoucherNoManual ELSE JD.RemarkDetail END AS RemarkDetail,  		
			JD.BDebetAmount, JD.BCreditAmount, 0, 
			JH.IDX_M_JournalType, 
			URLTransaction = CASE JH.IDX_M_JournalType 
				WHEN 5 THEN 'mc-sales-order/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- SALES INVOICE
				WHEN 2 THEN 'mc-purchase-order/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- PURCHASE INVOICE
				WHEN 3 THEN 'fm-financial-receive/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- FINANCIAL RECEIVE
				WHEN 4 THEN 'fm-financial-payment/update/' + CONVERT(VARCHAR, JH.IDX_ReferenceNo) -- FINANCIAL PAYMENT
				WHEN 1 THEN 'ac-journal/update/' + CONVERT(VARCHAR, JH.IDX_T_JournalHeader) -- JOURNAL MEMORIAL
				END
		FROM GL_T_JournalHeader JH WITH(NOLOCK)
		LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		INNER JOIN #COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
		--LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA
		LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON JH.IDX_M_Partner = MP.IDX_M_Partner
		LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = JH.IDX_M_Company
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON MB.IDX_M_Branch = JH.IDX_M_Branch
		LEFT JOIN GN_M_Project PJ WITH(NOLOCK) ON JD.IDX_M_Project = PJ.IDX_M_Project
		WHERE JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' AND JH.IDX_M_Company = @IDX_M_Company
			AND CONVERT(DATE,JH.JournalDate) BETWEEN @StartDate AND @EndDate
			--AND JH.IDX_T_JournalHeader NOT IN (391,426,427,429,430,457)
	END

	-- ===============================================
	-- Insert Beginning Balance
	-- ===============================================
	INSERT INTO #Ledger (IDX_M_Company, IDX_M_Branch, IDX_M_COA, COA_Count, ProjectID, ProjectDesc, COA, COADesc, PartnerName, JournalDesc, BDebetAmount, BCreditAmount, BBalanceAmount)
	SELECT @IDX_M_Company, @IDX_M_Branch, IDX_M_COA, 0, '', '', COAID, COADesc, '', 'Saldo Awal ' + COAID + ' - ' + COADesc, 0, 0, 0  
	FROM #COA WITH(NOLOCK)

	/*
	IF @IDX_M_Branch <> '0'
	BEGIN
		UPDATE #Ledger SET BBalanceAmount = Temp.BBalance
		FROM (
			SELECT JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA, SUM(JD.BDebetAmount - JD.BCreditAmount) AS BBalance
			FROM GL_T_JournalHeader JH WITH(NOLOCK)
			LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN #COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 	
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = JH.IDX_M_Company
			LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON MB.IDX_M_Branch = JH.IDX_M_Branch
			WHERE JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' AND JH.IDX_M_Company = @IDX_M_Company AND JH.IDX_M_Branch = @IDX_M_Branch AND JH.IDX_T_JournalHeader NOT IN (391,426,427,429,430,457)
				AND CONVERT(DATE,JH.JournalDate) < @StartDate
			GROUP BY JH.IDX_M_Company, JH.IDX_M_Branch, JD.IDX_M_COA 
		) Temp
		INNER JOIN #Ledger WITH(NOLOCK) ON #Ledger.IDX_M_Company = Temp.IDX_M_Company AND #Ledger.IDX_M_Branch = Temp.IDX_M_Branch AND #Ledger.IDX_M_COA = Temp.IDX_M_COA
		WHERE #Ledger.COA_Count = 0 

		UPDATE #Ledger SET BBalanceAmount = BBalanceAmount + ISNULL(Temp.BBBalance,0)
		FROM (
			SELECT IDX_M_Company, IDX_M_Branch, IDX_M_COA, SUM(BBBalance) AS BBBalance
			FROM GL_T_AccountBalance WITH(NOLOCK)
			WHERE JournalPeriod = '202006'
			GROUP BY IDX_M_Company, IDX_M_Branch, IDX_M_COA
		) Temp
		INNER JOIN #Ledger WITH(NOLOCK) ON #Ledger.IDX_M_Company = Temp.IDX_M_Company AND #Ledger.IDX_M_Branch = Temp.IDX_M_Branch AND #Ledger.IDX_M_COA = Temp.IDX_M_COA
		WHERE #Ledger.COA_Count = 0 
	END
	ELSE
	BEGIN
		UPDATE #Ledger SET BBalanceAmount = Temp.BBalance
		FROM (
			SELECT JH.IDX_M_Company, JD.IDX_M_COA, SUM(JD.BDebetAmount - JD.BCreditAmount) AS BBalance
			FROM GL_T_JournalHeader JH WITH(NOLOCK)
			LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN #COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 	
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = JH.IDX_M_Company
			WHERE JH.RecordStatus = 'A' AND JH.PostingStatus = 'P' AND JH.IDX_M_Company = @IDX_M_Company AND CONVERT(DATE,JH.JournalDate) < @StartDate AND JH.IDX_T_JournalHeader NOT IN (391,426,427,429,430,457)
			GROUP BY JH.IDX_M_Company, JD.IDX_M_COA 
		) Temp
		INNER JOIN #Ledger WITH(NOLOCK) ON #Ledger.IDX_M_Company = Temp.IDX_M_Company AND #Ledger.IDX_M_COA = Temp.IDX_M_COA
		WHERE #Ledger.COA_Count = 0 

		UPDATE #Ledger SET BBalanceAmount = BBalanceAmount + ISNULL(Temp.BBBalance,0)
		FROM (
			SELECT IDX_M_Company, IDX_M_COA, SUM(BBBalance) AS BBBalance
			FROM GL_T_AccountBalance WITH(NOLOCK)
			WHERE JournalPeriod = '202006'
			GROUP BY IDX_M_Company, IDX_M_COA
		) Temp
		INNER JOIN #Ledger WITH(NOLOCK) ON #Ledger.IDX_M_Company = Temp.IDX_M_Company AND #Ledger.IDX_M_COA = Temp.IDX_M_COA
		WHERE #Ledger.COA_Count = 0 
	END
	*/

	DECLARE @StartPeriod VARCHAR(6) = left(CONVERT(VARCHAR,@StartDate,112),6)
	DECLARE @MonthPeriod VARCHAR(2) = RIGHT(@StartPeriod,2)
	DECLARE @BeforeStartPeriod VARCHAR(6) = left(CONVERT(VARCHAR,DATEADD(M,-1,@StartDate),112),6) 

	--UPDATE #Ledger SET 
	--	BBalanceAmount = ISNULL(BEndingBalance,0)
	--FROM #Ledger
	--	LEFT JOIN ( SELECT IDX_M_COA, IDX_M_Branch, SUM(BEndingBalance) AS BEndingBalance
	--				FROM GL_T_AccountBalance AB WITH(NOLOCK)
	--				WHERE AB.JournalPeriod = @BeforeStartPeriod
	--				GROUP BY IDX_M_COA, IDX_M_Branch
	--			  ) AB ON #Ledger.IDX_M_COA = AB.IDX_M_COA AND #Ledger.IDX_M_Branch = AB.IDX_M_Branch AND #Ledger.COA_Count = 0 

	-- =======================================================
	-- UPDATE SALDO AWAL
	-- =======================================================
	IF EXISTS (
		SELECT IDX_GL_T_AccountBalance, JournalPeriod 
		FROM GL_T_AccountBalance AB
		WHERE AB.IDX_M_Company = @IDX_M_Company AND AB.JournalPeriod = @BeforeStartPeriod
	)
	BEGIN

		-- UPDATE FROM TABLE ACCOUNT BALANCE
		UPDATE #Ledger SET 
			BBalanceAmount = ISNULL(BEndingBalance,0)
		FROM #Ledger
			LEFT JOIN
		(
			SELECT IDX_M_COA, SUM(BEndingBalance) AS BEndingBalance
			FROM GL_T_AccountBalance AB
			WHERE AB.IDX_M_Company = @IDX_M_Company AND AB.JournalPeriod = @BeforeStartPeriod 
			GROUP BY IDX_M_COA
		) AB ON #Ledger.IDX_M_COA = AB.IDX_M_COA

	END
	ELSE
	BEGIN

		-- UPDATE BEGINING BALANCE FROM JOURNAL TRANSACTION
		UPDATE #Ledger SET 
			BBalanceAmount = ISNULL(DebetAmount - CreditAmount,0)
		FROM #Ledger
			LEFT JOIN
		(
			SELECT JD.IDX_M_COA, SUM(JD.BDebetAmount) AS DebetAmount, SUM(JD.BCreditAmount) AS CreditAmount
			FROM GL_T_JournalHeader JH WITH(NOLOCK)
					LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
			WHERE	JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A' 
					AND CONVERT(DATE,JH.JournalDate) < @StartDate
					AND JH.IDX_M_Company = @IDX_M_Company
			GROUP BY JD.IDX_M_COA
		) Temp ON #Ledger.IDX_M_COA = Temp.IDX_M_COA

	END

	IF @MonthPeriod = '01'
	BEGIN
		--AMBIL SALDO LABA TAHUN BERJALAN TAMBAH KE LABA TIDAK DICADANGKAN, UPDATE BEGINNING BALANCE JADI 0 UTK COA LTB, INCOME, & EXPENSE
		DECLARE @LTB MONEY
		SELECT @LTB = BBalanceAmount FROM #Ledger WHERE IDX_M_COA = 117

		UPDATE #Ledger SET BBalanceAmount = BBalanceAmount + @LTB WHERE IDX_M_COA = 115

		UPDATE A SET A.BBalanceAmount = 0 
			FROM #Ledger A WITH(NOLOCK)
			INNER JOIN GL_M_COA B WITH(NOLOCK) ON A.IDX_M_COA = B.IDX_M_COA
			INNER JOIN GL_M_COAType C WITH(NOLOCK) ON B.IDX_M_COAType = C.IDX_M_COAType
		WHERE A.IDX_M_COA = 117 OR C.COATypeID IN ('IC','EX')
	END
		
	-- ===========================================================
	-- UPDATE NOTA MANUAL
	-- ===========================================================
	UPDATE #Ledger SET NotaManual = A.ReferenceNo
	FROM (
		SELECT IDX_T_SalesOrder, SONumber, ReferenceNo 
		FROM MC_T_SalesOrder
		WHERE RecordStatus = 'A' AND SOStatus = 'A'
	) A
	INNER JOIN #Ledger ON RTRIM(#Ledger.ReferenceNo) = RTRIM(A.SONumber)
	WHERE LEFT (#Ledger.ReferenceNo,3) = 'SMC'

	UPDATE #Ledger SET NotaManual = A.ReferenceNo
	FROM (
		SELECT IDX_T_PurchaseOrder, PONumber, ReferenceNo 
		FROM MC_T_PurchaseOrder
		WHERE RecordStatus = 'A' AND POStatus = 'A'
	) A
	INNER JOIN #Ledger ON RTRIM(#Ledger.ReferenceNo) = RTRIM(A.PONumber)
	WHERE LEFT (#Ledger.ReferenceNo,3) = 'PMC'
	-- ===========================================================

	-- ===========================================================
	-- UPDATE SALDO AWAL
	-- ===========================================================
	UPDATE #Ledger SET BBalanceAmount = BDebetAmount - BCreditAmount WHERE COA_Count = 1	

	-- ===========================================================
	-- UPDATE COMPANY, BRANCH
	-- ===========================================================

	UPDATE #Ledger SET CompanyID = '' WHERE CompanyID IS NULL
	UPDATE #Ledger SET CompanyDesc = '' WHERE CompanyDesc IS NULL
	UPDATE #Ledger SET BranchID = '' WHERE BranchID IS NULL
	UPDATE #Ledger SET BranchDesc = '' WHERE BranchDesc IS NULL

	UPDATE #Ledger SET VoucherNo = '' WHERE VoucherNo IS NULL
	UPDATE #Ledger SET ReferenceNo = '' WHERE ReferenceNo IS NULL
	UPDATE #Ledger SET JournalDate = '' WHERE JournalDate IS NULL

	SELECT L.* 
	FROM #Ledger L	WITH(NOLOCK)
	ORDER BY IDX_M_Company, IDX_M_Branch, COA, COA_Count, JournalDate, VoucherNo 

	DROP TABLE #COA
	DROP TABLE #Ledger

END


