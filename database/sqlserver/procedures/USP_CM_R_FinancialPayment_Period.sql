-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 September 2018
-- Description:	Financial Payment report by period
-- =============================================

-- EXEC [dbo].[USP_CM_R_FinancialPayment_Period] 3, 90, '2024-01-01', '2024-01-31'

CREATE PROCEDURE [dbo].[USP_CM_R_FinancialPayment_Period]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT FPH.IDX_T_FinancialPaymentHeader, FPH.IDX_M_Company, FPH.IDX_M_Branch, GC.CompanyName AS CompanyName, MB.BranchID, MB.BranchAlias, MB.BranchName, 
		FPH.PaymentID, FPH.PaymentDate, FPH.PaymentStatus, FPH.IDX_M_Currency, FPH.IDX_M_PaymentType, 
		CU.CurrencyName AS Currency, MPT.Name AS PaymentType, FPH.RemarkHeader, FPH.PaymentStatus, 
		PaymentStatusDesc = CASE FPH.PaymentStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'F' THEN 'Validate' END, 
		FPH.IDX_M_FinancialAccount, ISNULL(MFA.FinancialAccountID,'') AS FinancialAccountID, ISNULL(MFA.FinancialAccountDesc,'') AS FinancialAccountDesc, 
		ISNULL(FRD.PaymentAmount,0) AS PaymentAmount, 
		GMP.PartnerID, GMP.PartnerName AS PartnerName 
	FROM CM_T_FinancialPaymentHeader FPH
		LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = FPH.IDX_M_Company 
		LEFT JOIN GN_M_Branch MB ON MB.IDX_M_Branch = FPH.IDX_M_Branch 
		LEFT JOIN GN_M_Currency CU ON CU.IDX_M_Currency = FPH.IDX_M_Currency
		LEFT JOIN GN_M_PaymentType MPT ON MPT.IDX_M_PaymentType = FPH.IDX_M_PaymentType
		LEFT JOIN (	SELECT IDX_T_FinancialPaymentHeader, SUM(PaymentAmount) AS PaymentAmount 
					FROM CM_T_FinancialPaymentDetail FRD 
					WHERE FRD.RecordStatus = 'A' GROUP BY IDX_T_FinancialPaymentHeader) FRD ON FRD.IDX_T_FinancialPaymentHeader = FPH.IDX_T_FinancialPaymentHeader 
		LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount 	
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = FPH.IDX_M_Partner	
	WHERE FPH.IDX_M_Company = @IDX_M_Company AND FPH.IDX_M_Branch = @IDX_M_Branch
		AND CONVERT(DATE,FPH.PaymentDate) BETWEEN @StartDate AND @EndDate
	ORDER BY FPH.IDX_M_Company, FPH.IDX_M_Branch, FPH.PaymentDate, FPH.PaymentID


	--SELECT FRH.IDX_M_Company, FRH.IDX_M_Branch, FRH.ReceiveID, FRH.ReceiveDate, FRH.ReceiveStatus, FRH.ReceiveStatus, 
	--	FRH.IDX_M_FinancialAccount, MFA.FinancialAccountID, MFA.FinancialAccountDesc
	--FROM CM_T_FinancialReceiveHeader FRH
	--	LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader 
	--	LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = FRH.IDX_M_FinancialAccount 
	--	LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = FRD.IDX_M_DocumentType AND RA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
	--WHERE FRH.IDX_M_Company = @IDX_M_Company AND FRH.IDX_M_Branch = @IDX_M_Branch
	--	AND CONVERT(DATE,FRH.ReceiveDate) BETWEEN @StartDate AND @EndDate
	--ORDER BY FRH.IDX_M_Company, FRH.IDX_M_Branch, FRH.ReceiveID


	--SELECT SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, ISNULL(GMP.Name,'') AS PartnerName, 
	--	ISNULL(SID.TotalInvoice,0) AS TotalInvoice, ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader 
	--FROM CM_T_SalesInvoiceHeader SIH
	--LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = SIH.IDX_M_Company 
	--LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
	--LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * UnitPrice) AS TotalInvoice 
	--			FROM CM_T_SalesInvoiceDetail SID
	--			GROUP BY IDX_T_SalesInvoiceHeader) SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader 
	--LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
	--			FROM CM_T_SalesInvoiceHeader SIH
	--			LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
	--			LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
	--			LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
	--			WHERE RA.AllocationStatus = 'A' 
	--			GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
	--				ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
	--WHERE SIH.IDX_M_Company = @IDX_M_Company AND SIH.IDX_M_Branch = @IDX_M_Branch
	--	AND CONVERT(DATE,SIH.InvoiceDate) BETWEEN @StartDate AND @EndDate
	--ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceNo

END


