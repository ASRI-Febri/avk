-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Purchase Invoice Tax
-- =============================================

--EXEC [USP_CM_PurchaseInvoiceTax_List] 718

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceTax_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_PurchaseInvoiceTax, PIT.IDX_T_PurchaseInvoiceHeader, PIT.IDX_T_PurchaseInvoiceDetail,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc + ' - Refer to Notes: ' + PID.RemarkDetail AS TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.AllowEdit,
		COA.COAID, COA.COADesc, COA.IDX_M_COA, PID.Quantity, PIH.InvoiceStatus  
	FROM CM_T_PurchaseInvoiceTax PIT
		LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIT.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail
		LEFT JOIN CM_T_PurchaseInvoiceHeader PIH ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader 
	ORDER BY PIT.IDX_T_PurchaseInvoiceDetail, PIT.IDX_T_PurchaseInvoiceTax

END




