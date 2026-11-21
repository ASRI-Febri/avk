-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Purchase Invoice
-- =============================================

-- EXEC [dbo].[USP_CM_PurchaseInvoice_Payment_List] 1

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_Payment_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT JH.*, JD.*,
	--	MJT.JournalTypeID, MJT.JournalTypeDesc,
	--	COA.COAID, COA.COADesc, COA.IDX_GL_M_COA  
	--FROM GL_T_JournalHeader JH
	--	LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_GL_T_JournalHeader = JD.IDX_GL_T_JournalHeader 
	--	LEFT JOIN CM_T_PurchaseInvoiceH RIH ON JH.IDX_ReferenceNo = RIH.IDX_CM_T_PurchaseInvoiceH		
	--	LEFT JOIN GL_M_COA COA ON JD.IDX_GL_M_COA = COA.IDX_GL_M_COA
	--	LEFT JOIN GL_M_JournalType MJT ON JH.IDX_GL_M_JournalType = MJT.IDX_GL_M_JournalType
	--WHERE JH.IDX_ReferenceNo = @IDX_CM_T_PurchaseInvoiceH 
	--ORDER BY JD.IDX_GL_T_JournalDetail

	SELECT FPH.IDX_T_FinancialPaymentHeader, FPH.PaymentID, FPH.PaymentDate, FPH.IDX_M_DocumentType DTypeHeader, FPH.PaymentStatus, FPH.RemarkHeader,
		FPD.IDX_T_FinancialPaymentDetail, PA.IDX_M_DocumentType AS DTypeDetail, PA.IDX_DocumentNo, PA.DocumentNo, PA.AllocationAmount AS PaymentAmount, FPD.RemarkDetail, 
		StatusDesc = CASE FPH.PaymentStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' WHEN 'F' THEN 'Validate' END, IDX_M_PaymentType, IDX_M_FinancialAccount
	FROM CM_T_PurchaseInvoiceHeader PIH
	INNER JOIN CM_T_PaymentAllocation PA ON PA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND PA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
	INNER JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
	INNER JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	WHERE PA.IDX_DocumentNo = @IDX_T_PurchaseInvoiceHeader
	
	

END




