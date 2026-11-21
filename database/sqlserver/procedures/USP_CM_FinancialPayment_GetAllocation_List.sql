-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 07 Jun 2024
-- Description:	Get allocation list for financial payment
-- =============================================

-- USP_CM_FinancialPayment_GetAllocation_List 1, 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_GetAllocation_List]
	@IDX_M_Branch			INT,
	@IDX_M_Partner			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT a.IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo, a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) 
            + ' - Amount: ' + CONVERT(varchar,SUM(DPP.DPP+TAX.TAX)) AS DocumentNo2
    FROM CM_T_PurchaseInvoiceHeader a WITH(NOLOCK)
        LEFT JOIN
        (
            SELECT IDX_T_PurchaseInvoiceHeader, IDX_T_PurchaseInvoiceDetail, Quantity * (UntaxedAmount - ISNULL(DiscountAmount,0)) AS DPP 
            FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
        ) DPP ON a.IDX_T_PurchaseInvoiceHeader = DPP.IDX_T_PurchaseInvoiceHeader
        LEFT JOIN
        (
            SELECT a.IDX_T_PurchaseInvoiceDetail, a.Quantity * SUM(ISNULL(b.TaxAmount,0)) AS TAX
            FROM CM_T_PurchaseInvoiceDetail a WITH(NOLOCK)
                LEFT JOIN CM_T_PurchaseInvoiceTax b WITH(NOLOCK) ON a.IDX_T_PurchaseInvoiceDetail = b.IDX_T_PurchaseInvoiceDetail
            GROUP BY a.IDX_T_PurchaseInvoiceDetail, a.Quantity
        ) TAX ON DPP.IDX_T_PurchaseInvoiceDetail = TAX.IDX_T_PurchaseInvoiceDetail
        LEFT JOIN
		(
			SELECT a.IDX_T_FinancialPaymentHeader, ISNULL(b.IDX_DocumentNo,0) AS IDX_DocumentNo, SUM(ISNULL(b.PaymentAmount,0)) AS PaymentAmount
			FROM CM_T_FinancialPaymentHeader a WITH(NOLOCK)
                LEFT JOIN CM_T_FinancialPaymentDetail b WITH(NOLOCK) ON a.IDX_T_FinancialPaymentHeader = b.IDX_T_FinancialPaymentHeader
			WHERE a.PaymentStatus <> 'V'
			GROUP BY a.IDX_T_FinancialPaymentHeader, b.IDX_DocumentNo
		) PAYMENT ON a.IDX_T_PurchaseInvoiceHeader = PAYMENT.IDX_DocumentNo
        WHERE a.InvoiceStatus IN ('A','F') AND IDX_M_Partner = @IDX_M_Partner AND a.IDX_M_Branch = @IDX_M_Branch
    GROUP BY a.IDX_T_PurchaseInvoiceHeader, a.InvoiceNo, a.InvoiceDate, PAYMENT.PaymentAmount
    HAVING SUM(DPP.DPP+TAX.TAX)-ISNULL(PAYMENT.PaymentAmount,0) > 1

END
