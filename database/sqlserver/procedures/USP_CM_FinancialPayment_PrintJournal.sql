-- =========================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 21 Mar 2019
-- Description	: List of journal from financial payment voucher
-- Mod			: 2020-04-20 by Anton --> Added validation PostingStatus = 'P' (case LEFT JOIN logic with NULL result when user using rollback function)
--				  2024-01-18 by Anton --> Added Project/LocationID infomation
--				  2024-03-06 by Anton --> Adjust print out voucher (journal accrue allocation invoice)
-- =========================================================================================================================================================

-- EXEC USP_CM_FinancialPayment_PrintJournal 587 

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_PrintJournal]
	@IDX_T_FinancialPaymentHeader		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #Journal (	
		SeqNo							INT,
		JournalType						VARCHAR(20),
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_Project					BIGINT,
		DocumentNo						VARCHAR(20), -- Invoice No or Payment ID
		IDX_M_COA						BIGINT,			
		---------------------------------------------------------------------
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(50),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(50),
		ProjectID						VARCHAR(100),
		ProjectDesc						VARCHAR(100),
		COAID							VARCHAR(250),
		COADesc							VARCHAR(250),		
		---------------------------------------------------------------------
		VoucherNo						VARCHAR(50),
		JournalDate						DATE,
		JournalDesc						VARCHAR(5000),
		---------------------------------------------------------------------
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2)	
	)

	-- ======================================================================
	-- INSERT PURCHASE INVOICE JOURNAL
	-- IDX JOURNAL TYPE = 2
	-- ======================================================================
	--INSERT INTO #Journal
	--SELECT 1, 'PurchaseInvoice', FPH.IDX_M_Company, FPH.IDX_M_Branch, PA.DocumentNo, JR.IDX_M_COA, 
	--	'','','','',
	--	JR.COAID, JR.COADesc, JR.VoucherNo, JR.JournalDate, JR.RemarkDetail, 
	--	JR.BDebetAmount, JR.BCreditAmount
	--FROM CM_T_PaymentAllocation PA WITH(NOLOCK)
	--LEFT JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
	--LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	--LEFT JOIN (
	--	SELECT JH.VoucherNo, JH.JournalDate, JH.ReferenceNo, JH.RemarkHeader, JD.IDX_M_COA, COA.COAID, COA.COADesc, JD.RemarkDetail, 
	--		JD.BDebetAmount, JD.BCreditAmount 
	--	FROM GL_T_JournalHeader JH WITH(NOLOCK)
	--	LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
	--	LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
	--	WHERE JH.IDX_M_JournalType = 2 AND PostingStatus = 'P'
	--) JR ON RTRIM(JR.ReferenceNo) = RTRIM(PA.DocumentNo)
	--WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
	--ORDER BY JR.VoucherNo

	--SELECT 1, 'PurchaseInvoice', FPH.IDX_M_Company, FPH.IDX_M_Branch, FPD.IDX_M_Project, PA.DocumentNo, JR.IDX_M_COA, 
	--	MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, MP.ProjectID, MP.ProjectName,
	--	JR.COAID, JR.COADesc, JR.VoucherNo, JR.JournalDate, JR.RemarkDetail, 
	--	JR.BDebetAmount, JR.BCreditAmount
	--FROM CM_T_PaymentAllocation PA WITH(NOLOCK)
	--LEFT JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
	--LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	--LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON FPD.IDX_M_Project = MP.IDX_M_Project
	--LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPH.IDX_M_Branch = MB.IDX_M_Branch
	--LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
	--LEFT JOIN (
	--	SELECT JH.VoucherNo, JH.JournalDate, JH.ReferenceNo, JH.RemarkHeader, JD.IDX_M_COA, COA.COAID, COA.COADesc, JD.RemarkDetail, 
	--		JD.BDebetAmount, JD.BCreditAmount 
	--	FROM GL_T_JournalHeader JH WITH(NOLOCK)
	--	LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
	--	LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
	--	WHERE JH.IDX_M_JournalType = 2 AND PostingStatus = 'P'
	--) JR ON RTRIM(JR.ReferenceNo) = RTRIM(PA.DocumentNo)
	--WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
	--ORDER BY JR.VoucherNo

	SELECT DISTINCT(C.DocumentNo) AS DocumentNo INTO #Tampung
	FROM CM_T_FinancialPaymentHeader A WITH(NOLOCK)
		INNER JOIN CM_T_FinancialPaymentDetail B WITH(NOLOCK) ON A.IDX_T_FinancialPaymentHeader = B.IDX_T_FinancialPaymentHeader
		INNER JOIN CM_T_PaymentAllocation C WITH(NOLOCK) ON B.IDX_T_FinancialPaymentDetail = C.IDX_T_FinancialPaymentDetail
	WHERE A.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

	INSERT INTO #Journal
		SELECT 
				1, 'PurchaseInvoice', ISNULL(MP.IDX_M_Company,0) AS IDX_M_Company, ISNULL(MP.IDX_M_Branch,0) AS IDX_M_Branch, B.IDX_M_Project, A.ReferenceNo, B.IDX_M_COA, 
				ISNULL(MC.CompanyID,'') AS CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, ISNULL(MP.ProjectID,'') AS ProjectID, ISNULL(MP.ProjectName,'') AS ProjectName,
				COA.COAID, COA.COADesc, A.VoucherNo, A.JournalDate, B.RemarkDetail, 
				B.BDebetAmount, B.BCreditAmount
		FROM GL_T_JournalHeader A WITH(NOLOCK)
			INNER JOIN GL_T_JournalDetail B WITH(NOLOCK) ON A.IDX_T_JournalHeader = B.IDX_T_JournalHeader
			INNER JOIN GL_M_COA COA WITH(NOLOCK) ON B.IDX_M_COA = COA.IDX_M_COA 
			LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON B.IDX_M_Project = MP.IDX_M_Project
			LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON A.IDX_M_Branch = MB.IDX_M_Branch
			LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON A.IDX_M_Company = MC.IDX_M_Company
		WHERE A.PostingStatus = 'P' AND A.ReferenceNo IN (SELECT DocumentNo FROM #Tampung )

	DROP TABLE #Tampung

	-- ======================================================================
	-- INSERT PAYMENT JOURNAL
	-- IDX JOURNAL TYPE = 7
	-- ======================================================================
	INSERT INTO #Journal
	SELECT 2, 'PaymentVoucher', FPH.IDX_M_Company, FPH.IDX_M_Branch, FPD.IDX_M_Project, FPH.PaymentID, FPD.COADetail, 
		MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, MP.ProjectID, MP.ProjectName,
		COA.COAID, COA.COADesc, '',FPH.PaymentDate, FPD.RemarkDetail, 
		CASE WHEN FPD.PaymentAmount < 0 
			THEN 0
			ELSE FPD.PaymentAmount
		END AS PaymentAmount,
		CASE WHEN FPD.PaymentAmount < 0 
			THEN (FPD.PaymentAmount * -1)
			ELSE 0
		END AS PaymentAmount 
	FROM CM_T_FinancialPaymentDetail FPD WITH(NOLOCK)
		LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
		LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON FPD.IDX_M_Project = MP.IDX_M_Project
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPD.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = FPD.COADetail 
	WHERE FPD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

	INSERT INTO #Journal
	SELECT 2, 'PaymentVoucher', FPH.IDX_M_Company, FPH.IDX_M_Branch, 0, FPH.PaymentID, MFA.IDX_M_COA, 
		MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, '', '',
		COA.COAID, COA.COADesc, '',FPH.PaymentDate, FPH.RemarkHeader, 0, FPH.PaymentAmount
	FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPH.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN CM_M_FinancialAccount MFA WITH(NOLOCK) ON MFA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = MFA.IDX_M_COA  
	WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

	-- ====================================================================== 
	-- OUTPUT
	-- ======================================================================
	SELECT * FROM #Journal 
	DROP TABLE #Journal

END
