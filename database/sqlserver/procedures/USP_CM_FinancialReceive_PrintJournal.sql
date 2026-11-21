-- ==============================================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 21 Mar 2019
-- Description	: List of journal from financial Receive voucher
-- Mod Desc		: 2020-06-04 by Anton --> adjustment issue journal SI list not appeared
--									  --> Added validation PostingStatus = 'P' (case LEFT JOIN logic with NULL result when user using rollback function)
--				  2020-07-24 by Anton --> Added logic when ReceiveAmount < 0 Then Amount journal to BDebetAmount, else BCreditAmount on step SELECT 2
--				  2024-01-12 by Anton --> Added Project/LocationID infomation
-- ==============================================================================================================================================================================

-- EXEC USP_CM_FinancialReceive_PrintJournal 43 
-- EXEC USP_CM_FinancialReceive_PrintJournal 16

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_PrintJournal]
	@IDX_T_FinancialReceiveHeader		BIGINT
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
		DocumentNo						VARCHAR(20), -- Invoice No or Receive ID
		IDX_M_COA						BIGINT,			
		---------------------------------------------------------------------
		CompanyID						VARCHAR(100),
		CompanyDesc						VARCHAR(100),
		BranchID						VARCHAR(100),
		BranchDesc						VARCHAR(100),
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
	-- INSERT SALES INVOICE JOURNAL
	-- IDX JOURNAL TYPE = 1
	-- ======================================================================
	INSERT INTO #Journal
	--SELECT 1, 'SalesInvoice', FPH.IDX_M_Company, FPH.IDX_M_Branch, FPD.IDX_M_Project, PA.DocumentNo, JR.IDX_M_COA, 
	--	MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, MP.ProjectID, MP.ProjectName,
	--	JR.COAID, JR.COADesc, JR.VoucherNo, JR.JournalDate, JR.RemarkDetail, 
	--	JR.BDebetAmount, JR.BCreditAmount
	--FROM CM_T_ReceiveAllocation PA
	--LEFT JOIN CM_T_FinancialReceiveDetail FPD WITH(NOLOCK) ON FPD.IDX_T_FinancialReceiveDetail = PA.IDX_T_FinancialReceiveDetail
	--LEFT JOIN CM_T_FinancialReceiveHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	--LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON FPD.IDX_M_Project = MP.IDX_M_Project
	--LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPD.IDX_M_Branch = MB.IDX_M_Branch
	--LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
	--LEFT JOIN (
	--	SELECT JH.VoucherNo, JH.JournalDate, JH.ReferenceNo, JH.RemarkHeader, JD.IDX_M_COA, COA.COAID, COA.COADesc, JD.RemarkDetail, 
	--		JD.BDebetAmount, JD.BCreditAmount 
	--	FROM GL_T_JournalHeader JH WITH(NOLOCK)
	--	LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
	--	LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
	--	WHERE JH.IDX_M_JournalType = 1 AND PostingStatus = 'P'
	--) JR ON RTRIM(JR.ReferenceNo) = RTRIM(PA.DocumentNo)
	--WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
	--ORDER BY JR.VoucherNo

	SELECT 1, 'SalesInvoice', FRH.IDX_M_Company, FRH.IDX_M_Branch, FRD.IDX_M_Project, PA.DocumentNo, JR.IDX_M_COA, 
		MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, MP.ProjectID, MP.ProjectName,
		JR.COAID, JR.COADesc, JR.VoucherNo, JR.JournalDate, JR.RemarkDetail, 
		JR.BDebetAmount, JR.BCreditAmount
	FROM CM_T_ReceiveAllocation PA
	LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON PA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
	LEFT JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader
	LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON FRD.IDX_M_Project = MP.IDX_M_Project
	LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FRH.IDX_M_Branch = MB.IDX_M_Branch
	LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
	LEFT JOIN (
		SELECT JH.VoucherNo, JH.JournalDate, JH.ReferenceNo, JH.RemarkHeader, JD.IDX_M_COA, COA.COAID, COA.COADesc, JD.RemarkDetail, 
			JD.BDebetAmount, JD.BCreditAmount 
		FROM GL_T_JournalHeader JH WITH(NOLOCK)
		LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA 
		WHERE JH.IDX_M_JournalType = 1 AND PostingStatus = 'P'
	) JR ON RTRIM(JR.ReferenceNo) = RTRIM(PA.DocumentNo)
	WHERE FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
	ORDER BY JR.VoucherNo

	-- ======================================================================
	-- INSERT RECEIVE JOURNAL
	-- IDX JOURNAL TYPE = 7
	-- ======================================================================	
	INSERT INTO #Journal
	SELECT 1, 'ReceiveVoucher', FPH.IDX_M_Company, FPH.IDX_M_Branch, 0, FPH.ReceiveID, MFA.IDX_M_COA, 
		MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, '', '',
		COA.COAID, COA.COADesc, '',FPH.ReceiveDate, FPH.RemarkHeader, FPH.ReceiveAmount, 0
	FROM CM_T_FinancialReceiveHeader FPH WITH(NOLOCK)
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPH.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN CM_M_FinancialAccount MFA WITH(NOLOCK) ON MFA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = MFA.IDX_M_COA  
	WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

	INSERT INTO #Journal
	SELECT 2, 'ReceiveVoucher', FPH.IDX_M_Company, FPH.IDX_M_Branch, FPD.IDX_M_Project, FPH.ReceiveID, FPD.COADetail, 
		MC.CompanyID, MC.CompanyName, MB.BranchID, MB.BranchName, MP.ProjectID, MP.ProjectName,
		COA.COAID, COA.COADesc, '',FPH.ReceiveDate, FPD.RemarkDetail,
		CASE WHEN FPD.ReceiveAmount >= 0 THEN 0 ELSE ABS(FPD.ReceiveAmount) END AS BDebetAmount, 
		CASE WHEN FPD.ReceiveAmount >= 0 THEN FPD.ReceiveAmount ELSE 0 END AS BCreditAmount
	FROM CM_T_FinancialReceiveDetail FPD WITH(NOLOCK)
		LEFT JOIN CM_T_FinancialReceiveHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
		LEFT JOIN GN_M_Project MP WITH(NOLOCK) ON FPD.IDX_M_Project = MP.IDX_M_Project
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPD.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MB.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = FPD.COADetail 
	WHERE FPD.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

	-- ====================================================================== 
	-- OUTPUT
	-- ======================================================================
	SELECT * FROM #Journal WITH(NOLOCK)

END
