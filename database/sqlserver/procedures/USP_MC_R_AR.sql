
CREATE PROCEDURE [dbo].[USP_MC_R_AR]
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
		IDX_T_SalesOrder			BIGINT,
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
		TotalSalesAmount			DECIMAL(18,4),				
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
		IDX_T_SalesOrder			INT,        
		-----------------------------------------------------------
		CashAmount					DECIMAL(22,4),
		TransferAmount				DECIMAL(22,4)
	)
		
	-- ======================================================================================================================
	-- INSERT PENJUALAN VALAS
	-- ======================================================================================================================
	INSERT INTO #Transaction
	SELECT S.IDX_M_Branch, S.IDX_T_SalesOrder, ISNULL(S.IDX_M_Partner, 0), UPPER(ISNULL(GMP.PartnerName,'')), 
		L.BranchID, L.BranchName, S.SONumber, S.SODate, S.ReferenceNo, S.SONotes, 
		--------------------------------------------------------------
		ISNULL(SOD.BaseCurrencyAmount, 0), 0, 0, 0
	FROM [dbo].MC_T_SalesOrder S 	
	LEFT JOIN (
		SELECT SOD.IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS BaseCurrencyAmount 
		FROM MC_T_SalesOrderDetail SOD
		WHERE SOD.RecordStatus = 'A'
		GROUP BY SOD.IDX_T_SalesOrder
	) SOD ON SOD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
	LEFT JOIN GN_M_Branch L ON L.IDX_M_Branch = S.IDX_M_Branch	
	LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = S.IDX_M_Partner
	WHERE S.IDX_M_Branch = @IDX_M_Branch AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate
		AND S.SOStatus = 'A'	
	ORDER BY S.SODate, SONumber

	-- ======================================================================================================================
	-- UPDATE PEMBAYARAN
	-- ======================================================================================================================
	UPDATE #Transaction SET PaymentCashAmount = PMT.ReceiveAmount
	FROM (
		SELECT 			
			FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.ReceiveAmount) AS ReceiveAmount
		FROM CM_T_FinancialReceiveDetail FPD 
		INNER JOIN CM_T_FinancialReceiveHeader FPH
			ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
		INNER JOIN MC_T_SalesOrder MH 
			ON MH.SONumber = FPD.DocumentNo
			AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
		INNER JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		WHERE FPH.ReceiveStatus = 'A' AND FPH.ReceiveStatus = 'A'
			AND FPH.IDX_M_FinancialAccount = 3 -- CASH
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT
	INNER JOIN #Transaction ON #Transaction.IDX_T_SalesOrder = PMT.IDX_DocumentNo AND #Transaction.TransactionNo = PMT.DocumentNo

	UPDATE #Transaction SET PaymentTransferAmount = PMT.ReceiveAmount
	FROM (
		SELECT 			
			FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.ReceiveAmount) AS ReceiveAmount
		FROM CM_T_FinancialReceiveDetail FPD 
		INNER JOIN CM_T_FinancialReceiveHeader FPH
			ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
		INNER JOIN MC_T_SalesOrder MH 
			ON MH.SONumber = FPD.DocumentNo
			AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
		INNER JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
		WHERE FPH.ReceiveStatus = 'A' AND FPH.ReceiveStatus = 'A'
			AND FPH.IDX_M_FinancialAccount <> 3 -- TRANSFER
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT
	INNER JOIN #Transaction ON #Transaction.IDX_T_SalesOrder = PMT.IDX_DocumentNo AND #Transaction.TransactionNo = PMT.DocumentNo

	UPDATE #Transaction SET OutstandingAmount = TotalSalesAmount - PaymentCashAmount - PaymentTransferAmount

	-- ======================================================================================================================
	-- OUTPUT
	-- ======================================================================================================================

	SELECT * FROM #Transaction
	ORDER BY TransactionDate, TransactionNo
	

END
