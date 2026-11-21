-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Sales Invoice Tax
-- =============================================

--EXEC [USP_CM_SalesInvoiceTax_List] 12533

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceTax_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PIT.IDX_T_SalesInvoiceTax, PIT.IDX_T_SalesInvoiceHeader, PIT.IDX_T_SalesInvoiceDetail,
		PIT.IDX_M_Tax, PIT.TaxID, PIT.TaxDesc + ' - Refer to Notes: ' + PID.RemarkDetail AS TaxDesc, PIT.TaxRate, PIT.TaxAmount, PIT.AllowEdit,
		COA.COAID, COA.COADesc, COA.IDX_M_COA, PID.Quantity, PIH.InvoiceStatus   
	FROM CM_T_SalesInvoiceTax PIT
		LEFT JOIN CM_T_SalesInvoiceDetail PID ON PIT.IDX_T_SalesInvoiceDetail = PID.IDX_T_SalesInvoiceDetail
		LEFT JOIN CM_T_SalesInvoiceHeader PIH ON PID.IDX_T_SalesInvoiceHeader = PIH.IDX_T_SalesInvoiceHeader		
		LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
	WHERE PIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader 
	ORDER BY PIT.IDX_T_SalesInvoiceDetail, PIT.IDX_T_SalesInvoiceTax

END




