-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Sales Invoice Detail
-- =============================================

--EXEC [USP_CM_SalesInvoiceDetail_List] 6039

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceDetail_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MI.ItemSKU AS ItemSKU, MI.ItemAlias AS ItemAlias, MI.ItemName AS ItemDesc,
		UOM.UoMID AS UOMID, UOM.UoMName AS UOMDesc,
		MBI.BrandID AS BrandAlias, MBI.BrandName AS BrandDesc,
		CUR.CurrencyID AS Alias, CUR.CurrencyName AS CurrencyDesc, 
		SID.IDX_T_SalesInvoiceDetail, SID.IDX_T_SalesInvoiceHeader, SID.IDX_M_Branch, SID.IDX_M_Project, SID.IDX_M_Item, SID.IDX_M_UoM, SID.IDX_M_COA, SID.IDX_M_Tax, SID.IncludeTax,
		SID.ItemDesc, SID.Quantity, SID.UnitPrice, SID.UntaxedAmount, SID.DiscountAmount, ISNULL(PPN.TaxAmount,0) AS TaxAmount, ISNULL(PPH.PPHAmount,0) AS PPHAmount, SID.RemarkDetail, 
		SID.UCreate, SID.DCreate, SID.UModified, SID.DModified, SID.RecordStatus, MPR.ProjectID, MPR.ProjectName, SIH.IDX_M_Partner, SIH.InvoiceStatus, 
		StatusDesc = CASE SIH.InvoiceStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END,
		TotalSales = SID.UnitPrice * SID.Quantity,
		TotalDiscount = SID.DiscountAmount * SID.Quantity,
		TotalTax = ISNULL(TotalPPN.TaxAmount,0) * SID.Quantity,
		TotalPPH = ISNULL(TotalPPH.PPHAmount,0) * SID.Quantity,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM CM_T_SalesInvoiceDetail SID WITH(NOLOCK)
		LEFT JOIN CM_T_SalesInvoiceHeader SIH WITH(NOLOCK) ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
		LEFT JOIN ( SELECT SIT.IDX_T_SalesInvoiceHeader, SUM(SIT.TaxAmount) AS TaxAmount 
					FROM CM_T_SalesInvoiceTax SIT WITH(NOLOCK)
						INNER JOIN GL_M_Tax MT WITH(NOLOCK) ON SIT.IDX_M_Tax = MT.IDX_M_Tax
					WHERE MT.IsWithHoldingTax = 0
					GROUP BY SIT.IDX_T_SalesInvoiceHeader) TotalPPN ON SIH.IDX_T_SalesInvoiceHeader = TotalPPN.IDX_T_SalesInvoiceHeader
		LEFT JOIN ( SELECT SIT.IDX_T_SalesInvoiceHeader, SUM(SIT.TaxAmount) AS PPHAmount 
					FROM CM_T_SalesInvoiceTax SIT WITH(NOLOCK)
						INNER JOIN GL_M_Tax MT WITH(NOLOCK) ON SIT.IDX_M_Tax = MT.IDX_M_Tax
					WHERE MT.IsWithHoldingTax = 1
					GROUP BY SIT.IDX_T_SalesInvoiceHeader) TotalPPH ON SIH.IDX_T_SalesInvoiceHeader = TotalPPH.IDX_T_SalesInvoiceHeader
		LEFT JOIN ( SELECT SIT.IDX_T_SalesInvoiceHeader, SIT.IDX_T_SalesInvoiceDetail, SUM(SIT.TaxAmount) AS TaxAmount 
					FROM CM_T_SalesInvoiceTax SIT WITH(NOLOCK)
						INNER JOIN GL_M_Tax MT WITH(NOLOCK) ON SIT.IDX_M_Tax = MT.IDX_M_Tax
					WHERE MT.IsWithHoldingTax = 0
					GROUP BY SIT.IDX_T_SalesInvoiceHeader, SIT.IDX_T_SalesInvoiceDetail ) PPN ON SID.IDX_T_SalesInvoiceDetail = PPN.IDX_T_SalesInvoiceDetail
		LEFT JOIN ( SELECT SIT.IDX_T_SalesInvoiceHeader, SIT.IDX_T_SalesInvoiceDetail, SUM(SIT.TaxAmount) AS PPHAmount 
					FROM CM_T_SalesInvoiceTax SIT WITH(NOLOCK)
						INNER JOIN GL_M_Tax MT WITH(NOLOCK) ON SIT.IDX_M_Tax = MT.IDX_M_Tax
					WHERE MT.IsWithHoldingTax = 1
					GROUP BY SIT.IDX_T_SalesInvoiceHeader, SIT.IDX_T_SalesInvoiceDetail ) PPH ON SID.IDX_T_SalesInvoiceDetail = PPH.IDX_T_SalesInvoiceDetail
		LEFT JOIN GN_M_Project MPR WITH(NOLOCK) ON SID.IDX_M_Project = MPR.IDX_M_Project
		LEFT JOIN IN_M_Item MI WITH(NOLOCK) ON SID.IDX_M_Item = MI.IDX_M_Item
		LEFT JOIN IN_M_Brand MBI WITH(NOLOCK) ON MI.IDX_M_Brand = MBI.IDX_M_Brand
		LEFT JOIN IN_M_UOM UOM WITH(NOLOCK) ON SID.IDX_M_UOM = UOM.IDX_M_UOM
		LEFT JOIN GN_M_Currency CUR WITH(NOLOCK) ON SIH.IDX_M_Currency = CUR.IDX_M_Currency
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON SID.IDX_M_COA = COA.IDX_M_COA
	WHERE SID.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND SID.RecordStatus = 'A'
	ORDER BY SID.IDX_T_SalesInvoiceDetail

END




