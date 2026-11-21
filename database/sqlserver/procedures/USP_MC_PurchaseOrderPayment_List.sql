
CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrderPayment_List]
	@IDX_T_PurchaseOrder			BIGINT = 0
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FPH.IDX_T_FinancialPaymentHeader, FPH.PaymentID, FPH.PaymentDate, 
		FPH.IDX_M_DocumentType AS DTypeHeader, FPH.PaymentStatus, FPH.RemarkHeader,
		FPD.IDX_T_FinancialPaymentDetail, FPD.IDX_M_DocumentType AS DTypeDetail, 
		FPD.IDX_DocumentNo, FPD.DocumentNo, FPD.PaymentAmount, FPD.RemarkDetail, 
		MH.PONumber, 
		FA.FinancialAccountID, FA.FinancialAccountDesc,
		StatusDesc = CASE RTRIM(ISNULL(FPH.PaymentStatus,''))
			WHEN 'D' THEN 'Draft'
			WHEN 'A' THEN 'Approved'
			WHEN 'V' THEN 'Void'
			WHEN 'C' THEN 'Void'
			WHEN '' THEN 'Unknown'
			ELSE 'Unknown (' + RTRIM(FPH.PaymentStatus) + ')' END
	FROM CM_T_FinancialPaymentHeader FPH
	LEFT JOIN CM_T_FinancialPaymentDetail FPD 
		ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	LEFT JOIN MC_T_PurchaseOrder MH ON 
		--MH.IDX_M_DocumentType = FPD.IDX_M_DocumentType
		MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
		AND MH.PONumber = FPD.DocumentNo
		AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
	LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
	WHERE FPH.RecordStatus = 'A' AND FPD.RecordStatus = 'A' AND FPH.PaymentStatus <> 'V'
		AND FPD.IDX_DocumentNo = @IDX_T_PurchaseOrder

END
