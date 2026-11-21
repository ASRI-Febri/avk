-- ==========================================================================================
-- Author		: Anton
-- Create date	: 2024-01-15
-- Description	: Mutasi Bank / Bank Transfer Report by Period
-- ==========================================================================================

-- EXEC [dbo].[USP_CM_R_BankTransfer_Period] 14, '2024-01-01', '2024-01-31'

CREATE PROCEDURE [dbo].[USP_CM_R_BankTransfer_Period]
	@IDX_M_FinancialAccount		BIGINT,
	@StartDate					DATE,
	@EndDate					DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @StartPeriod VARCHAR(6) = left(CONVERT(VARCHAR,@StartDate,112),6)
	DECLARE @MonthPeriod VARCHAR(2) = RIGHT(@StartPeriod,2)
	DECLARE @BeforeStartPeriod VARCHAR(6) = left(CONVERT(VARCHAR,DATEADD(M,-1,@StartDate),112),6) 
	DECLARE @IDX_GC BIGINT = (SELECT IDX_M_Company FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount)
	DECLARE @IDX_COA BIGINT = (SELECT IDX_M_COA FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount)
	DECLARE @FA_Desc VARCHAR(100) = (SELECT FinancialAccountDesc FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount)

	--SELECT @StartPeriod SELECT @MonthPeriod SELECT @BeforeStartPeriod

	CREATE TABLE #Report	(
		Counting				INT, -- 0 = Saldo Awal, 1 = Transaction 	
		IDX_Trans				BIGINT,
		IDX_FA					BIGINT,
		TransType				VARCHAR(50),
		TransDate				DATE,
		PostedDate				DATE,
		VoucherNo				VARCHAR(100),
		TransStatus				VARCHAR(50),
		Debet					DECIMAL(22,2),
		Credit					DECIMAL(22,2),
		Balance					DECIMAL(22,2),
		Remarks					VARCHAR(1000),
		URLTransaction			VARCHAR(500)
	)

	INSERT INTO #Report
	SELECT	1 AS Counting, fph.IDX_T_FinancialPaymentHeader, fph.IDX_M_FinancialAccount, 'PAYMENT' AS TransType, CONVERT(DATE,fph.PaymentDate) AS TransDate,
			ISNULL(CONVERT(DATE,fph.ValidationDate),'') AS PostedDate, fph.PaymentID AS VoucherNo, 
			CASE fph.PaymentStatus WHEN 'D' THEN 'DRAFT' WHEN 'A' THEN 'APPROVED' WHEN 'F' THEN 'VALIDATE' END AS TransStatus, 
			0 AS Debet, fph.PaymentAmount AS Credit, 0, UPPER(fph.RemarkHeader) AS Description, 
			('fm-financial-payment/update/' + CONVERT(VARCHAR, fph.IDX_T_FinancialPaymentHeader)) AS URLTransaction
	FROM CM_T_FinancialPaymentHeader fph WITH(NOLOCK)
	WHERE fph.IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND CONVERT(DATE,fph.PaymentDate) BETWEEN @StartDate AND @EndDate AND fph.PaymentStatus <> 'V'
	UNION ALL
	SELECT	1, fph.IDX_T_FinancialReceiveHeader, fph.IDX_M_FinancialAccount, 'RECEIVE' AS TransType, CONVERT(DATE,fph.ReceiveDate) AS TransDate,
			ISNULL(CONVERT(DATE,fph.ApprovalDate),''),fph.ReceiveID, 
			CASE fph.ReceiveStatus WHEN 'D' THEN 'DRAFT' WHEN 'A' THEN 'VALIDATE' END AS TransStatus, 
			fph.ReceiveAmount, 0, 0, UPPER(fph.RemarkHeader), 
			('fm-financial-receive/update/' + CONVERT(VARCHAR, fph.IDX_T_FinancialReceiveHeader)) AS URLTransaction
	FROM CM_T_FinancialReceiveHeader fph WITH(NOLOCK)
	WHERE fph.IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND CONVERT(DATE,fph.ReceiveDate) BETWEEN @StartDate AND @EndDate AND fph.ReceiveStatus <> 'V'
	ORDER BY TransDate

	--SELECT * FROM #Report

	INSERT INTO #Report
	SELECT 0, 0, @IDX_M_FinancialAccount, 'BALANCE', '1900-01-01', '1900-01-01', '', '', 0, 0, 0, 'BEGINNING BALANCE','#'

	--SELECT * FROM #Report

	UPDATE #Report SET Balance = (SELECT BEndingBalance 
								  FROM GL_T_AccountBalance WITH(NOLOCK) 
								  WHERE JournalPeriod = @BeforeStartPeriod AND IDX_M_Company = @IDX_GC AND IDX_M_COA = @IDX_COA) 
	WHERE Counting = 0

	UPDATE #Report SET Balance = Debet - Credit WHERE Counting <> 0

	SELECT Counting, IDX_FA, @FA_Desc AS FA_Desc, TransType, TransDate, PostedDate, VoucherNo, TransStatus, Debet, Credit, Balance, Remarks, URLTransaction
	FROM #Report 
	ORDER BY Counting, TransDate, TransType

	DROP TABLE #Report

END


