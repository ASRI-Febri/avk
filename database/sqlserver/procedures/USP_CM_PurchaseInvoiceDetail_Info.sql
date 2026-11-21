-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Get Detail Information for Purchase Invoice Detail based on ID
-- =============================================

-- EXEC USP_CM_PurchaseInvoiceDetail_Info 9

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceDetail_Info]
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceDetail BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MI.ItemSKU AS ItemSKU, MI.ItemName AS ItemDesc, MI.LastPurchasePrice AS BasePrice, MI.SellingPrice AS SellingPrice,
		UOM.UoMID AS UOMID, UOM.UoMName AS UOMDesc,
		MBI.BrandID AS BrandID, MBI.BrandName AS BrandDesc, MBI.BrandID AS BrandInitial,
		CUR.CurrencyID AS CurrencyID, CUR.CurrencyName AS CurrencyDesc, 
		RIH.IDX_M_Partner, RIH.InvoiceStatus, GMP.PartnerID, GMP.PartnerName AS PartnerName, 
		RID.*, MPR.ProjectID, MPR.ProjectName,
		StatusDesc = CASE RIH.InvoiceStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Void' END, 
		COA.COAID, COA.COADesc, COA.IDX_M_COA, CONCAT(RTRIM(LTRIM(COAID)), ' - ', RTRIM(LTRIM(COADesc))) AS COADesc1
	FROM CM_T_PurchaseInvoiceDetail RID WITH(NOLOCK)
		LEFT JOIN CM_T_PurchaseInvoiceHeader RIH WITH(NOLOCK) ON RID.IDX_T_PurchaseInvoiceHeader = RIH.IDX_T_PurchaseInvoiceHeader
		LEFT JOIN GN_M_Project MPR WITH(NOLOCK) ON RID.IDX_M_Project = MPR.IDX_M_Project
		LEFT JOIN IN_M_Item MI WITH(NOLOCK) ON RID.IDX_M_Item = MI.IDX_M_Item
		LEFT JOIN IN_M_Brand MBI WITH(NOLOCK) ON MI.IDX_M_Brand = MBI.IDX_M_Brand
		LEFT JOIN IN_M_UOM UOM WITH(NOLOCK) ON RID.IDX_M_UOM = UOM.IDX_M_UOM
		LEFT JOIN GN_M_Currency CUR WITH(NOLOCK) ON RIH.IDX_M_Currency = CUR.IDX_M_Currency
		LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON RIH.IDX_M_Partner = GMP.IDX_M_Partner
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON RID.IDX_M_COA = COA.IDX_M_COA
	WHERE RID.IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail
	ORDER BY RID.IDX_T_PurchaseInvoiceDetail DESC
END




