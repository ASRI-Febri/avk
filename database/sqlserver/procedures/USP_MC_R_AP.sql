
CREATE PROCEDURE [dbo].[USP_MC_R_AP]
	@IDX_M_Branch				INT,
	@IDX_M_Partner				INT,	
	@StartDate					DATE,
	@EndDate					DATE,	    
	-------------------------------------------
	@GroupBy					VARCHAR(10) = 'NOTA' -- NOTA, PARTNER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SELECT * FROM MC_M_TransactionType
	--1	BUY
	--2	SELL
	--3	PO
	--4	ADJIN
	--5	ADJOUT

	-- ============================================================
	-- TEMP TABLE TRANSACTION
	-- ============================================================
	CREATE TABLE #Transaction (
		IDX_M_Branch				BIGINT,
		IDX_T_PurchaseOrder			BIGINT,
        IDX_M_Partner               INT,
		-----------------------------------------------------------
        PartnerName					VARCHAR(150),		
		BranchID					VARCHAR(50),
		BranchName					VARCHAR(150),		
		TransactionNo				VARCHAR(50),
		TransactionDate				DATE, 
		ReferenceNo					VARCHAR(50),
		RemarkHeader				VARCHAR(1500),
		-----------------------------------------------------------
		TotalPurchaseAmount			DECIMAL(18,4),				
		------------------------------------------------------------
		PaymentCashAmount			DECIMAL(18,4),
		PaymentTransferAmount		DECIMAL(18,4),
		OutstandingAmount			DECIMAL(18,4)
	)

	-- ============================================================
	-- PAYMENT TABLE 
	-- ============================================================
	CREATE TABLE #Payment (
		AsOfDate                    DATE,
		IDX_T_PurchaseOrder			INT,        
		-----------------------------------------------------------
		CashAmount					DECIMAL(22,4),
		TransferAmount				DECIMAL(22,4)
	)
		
	-- ======================================================================================================================
	-- INSERT PEMBELIAN VALAS
	-- ======================================================================================================================
	INSERT INTO #Transaction
	SELECT S.IDX_M_Branch, S.IDX_T_PurchaseOrder, ISNULL(S.IDX_M_Partner, 0), UPPER(ISNULL(GMP.PartnerName,'')), 
		L.BranchID, L.BranchName, S.PONumber, S.PODate, S.ReferenceNo, S.PONotes, 
		--------------------------------------------------------------
		ISNULL(SOD.BaseCurrencyAmount, 0), 0, 0, 0
	FROM [dbo].MC_T_PurchaseOrder S 	
	LEFT JOIN (
		SELECT SOD.IDX_T_PurchaseOrder, SUM(BaseCurrencyAmount) AS BaseCurrencyAmount 
		FROM MC_T_PurchaseOrderDetail SOD
		WHERE SOD.RecordStatus = 'A'
		GROUP BY SOD.IDX_T_PurchaseOrder
	) SOD ON SOD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch	
	LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.PODate) BETWEEN @StartDate AND @EndDate
		AND S.POStatus = 'A'	
	ORDER BY S.PODate, PONumber

	-- ======================================================================================================================
	-- UPDATE PEMBAYARAN
	-- ======================================================================================================================
	UPDATE #Transaction SET PaymentCashAmount = PMT.PaymentAmount
	FROM (
		SELECT 			
			FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.PaymentAmount) AS PaymentAmount
		FROM CM_T_FinancialPaymentDetail FPD 
		LEFT JOIN CM_T_FinancialPaymentHeader FPH
			ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
		LEFT JOIN MC_T_PurchaseOrder MH 
			ON MH.PONumber = FPD.DocumentNo
			AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
		LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		WHERE FPH.PaymentStatus = 'A' AND FPH.PaymentStatus = 'A'
			AND FPH.IDX_M_FinancialAccount = 3 -- CASH
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT
	INNER JOIN #Transaction ON #Transaction.IDX_T_PurchaseOrder = PMT.IDX_DocumentNo AND #Transaction.TransactionNo = PMT.DocumentNo

	UPDATE #Transaction SET PaymentTransferAmount = PMT.PaymentAmount
	FROM (
		SELECT 			
			FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.PaymentAmount) AS PaymentAmount
		FROM CM_T_FinancialPaymentDetail FPD 
		INNER JOIN CM_T_FinancialPaymentHeader FPH
			ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
		INNER JOIN MC_T_PurchaseOrder MH 
			ON MH.PONumber = FPD.DocumentNo
			AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
		INNER JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		WHERE FPH.PaymentStatus = 'A' AND FPH.PaymentStatus = 'A'
			AND FPH.IDX_M_FinancialAccount <> 3 -- TRANSFER
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT
	INNER JOIN #Transaction ON #Transaction.IDX_T_PurchaseOrder = PMT.IDX_DocumentNo AND #Transaction.TransactionNo = PMT.DocumentNo

	UPDATE #Transaction SET OutstandingAmount = TotalPurchaseAmount - PaymentCashAmount - PaymentTransferAmount

	-- ======================================================================================================================
	-- OUTPUT
	-- ======================================================================================================================

	SELECT * 
	FROM #Transaction
	ORDER BY IDX_M_Branch, TransactionDate, TransactionNo
	

END
