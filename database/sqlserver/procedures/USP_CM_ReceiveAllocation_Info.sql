-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Financial Receive Detail
-- =============================================

-- EXEC USP_CM_ReceiveAllocation_Info 1

CREATE PROCEDURE [dbo].[USP_CM_ReceiveAllocation_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_ReceiveAllocation		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		RA.IDX_T_ReceiveAllocation, RA.AllocationID, RA.IDX_M_DocumentType, RA.IDX_DocumentNo, RA.DocumentNo, RA.AllocationDate, 
		RA.AllocationAmount, RA.AllocationStatus, RA.IDX_M_Partner, RA.COAAllocation, RA.RemarkAllocation, RA.RecordStatus, 
		GMP.PartnerID, GMP.PartnerName AS PartnerDesc, 
		FRH.IDX_T_FinancialReceiveHeader, FRH.ReceiveID, FRH.ReceiveDate, FRH.ReceiveStatus, 
		FRD.IDX_T_FinancialReceiveDetail, FRD.COADetail, FRD.ReceiveAmount, 
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE RA.AllocationStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COAD.COAID AS COA1, COAD.COADesc AS COADesc11, COAD.COADesc2 AS COADesc12, 
		COAA.COAID AS COA2, COAA.COADesc AS COADesc21, COAA.COADesc2 AS COADesc22,
		CONCAT(COAD.COAID, ' - ', COAD.COADesc) AS COADesc1
	FROM CM_T_ReceiveAllocation RA  
		LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
		LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader	
		LEFT JOIN GN_M_DocumentType MDT ON RA.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COAD ON FRD.COADetail = COAD.IDX_M_COA
		LEFT JOIN GL_M_COA COAA ON RA.COAAllocation = COAA.IDX_M_COA
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = RA.IDX_M_Partner 
	WHERE RA.IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation	

END



