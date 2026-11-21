-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================

-- EXEC [dbo].[USP_CM_R_SalesInvoice_ItemCategorySummary] 1 ,4 ,'2019-12-01' ,'2020-01-16' ,'' ,0 ,0
-- EXEC [dbo].[USP_CM_R_SalesInvoice_ItemCategorySummary] 1 ,4 ,'2019-12-11' ,'2020-01-17' ,'' ,0 ,0
-- EXEC [dbo].[USP_CM_R_SalesInvoice_ItemCategorySummary] 1 ,4 ,'2020-01-01' ,'2020-01-31' ,'' ,0 ,0

CREATE PROCEDURE [dbo].[USP_CM_R_SalesInvoice_ItemCategorySummary_Backup]
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
		ItemCategoryName				VARCHAR(500),
		IDX_M_Item						BIGINT,
		Quantity						DECIMAL(18,2),
		UnitPrice						DECIMAL(18,2),
		UntaxedAmount					DECIMAL(18,2),
		DiscountAmount					DECIMAL(18,2),
		TaxAmount						DECIMAL(18,2),
		----------------------------------------------------
		WeightNetto						DECIMAL(18,3),
		Amount							DECIMAL(18,3),
		NetPrice						DECIMAL(18,3)
	)

	SET @_ItemName = '%%'
	IF RTRIM(@ItemName) <> ''
		SET @_ItemName = '%' + RTRIM(@ItemName) + '%'

	SET @_SqlSelect = 'SELECT MIC.Name AS ItemCategoryName, 
		COUNT(SID.IDX_M_Item) AS IDX_M_ItemCount, SUM(SID.Quantity) AS Quantity, SUM(SID.UnitPrice) AS UnitPrice, SUM(SID.UntaxedAmount) AS UntaxedAmount, SUM(SID.DiscountAmount) AS DiscountAmount, SUM(SID.TaxAmount) AS TaxAmount, 
		SUM(SID.Quantity * MI.WeightNetto) AS WeightNetto, SUM(SID.Quantity * SID.UnitPrice) AS Amount, ( SUM(SID.Quantity * SID.UnitPrice) / SUM(SID.Quantity * MI.WeightNetto) ) AS NetPrice '
	
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
	
	SET @_SqlOrder = ' GROUP BY MIC.Name ORDER BY MIC.Name ASC '

	--PRINT (@_SqlSelect + @_SqlFrom + @_SqlWhere)

	INSERT INTO #Temp
	EXEC (@_SqlSelect + @_SqlFrom + @_SqlWhere + @_SqlOrder)

	-- =========================================================================================
	-- OUTPUT RESULT
	-- =========================================================================================
	
	SELECT * FROM #Temp 

	DROP TABLE #Temp

END


