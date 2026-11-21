-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Financial Receive
-- =============================================

-- EXEC [USP_CM_FinancialReceive_Journal_List] 37

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialReceiveHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
    -- Insert statements for procedure here
	--SELECT * FROM (
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc 
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		INNER JOIN CM_T_FinancialReceiveHeader FRH ON JH.ReferenceNo = FRH.ReceiveID AND FRH.IDX_T_FinancialReceiveHeader = JH.IDX_ReferenceNo
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE FRH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader 
	--UNION
	--SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
	--	JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
	--	JD.RemarkDetail,
	--	MJT.JournalTypeID, MJT.JournalTypeDesc,
	--	COA.COAID, COA.COADesc  
	--FROM GL_T_JournalHeader JH
	--	LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
	--	INNER JOIN (
	--		SELECT FRH.IDX_T_FinancialReceiveHeader, RA.AllocationID 
	--		FROM CM_T_FinancialReceiveHeader FRH 
	--		LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader
	--		LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
	--		WHERE FRH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader 
	--	) FRH ON RTRIM(FRH.AllocationID) = RTRIM(JH.ReferenceNo)
	--	LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
	--	LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	--WHERE JH.IDX_M_JournalType = 8 AND FRH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader 	
	--) Temp 
	ORDER BY IDX_T_JournalHeader, IDX_T_JournalDetail
	*/

	IF (SELECT ReceiveStatus FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader) = 'A'
	BEGIN
		SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
			JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
			JD.RemarkDetail,
			MJT.JournalTypeID, MJT.JournalTypeDesc,
			COA.COAID, COA.COADesc, COA.IDX_M_COA  
		FROM GL_T_JournalHeader JH WITH(NOLOCK)
			INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader AND JH.PostingStatus = 'P'
			INNER JOIN CM_T_FinancialReceiveHeader FPH WITH(NOLOCK) ON JH.ReferenceNo = FPH.ReceiveID AND FPH.IDX_T_FinancialReceiveHeader = JH.IDX_ReferenceNo 
			LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
			LEFT JOIN GL_M_JournalType MJT WITH(NOLOCK) ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
		WHERE FPH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader
		ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail
	END
	ELSE
	BEGIN
		CREATE TABLE #DraftJournal
		(
			IDX_T_JournalHeader BIGINT,
			VoucherNo			VARCHAR(50),
			JournalDate			DATETIME,
			IDX_T_JournalDetail BIGINT,
			IDX_M_COA			BIGINT,
			BDebetAmount		MONEY,
			BCreditAmount		MONEY,
			RemarkDetail		VARCHAR(1000),
			JournalTypeID		VARCHAR(5),
			JournalTypeDesc		VARCHAR(100),
			COAID				VARCHAR(30),
			COADesc				VARCHAR(250),
			IDX_M_COA2			BIGINT
		)
				
		INSERT INTO #DraftJournal
		SELECT	FPH.IDX_T_FinancialReceiveHeader, FPH.ReceiveID, FPH.ReceiveDate, FPD.IDX_T_FinancialReceiveDetail, FPD.COADetail,
				CASE WHEN FPD.ReceiveAmount > 0 THEN FPD.ReceiveAmount ELSE 0 END AS BCreditAmount,
				CASE WHEN FPD.ReceiveAmount > 0 THEN 0 ELSE ABS(FPD.ReceiveAmount) END AS BDebetAmount,
				FPD.RemarkDetail, 'FR', 'Draft Financial Receive Journal', COA.COAID, COA.COADesc, COA.IDX_M_COA
		FROM CM_T_FinancialReceiveHeader FPH WITH(NOLOCK) 
			INNER JOIN CM_T_FinancialReceiveDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
			INNER JOIN GL_M_COA COA WITH(NOLOCK) ON FPD.COADetail = COA.IDX_M_COA
		WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

		INSERT INTO #DraftJournal
		SELECT	FPH.IDX_T_FinancialReceiveHeader, FPH.ReceiveID, FPH.ReceiveDate, FPH.IDX_T_FinancialReceiveHeader, FPH.COAHeader,
				CASE WHEN FPH.ReceiveAmount > 0 THEN 0 ELSE FPH.ReceiveAmount END AS BCreditAmount,
				CASE WHEN FPH.ReceiveAmount > 0 THEN FPH.ReceiveAmount ELSE 0 END AS BDebetAmount,
				FPH.RemarkHeader, 'FR', 'Draft Financial Receive Journal', COA.COAID, COA.COADesc, COA.IDX_M_COA
		FROM CM_T_FinancialReceiveHeader FPH WITH(NOLOCK) 
			INNER JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
			INNER JOIN GL_M_COA COA WITH(NOLOCK) ON FA.IDX_M_COA = COA.IDX_M_COA
		WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

		SELECT * FROM #DraftJournal WITH(NOLOCK) ORDER BY IDX_T_JournalHeader, BDebetAmount DESC, BCreditAmount

		DROP TABLE #DraftJournal
	END

END


