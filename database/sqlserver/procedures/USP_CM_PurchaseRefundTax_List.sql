-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Purchase Refund Tax
-- =============================================

--EXEC [USP_CM_PurchaseRefundTax_List] 10

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefundTax_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseRefundHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_PurchaseRefundTax, PIT.IDX_T_PurchaseRefundHeader, PIT.IDX_T_PurchaseRefundDetail,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.AllowEdit,
		COA.COAID, COA.COADesc, COA.IDX_M_COA, PID.Quantity   
	FROM CM_T_PurchaseRefundTax PIT
		LEFT JOIN CM_T_PurchaseRefundDetail PID ON PIT.IDX_T_PurchaseRefundDetail = PID.IDX_T_PurchaseRefundDetail
		LEFT JOIN CM_T_PurchaseRefundHeader PIH ON PID.IDX_T_PurchaseRefundHeader = PIH.IDX_T_PurchaseRefundHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader 
	ORDER BY PID.IDX_T_PurchaseRefundDetail

END




