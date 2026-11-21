-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Payment Allocation
-- =============================================

-- EXEC USP_CM_PaymentAllocation_List 45

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialPaymentHeader		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		RA.IDX_T_PaymentAllocation, RA.IDX_DocumentNo, RA.DocumentNo, RA.AllocationDate, RA.AllocationAmount, RA.AllocationStatus, RA.RemarkAllocation, 
		GMP.PartnerID, GMP.PartnerName, 
		FRH.IDX_T_FinancialPaymentHeader, FRH.PaymentID, FRH.PaymentDate, FRH.PaymentStatus, 
		FRD.IDX_T_FinancialPaymentDetail, FRD.COADetail, FRD.PaymentAmount, FRD.RemarkDetail, 
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE RA.AllocationStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COAD.COAID AS COA1, COAD.COADesc AS COADesc11, COAD.COADesc2 AS COADesc12, 
		COAA.COAID AS COA2, COAA.COADesc AS COADesc21, COAA.COADesc2 AS COADesc22, 
		URLDocument = CASE RA.IDX_M_DocumentType WHEN 1 THEN 'fm-sales-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo)
			WHEN 2 THEN 'fm-purchase-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo)
			ELSE 'fm-purchase-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo) END		
	FROM CM_T_PaymentAllocation RA  
		LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
		LEFT JOIN CM_T_FinancialPaymentHeader FRH ON FRD.IDX_T_FinancialPaymentHeader = FRH.IDX_T_FinancialPaymentHeader	
		LEFT JOIN GN_M_DocumentType MDT ON RA.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COAD ON FRD.COADetail = COAD.IDX_M_COA
		LEFT JOIN GL_M_COA COAA ON RA.COAAllocation = COAA.IDX_M_COA
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = RA.IDX_M_Partner 
	WHERE FRD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader 
	ORDER BY FRD.IDX_T_FinancialPaymentDetail, RA.IDX_T_PaymentAllocation DESC

END


