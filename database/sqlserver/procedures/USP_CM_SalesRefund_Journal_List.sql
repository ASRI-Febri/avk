
-- EXEC [USP_CM_SalesRefund_Journal_List] 1

CREATE PROCEDURE [dbo].[USP_CM_SalesRefund_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesRefundHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		INNER JOIN CM_T_SalesRefundHeader PRH ON JH.ReferenceNo = PRH.RefundNo		
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE PRH.IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND JH.PostingStatus = 'P'
	--ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail
	UNION
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 				
		INNER JOIN CM_T_FinancialPaymentHeader FPH ON JH.ReferenceNo = FPH.PaymentID
		LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentHeader = FPH.IDX_T_FinancialPaymentHeader
		INNER JOIN CM_T_SalesRefundHeader PRH ON PRH.IDX_M_DocumentType = FPD.IDX_M_DocumentType AND PRH.IDX_T_SalesRefundHeader = FPD.IDX_DocumentNo
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE PRH.IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND JH.PostingStatus = 'P'
END




