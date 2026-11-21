-- =============================================================================================================================================
-- Author		: Anton
-- Create date	: 2021-09-06
-- Description	: Payment PO report by period
-- Mod			: 2021-09-16 by Anton --> Adjust logic calculation
--				  2021-10-26 by Anton --> Added filter parameter for project
--				  2022-06-27 by Anton --> Added column Invoice Amount Without PPH & PDCNo
--				  2022-06-28 by Anton --> Data payment approved when payment status start from already Handover (before only status validate)
-- =============================================================================================================================================
-- EXEC [dbo].[USP_CM_R_PaymentPO_Period] 1, 1, '2020-01-01', '2022-06-27', 0, 1
-- EXEC [dbo].[USP_CM_R_PaymentPO_Period] 1, 1, '2020-01-01', '2021-12-31', 11, -1
-- EXEC [dbo].[USP_CM_R_PaymentPO_Period] 1, 1, '2021-01-01', '2021-12-31', 11, 1
-- =======================================================================================================

CREATE PROCEDURE [dbo].[USP_CM_R_PaymentPO_Period]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE,
	@IDX_M_Partner		INT = 0,
	@IDX_M_Project		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF @IDX_M_Partner = 0
	BEGIN
		IF @IDX_M_Project = -1
		BEGIN
			SELECT	a.IDX_T_PurchaseOrder, a.IDX_M_Company, a.IDX_M_Branch, a.PODate, a.PONumber, a.IDX_M_Partner, b.PartnerName, a.PODescription, c.POAmount, 
					ISNULL(inv.IDX_T_PurchaseInvoiceHeader,0) AS IDX_T_PurchaseInvoiceHeader, ISNULL(inv.InvoiceDescription,'-') AS InvoiceDescription, 
					ISNULL(inv.InvoiceNo,'-') AS InvoiceNo, ISNULL(inv.InvoiceDate,'') as InvoiceDate, ISNULL(inv.InvoiceAmount,0) AS InvoiceAmount, ISNULL(invnopph.SubTotalNoPPH,0) AS InvoiceAmountNoPPH,
					ISNULL(pay.PaymentDescription,'-') AS PaymentDescription, ISNULL(pay.PaymentID,'-') AS PaymentID, ISNULL(pay.PDCNo,'-') AS PDCNo, ISNULL(pay.PaymentAmount,0) AS PaymentAmount
			FROM PR_T_PurchaseOrder a WITH(NOLOCK)
				INNER JOIN GN_M_Partner b WITH(NOLOCK) ON a.IDX_M_Partner = b.IDX_M_Partner
				LEFT JOIN	( SELECT IDX_T_PurchaseOrder, SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS POAmount
							  FROM PR_T_PurchaseOrderDetail WITH(NOLOCK)
							  GROUP BY IDX_T_PurchaseOrder 
							  ) c ON a.IDX_T_PurchaseOrder = c.IDX_T_PurchaseOrder
				--LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
				--			  SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS InvoiceAmount
				--			  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
				--				INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				--			  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
				--			  GROUP BY PIH.IDX_ReferenceNo, PIH.InvoiceNo, PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader 
				--			  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceDate, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
									 ISNULL(PID.TotalInvoice,0) AS InvoiceAmount
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
							  	LEFT JOIN (	SELECT IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount  + ISNULL(Tax,0))) AS TotalInvoice
							  				FROM ( SELECT PID.IDX_T_PurchaseInvoiceHeader, Quantity, UnitPrice, DiscountAmount, 
							  						( SELECT SUM(X.TaxAmount) 
													  FROM CM_T_PurchaseInvoiceTax X WITH(NOLOCK)
													  	INNER JOIN CM_T_PurchaseInvoiceHeader Y WITH(NOLOCK) ON X.IDX_T_PurchaseInvoiceHeader = Y.IDX_T_PurchaseInvoiceHeader 
														AND Y.InvoiceStatus = 'A'
													  WHERE X.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
													  GROUP BY X.IDX_T_PurchaseInvoiceDetail ) Tax
							  		 			   FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ) A
							  					   GROUP BY A.IDX_T_PurchaseInvoiceHeader ) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
							  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
							  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(X.SubTotalNoPPH) AS SubTotalNoPPH
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
								LEFT JOIN
									(
									SELECT	PID.IDX_T_PurchaseInvoiceDetail, PID.IDX_T_PurchaseInvoiceHeader, 
											PID.Quantity * (PID.UntaxedAmount - PID.DiscountAmount + ISNULL(AmountNoPPH.TaxAmountNoPPH,0)) as SubTotalNoPPH
									FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
									LEFT JOIN
									(
										SELECT A.IDX_T_PurchaseInvoiceDetail, SUM(A.TaxAmount) as TaxAmountNoPPH
										FROM CM_T_PurchaseInvoiceTax A WITH(NOLOCK)
											INNER JOIN GL_M_Tax B WITH(NOLOCK) on a.IDX_M_Tax = b.IDX_M_Tax
										WHERE A.RecordStatus = 'A' AND B.IsWithHoldingTax = 0
										GROUP BY A.IDX_T_PurchaseInvoiceDetail
									) AmountNoPPH ON PID.IDX_T_PurchaseInvoiceDetail = AmountNoPPH.IDX_T_PurchaseInvoiceDetail
									WHERE PID.RecordStatus = 'A' --AND PID.IDX_M_Item <> 177 --IDX 177 = Pembulatan
								) X ON PIH.IDX_T_PurchaseInvoiceHeader = X.IDX_T_PurchaseInvoiceHeader
							  WHERE PIH.ReferenceNo LIKE 'PO-%' AND PIH.InvoiceStatus = 'A' 
							  GROUP BY PIH.IDX_T_PurchaseInvoiceHeader
							  ) invnopph ON inv.IDX_T_PurchaseInvoiceHeader = invnopph.IDX_T_PurchaseInvoiceHeader
				LEFT JOIN	( SELECT FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader AS PaymentDescription, SUM(PA.AllocationAmount) as PaymentAmount
							  FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
								INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
								INNER JOIN CM_T_PaymentAllocation PA WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
							  WHERE FPH.PaymentStatus IN ('H','F') AND PA.AllocationStatus = 'A'
							  GROUP BY FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader 
							  ) pay ON inv.IDX_T_PurchaseInvoiceHeader = pay.IDX_DocumentNo
			WHERE	a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch AND a.POStatus <> 'D' AND a.PONumber LIKE 'PO-%' 
					AND a.PODate BETWEEN @StartDate AND @EndDate
			ORDER BY a.PODate
		END
		ELSE
		BEGIN
			SELECT	a.IDX_T_PurchaseOrder, a.IDX_M_Company, a.IDX_M_Branch, a.PODate, a.PONumber, a.IDX_M_Partner, b.PartnerName, a.PODescription, c.POAmount, 
					ISNULL(inv.IDX_T_PurchaseInvoiceHeader,0) AS IDX_T_PurchaseInvoiceHeader, ISNULL(inv.InvoiceDescription,'-') AS InvoiceDescription, 
					ISNULL(inv.InvoiceNo,'-') AS InvoiceNo, ISNULL(inv.InvoiceDate,'') as InvoiceDate, ISNULL(inv.InvoiceAmount,0) AS InvoiceAmount, ISNULL(invnopph.SubTotalNoPPH,0) AS InvoiceAmountNoPPH,
					ISNULL(pay.PaymentDescription,'-') AS PaymentDescription, ISNULL(pay.PaymentID,'-') AS PaymentID, ISNULL(pay.PDCNo,'-') AS PDCNo, ISNULL(pay.PaymentAmount,0) AS PaymentAmount
			FROM PR_T_PurchaseOrder a WITH(NOLOCK)
				INNER JOIN GN_M_Partner b WITH(NOLOCK) ON a.IDX_M_Partner = b.IDX_M_Partner
				INNER JOIN GN_M_Project g WITH(NOLOCK) ON a.IDX_M_Project = g.IDX_M_Project
				LEFT JOIN	( SELECT IDX_T_PurchaseOrder, SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS POAmount
							  FROM PR_T_PurchaseOrderDetail WITH(NOLOCK)
							  GROUP BY IDX_T_PurchaseOrder 
							  ) c ON a.IDX_T_PurchaseOrder = c.IDX_T_PurchaseOrder
				--LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
				--			  SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS InvoiceAmount
				--			  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
				--				INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				--			  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
				--			  GROUP BY PIH.IDX_ReferenceNo, PIH.InvoiceNo, PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader 
				--			  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceDate, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
									 ISNULL(PID.TotalInvoice,0) AS InvoiceAmount
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
							  	LEFT JOIN (	SELECT IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount  + ISNULL(Tax,0))) AS TotalInvoice
							  				FROM ( SELECT PID.IDX_T_PurchaseInvoiceHeader, Quantity, UnitPrice, DiscountAmount, 
							  						( SELECT SUM(X.TaxAmount) 
													  FROM CM_T_PurchaseInvoiceTax X WITH(NOLOCK)
													  	INNER JOIN CM_T_PurchaseInvoiceHeader Y WITH(NOLOCK) ON X.IDX_T_PurchaseInvoiceHeader = Y.IDX_T_PurchaseInvoiceHeader 
														AND Y.InvoiceStatus = 'A'
													  WHERE X.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
													  GROUP BY X.IDX_T_PurchaseInvoiceDetail ) Tax
							  		 			   FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ) A
							  					   GROUP BY A.IDX_T_PurchaseInvoiceHeader ) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
							  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
							  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, X.SubTotalNoPPH AS SubTotalNoPPH
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
								LEFT JOIN
									(
									SELECT	PID.IDX_T_PurchaseInvoiceHeader, 
											SUM(PID.Quantity * (PID.UntaxedAmount - PID.DiscountAmount + ISNULL(AmountNoPPH.TaxAmountNoPPH,0))) as SubTotalNoPPH
									FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
									LEFT JOIN
									(
										SELECT A.IDX_T_PurchaseInvoiceDetail, SUM(A.TaxAmount) as TaxAmountNoPPH
										FROM CM_T_PurchaseInvoiceTax A WITH(NOLOCK)
											INNER JOIN GL_M_Tax B WITH(NOLOCK) on a.IDX_M_Tax = b.IDX_M_Tax
										WHERE A.RecordStatus = 'A' AND B.IsWithHoldingTax = 0
										GROUP BY A.IDX_T_PurchaseInvoiceDetail
									) AmountNoPPH ON PID.IDX_T_PurchaseInvoiceDetail = AmountNoPPH.IDX_T_PurchaseInvoiceDetail
									WHERE PID.RecordStatus = 'A' --AND PID.IDX_M_Item <> 177 --IDX 177 = Pembulatan
									GROUP BY PID.IDX_T_PurchaseInvoiceHeader
								) X ON PIH.IDX_T_PurchaseInvoiceHeader = X.IDX_T_PurchaseInvoiceHeader
							  WHERE PIH.ReferenceNo LIKE 'PO-%' AND PIH.InvoiceStatus = 'A'  

							  ) invnopph ON inv.IDX_T_PurchaseInvoiceHeader = invnopph.IDX_T_PurchaseInvoiceHeader
				LEFT JOIN	( SELECT FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader AS PaymentDescription, SUM(PA.AllocationAmount) as PaymentAmount
							  FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
								INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
								INNER JOIN CM_T_PaymentAllocation PA WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
							  WHERE FPH.PaymentStatus IN ('H','F') AND PA.AllocationStatus = 'A'
							  GROUP BY FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader 
							  ) pay ON inv.IDX_T_PurchaseInvoiceHeader = pay.IDX_DocumentNo
			WHERE	a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch AND a.POStatus <> 'D' AND g.IDX_M_Project = @IDX_M_Project AND a.PONumber LIKE 'PO-%' 
					AND a.PODate BETWEEN @StartDate AND @EndDate
			ORDER BY a.PODate, InvoiceDate
		END
	END

	IF @IDX_M_Partner <> 0
	BEGIN
		IF @IDX_M_Project = -1
		BEGIN
			SELECT	a.IDX_T_PurchaseOrder, a.IDX_M_Company, a.IDX_M_Branch, a.PODate, a.PONumber, a.IDX_M_Partner, b.PartnerName, a.PODescription, c.POAmount, 
					ISNULL(inv.IDX_T_PurchaseInvoiceHeader,0) AS IDX_T_PurchaseInvoiceHeader, ISNULL(inv.InvoiceDescription,'-') AS InvoiceDescription, 
					ISNULL(inv.InvoiceNo,'-') AS InvoiceNo, ISNULL(inv.InvoiceDate,'') as InvoiceDate, ISNULL(inv.InvoiceAmount,0) AS InvoiceAmount, ISNULL(invnopph.SubTotalNoPPH,0) AS InvoiceAmountNoPPH,
					ISNULL(pay.PaymentDescription,'-') AS PaymentDescription, ISNULL(pay.PaymentID,'-') AS PaymentID, ISNULL(pay.PDCNo,'-') AS PDCNo, ISNULL(pay.PaymentAmount,0) AS PaymentAmount
			FROM PR_T_PurchaseOrder a WITH(NOLOCK)
				INNER JOIN GN_M_Partner b WITH(NOLOCK) ON a.IDX_M_Partner = b.IDX_M_Partner
				LEFT JOIN	( SELECT IDX_T_PurchaseOrder, SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS POAmount
							  FROM PR_T_PurchaseOrderDetail WITH(NOLOCK)
							  GROUP BY IDX_T_PurchaseOrder 
							  ) c ON a.IDX_T_PurchaseOrder = c.IDX_T_PurchaseOrder
				--LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
				--			  SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS InvoiceAmount
				--			  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
				--				INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				--			  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
				--			  GROUP BY PIH.IDX_ReferenceNo, PIH.InvoiceNo, PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader 
				--			  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceDate, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
									 ISNULL(PID.TotalInvoice,0) AS InvoiceAmount
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
							  	LEFT JOIN (	SELECT IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount  + ISNULL(Tax,0))) AS TotalInvoice
							  				FROM ( SELECT PID.IDX_T_PurchaseInvoiceHeader, Quantity, UnitPrice, DiscountAmount, 
							  						( SELECT SUM(X.TaxAmount) 
													  FROM CM_T_PurchaseInvoiceTax X WITH(NOLOCK)
													  	INNER JOIN CM_T_PurchaseInvoiceHeader Y WITH(NOLOCK) ON X.IDX_T_PurchaseInvoiceHeader = Y.IDX_T_PurchaseInvoiceHeader 
														AND Y.InvoiceStatus = 'A'
													  WHERE X.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
													  GROUP BY X.IDX_T_PurchaseInvoiceDetail ) Tax
							  		 			   FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ) A
							  					   GROUP BY A.IDX_T_PurchaseInvoiceHeader ) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
							  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
							  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(X.SubTotalNoPPH) AS SubTotalNoPPH
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
								LEFT JOIN
									(
									SELECT	PID.IDX_T_PurchaseInvoiceDetail, PID.IDX_T_PurchaseInvoiceHeader, 
											PID.Quantity * (PID.UntaxedAmount - PID.DiscountAmount + ISNULL(AmountNoPPH.TaxAmountNoPPH,0)) as SubTotalNoPPH
									FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
									LEFT JOIN
									(
										SELECT A.IDX_T_PurchaseInvoiceDetail, SUM(A.TaxAmount) as TaxAmountNoPPH
										FROM CM_T_PurchaseInvoiceTax A WITH(NOLOCK)
											INNER JOIN GL_M_Tax B WITH(NOLOCK) on a.IDX_M_Tax = b.IDX_M_Tax
										WHERE A.RecordStatus = 'A' AND B.IsWithHoldingTax = 0
										GROUP BY A.IDX_T_PurchaseInvoiceDetail
									) AmountNoPPH ON PID.IDX_T_PurchaseInvoiceDetail = AmountNoPPH.IDX_T_PurchaseInvoiceDetail
									WHERE PID.RecordStatus = 'A' --AND PID.IDX_M_Item <> 177 --IDX 177 = Pembulatan
								) X ON PIH.IDX_T_PurchaseInvoiceHeader = X.IDX_T_PurchaseInvoiceHeader
							  WHERE PIH.ReferenceNo LIKE 'PO-%' AND PIH.InvoiceStatus = 'A' 
							  GROUP BY PIH.IDX_T_PurchaseInvoiceHeader
							  ) invnopph ON inv.IDX_T_PurchaseInvoiceHeader = invnopph.IDX_T_PurchaseInvoiceHeader
				LEFT JOIN	( SELECT FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader AS PaymentDescription, SUM(PA.AllocationAmount) as PaymentAmount
							  FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
								INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
								INNER JOIN CM_T_PaymentAllocation PA WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
							  WHERE FPH.PaymentStatus IN ('H','F') AND PA.AllocationStatus = 'A'
							  GROUP BY FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader 
							  ) pay ON inv.IDX_T_PurchaseInvoiceHeader = pay.IDX_DocumentNo
			WHERE	a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch AND a.POStatus <> 'D' AND a.PONumber LIKE 'PO-%' 
					AND a.PODate BETWEEN @StartDate AND @EndDate AND a.IDX_M_Partner = @IDX_M_Partner
			ORDER BY a.PODate
		END
		ELSE
		BEGIN
			SELECT	a.IDX_T_PurchaseOrder, a.IDX_M_Company, a.IDX_M_Branch, a.PODate, a.PONumber, a.IDX_M_Partner, b.PartnerName, a.PODescription, c.POAmount, 
					ISNULL(inv.IDX_T_PurchaseInvoiceHeader,0) AS IDX_T_PurchaseInvoiceHeader, ISNULL(inv.InvoiceDescription,'-') AS InvoiceDescription, 
					ISNULL(inv.InvoiceNo,'-') AS InvoiceNo, ISNULL(inv.InvoiceDate,'') as InvoiceDate, ISNULL(inv.InvoiceAmount,0) AS InvoiceAmount, ISNULL(invnopph.SubTotalNoPPH,0) AS InvoiceAmountNoPPH,
					ISNULL(pay.PaymentDescription,'-') AS PaymentDescription, ISNULL(pay.PaymentID,'-') AS PaymentID, ISNULL(pay.PDCNo,'-') AS PDCNo, ISNULL(pay.PaymentAmount,0) AS PaymentAmount
			FROM PR_T_PurchaseOrder a WITH(NOLOCK)
				INNER JOIN GN_M_Partner b WITH(NOLOCK) ON a.IDX_M_Partner = b.IDX_M_Partner
				INNER JOIN GN_M_Project g WITH(NOLOCK) ON a.IDX_M_Project = g.IDX_M_Project
				LEFT JOIN	( SELECT IDX_T_PurchaseOrder, SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS POAmount
							  FROM PR_T_PurchaseOrderDetail WITH(NOLOCK)
							  GROUP BY IDX_T_PurchaseOrder 
							  ) c ON a.IDX_T_PurchaseOrder = c.IDX_T_PurchaseOrder
				--LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
				--			  SUM(Quantity * (UntaxedAmount - DiscountAmount + TaxAmount)) AS InvoiceAmount
				--			  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
				--				INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				--			  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
				--			  GROUP BY PIH.IDX_ReferenceNo, PIH.InvoiceNo, PIH.IDX_T_PurchaseInvoiceHeader, PIH.RemarkHeader 
				--			  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceDate, PIH.RemarkHeader AS InvoiceDescription, PIH.InvoiceNo, PIH.IDX_ReferenceNo, 
									 ISNULL(PID.TotalInvoice,0) AS InvoiceAmount
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)	
							  	LEFT JOIN (	SELECT IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount  + ISNULL(Tax,0))) AS TotalInvoice
							  				FROM ( SELECT PID.IDX_T_PurchaseInvoiceHeader, Quantity, UnitPrice, DiscountAmount, 
							  						( SELECT SUM(X.TaxAmount) 
													  FROM CM_T_PurchaseInvoiceTax X WITH(NOLOCK)
													  	INNER JOIN CM_T_PurchaseInvoiceHeader Y WITH(NOLOCK) ON X.IDX_T_PurchaseInvoiceHeader = Y.IDX_T_PurchaseInvoiceHeader 
														AND Y.InvoiceStatus = 'A'
													  WHERE X.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
													  GROUP BY X.IDX_T_PurchaseInvoiceDetail ) Tax
							  		 			   FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ) A
							  					   GROUP BY A.IDX_T_PurchaseInvoiceHeader ) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
							  WHERE PIH.IDX_ReferenceNo <> 0 AND PIH.InvoiceStatus = 'A' AND PIH.RecordStatus = 'A'
							  ) inv ON a.IDX_T_PurchaseOrder = inv.IDX_ReferenceNo
				LEFT JOIN	( SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(X.SubTotalNoPPH) AS SubTotalNoPPH
							  FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
								LEFT JOIN
									(
									SELECT	PID.IDX_T_PurchaseInvoiceDetail, PID.IDX_T_PurchaseInvoiceHeader, 
											PID.Quantity * (PID.UntaxedAmount - PID.DiscountAmount + ISNULL(AmountNoPPH.TaxAmountNoPPH,0)) as SubTotalNoPPH
									FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK)
									LEFT JOIN
									(
										SELECT A.IDX_T_PurchaseInvoiceDetail, SUM(A.TaxAmount) as TaxAmountNoPPH
										FROM CM_T_PurchaseInvoiceTax A WITH(NOLOCK)
											INNER JOIN GL_M_Tax B WITH(NOLOCK) on a.IDX_M_Tax = b.IDX_M_Tax
										WHERE A.RecordStatus = 'A' AND B.IsWithHoldingTax = 0
										GROUP BY A.IDX_T_PurchaseInvoiceDetail
									) AmountNoPPH ON PID.IDX_T_PurchaseInvoiceDetail = AmountNoPPH.IDX_T_PurchaseInvoiceDetail
									WHERE PID.RecordStatus = 'A' --AND PID.IDX_M_Item <> 177 --IDX 177 = Pembulatan
								) X ON PIH.IDX_T_PurchaseInvoiceHeader = X.IDX_T_PurchaseInvoiceHeader
							  WHERE PIH.ReferenceNo LIKE 'PO-%' AND PIH.InvoiceStatus = 'A' 
							  GROUP BY PIH.IDX_T_PurchaseInvoiceHeader
							  ) invnopph ON inv.IDX_T_PurchaseInvoiceHeader = invnopph.IDX_T_PurchaseInvoiceHeader
				LEFT JOIN	( SELECT FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader AS PaymentDescription, SUM(PA.AllocationAmount) as PaymentAmount
							  FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
								INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
								INNER JOIN CM_T_PaymentAllocation PA WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
							  WHERE FPH.PaymentStatus IN ('H','F') AND PA.AllocationStatus = 'A'
							  GROUP BY FPH.PaymentID, FPH.PDCNo, PA.IDX_DocumentNo, FPH.RemarkHeader 
							  ) pay ON inv.IDX_T_PurchaseInvoiceHeader = pay.IDX_DocumentNo
			WHERE	a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch AND a.POStatus <> 'D' AND g.IDX_M_Project = @IDX_M_Project AND a.PONumber LIKE 'PO-%' 
					AND a.PODate BETWEEN @StartDate AND @EndDate AND a.IDX_M_Partner = @IDX_M_Partner
			ORDER BY a.PODate
		END
	END

END
