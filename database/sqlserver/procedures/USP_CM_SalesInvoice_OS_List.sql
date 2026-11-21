-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 3 Juli 2018
-- Description:	List outstanding Sales invoice by partner
-- =============================================

-- EXEC [USP_CM_SalesInvoice_OS_List] 2

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_OS_List]
	@IDX_M_Partner	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIH.IDX_T_SalesInvoiceHeader, PIH.IDX_M_DocumentType, MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		PIH.InvoiceNo, PIH.InvoiceDate, PIH.InvoiceDueDate, PID.TotalInvoice, FP.ReceiveAmount, OSAmount = PID.TotalInvoice - FP.ReceiveAmount 
	FROM CM_T_SalesInvoiceHeader PIH
	LEFT JOIN GN_M_DocumentType MDT ON MDT.IDX_M_DocumentType = PIH.IDX_M_DocumentType
	LEFT JOIN (	SELECT PID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount)) AS TotalInvoice 
				FROM CM_T_SalesInvoiceDetail PID
				GROUP BY IDX_T_SalesInvoiceHeader) PID ON PID.IDX_T_SalesInvoiceHeader = PIH.IDX_T_SalesInvoiceHeader 
	LEFT JOIN (	SELECT PIH.IDX_T_SalesInvoiceHeader, PIH.InvoiceNo, ISNULL(FPD.ReceiveAmount,0) AS ReceiveAmount
				FROM CM_T_SalesInvoiceHeader PIH
				LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND FPD.IDX_DocumentNo = PIH.IDX_T_SalesInvoiceHeader
				LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader) FP 
					ON FP.IDX_T_SalesInvoiceHeader = PIH.IDX_T_SalesInvoiceHeader
	WHERE PIH.InvoiceStatus = 'A' AND PIH.IDX_M_Partner = @IDX_M_Partner AND (PID.TotalInvoice - FP.ReceiveAmount) > 0
END



