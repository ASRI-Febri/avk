-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Purchase Invoice Detail
-- =============================================

--EXEC [USP_CM_PurchaseInvoiceDetail_List] 1

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceDetail_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MI.ItemSKU AS ItemSKU, MI.ItemAlias AS ItemAlias, MI.ItemName AS ItemDesc,
		UOM.UoMID AS UOMID, UOM.UoMName AS UOMDesc,
		MBI.BrandID AS BrandAlias, MBI.BrandName AS BrandDesc,
		CUR.CurrencyID AS CurrencyAlias, CUR.CurrencyName AS CurrencyDesc, 
		PID.*, MPR.ProjectID, MPR.ProjectName, PIH.IDX_M_Partner, PIH.InvoiceStatus, 
		StatusDesc = CASE PIH.InvoiceStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END,
		TotalSales = PID.UnitPrice * PID.Quantity,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
		LEFT JOIN CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
		LEFT JOIN GN_M_Project MPR WITH(NOLOCK) ON PID.IDX_M_Project = MPR.IDX_M_Project
		LEFT JOIN IN_M_Item MI WITH(NOLOCK) ON PID.IDX_M_Item = MI.IDX_M_Item
		LEFT JOIN IN_M_Brand MBI WITH(NOLOCK) ON MI.IDX_M_Brand = MBI.IDX_M_Brand
		LEFT JOIN IN_M_UOM UOM WITH(NOLOCK) ON PID.IDX_M_UOM = UOM.IDX_M_UOM
		LEFT JOIN GN_M_Currency CUR WITH(NOLOCK) ON PIH.IDX_M_Currency = CUR.IDX_M_Currency
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PID.IDX_M_COA = COA.IDX_M_COA
	WHERE PID.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND PID.RecordStatus = 'A'
	ORDER BY PID.IDX_T_PurchaseInvoiceDetail

END




