-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Receive Allocation
-- =============================================

-- EXEC USP_CM_ReceiveAllocation_List 32
-- EXEC USP_CM_ReceiveAllocation_List 2

CREATE PROCEDURE [dbo].[USP_CM_ReceiveAllocation_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialReceiveHeader		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		RA.IDX_T_ReceiveAllocation, RA.IDX_DocumentNo, RA.DocumentNo, RA.AllocationDate, RA.AllocationAmount, RA.AllocationStatus, RA.RemarkAllocation, 
		GMP.PartnerID, GMP.PartnerName AS PartnerName, 
		FRH.IDX_T_FinancialReceiveHeader, FRH.ReceiveID, FRH.ReceiveDate, FRH.ReceiveStatus, 
		FRD.IDX_T_FinancialReceiveDetail, FRD.COADetail, FRD.ReceiveAmount, FRD.RemarkDetail, 
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE RA.AllocationStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COAD.COAID AS COA1, COAD.COADesc AS COADesc11, COAD.COADesc2 AS COADesc12, 
		COAA.COAID AS COA2, COAA.COADesc AS COADesc21, COAA.COADesc2 AS COADesc22, 
		URLDocument = CASE RA.IDX_M_DocumentType WHEN 1 THEN 'fm-sales-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo)
			WHEN 2 THEN 'fm-purchase-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo)
			ELSE 'fm-sales-invoice/update/' + CONVERT(VARCHAR, RA.IDX_DocumentNo) END		
	FROM CM_T_ReceiveAllocation RA  
		LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
		LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader	
		LEFT JOIN GN_M_DocumentType MDT ON RA.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COAD ON FRD.COADetail = COAD.IDX_M_COA
		LEFT JOIN GL_M_COA COAA ON RA.COAAllocation = COAA.IDX_M_COA
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = RA.IDX_M_Partner 
	WHERE FRD.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader 
	ORDER BY FRD.IDX_T_FinancialReceiveDetail, RA.IDX_T_ReceiveAllocation DESC

END



