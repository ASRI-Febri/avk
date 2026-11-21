-- =================================================
-- Author		: Deva
-- Create date	: 26 November 2019
-- Description	: Show Sales Refund Tax Records List
-- =================================================

--EXEC [USP_CM_SalesRefundTax_List] 1

CREATE PROCEDURE [dbo].[USP_CM_SalesRefundTax_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesRefundHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TSRT.*,
		COA.COAID, COA.COADesc, COA.IDX_M_COA, TSRD.Quantity, TSRD.RefundQuantity   
	FROM CM_T_SalesRefundTax TSRT
		LEFT JOIN CM_T_SalesRefundDetail TSRD ON TSRT.IDX_T_SalesRefundDetail = TSRD.IDX_T_SalesRefundDetail
		LEFT JOIN CM_T_SalesRefundHeader TSRH ON TSRD.IDX_T_SalesRefundHeader = TSRH.IDX_T_SalesRefundHeader		
		LEFT JOIN GL_M_COA COA ON TSRT.TaxCOA = COA.IDX_M_COA
	WHERE TSRT.IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader 
	ORDER BY TSRD.IDX_T_SalesRefundDetail

END




