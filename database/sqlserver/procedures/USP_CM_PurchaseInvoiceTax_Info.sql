-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Info Purchase Invoice Tax
-- =============================================

-- EXEC [USP_CM_PurchaseInvoiceTax_Info] 10

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceTax_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceTax	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_PurchaseInvoiceTax, PIT.IDX_T_PurchaseInvoiceHeader, PIT.IDX_T_PurchaseInvoiceDetail, RID.IDX_M_Item,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.RecordStatus, 
		COA.COAID, COA.COADesc, COA.IDX_M_COA, RID.Quantity, CONCAT(RTRIM(LTRIM(COAID)), ' - ', RTRIM(LTRIM(COADesc))) AS COADesc1, 
		RIH.InvoiceNo, TaxCOA  
	FROM CM_T_PurchaseInvoiceTax PIT
		LEFT JOIN CM_T_PurchaseInvoiceDetail RID ON PIT.IDX_T_PurchaseInvoiceDetail = RID.IDX_T_PurchaseInvoiceDetail
		LEFT JOIN CM_T_PurchaseInvoiceHeader RIH ON RID.IDX_T_PurchaseInvoiceHeader = RIH.IDX_T_PurchaseInvoiceHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_PurchaseInvoiceTax = @IDX_T_PurchaseInvoiceTax 
	ORDER BY RID.IDX_T_PurchaseInvoiceDetail

END




