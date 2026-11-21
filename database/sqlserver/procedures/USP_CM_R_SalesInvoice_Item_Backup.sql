-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 September 2018
-- Description:	Sales invoice item report by period
-- Mod : 2020-01-21 by Anton --> added ORDER BY ItemCategoryName
-- =============================================

-- EXEC [dbo].[USP_CM_R_SalesInvoice_Item_Backup] 1 ,4 ,'2019-06-01' ,'2019-06-21' ,'' ,0 ,0
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Item_Backup] 1 ,4 ,'2020-01-01' ,'2020-01-06' ,'' ,0 ,0
-- EXEC [dbo].[USP_CM_R_SalesInvoice_Item_Backup] 1 ,4 ,'2019-11-01' ,'2019-11-30' ,'' ,0 ,0

CREATE PROCEDURE [dbo].[USP_CM_R_SalesInvoice_Item_Backup]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			VARCHAR(10),
	@EndDate			VARCHAR(10),
	@ItemName			VARCHAR(50),
	@IDX_M_Partner		INT = 0,
	@IDX_M_Item			INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SqlSelect		VARCHAR(5000)
	DECLARE @_SqlFrom		VARCHAR(5000)
	DECLARE @_SqlWhere		VARCHAR(5000)
	DECLARE @_SqlOrder		VARCHAR(5000)

	DECLARE @_ItemName		VARCHAR(500)

	CREATE TABLE #Temp (
		IDX_T_SalesInvoiceHeader		BIGINT,
		IDX_M_DocumentType				INT,
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		InvoiceDate						DATE,
		InvoiceNo						VARCHAR(50),
		PartnerName						VARCHAR(500),
		RemarkHeader					VARCHAR(500),
		BrandName						VARCHAR(50),
		ItemCategoryName				VARCHAR(500),
		IDX_M_Item						BIGINT,
		ItemName						VARCHAR(500),
		SKUCode							VARCHAR(50),
		Quantity						DECIMAL(18,2),
		UnitPrice						DECIMAL(18,2),
		UntaxedAmount					DECIMAL(18,2),
		DiscountAmount					DECIMAL(18,2),
		TaxAmount						DECIMAL(18,2),
		----------------------------------------------------
		IDX_T_FinancialReceiveHeader	BIGINT,
		CashReceive						DECIMAL(18,2),
		BankReceive						DECIMAL(18,2),
		CardNumber						VARCHAR(50),
		BankDesc						VARCHAR(50),
		BankFee							DECIMAL(18,2),
		WeightNetto						DECIMAL(18,3)
	)

	SET @_ItemName = '%%'
	IF RTRIM(@ItemName) <> ''
		SET @_ItemName = '%' + RTRIM(@ItemName) + '%'

	SET @_SqlSelect = 'SELECT SIH.IDX_T_SalesInvoiceHeader, SIH.IDX_M_DocumentType, SIH.IDX_M_Company, SIH.IDX_M_Branch, SIH.InvoiceDate, SIH.InvoiceNo, ISNULL(GMP.PartnerName,'''') AS PartnerName, SIH.RemarkHeader, 
		MBR.Name AS BrandName, MIC.Name AS ItemCategoryName, 
		SID.IDX_M_Item, MI.Name AS ItemName, MI.SKUCode, SID.Quantity, SID.UnitPrice, SID.UntaxedAmount, SID.DiscountAmount, SID.TaxAmount, 0, 0, 0, '''', '''', 0, MI.WeightNetto '
	
	SET @_SqlFrom = ' FROM CM_T_SalesInvoiceHeader SIH 
	LEFT JOIN CM_T_SalesInvoiceDetail SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
	LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = SIH.IDX_M_Company 
	LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
	LEFT JOIN IN_M_Item MI ON MI.IDX_M_Item = SID.IDX_M_Item	
	LEFT JOIN IN_M_Brand MBR ON MBR.IDX_M_Brand = MI.IDX_M_Brand
	LEFT JOIN IN_M_ItemCategory MIC ON MIC.IDX_M_ItemCategory = MI.IDX_M_ItemCategory '

	SET @_SqlWhere = ' WHERE SIH.IDX_M_Company = ' + CONVERT(VARCHAR,@IDX_M_Company) + ' AND SIH.IDX_M_Branch = ' + CONVERT(VARCHAR,@IDX_M_Branch) + 
		' AND ISNULL(MI.Name,'''') LIKE ''' + @_ItemName + 
		''' AND CONVERT(DATE,SIH.InvoiceDate) BETWEEN ''' + @StartDate + ''' AND ''' + @EndDate + ''' AND SIH.InvoiceStatus IN (''A'',''F'') ' 

	IF @IDX_M_Partner <> 0
		SET @_SqlWhere = @_SqlWhere + ' AND SIH.IDX_M_Partner = ' + CONVERT(VARCHAR,@IDX_M_Partner)

	IF @IDX_M_Item <> 0
		SET @_SqlWhere = @_SqlWhere + ' AND SID.IDX_M_Item = ' + CONVERT(VARCHAR,@IDX_M_Item) 
	
	SET @_SqlOrder = ' ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, MI.Name, ISNULL(GMP.Name,''''), SIH.InvoiceNo '
	--SET @_SqlOrder = ' ORDER BY SIH.IDX_M_Company, SIH.IDX_M_Branch, MIC.Name, MI.Name, ISNULL(GMP.Name,''''), SIH.InvoiceNo '

	--PRINT (@_SqlSelect + @_SqlFrom + @_SqlWhere)

	INSERT INTO #Temp
	EXEC (@_SqlSelect + @_SqlFrom + @_SqlWhere)

	-- =========================================================================================
	-- UPDATE PAYMENT
	-- =========================================================================================
	UPDATE #Temp SET IDX_T_FinancialReceiveHeader = FR.IDX_T_FinancialReceiveHeader, CashReceive = ReceiveAmount FROM (
		SELECT SIH.IDX_T_SalesInvoiceHeader, FRH.IDX_T_FinancialReceiveHeader, SIH.IDX_M_DocumentType, FRH.IDX_M_PaymentType, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
		FROM CM_T_SalesInvoiceHeader SIH
		LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
		LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
		LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
		WHERE RA.AllocationStatus = 'A' AND FRH.IDX_M_PaymentType = 1
		GROUP BY SIH.IDX_T_SalesInvoiceHeader, FRH.IDX_T_FinancialReceiveHeader, SIH.IDX_M_DocumentType, FRH.IDX_M_PaymentType) FR
	INNER JOIN #Temp ON #Temp.IDX_T_SalesInvoiceHeader = FR.IDX_T_SalesInvoiceHeader
	
	UPDATE #Temp SET IDX_T_FinancialReceiveHeader = FR.IDX_T_FinancialReceiveHeader, BankReceive = ReceiveAmount FROM (
		SELECT SIH.IDX_T_SalesInvoiceHeader, FRH.IDX_T_FinancialReceiveHeader, SIH.IDX_M_DocumentType, FRH.IDX_M_PaymentType, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
		FROM CM_T_SalesInvoiceHeader SIH
		LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
		LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
		LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
		WHERE RA.AllocationStatus = 'A' AND FRH.IDX_M_PaymentType = 2
		GROUP BY SIH.IDX_T_SalesInvoiceHeader, FRH.IDX_T_FinancialReceiveHeader, SIH.IDX_M_DocumentType, FRH.IDX_M_PaymentType) FR
	INNER JOIN #Temp ON #Temp.IDX_T_SalesInvoiceHeader = FR.IDX_T_SalesInvoiceHeader

	-- =========================================================================================
	-- UPDATE CARD INFO
	-- =========================================================================================
	UPDATE #Temp SET CardNumber = C.CardNumber, BankDesc = C.CardTypeName FROM (
		SELECT IDX_T_FinancialReceiveHeader, FRH.CardNumber, ISNULL(BCP.CardPattern,'') AS CardPattern, ISNULL(BCT.Name,'') AS CardTypeName
		FROM CM_T_FinancialReceiveHeader FRH
		LEFT JOIN GN_M_BankCardPattern BCP ON BCP.CardPattern = LEFT(CardNumber,6)
		LEFT JOIN GN_M_BankCardType BCT ON BCT.IDX_M_CardType = BCP.IDX_M_CardType
		WHERE IDX_M_PaymentType = 2) C
	INNER JOIN #Temp ON #Temp.IDX_T_FinancialReceiveHeader = C.IDX_T_FinancialReceiveHeader

	-- =========================================================================================
	-- OUTPUT RESULT
	-- =========================================================================================
	
	SELECT * FROM #Temp WITH(NOLOCK)
	ORDER BY ItemCategoryName

	DROP TABLE #Temp

END


