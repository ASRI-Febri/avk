-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Financial Payment Detail by ID
-- =============================================

--EXEC USP_CM_FinancialPaymentDetail_List 7

CREATE PROCEDURE [dbo].[USP_CM_FinancialPaymentDetail_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialPaymentHeader		BIGINT = 0		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT FPH.*, FPD.*, MPR.ProjectID, MPR.ProjectName,
		MDT.DocumentTypeID, MDT.DocumentTypeCategory, MDT.DocumentTypeDesc,
		StatusDesc = CASE FPH.PaymentStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COA.COAID, COA.COADesc, COA.COADesc2,
		ReconcileAmount = ISNULL(Recon.ReconcileAmount,0) 		
	FROM CM_T_FinancialPaymentDetail FPD WITH(NOLOCK)	
		LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentHeader = FPH.IDX_T_FinancialPaymentHeader	
		LEFT JOIN GN_M_Project MPR WITH(NOLOCK) ON FPD.IDX_M_Project = MPR.IDX_M_Project
		LEFT JOIN GN_M_DocumentType MDT WITH(NOLOCK) ON FPD.IDX_M_DocumentType = MDT.IDX_M_DocumentType	
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON FPD.COADetail = COA.IDX_M_COA
		LEFT JOIN (	SELECT IDX_T_FinancialPaymentDetail, SUM(AllocationAmount) AS ReconcileAmount
					FROM CM_T_PaymentAllocation WITH(NOLOCK)
					GROUP BY IDX_T_FinancialPaymentDetail) Recon ON Recon.IDX_T_FinancialPaymentDetail = FPD.IDX_T_FinancialPaymentDetail
	WHERE FPD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader 
	ORDER BY FPD.IDX_T_FinancialPaymentDetail DESC

END


