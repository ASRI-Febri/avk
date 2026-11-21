-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 September 2018
-- Description:	Purchase invoice report by period
-- =============================================

-- EXEC [dbo].[USP_CM_R_PurchaseInvoice_Period] 1, 3, '2023-01-01', '2023-10-12', 0
-- EXEC [dbo].[USP_CM_R_PurchaseInvoice_Period] 1, 1, '2023-01-01', '2023-10-12', ''
-- EXEC [dbo].[USP_CM_R_PurchaseInvoice_Period] 2, 89, '2024-01-01', '2024-03-31', ''

CREATE PROCEDURE [dbo].[USP_CM_R_PurchaseInvoice_Period]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT = 0,
	@StartDate			DATE,
	@EndDate			DATE,
	@IDX_M_Partner		INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @IDX_M_Branch = 0
	BEGIN
		IF @IDX_M_Partner = 0
		BEGIN
			SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.IDX_M_Company, PIH.IDX_M_Branch, PIH.InvoiceDate, PIH.InvoiceNo, 
				PIH.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				ISNULL(PID.TotalInvoice,0) AS TotalInvoice, ISNULL(FR.PaymentAmount,0) AS PaymentAmount, PIH.RemarkHeader,
				UPPER(GMP.BankName) AS BankName, GMP.AccountName, GMP.AccountNumber  
			FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = PIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
			LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount - DiscountAmount)) + SUM(Quantity * ISNULL(PIT.TaxAmount,0)) AS TotalInvoice 
						FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
							LEFT JOIN CM_T_PurchaseInvoiceTax PIT WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceDetail = PIT.IDX_T_PurchaseInvoiceDetail
						GROUP BY PID.IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 	
			LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount
					FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
					LEFT JOIN CM_T_PaymentAllocation RA WITH(NOLOCK) ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
					LEFT JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					LEFT JOIN CM_T_FinancialPaymentHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
					WHERE RA.AllocationStatus = 'A' AND RA.AllocationDate BETWEEN @StartDate AND @EndDate
					GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			--LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(FPD.PaymentAmount,0)) AS PaymentAmount
			--			FROM CM_T_PurchaseInvoiceHeader PIH				
			--			LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader AND FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType
			--			LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
			--			WHERE FPH.PaymentStatus = 'A' 
			--			GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR 
			--				ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			WHERE PIH.IDX_M_Company = @IDX_M_Company --AND PIH.IDX_M_Branch = @IDX_M_Branch
				AND CONVERT(DATE,PIH.InvoiceDate) BETWEEN @StartDate AND @EndDate 
				AND PIH.InvoiceStatus IN ('A','F')
			ORDER BY PIH.IDX_M_Company, PIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), PIH.InvoiceNo
		END

		IF @IDX_M_Partner <> 0
		BEGIN
			SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.IDX_M_Company, PIH.IDX_M_Branch, PIH.InvoiceDate, PIH.InvoiceNo, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				ISNULL(PID.TotalInvoice,0) AS TotalInvoice, ISNULL(FR.PaymentAmount,0) AS PaymentAmount, PIH.RemarkHeader 
			FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = PIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
			LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount - DiscountAmount)) + SUM(Quantity * ISNULL(PIT.TaxAmount,0)) AS TotalInvoice 
						FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
							LEFT JOIN CM_T_PurchaseInvoiceTax PIT WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceDetail = PIT.IDX_T_PurchaseInvoiceDetail
						GROUP BY PID.IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 	
			LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(FPD.PaymentAmount,0)) AS PaymentAmount
						FROM CM_T_PurchaseInvoiceHeader PIH	WITH(NOLOCK)			
						LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader AND FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType
						LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
						WHERE FPH.PaymentStatus = 'A' AND FPH.ValidationDate BETWEEN @StartDate AND @EndDate
						GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR 
							ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			WHERE PIH.IDX_M_Company = @IDX_M_Company --AND PIH.IDX_M_Branch = @IDX_M_Branch
				AND CONVERT(DATE,PIH.InvoiceDate) BETWEEN @StartDate AND @EndDate 
				AND PIH.IDX_M_Partner = @IDX_M_Partner
				AND PIH.InvoiceStatus IN ('A','F')
			ORDER BY PIH.IDX_M_Company, PIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), PIH.InvoiceNo
		END
	END
	ELSE
	BEGIN
		IF @IDX_M_Partner = 0
		BEGIN
			SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.IDX_M_Company, PIH.IDX_M_Branch, PIH.InvoiceDate, PIH.InvoiceNo, 
				PIH.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				ISNULL(PID.TotalInvoice,0) AS TotalInvoice, ISNULL(FR.PaymentAmount,0) AS PaymentAmount, PIH.RemarkHeader,
				UPPER(GMP.BankName) AS BankName, GMP.AccountName, GMP.AccountNumber  
			FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = PIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
				LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount - DiscountAmount)) + SUM(Quantity * ISNULL(PIT.TaxAmount,0)) AS TotalInvoice 
							FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
								LEFT JOIN CM_T_PurchaseInvoiceTax PIT WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceDetail = PIT.IDX_T_PurchaseInvoiceDetail
							GROUP BY PID.IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 	
			LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount
					FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
					LEFT JOIN CM_T_PaymentAllocation RA WITH(NOLOCK) ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
					LEFT JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					LEFT JOIN CM_T_FinancialPaymentHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
					WHERE RA.AllocationStatus = 'A' AND RA.AllocationDate BETWEEN @StartDate AND @EndDate
					GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			--LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(FPD.PaymentAmount,0)) AS PaymentAmount
			--			FROM CM_T_PurchaseInvoiceHeader PIH				
			--			LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader AND FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType
			--			LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
			--			WHERE FPH.PaymentStatus = 'A' 
			--			GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR 
			--				ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			WHERE PIH.IDX_M_Company = @IDX_M_Company AND PIH.IDX_M_Branch = @IDX_M_Branch
				AND CONVERT(DATE,PIH.InvoiceDate) BETWEEN @StartDate AND @EndDate 
				AND PIH.InvoiceStatus IN ('A','F')
			ORDER BY PIH.IDX_M_Company, PIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), PIH.InvoiceNo
		END

		IF @IDX_M_Partner <> 0
		BEGIN
			SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.IDX_M_Company, PIH.IDX_M_Branch, PIH.InvoiceDate, PIH.InvoiceNo, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				ISNULL(PID.TotalInvoice,0) AS TotalInvoice, ISNULL(FR.PaymentAmount,0) AS PaymentAmount, PIH.RemarkHeader 
			FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = PIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
			LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount - DiscountAmount)) + SUM(Quantity * ISNULL(PIT.TaxAmount,0)) AS TotalInvoice 
						FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
							LEFT JOIN CM_T_PurchaseInvoiceTax PIT WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceDetail = PIT.IDX_T_PurchaseInvoiceDetail
						GROUP BY PID.IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 	
			LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(FPD.PaymentAmount,0)) AS PaymentAmount
						FROM CM_T_PurchaseInvoiceHeader PIH	WITH(NOLOCK)		
						LEFT JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader AND FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType
						LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
						WHERE FPH.PaymentStatus = 'A' AND FPH.ValidationDate BETWEEN @StartDate AND @EndDate
						GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FR 
							ON FR.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			WHERE PIH.IDX_M_Company = @IDX_M_Company AND PIH.IDX_M_Branch = @IDX_M_Branch
				AND CONVERT(DATE,PIH.InvoiceDate) BETWEEN @StartDate AND @EndDate 
				AND PIH.IDX_M_Partner = @IDX_M_Partner
				AND PIH.InvoiceStatus IN ('A','F')
			ORDER BY PIH.IDX_M_Company, PIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), PIH.InvoiceNo
		END
	END

END


