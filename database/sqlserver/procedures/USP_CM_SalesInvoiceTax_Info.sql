-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Info Sales Invoice Tax
-- =============================================

-- EXEC [USP_CM_SalesInvoiceTax_Info] 10

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceTax_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceTax	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_SalesInvoiceTax, PIT.IDX_T_SalesInvoiceHeader, PIT.IDX_T_SalesInvoiceDetail, RID.IDX_M_Item,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.RecordStatus, 
		COA.COAID, COA.COADesc, COA.IDX_M_COA, RID.Quantity, COA.IDX_M_COA, RID.Quantity, CONCAT(RTRIM(LTRIM(COAID)), ' - ', RTRIM(LTRIM(COADesc))) AS COADesc1, 
		RIH.InvoiceNo  
	FROM CM_T_SalesInvoiceTax PIT
		LEFT JOIN CM_T_SalesInvoiceDetail RID ON PIT.IDX_T_SalesInvoiceDetail = RID.IDX_T_SalesInvoiceDetail
		LEFT JOIN CM_T_SalesInvoiceHeader RIH ON RID.IDX_T_SalesInvoiceHeader = RIH.IDX_T_SalesInvoiceHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_SalesInvoiceTax = @IDX_T_SalesInvoiceTax 
	ORDER BY RID.IDX_T_SalesInvoiceDetail

END




