-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Financial Payment
-- =============================================

-- EXEC [USP_CM_FinancialPayment_Journal_List] 104
-- EXEC [USP_CM_FinancialPayment_Journal_List] 98

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialPaymentHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF (SELECT PaymentStatus FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader) in ('F','V')
	BEGIN
		SELECT JH.IDX_T_JournalHeader, JH.ReferenceNo + '/' + JH.VoucherNo AS VoucherNo, CONVERT(DATE,JH.JournalDate) AS JournalDate,
			JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
			JD.RemarkDetail,
			MJT.JournalTypeID, MJT.JournalTypeDesc,
			COA.COAID, COA.COADesc, COA.IDX_M_COA  
		FROM GL_T_JournalHeader JH
			INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader AND JH.PostingStatus = 'P'
			INNER JOIN CM_T_FinancialPaymentHeader FPH ON JH.ReferenceNo = FPH.PaymentID AND FPH.IDX_T_FinancialPaymentHeader = JH.IDX_ReferenceNo 
			LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
			LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
		WHERE FPH.IDX_T_FinancialPaymentHeader  = @IDX_T_FinancialPaymentHeader 
		ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail
	END
	ELSE
	BEGIN
		CREATE TABLE #DraftJournal
		(
			IDX_T_JournalHeader BIGINT,
			VoucherNo			VARCHAR(50),
			JournalDate			DATE,
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

		DECLARE @_TotalPayment		DECIMAL(22,2)

		SELECT @_TotalPayment = SUM(PaymentAmount) 
		FROM CM_T_FinancialPaymentDetail
		WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

		INSERT INTO #DraftJournal
		SELECT	FPH.IDX_T_FinancialPaymentHeader, FPH.PaymentID, CONVERT(DATE,FPH.PaymentDate), FPH.IDX_T_FinancialPaymentHeader, FPH.COAHeader,
				--CASE WHEN FPH.PaymentAmount > 0 THEN 0 ELSE FPH.PaymentAmount END AS BDebetAmount,
				--CASE WHEN FPH.PaymentAmount > 0 THEN FPH.PaymentAmount ELSE 0 END AS BCreditAmount,
				0 AS BDebetAmount, 
				@_TotalPayment AS BCreditAmount, 
				FPH.RemarkHeader, 'FP', 'Draft Financial Payment Journal', COA.COAID, COA.COADesc, COA.IDX_M_COA
		FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) 
			INNER JOIN GL_M_COA COA WITH(NOLOCK) ON FPH.COAHeader = COA.IDX_M_COA
		WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

		-- ===================================================================
		-- UNTUK FINANCIAL PAYMENT > 0 JOURNAL DEBET
		-- UNTUK FINANCIAL PAYMENT < 0 JOURNAL CREDIT
		-- ===================================================================
		INSERT INTO #DraftJournal
		SELECT	FPH.IDX_T_FinancialPaymentHeader, FPH.PaymentID, CONVERT(DATE,FPH.PaymentDate), FPD.IDX_T_FinancialPaymentDetail, FPD.COADetail,
				CASE WHEN FPD.PaymentAmount > 0 THEN FPD.PaymentAmount ELSE 0 END AS BDebetAmount,
				CASE WHEN FPD.PaymentAmount < 0 THEN ABS(FPD.PaymentAmount) END AS BCreditAmount,
				FPD.RemarkDetail, 'FP', 'Draft Financial Payment Journal', COA.COAID, COA.COADesc, COA.IDX_M_COA
		FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) 
			INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
			INNER JOIN GL_M_COA COA WITH(NOLOCK) ON FPD.COADetail = COA.IDX_M_COA
		WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

		
		


		SELECT * FROM #DraftJournal WITH(NOLOCK) ORDER BY IDX_T_JournalHeader, BDebetAmount DESC, BCreditAmount

		DROP TABLE #DraftJournal
	END

END




