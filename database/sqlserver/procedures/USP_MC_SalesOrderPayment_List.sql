
CREATE PROCEDURE [dbo].[USP_MC_SalesOrderPayment_List]
	@IDX_T_SalesOrder			BIGINT = 0
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FPH.IDX_T_FinancialReceiveHeader, FPH.ReceiveID, FPH.ReceiveDate, 
		FPH.IDX_M_DocumentType AS DTypeHeader, FPH.ReceiveStatus, FPH.RemarkHeader,
		FPD.IDX_T_FinancialReceiveDetail, FPD.IDX_M_DocumentType AS DTypeDetail, 
		FPD.IDX_DocumentNo, FPD.DocumentNo, FPD.ReceiveAmount, FPD.RemarkDetail, 
		MH.SONumber, 
		FA.FinancialAccountID, FA.FinancialAccountDesc,
		StatusDesc = CASE RTRIM(ISNULL(FPH.ReceiveStatus,''))
			WHEN 'D' THEN 'Draft'
			WHEN 'A' THEN 'Approved'
			WHEN 'V' THEN 'Void'
			WHEN 'C' THEN 'Void'
			WHEN '' THEN 'Unknown'
			ELSE 'Unknown (' + RTRIM(FPH.ReceiveStatus) + ')' END
	FROM CM_T_FinancialReceiveDetail FPD 
	INNER JOIN CM_T_FinancialReceiveHeader FPH
		ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	INNER JOIN MC_T_SalesOrder MH 
		ON --MH.IDX_M_DocumentType = FPD.IDX_M_DocumentType 
		MH.SONumber = FPD.DocumentNo
		AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
		AND MH.IDX_T_SalesOrder = @IDX_T_SalesOrder
	INNER JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
	WHERE FPD.IDX_DocumentNo = @IDX_T_SalesOrder

END
