-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Receiving Item Header by ID
-- =============================================

-- EXEC [USP_CM_PurchaseInvoice_Info] 3

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT RIH.*, MC.CompanyAlias, MC.CompanyName AS CompanyName, MB.BranchID, MB.BranchAlias, MB.BranchName, 
		MBP.PartnerID, MBP.PartnerName AS PartnerName, PartnerDesc = (MBP.PartnerID + ' - ' + MBP.PartnerName),
		MU.Name AS UserName, RIH.UCreate AS CreateByID, RIH.DCreate AS CreateByDate, MU.Name AS CreateByName, 
		RIH.UModified AS ModifiedByID, RIH.DModified AS ModifiedByDate, MUM.Name AS ModifiedByName, 
		RIH.ApproveBy AS ApprovedByID, RIH.ApprovedDate AS ApprovedByDate, MUA.Name AS ApprovedByName, 
		LI.Alias AS LocationID, LI.LocationName AS LocationDesc,
		StatusDesc = CASE RIH.InvoiceStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' WHEN 'V' THEN 'Validate' END,
		COA.COADesc, COA.COAID, COAHeaderDesc = COA.COAID + ' - '  + COA.COADesc, 
		DPPAmount = (SELECT SUM(((RID.UntaxedAmount - RID.DiscountAmount) * RID.Quantity))
					FROM CM_T_PurchaseInvoiceDetail RID 
					WHERE RIH.IDX_T_PurchaseInvoiceHeader = RID.IDX_T_PurchaseInvoiceHeader),
		TaxAmount = ISNULL((SELECT SUM(Tax.TaxAmount * PID.Quantity)
					FROM CM_T_PurchaseInvoiceTax Tax 
					LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PID.IDX_T_PurchaseInvoiceDetail = Tax.IDX_T_PurchaseInvoiceDetail
					WHERE RIH.IDX_T_PurchaseInvoiceHeader = Tax.IDX_T_PurchaseInvoiceHeader),0),
		TotalAmount = (SELECT SUM(((RID.UntaxedAmount - RID.DiscountAmount) * RID.Quantity))
					FROM CM_T_PurchaseInvoiceDetail RID 
					WHERE RIH.IDX_T_PurchaseInvoiceHeader = RID.IDX_T_PurchaseInvoiceHeader) 
					+ 
					ISNULL((SELECT SUM(Tax.TaxAmount * PID.Quantity)
					FROM CM_T_PurchaseInvoiceTax Tax 
					LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PID.IDX_T_PurchaseInvoiceDetail = Tax.IDX_T_PurchaseInvoiceDetail
					WHERE RIH.IDX_T_PurchaseInvoiceHeader = Tax.IDX_T_PurchaseInvoiceHeader),0),
		--PaymentAmount = (SELECT ISNULL(SUM(FPD.PaymentAmount),0)
		--			FROM CM_T_FinancialPaymentDetail FPD
		--			WHERE FPD.IDX_M_DocumentType = 2 AND FPD.IDX_DocumentNo = RIH.IDX_T_PurchaseInvoiceHeader)
		PaymentAmount = ISNULL((SELECT SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
						FROM CM_T_PurchaseInvoiceHeader SIH
						LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_PurchaseInvoiceHeader
						LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
						LEFT JOIN CM_T_FinancialPaymentHeader FRH ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
						WHERE RA.AllocationStatus = 'A' AND SIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
						GROUP BY SIH.IDX_T_PurchaseInvoiceHeader),0), 
		X.PaymentStatus, X.PaymentCss
	FROM CM_T_PurchaseInvoiceHeader RIH
		LEFT JOIN GN_M_Company MC ON RIH.IDX_M_Company = MC.IDX_M_Company	
		LEFT JOIN GN_M_Branch MB ON MB.IDX_M_Branch = RIH.IDX_M_Branch		
		LEFT JOIN GN_M_Partner MBP ON RIH.IDX_M_Partner = MBP.IDX_M_Partner
		
		LEFT JOIN IN_M_LocationInventory LI ON RIH.IDX_M_LocationInventory = LI.IDX_M_LocationInventory
		LEFT JOIN GL_M_COA COA ON RIH.COAHeader = COA.IDX_M_COA
		LEFT JOIN dbo.fn_GetPurchaseInvoicePayment(@IDX_T_PurchaseInvoiceHeader) X ON X.IDX_T_PurchaseInvoiceHeader = RIH.IDX_T_PurchaseInvoiceHeader 
		LEFT JOIN SM_M_User MU ON MU.LoginID = RIH.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = RIH.UModified
		LEFT JOIN SM_M_User MUA ON MUA.LoginID = RIH.ApproveBy
		LEFT JOIN SM_M_User MUV ON MUV.LoginID = RIH.VoidBy
	WHERE RIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

END


