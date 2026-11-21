-- =============================================
-- Author		: Anton
-- Create date	: 2021-11-24
-- Description	: Report Cashflow Finance

-- EXEC [dbo].[USP_CM_R_Cashflow] 1, 1, '2021-01-01', '2021-12-31'
-- =============================================

CREATE PROCEDURE [dbo].[USP_CM_R_Cashflow]
	@IDX_M_Company		BIGINT,
	@IDX_M_Branch		BIGINT,
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN

	SET NOCOUNT ON;

	IF @IDX_M_Company = 0 OR @IDX_M_Company = NULL 
	BEGIN
		SET @IDX_M_Company = 1
	END

	IF @IDX_M_Branch = 0 OR @IDX_M_Branch = NULL
	BEGIN
		SET @IDX_M_Branch = 1
	END

	DECLARE @StartPeriod	VARCHAR(6)	= LEFT(CONVERT(VARCHAR,@StartDate,112),6)
	DECLARE @EndPeriod		VARCHAR(6)	= LEFT(CONVERT(VARCHAR,@EndDate,112),6)
	
	CREATE TABLE #Cashflow
	(
		Seq VARCHAR(10),
		CashflowPeriod VARCHAR(6),
		CashflowID VARCHAR(10),
		CashflowDesc VARCHAR(500),
		Amount MONEY
	)

	INSERT INTO #Cashflow
		SELECT
			NULL,
			SUBSTRING(CONVERT(VARCHAR,a.PostingDate,112),5,2) AS ValidatePeriod,
			CASE WHEN b.ODebetAmount = 0 and b.OCreditAmount > 0 THEN ISNULL(cfin.CashflowID,'-')
				 WHEN b.ODebetAmount > 0 and b.OCreditAmount = 0 THEN ISNULL(cfout.CashflowID,'-')
			END AS CashflowID,
			CASE WHEN b.ODebetAmount = 0 and b.OCreditAmount > 0 THEN ISNULL(cfin.CashflowDesc,'UN-MAPPED')
				 WHEN b.ODebetAmount > 0 and b.OCreditAmount = 0 THEN ISNULL(cfout.CashflowDesc,'UN-MAPPED')
			END AS CashflowDesc,
			CASE WHEN b.ODebetAmount > 0 then b.ODebetAmount else b.OCreditAmount
			END AS [Amount]
		FROM GL_T_JournalHeader a WITH(NOLOCK)
		LEFT JOIN GL_T_JournalDetail b WITH(NOLOCK) ON a.IDX_T_JournalHeader = b.IDX_T_JournalHeader
		LEFT JOIN GL_M_COA c WITH(NOLOCK) ON b.IDX_M_COA = c.IDX_M_COA
		LEFT JOIN CM_M_FinancialAccount bank WITH(NOLOCK) ON b.IDX_M_COA = bank.IDX_M_COA
		LEFT JOIN CM_M_CashflowID cfout WITH(NOLOCK) ON c.IDX_M_CashflowOut = cfout.IDX_M_CashflowID
		LEFT JOIN CM_M_CashflowID cfin WITH(NOLOCK) ON c.IDX_M_CashflowIn = cfin.IDX_M_CashflowID
		WHERE	a.IDX_M_JournalType in (6,7) AND CONVERT(DATE,a.PostingDate) BETWEEN @StartDate AND @EndDate
				AND a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch
				AND bank.IDX_M_FinancialAccount IS NULL AND a.PostingStatus = 'P' AND a.RecordStatus = 'A' AND b.RecordStatus = 'A'
		ORDER BY a.PostingDate, a.VoucherNo

	--INSERT INTO #Cashflow
	--	SELECT
	--		NULL,
	--		SUBSTRING(CONVERT(VARCHAR,a.ValidationDate,112),5,2) AS ValidatePeriod,
	--		CASE WHEN b.PaymentAmount > 0 THEN ISNULL(cfout.CashflowID,'-') ELSE ISNULL(cfin.CashflowID,'-') END AS CashflowID,
	--		CASE WHEN b.PaymentAmount > 0 THEN ISNULL(cfout.CashflowDesc,'UN-MAPPED') ELSE ISNULL(cfin.CashflowDesc,'UN-MAPPED') END AS CashflowDesc,
	--		b.PaymentAmount
	--	FROM CM_T_FinancialPaymentHeader a WITH(NOLOCK)
	--		LEFT JOIN CM_T_FinancialPaymentDetail b WITH(NOLOCK) ON a.IDX_T_FinancialPaymentHeader = b.IDX_T_FinancialPaymentHeader
	--		LEFT JOIN GL_M_COA c WITH(NOLOCK) ON b.COADetail = c.IDX_M_COA
	--		LEFT JOIN CM_M_CashflowID cfout WITH(NOLOCK) ON c.IDX_M_CashflowOut = cfout.IDX_M_CashflowID
	--		LEFT JOIN CM_M_CashflowID cfin WITH(NOLOCK) ON c.IDX_M_CashflowIn = cfin.IDX_M_CashflowID
	--	WHERE CONVERT(DATE,a.ValidationDate) BETWEEN @StartDate AND @EndDate AND a.PaymentStatus = 'F' AND b.IDX_DocumentNo = 0 
	--		AND a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch
	--	ORDER BY a.ValidationDate, a.PaymentID

	--INSERT INTO #Cashflow
	--	SELECT
	--		NULL,
	--		SUBSTRING(CONVERT(VARCHAR,a.ApprovalDate,112),5,2) AS ValidatePeriod,
	--		CASE WHEN b.ReceiveAmount > 0 THEN ISNULL(cfin.CashflowID,'-') ELSE ISNULL(cfout.CashflowID,'-') END AS CashflowID,
	--		CASE WHEN b.ReceiveAmount > 0 THEN ISNULL(cfin.CashflowDesc,'UN-MAPPED') ELSE ISNULL(cfout.CashflowDesc,'UN-MAPPED') END AS CashflowDesc,
	--		b.ReceiveAmount
	--	FROM CM_T_FinancialReceiveHeader a WITH(NOLOCK)
	--		LEFT JOIN CM_T_FinancialReceiveDetail b WITH(NOLOCK) ON a.IDX_T_FinancialReceiveHeader = b.IDX_T_FinancialReceiveHeader
	--		LEFT JOIN GL_M_COA c WITH(NOLOCK) ON b.COADetail = c.IDX_M_COA
	--		LEFT JOIN CM_M_CashflowID cfout WITH(NOLOCK) ON c.IDX_M_CashflowOut = cfout.IDX_M_CashflowID
	--		LEFT JOIN CM_M_CashflowID cfin WITH(NOLOCK) ON c.IDX_M_CashflowIn = cfin.IDX_M_CashflowID
	--	WHERE CONVERT(DATE,a.ApprovalDate) BETWEEN @StartDate AND @EndDate and a.ReceiveStatus = 'A' and b.IDX_DocumentNo = 0
	--		AND a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch
	--	ORDER BY a.ApprovalDate, a.ReceiveID

	--INSERT INTO #Cashflow
	--	SELECT 
	--		NULL,
	--		SUBSTRING(CONVERT(VARCHAR,a.ValidationDate,112),5,2) AS ValidatePeriod,
	--		CASE WHEN (e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) >= 0 THEN ISNULL(cfout.CashflowID,'-') ELSE ISNULL(cfin.CashflowID,'-') END AS CashflowID,
	--		CASE WHEN (e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) >= 0 THEN ISNULL(cfout.CashflowDesc,'UN-MAPPED') ELSE ISNULL(cfin.CashflowDesc,'UN-MAPPED') END AS CashflowDesc,
	--		(e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) AS InvoiceAmount
	--	FROM CM_T_FinancialPaymentHeader a WITH(NOLOCK)
	--		LEFT JOIN CM_T_FinancialPaymentDetail b WITH(NOLOCK) ON a.IDX_T_FinancialPaymentHeader = b.IDX_T_FinancialPaymentHeader
	--		LEFT JOIN CM_T_PurchaseInvoiceHeader d WITH(NOLOCK) ON b.IDX_DocumentNo = d.IDX_T_PurchaseInvoiceHeader
	--		LEFT JOIN CM_T_PurchaseInvoiceDetail e WITH(NOLOCK) ON d.IDX_T_PurchaseInvoiceHeader = e.IDX_T_PurchaseInvoiceHeader
	--		LEFT JOIN GL_M_COA c WITH(NOLOCK) ON e.IDX_M_COA = c.IDX_M_COA
	--		LEFT JOIN CM_M_CashflowID cfout WITH(NOLOCK) ON c.IDX_M_CashflowOut = cfout.IDX_M_CashflowID
	--		LEFT JOIN CM_M_CashflowID cfin WITH(NOLOCK) ON c.IDX_M_CashflowIn = cfin.IDX_M_CashflowID
	--	WHERE CONVERT(DATE,a.ValidationDate) BETWEEN @StartDate AND @EndDate and a.PaymentStatus = 'F' and b.IDX_DocumentNo <> 0
	--		AND a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch
	--	ORDER BY a.ValidationDate, a.PaymentID

	--INSERT INTO #Cashflow
	--	SELECT 
	--		NULL,
	--		SUBSTRING(CONVERT(VARCHAR,a.ApprovalDate,112),5,2) AS ValidatePeriod,
	--		CASE WHEN (e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) >= 0 THEN ISNULL(cfin.CashflowID,'-') ELSE ISNULL(cfout.CashflowID,'-') END AS CashflowID,
	--		CASE WHEN (e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) >= 0 THEN ISNULL(cfin.CashflowDesc,'UN-MAPPED') ELSE ISNULL(cfout.CashflowDesc,'UN-MAPPED') END AS CashflowDesc,
	--		(e.Quantity*(e.UntaxedAmount+e.TaxAmount-e.DiscountAmount)) AS InvoiceAmount
	--	FROM CM_T_FinancialReceiveHeader a WITH(NOLOCK)
	--		LEFT JOIN CM_T_FinancialReceiveDetail b WITH(NOLOCK) ON a.IDX_T_FinancialReceiveHeader = b.IDX_T_FinancialReceiveHeader
	--		LEFT JOIN CM_T_SalesInvoiceHeader d WITH(NOLOCK) ON b.IDX_DocumentNo = d.IDX_T_SalesInvoiceHeader
	--		LEFT JOIN CM_T_SalesInvoiceDetail e WITH(NOLOCK) ON d.IDX_T_SalesInvoiceHeader = e.IDX_T_SalesInvoiceHeader
	--		LEFT JOIN GL_M_COA c WITH(NOLOCK) ON e.IDX_M_COA = c.IDX_M_COA
	--		LEFT JOIN CM_M_CashflowID cfout WITH(NOLOCK) ON c.IDX_M_CashflowOut = cfout.IDX_M_CashflowID
	--		LEFT JOIN CM_M_CashflowID cfin WITH(NOLOCK) ON c.IDX_M_CashflowIn = cfin.IDX_M_CashflowID
	--	WHERE CONVERT(DATE,a.ApprovalDate) BETWEEN @StartDate AND @EndDate and a.ReceiveStatus = 'A' and b.IDX_DocumentNo <> 0
	--		AND a.IDX_M_Company = @IDX_M_Company AND a.IDX_M_Branch = @IDX_M_Branch
	--	ORDER BY a.ApprovalDate, a.ReceiveID

	UPDATE #Cashflow SET Seq = '0.1' WHERE CashflowID = '-'
	UPDATE #Cashflow SET Seq = LEFT(CashflowID,4) WHERE CashflowID <> '-'

	INSERT INTO #Cashflow
		SELECT CASE WHEN LEFT(a.CashflowID,1) = '1' THEN '1.00' ELSE '2.00' END AS Seq,
			   a.CashflowPeriod,
			   CASE WHEN LEFT(a.CashflowID,1) = '1' THEN '1.00.00' ELSE '2.00.00' END AS CashflowID,
			   CASE WHEN LEFT(a.CashflowID,1) = '1' THEN 'PENERIMAAN' ELSE 'PENERIMAAN LAIN' END AS CashflowDesc,
			   SUM(ABS(a.Amount)) AS Amount
		FROM #Cashflow a WITH(NOLOCK)
			INNER JOIN CM_M_CashflowID b WITH(NOLOCK) ON a.CashflowID = b.CashflowID
		WHERE b.InFlag = 1
		GROUP BY LEFT(a.CashflowID,1), a.CashflowPeriod

	INSERT INTO #Cashflow
		SELECT CASE LEFT(a.CashflowID,1) WHEN '3' THEN '3.00' WHEN '4' THEN '4.00' WHEN '5' THEN '5.00' WHEN '6' THEN '6.00' WHEN '7' THEN '7.00' ELSE '8.00' END AS Seq,
			   a.CashflowPeriod,
			   CASE LEFT(a.CashflowID,1) WHEN '3' THEN '3.00.00' WHEN '4' THEN '4.00.00' WHEN '5' THEN '5.00.00' WHEN '6' THEN '6.00.00' 
										 WHEN '7' THEN '7.00.00' ELSE '8.00.00' END AS CashflowID,
			   CASE LEFT(a.CashflowID,1) WHEN '3' THEN 'BIAYA POKOK' WHEN '4' THEN 'BIAYA PROYEK' WHEN '5' THEN 'BIAYA OPERASIONAL' WHEN '6' THEN 'BIAYA PAJAK' 
										 WHEN '7' THEN 'BIAYA CIBODAS' ELSE 'BIAYA LAINNYA' END AS CashflowDesc,
			   SUM(ABS(a.Amount)) AS Amount
		FROM #Cashflow a WITH(NOLOCK)
			INNER JOIN CM_M_CashflowID b WITH(NOLOCK) ON a.CashflowID = b.CashflowID
		WHERE b.OutFlag = 1
		GROUP BY LEFT(a.CashflowID,1), a.CashflowPeriod

	INSERT INTO #Cashflow
		SELECT '2.9', CashflowPeriod, '-', 'Total IN', SUM(ABS(Amount)) AS Amount
		FROM #Cashflow WITH(NOLOCK)
		WHERE LEFT(Seq,1) < '3' and Seq not in ('0.1','1.00','2.00')
		GROUP BY CashflowPeriod
		ORDER BY CashflowPeriod

	INSERT INTO #Cashflow
		SELECT '8.9', CashflowPeriod, '-', 'Total OUT', SUM(ABS(Amount)) AS Amount
		FROM #Cashflow WITH(NOLOCK)
		WHERE LEFT(Seq,1) > '2' and Seq not in ('3.00','4.00','5.00','6.00','7.00','8.00')
		GROUP BY CashflowPeriod
		ORDER BY CashflowPeriod

	CREATE TABLE #InOut
	(
		Seq VARCHAR(10),
		CashflowPeriod VARCHAR(6),
		AmountIn MONEY,
		AmountOut MONEY,
		InMinusOut MONEY
	)

	INSERT INTO #InOut
		SELECT '9.0', CashflowPeriod, Amount, NULL, NULL
		FROM #Cashflow WITH(NOLOCK)
		WHERE Seq in ('2.9') 
		ORDER BY CashflowPeriod

	UPDATE b SET b.AmountOut = a.Amount
	FROM #Cashflow a WITH(NOLOCK)
		INNER JOIN #InOut b WITH(NOLOCK) ON a.CashflowPeriod = b.CashflowPeriod
	WHERE a.Seq in ('8.9') 

	UPDATE #InOut SET InMinusOut = AmountIn - AmountOut

	INSERT INTO #Cashflow
		SELECT Seq, CashflowPeriod, '-', 'Total IN-OUT', InMinusOut
		FROM #InOut WITH(NOLOCK)
		ORDER BY CashflowPeriod

	SELECT	Seq, CashflowID, CashflowDesc,
		ISNULL([01],0) AS Januari, 
		ISNULL([02],0) AS Februari, 
		ISNULL([03],0) AS Maret, 
		ISNULL([04],0) AS April, 
		ISNULL([05],0) AS Mei, 
		ISNULL([06],0) AS Juni, 
		ISNULL([07],0) AS Juli, 
		ISNULL([08],0) AS Agustus, 
		ISNULL([09],0) AS September, 
		ISNULL([10],0) AS Oktober, 
		ISNULL([11],0) AS November, 
		ISNULL([12],0) AS Desember
	FROM
	(
		SELECT	Seq, CashflowID, CashflowDesc, 
				CashflowPeriod, 
				CASE WHEN Seq <> '9.0' THEN SUM(ABS(Amount)) ELSE (SUM(Amount)) END AS Amount
		FROM #Cashflow WITH(NOLOCK)
		GROUP BY Seq, CashflowID, CashflowDesc, CashflowPeriod
	) AS SourceTable PIVOT(SUM(Amount) FOR CashflowPeriod IN ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],[11],[12])) AS PivotTable
	ORDER BY Seq, CashflowID

	DROP TABLE #InOut
	DROP TABLE #Cashflow
	
END
