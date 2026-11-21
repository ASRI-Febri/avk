-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 01 September 2018
-- Description	: Sales invoice report by period
-- Mod			: 2020-02-19 by Anton --> Added Refund Transactions
--				  2020-03-09 by Anton --> Added Sales Person Information
-- ==========================================================================================
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Period] 1, 4, '2020-01-01', '2020-01-31', 0, -1
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Period] 1, 4, '2020-01-01', '2020-01-31', 0, 20
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Period] 1, 4, '2019-11-01', '2019-11-30', 0, -1
-- ==========================================================================================

CREATE PROCEDURE [dbo].[USP_CM_R_SalesInvoice_Period-Backup]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE,
	@IDX_M_Partner		INT = 0,
	@IDX_SalesPerson	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @IDX_M_Partner = 0
	BEGIN
		IF @IDX_SalesPerson < 0
		BEGIN
			SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				GMSP.SalesPersonName,
				--ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0)/1.1 ELSE SID.TotalInvoice END AS TotalDPP, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) ELSE 0 END AS TotalPPN, 
				ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
			FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
			LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SIH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
			LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + ISNULL(TaxAmount,0))) AS TotalInvoice, SUM(TaxAmount) AS TotalTax
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
			UNION ALL
			SELECT	SRH.IDX_T_SalesInvoiceHeader, SRH.IDX_M_Company, SRH.IDX_M_Branch, SRH.RefundDate, SRH.RefundNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
					GMSP.SalesPersonName,
					--(ISNULL(SRD.TotalInvoice,0)/1.1)*-1 AS TotalDPP, (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 AS TotalPPN, 
					CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0)/1.1)*-1 ELSE SRD.TotalInvoice*-1 END AS TotalDPP, 
					CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 ELSE 0 END AS TotalPPN, 
					(ISNULL(SRD.TotalInvoice,0))*-1 AS TotalInvoice, 
					0 AS ReceiveAmount, SRH.RemarkHeader + ' - ' + SRH.RefundNo + ' - SI Number: ' + SRH.InvoiceReferenceNo AS RemarkHeader, '-' AS TaxInvoiceNo
				FROM CM_T_SalesRefundHeader SRH WITH(NOLOCK)
				LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SRH.IDX_M_Company 
				LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SRH.IDX_M_Partner 
				LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SRH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
				LEFT JOIN (	SELECT	SRD.IDX_T_SalesRefundHeader, SUM(RefundQuantity * (RefundPrice - DiscountAmount + ISNULL(TaxRefundAmount,0))) AS TotalInvoice,
									SUM(ISNULL(TaxRefundAmount,0)) AS TotalTax
							FROM CM_T_SalesRefundDetail SRD WITH(NOLOCK)
							GROUP BY IDX_T_SalesRefundHeader) SRD ON SRD.IDX_T_SalesRefundHeader = SRH.IDX_T_SalesRefundHeader
				WHERE SRH.IDX_M_Company = @IDX_M_Company AND SRH.IDX_M_Branch = @IDX_M_Branch
					AND CONVERT(DATE,SRH.RefundDate) BETWEEN @StartDate AND @EndDate
					AND SRH.RefundStatus IN ('A','F')
			ORDER BY IDX_M_Company, IDX_M_Branch, PartnerName, IDX_M_Partner, InvoiceNo
			--ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), SIH.InvoiceNo
		END
		ELSE
		BEGIN
			SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				GMSP.SalesPersonName,
				--ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0)/1.1 ELSE SID.TotalInvoice END AS TotalDPP, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) ELSE 0 END AS TotalPPN, 
				ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
			FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
			LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SIH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
			LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + ISNULL(TaxAmount,0))) AS TotalInvoice, SUM(TaxAmount) AS TotalTax
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
				AND SIH.InvoiceStatus IN ('A','F') AND SIH.IDX_M_SalesPerson = @IDX_SalesPerson
			UNION ALL
			SELECT	SRH.IDX_T_SalesInvoiceHeader, SRH.IDX_M_Company, SRH.IDX_M_Branch, SRH.RefundDate, SRH.RefundNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
					GMSP.SalesPersonName,
					--(ISNULL(SRD.TotalInvoice,0)/1.1)*-1 AS TotalDPP, (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 AS TotalPPN, 
					CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0)/1.1)*-1 ELSE SRD.TotalInvoice*-1 END AS TotalDPP, 
					CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 ELSE 0 END AS TotalPPN, 
					(ISNULL(SRD.TotalInvoice,0))*-1 AS TotalInvoice, 
					0 AS ReceiveAmount, SRH.RemarkHeader + ' - ' + SRH.RefundNo + ' - SI Number: ' + SRH.InvoiceReferenceNo AS RemarkHeader, '-' AS TaxInvoiceNo
				FROM CM_T_SalesRefundHeader SRH WITH(NOLOCK)
				LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SRH.IDX_M_Company 
				LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SRH.IDX_M_Partner 
				LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SRH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
				LEFT JOIN (	SELECT	SRD.IDX_T_SalesRefundHeader, SUM(RefundQuantity * (RefundPrice - DiscountAmount + ISNULL(TaxRefundAmount,0))) AS TotalInvoice,
									SUM(ISNULL(TaxRefundAmount,0)) AS TotalTax
							FROM CM_T_SalesRefundDetail SRD WITH(NOLOCK)
							GROUP BY IDX_T_SalesRefundHeader) SRD ON SRD.IDX_T_SalesRefundHeader = SRH.IDX_T_SalesRefundHeader
				WHERE SRH.IDX_M_Company = @IDX_M_Company AND SRH.IDX_M_Branch = @IDX_M_Branch
					AND CONVERT(DATE,SRH.RefundDate) BETWEEN @StartDate AND @EndDate
					AND SRH.RefundStatus IN ('A','F') AND SRH.IDX_M_SalesPerson = @IDX_SalesPerson
			ORDER BY IDX_M_Company, IDX_M_Branch, PartnerName, IDX_M_Partner, InvoiceNo
		END
	END

	IF @IDX_M_Partner <> 0
	BEGIN
		IF @IDX_SalesPerson < 0
		BEGIN
			SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				GMSP.SalesPersonName,
				--ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0)/1.1 ELSE SID.TotalInvoice END AS TotalDPP, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) ELSE 0 END AS TotalPPN, 
				ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
			FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
			LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SIH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
			LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + ISNULL(TaxAmount,0))) AS TotalInvoice, SUM(TaxAmount) AS TotalTax 
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
			UNION ALL
			SELECT SRH.IDX_T_SalesInvoiceHeader, SRH.IDX_M_Company, SRH.IDX_M_Branch, SRH.RefundDate, SRH.RefundNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
						GMSP.SalesPersonName,
						--(ISNULL(SRD.TotalInvoice,0)/1.1)*-1 AS TotalDPP, (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 AS TotalPPN, 
						CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0)/1.1)*-1 ELSE SRD.TotalInvoice*-1 END AS TotalDPP, 
						CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 ELSE 0 END AS TotalPPN, 
						(ISNULL(SRD.TotalInvoice,0))*-1 AS TotalInvoice, 
						0 AS ReceiveAmount, SRH.RemarkHeader + ' - ' + SRH.RefundNo + ' - SI Number: ' + SRH.InvoiceReferenceNo AS RemarkHeader, '-' AS TaxInvoiceNo
					FROM CM_T_SalesRefundHeader SRH WITH(NOLOCK)
					LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SRH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SRH.IDX_M_Partner 
					LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SRH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
					LEFT JOIN (	SELECT	SRD.IDX_T_SalesRefundHeader, SUM(RefundQuantity * (RefundPrice - DiscountAmount + ISNULL(TaxRefundAmount,0))) AS TotalInvoice,
										SUM(ISNULL(TaxRefundAmount,0)) AS TotalTax
								FROM CM_T_SalesRefundDetail SRD WITH(NOLOCK)
								GROUP BY IDX_T_SalesRefundHeader) SRD ON SRD.IDX_T_SalesRefundHeader = SRH.IDX_T_SalesRefundHeader
					WHERE SRH.IDX_M_Company = @IDX_M_Company AND SRH.IDX_M_Branch = @IDX_M_Branch
						AND CONVERT(DATE,SRH.RefundDate) BETWEEN @StartDate AND @EndDate
						AND SRH.RefundStatus IN ('A','F')
						AND SRH.IDX_M_Partner = @IDX_M_Partner
			ORDER BY IDX_M_Company, IDX_M_Branch, PartnerName, IDX_M_Partner, InvoiceNo
			--ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), SIH.InvoiceNo
		END
		ELSE
		BEGIN
			SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
				GMSP.SalesPersonName,
				--ISNULL(SID.TotalInvoice,0)/1.1 AS TotalDPP, ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) AS TotalPPN, ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0)/1.1 ELSE SID.TotalInvoice END AS TotalDPP, 
				CASE WHEN SID.TotalTax <> 0 THEN ISNULL(SID.TotalInvoice,0) - (ISNULL(SID.TotalInvoice,0)/1.1) ELSE 0 END AS TotalPPN, 
				ISNULL(SID.TotalInvoice,0) AS TotalInvoice, 
				ISNULL(FR.ReceiveAmount,0) AS ReceiveAmount, SIH.RemarkHeader, ISNULL(SIH.TaxInvoiceNo,'') AS TaxInvoiceNo
			FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
			LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SIH.IDX_M_Company 
			LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
			LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SIH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
			LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount + ISNULL(TaxAmount,0))) AS TotalInvoice, SUM(TaxAmount) AS TotalTax 
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
				AND SIH.IDX_M_SalesPerson = @IDX_SalesPerson
			UNION ALL
			SELECT SRH.IDX_T_SalesInvoiceHeader, SRH.IDX_M_Company, SRH.IDX_M_Branch, SRH.RefundDate, SRH.RefundNo, GMP.IDX_M_Partner, ISNULL(GMP.PartnerName,'') AS PartnerName, 
						GMSP.SalesPersonName,
						--(ISNULL(SRD.TotalInvoice,0)/1.1)*-1 AS TotalDPP, (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 AS TotalPPN, 
						CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0)/1.1)*-1 ELSE SRD.TotalInvoice*-1 END AS TotalDPP, 
						CASE WHEN SRD.TotalTax <> 0 THEN (ISNULL(SRD.TotalInvoice,0) - (ISNULL(SRD.TotalInvoice,0)/1.1))*-1 ELSE 0 END AS TotalPPN, 
						(ISNULL(SRD.TotalInvoice,0))*-1 AS TotalInvoice, 
						0 AS ReceiveAmount, SRH.RemarkHeader + ' - ' + SRH.RefundNo + ' - SI Number: ' + SRH.InvoiceReferenceNo AS RemarkHeader, '-' AS TaxInvoiceNo
					FROM CM_T_SalesRefundHeader SRH WITH(NOLOCK)
					LEFT JOIN GN_M_Company GC WITH(NOLOCK) ON GC.IDX_M_Company = SRH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP WITH(NOLOCK) ON GMP.IDX_M_Partner = SRH.IDX_M_Partner 
					LEFT JOIN GN_M_SalesPerson GMSP WITH(NOLOCK) ON SRH.IDX_M_SalesPerson = GMSP.IDX_M_SalesPerson
					LEFT JOIN (	SELECT	SRD.IDX_T_SalesRefundHeader, SUM(RefundQuantity * (RefundPrice - DiscountAmount + ISNULL(TaxRefundAmount,0))) AS TotalInvoice,
										SUM(ISNULL(TaxRefundAmount,0)) AS TotalTax
								FROM CM_T_SalesRefundDetail SRD WITH(NOLOCK)
								GROUP BY IDX_T_SalesRefundHeader) SRD ON SRD.IDX_T_SalesRefundHeader = SRH.IDX_T_SalesRefundHeader
					WHERE SRH.IDX_M_Company = @IDX_M_Company AND SRH.IDX_M_Branch = @IDX_M_Branch
						AND CONVERT(DATE,SRH.RefundDate) BETWEEN @StartDate AND @EndDate
						AND SRH.RefundStatus IN ('A','F')
						AND SRH.IDX_M_Partner = @IDX_M_Partner
						AND SRH.IDX_M_SalesPerson = @IDX_SalesPerson
			ORDER BY IDX_M_Company, IDX_M_Branch, PartnerName, IDX_M_Partner, InvoiceNo
			--ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, ISNULL(GMP.PartnerName,''), SIH.InvoiceNo
		END
	END

END


