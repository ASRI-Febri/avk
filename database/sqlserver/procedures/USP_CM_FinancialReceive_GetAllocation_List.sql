-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 07 Jun 2024
-- Description:	Get allocation list for financial receive
-- =============================================

-- USP_CM_FinancialReceive_GetAllocation_List 1, 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_GetAllocation_List]
	@IDX_M_Branch			INT,
	@IDX_M_Partner			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT a.IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, a.InvoiceNo AS DocumentNo,
	CASE WHEN ISNULL(A.TotalSalesAmount,0) > 0 
	        THEN 
	        a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,A.TotalSalesAmount) 
	        ELSE
	        a.InvoiceNo + ' - Date: ' + CONVERT(VARCHAR,CONVERT(DATE,a.InvoiceDate)) + ' - Amount: ' + CONVERT(VARCHAR,sum(DPP.DPP+TAX.TAX)) 
            END AS DocumentNo2
    FROM CM_T_SalesInvoiceHeader a WITH(NOLOCK)
        LEFT JOIN
        (
            SELECT IDX_T_SalesInvoiceHeader, IDX_T_SalesInvoiceDetail, Quantity * (UntaxedAmount - ISNULL(DiscountAmount,0)) AS DPP 
            FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
        ) DPP ON a.IDX_T_SalesInvoiceHeader = DPP.IDX_T_SalesInvoiceHeader
        LEFT JOIN
        (
            SELECT a.IDX_T_SalesInvoiceDetail, a.Quantity * SUM(ISNULL(b.TaxAmount,0)) AS TAX
            FROM CM_T_SalesInvoiceDetail a WITH(NOLOCK)
                LEFT JOIN CM_T_SalesInvoiceTax b WITH(NOLOCK) ON a.IDX_T_SalesInvoiceDetail = b.IDX_T_SalesInvoiceDetail
            GROUP BY a.IDX_T_SalesInvoiceDetail, a.Quantity
        ) TAX ON DPP.IDX_T_SalesInvoiceDetail = TAX.IDX_T_SalesInvoiceDetail
        LEFT JOIN
        (
            SELECT a.IDX_DocumentNo, a.DocumentNo, SUM(a.AllocationAmount) AS ReceiveAmount
			FROM CM_T_ReceiveAllocation a WITH(NOLOCK)
				INNER JOIN CM_T_SalesInvoiceHeader b WITH(NOLOCK) ON a.IDX_DocumentNo = b.IDX_T_SalesInvoiceHeader and a.DocumentNo = b.InvoiceNo
			GROUP BY a.IDX_DocumentNo, a.DocumentNo
        ) REVENUE ON a.IDX_T_SalesInvoiceHeader = REVENUE.IDX_DocumentNo
        WHERE a.InvoiceStatus IN ('A','F') AND a.IDX_M_Partner = @IDX_M_Partner AND a.IDX_M_Branch = @IDX_M_Branch
    GROUP BY a.IDX_T_SalesInvoiceHeader, a.InvoiceNo, a.InvoiceDate, REVENUE.ReceiveAmount, A.TotalSalesAmount
    HAVING 
        CASE WHEN ISNULL(A.TotalSalesAmount,0) > 0 
        THEN 
            A.TotalSalesAmount-ISNULL(REVENUE.ReceiveAmount,0) 
        ELSE 
            SUM(DPP.DPP+TAX.TAX)-ISNULL(REVENUE.ReceiveAmount,0) 
        END
    >1
END
