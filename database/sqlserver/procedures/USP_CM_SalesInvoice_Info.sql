-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 20 Oktober 2016
-- Description	: Info detail for Sales Invoice
-- Mod			: 2020-01-23 by Anton --> Adjust logic PKPFlag
-- =============================================

-- EXEC [USP_CM_SalesInvoice_Info] 1213
-- EXEC [USP_CM_SalesInvoice_Info] 20288

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	--RIH.*, 
			RIH.InvoiceDate,
			CONVERT(DATE,RIH.InvoiceDueDate) AS InvoiceDueDate,
			
			CASE WHEN InvoiceDate BETWEEN '2019-12-16' AND '2019-12-31'
				THEN RIH.ERPNo 
				ELSE RIH.InvoiceNo
			END InvoiceNo,
			--RIH.InvoiceNo,
			RIH.ReferenceNo,

			RIH.TaxInvoiceNo,
			RIH.ApprovedDate,
			RIH.IDX_M_SalesPerson,
			RIH.IDX_M_Currency,
			RIH.IDX_T_SalesInvoiceHeader,
			RIH.IDX_M_Partner,
			RIH.IDX_M_LocationInventory,
			RIH.IDX_M_DocumentType,
			RIH.IDX_ReferenceNo,
			RIH.InvoiceStatus,
			RIH.COAHeader,
			RIH.RecordStatus,
			RIH.IDX_M_Company,
			RIH.IDX_M_Branch,
			RIH.RemarkHeader,
			RIH.AuditNotes,
	
			MC.CompanyAlias, 'PT. ' + UPPER(MC.CompanyName) AS CompanyName, 
			MC.LegalAddress, 'Kel. ' + MC.Subdistrict + ', Kec. ' + MC.District + ', ' + MC.City + ' - ' + MC.Province + ' (' + MC.Zip + ')' AS LegalAddressDetail,
			MC.NPWP, MC.BankAccountNumber, MC.BankName, MB.BranchID, MB.BranchAlias, MB.BranchName, MC.Phone AS CompanyPhone,
			MBP.PartnerID, MBP.PartnerName AS PartnerName, PartnerDesc = (MBP.PartnerID + ' ' + MBP.PartnerName), MBP.TaxIdentityNumber, 		
			MU.Name AS UserName, RIH.UCreate AS CreateByID, RIH.DCreate AS CreateByDate, MU.Name AS CreateByName, 
			RIH.UModified AS ModifiedByID, RIH.DModified AS ModifiedByDate, MUM.Name AS ModifiedByName, 
			RIH.ApproveBy AS ApprovedByID, RIH.ApprovedDate AS ApprovedByDate, MUA.Name AS ApprovedByName, 
			RIH.VoidBy AS VoidByID, RIH.VoidDate AS VoidByDate, MUV.Name AS VoidByName, 
		
		
		
		LI.Alias AS LocationID, LI.LocationName AS LocationDesc,
		StatusDesc = CASE RIH.InvoiceStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Cancel' WHEN 'F' THEN 'Validate' WHEN 'V' THEN 'Void' END,
		COA.COADesc, COA.COAID,
		DPPAmount = (SELECT SUM(((RID.UntaxedAmount - RID.DiscountAmount) * RID.Quantity))
					FROM CM_T_SalesInvoiceDetail RID 
					WHERE RIH.IDX_T_SalesInvoiceHeader = RID.IDX_T_SalesInvoiceHeader),
		TaxAmount = ISNULL((SELECT SUM(Tax.TaxAmount * PID.Quantity)
					FROM CM_T_SalesInvoiceTax Tax 
					LEFT JOIN CM_T_SalesInvoiceDetail PID ON PID.IDX_T_SalesInvoiceDetail = Tax.IDX_T_SalesInvoiceDetail
					WHERE RIH.IDX_T_SalesInvoiceHeader = Tax.IDX_T_SalesInvoiceHeader),0),
		TotalAmount = (SELECT SUM(((RID.UntaxedAmount - RID.DiscountAmount) * RID.Quantity))
					FROM CM_T_SalesInvoiceDetail RID 
					WHERE RIH.IDX_T_SalesInvoiceHeader = RID.IDX_T_SalesInvoiceHeader) 
					+ 
					ISNULL((SELECT SUM(Tax.TaxAmount * PID.Quantity)
					FROM CM_T_SalesInvoiceTax Tax 
					LEFT JOIN CM_T_SalesInvoiceDetail PID ON PID.IDX_T_SalesInvoiceDetail = Tax.IDX_T_SalesInvoiceDetail
					WHERE RIH.IDX_T_SalesInvoiceHeader = Tax.IDX_T_SalesInvoiceHeader),0),
		PaymentAmount = (SELECT SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
						FROM CM_T_SalesInvoiceHeader SIH
						LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
						LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
						LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
						WHERE RA.AllocationStatus = 'A' AND SIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader
						GROUP BY SIH.IDX_T_SalesInvoiceHeader),
		COAHeaderDesc = COA.COAID + ' - ' + COA.COADesc, 
		X.PaymentStatus, X.PaymentCss, GPA.Street AS PartnerAddress, MSP.SalesPersonID, MSP.SalesPersonName, 
		--PKPFlag = CASE WHEN RTRIM(MBP.TaxIdentityNumber) <> '' THEN 'PKP' WHEN MBP.TaxIdentityNumber IS NULL THEN 'NON PKP' END 
		PKPFlag =	CASE WHEN RTRIM(MBP.TaxIdentityNumber) = '00.000.000.0-000.000' OR RTRIM(MBP.TaxIdentityNumber) IS NULL OR RTRIM(MBP.TaxIdentityNumber) = ''
						THEN 'NON PKP'
					ELSE 'PKP' END 
	FROM CM_T_SalesInvoiceHeader RIH
		LEFT JOIN GN_M_Company MC ON RIH.IDX_M_Company = MC.IDX_M_Company	
		LEFT JOIN GN_M_Branch MB ON MB.IDX_M_Branch = RIH.IDX_M_Branch	
		LEFT JOIN GN_M_Partner MBP ON RIH.IDX_M_Partner = MBP.IDX_M_Partner
		LEFT JOIN SM_M_User MU ON RIH.UCreate = MU.LoginID
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = RIH.UModified
		LEFT JOIN SM_M_User MUA ON MUA.LoginID = RIH.ApproveBy
		LEFT JOIN SM_M_User MUV ON MUV.LoginID = RIH.VoidBy
		LEFT JOIN IN_M_LocationInventory LI ON RIH.IDX_M_LocationInventory = LI.IDX_M_LocationInventory
		LEFT JOIN GL_M_COA COA ON RIH.COAHeader = COA.IDX_M_COA
		LEFT JOIN dbo.fn_GetSalesInvoicePayment(@IDX_T_SalesInvoiceHeader) X ON X.IDX_T_SalesInvoiceHeader = RIH.IDX_T_SalesInvoiceHeader 
		LEFT JOIN (SELECT * FROM GN_M_PartnerAddress WHERE IDX_M_AddressType = 1) GPA ON GPA.IDX_M_Partner = MBP.IDX_M_Partner 
		LEFT JOIN GN_M_SalesPerson MSP ON MSP.IDX_M_SalesPerson = RIH.IDX_M_SalesPerson
	WHERE RIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

END


