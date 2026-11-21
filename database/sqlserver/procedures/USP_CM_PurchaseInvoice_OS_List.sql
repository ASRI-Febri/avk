-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 3 Juli 2018
-- Description:	List outstanding purchase invoice by partner
-- =============================================

-- EXEC [USP_CM_PurchaseInvoice_OS_List] 1

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_OS_List]
	@IDX_M_Partner	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.IDX_M_DocumentType, MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		PIH.InvoiceNo, PIH.InvoiceDate, PIH.InvoiceDueDate, PID.TotalInvoice, ISNULL(FP.PaymentAmount,0) AS PaymentAmount, 
		OSAmount = ISNULL(PID.TotalInvoice,0) - ISNULL(FP.PaymentAmount,0), PIH.RemarkHeader 
	FROM CM_T_PurchaseInvoiceHeader PIH
	LEFT JOIN GN_M_DocumentType MDT ON MDT.IDX_M_DocumentType = PIH.IDX_M_DocumentType
	LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount)) AS TotalInvoice 
				FROM CM_T_PurchaseInvoiceDetail PID
				GROUP BY IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
	LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount
				FROM CM_T_PurchaseInvoiceHeader PIH
				LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
				LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
				LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
				WHERE RA.AllocationStatus = 'A' 
				GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FP 
					ON FP.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
	WHERE PIH.InvoiceStatus = 'A' AND PIH.IDX_M_Partner = @IDX_M_Partner AND (PID.TotalInvoice - ISNULL(FP.PaymentAmount,0)) > 0
END



