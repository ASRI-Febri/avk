-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Financial Receive Detail
-- =============================================

-- EXEC USP_CM_FinancialReceiveDetail_Info 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceiveDetail_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialReceiveDetail		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT FPH.ReceiveID, FPH.ReceiveStatus, FPH.IDX_M_Partner, FPH.IDX_M_Branch, FPH.ReceiveDate, 
		FPD.*, 
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE FPH.ReceiveStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END,
		COA.COAID, COA.COADesc, COA.IDX_M_COA, CONCAT(RTRIM(LTRIM(COAID)), ' - ', RTRIM(LTRIM(COADesc))) AS COADesc1, 
		PIH.InvoiceNo, PIH.InvoiceDate, PIH.InvoiceDueDate, PID.TotalInvoice, FP.ReceiveAmount AS PaidAmount,
		ReconcileAmount = ISNULL(Recon.ReconcileAmount,0)
	FROM CM_T_FinancialReceiveDetail FPD	
		LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPD.IDX_T_FinancialReceiveHeader = FPH.IDX_T_FinancialReceiveHeader	
		LEFT JOIN GN_M_DocumentType MDT ON FPD.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = FPD.COADetail
		LEFT JOIN CM_T_PurchaseInvoiceHeader PIH ON PIH.IDX_T_PurchaseInvoiceHeader = FPD.IDX_DocumentNo 
		LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * UnitPrice) AS TotalInvoice 
					FROM CM_T_PurchaseInvoiceDetail PID
					GROUP BY IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
		LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceNo, ISNULL(FPD.ReceiveAmount,0) AS ReceiveAmount
					FROM CM_T_PurchaseInvoiceHeader PIH
					LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
					LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader) FP 
						ON FP.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
		LEFT JOIN (	SELECT IDX_T_FinancialReceiveDetail, SUM(AllocationAmount) AS ReconcileAmount
					FROM CM_T_ReceiveAllocation
					GROUP BY IDX_T_FinancialReceiveDetail) Recon ON Recon.IDX_T_FinancialReceiveDetail = FPD.IDX_T_FinancialReceiveDetail					
	WHERE FPD.IDX_T_FinancialReceiveDetail = @IDX_T_FinancialReceiveDetail
	ORDER BY FPD.IDX_T_FinancialReceiveDetail DESC

END



