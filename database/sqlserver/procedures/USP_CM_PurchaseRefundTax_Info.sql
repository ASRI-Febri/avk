-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Info Purchase Refund Tax
-- =============================================

-- EXEC [USP_CM_PurchaseRefundTax_Info] 10

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefundTax_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseRefundTax	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_PurchaseRefundTax, PIT.IDX_T_PurchaseRefundHeader, PIT.IDX_T_PurchaseRefundDetail,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.RecordStatus, 
		COA.COAID, COA.COADesc, COA.IDX_M_COA, RID.Quantity,
		RIH.InvoiceNo  
	FROM CM_T_PurchaseRefundTax PIT
		LEFT JOIN CM_T_PurchaseRefundDetail RID ON PIT.IDX_T_PurchaseRefundDetail = RID.IDX_T_PurchaseRefundDetail
		LEFT JOIN CM_T_PurchaseRefundHeader RIH ON RID.IDX_T_PurchaseRefundHeader = RIH.IDX_T_PurchaseRefundHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_PurchaseRefundTax = @IDX_T_PurchaseRefundTax 
	ORDER BY RID.IDX_T_PurchaseRefundDetail

END




