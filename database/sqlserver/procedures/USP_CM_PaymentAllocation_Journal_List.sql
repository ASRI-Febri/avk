-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Financial Payment ALlocation
-- =============================================

-- EXEC [USP_CM_PaymentAllocation_Journal_List] 5

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialPaymentHeader	BIGINT
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
		INNER JOIN (
			SELECT FRH.IDX_T_FinancialPaymentHeader, RA.AllocationID 
			FROM CM_T_FinancialPaymentHeader FRH 
			LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentHeader = FRH.IDX_T_FinancialPaymentHeader
			LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_T_FinancialPaymentDetail = FRD.IDX_T_FinancialPaymentDetail
			WHERE FRH.IDX_T_FinancialPaymentHeader  = @IDX_T_FinancialPaymentHeader 
		) FRH ON RTRIM(FRH.AllocationID) = RTRIM(JH.ReferenceNo)
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE JH.IDX_M_JournalType = 9 AND FRH.IDX_T_FinancialPaymentHeader  = @IDX_T_FinancialPaymentHeader 
	ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail

END



