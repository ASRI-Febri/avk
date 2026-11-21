-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 September 2018
-- Description:	Sales invoice report by period
-- =============================================

-- EXEC [dbo].[USP_CM_R_SalesInvoice_Period] 1, 4, '2020-01-01', '2020-01-31', 0
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Period] 1, 4, '2019-11-01', '2019-11-30', 0

CREATE PROCEDURE [dbo].[USP_CM_R_SalesInvoice_Period_Backup]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE,
	@IDX_M_Partner		INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @IDX_M_Partner = 0
	BEGIN
		SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, ISNULL(GMP.PartnerName,'') AS PartnerName, 
			ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
			ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
		FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
		LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
		LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
		LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + TaxAmount)) AS TotalInvoice 
					FROM CM_T_SalesInvoiceDetail SID WITH(NOLOCK)
					GROUP BY IDX_T_SalesInvoiceHeader) SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader 
		LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
					FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
					LEFT JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
					LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					LEFT JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
					WHERE RA.AllocationStatus = 'A' 
					GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
						ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
		WHERE SIH.IDX_M_Company = @IDX_M_Company AND SIH.IDX_M_Branch = @IDX_M_Branch
			AND CONVERT(DATE,SIH.InvoiceDate) BETWEEN @StartDate AND @EndDate
			AND SIH.InvoiceStatus IN ('A','F')
		ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), SIH.InvoiceNo
	END

	IF @IDX_M_Partner <> 0
	BEGIN
		SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, ISNULL(GMP.PartnerName,'') AS PartnerName, 
			ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
			ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
		FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
		LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
		LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
		LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + TaxAmount)) AS TotalInvoice 
					FROM CM_T_SalesInvoiceDetail SID WITH(NOLOCK)
					GROUP BY IDX_T_SalesInvoiceHeader) SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader 
		LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
					FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
					LEFT JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
					LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					LEFT JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
					WHERE RA.AllocationStatus = 'A' 
					GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
						ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
		WHERE SIH.IDX_M_Company = @IDX_M_Company AND SIH.IDX_M_Branch = @IDX_M_Branch
			AND CONVERT(DATE,SIH.InvoiceDate) BETWEEN @StartDate AND @EndDate
			AND SIH.InvoiceStatus IN ('A','F')
			AND SIH.IDX_M_Partner = @IDX_M_Partner
		ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), SIH.InvoiceNo
	END

END


