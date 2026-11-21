-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Sales Invoice
-- =============================================

-- EXEC [dbo].[USP_CM_SalesInvoice_Payment_List] 118

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Payment_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT JH.*, JD.*,
	--	MJT.JournalTypeID, MJT.JournalTypeDesc,
	--	COA.COAID, COA.COADesc, COA.IDX_GL_M_COA  
	--FROM GL_T_JournalHeader JH
	--	LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_GL_T_JournalHeader = JD.IDX_GL_T_JournalHeader 
	--	LEFT JOIN CM_T_SalesInvoiceH RIH ON JH.IDX_ReferenceNo = RIH.IDX_CM_T_SalesInvoiceH		
	--	LEFT JOIN GL_M_COA COA ON JD.IDX_GL_M_COA = COA.IDX_GL_M_COA
	--	LEFT JOIN GL_M_JournalType MJT ON JH.IDX_GL_M_JournalType = MJT.IDX_GL_M_JournalType
	--WHERE JH.IDX_ReferenceNo = @IDX_CM_T_SalesInvoiceH 
	--ORDER BY JD.IDX_GL_T_JournalDetail

	SELECT SIH.IDX_T_SalesInvoiceHeader, ISNULL(RA.AllocationAmount,0) AS ReceiveAmount, 
		FRH.IDX_T_FinancialReceiveHeader, FRH.ReceiveID, FRH.ReceiveDate, FRH.IDX_M_DocumentType DTypeHeader, FRH.ReceiveStatus, FRH.RemarkHeader,
		FRD.IDX_T_FinancialReceiveDetail, RA.IDX_M_DocumentType AS DTypeDetail, RA.IDX_DocumentNo, RA.DocumentNo, FRD.RemarkDetail, AllocationStatus, 
		StatusDesc = CASE RA.AllocationStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, IDX_M_PaymentType, IDX_M_FinancialAccount
	FROM CM_T_SalesInvoiceHeader SIH
	LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
	LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
	LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
	WHERE RA.IDX_DocumentNo = @IDX_T_SalesInvoiceHeader
	

	--SELECT FPH.IDX_T_FinancialReceiveHeader, FPH.ReceiveID, FPH.ReceiveDate, FPH.IDX_M_DocumentType DTypeHeader, FPH.ReceiveStatus, FPH.RemarkHeader,
	--	FPD.IDX_T_FinancialReceiveDetail, FPD.IDX_M_DocumentType AS DTypeDetail, FPD.IDX_DocumentNo, FPD.DocumentNo, FPD.ReceiveAmount, FPD.RemarkDetail, 
	--	StatusDesc = CASE FPH.ReceiveStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END
	--FROM CM_T_FinancialReceiveHeader FPH
	--	LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	--	INNER JOIN CM_T_SalesInvoiceHeader PIH ON PIH.IDX_T_SalesInvoiceHeader = FPD.IDX_DocumentNo
	--WHERE FPD.IDX_DocumentNo = @IDX_T_SalesInvoiceHeader

END




