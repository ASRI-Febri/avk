-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================

-- EXEC [dbo].[USP_CM_R_SalesInvoice_DetailBySalesPersonSummary] 1, 4, 11, '2019-12-01', '2019-12-31'

CREATE PROCEDURE [dbo].[USP_CM_R_SalesInvoice_DetailBySalesPersonSummary_Backup]
	@IDX_M_Company				INT,
	@IDX_M_Branch				INT,
	@IDX_SalesPerson			BIGINT,
	@StartDate					DATE, 
	@EndDate					DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SqlSelect			VARCHAR(5000)
	DECLARE @_SqlFrom			VARCHAR(5000)
	DECLARE @_SqlWhere			VARCHAR(5000)
	DECLARE @_SqlGroup			VARCHAR(5000)
	DECLARE @_SqlOrder			VARCHAR(5000)

	DECLARE @_IDX_M_Branch		VARCHAR(30)

	-- BRANCH
	IF (@IDX_M_Branch = '' OR @IDX_M_Branch = 0)
	BEGIN
		SET @_IDX_M_Branch = ''
	END
	ELSE
	BEGIN
		SET @_IDX_M_Branch = ''' AND SIH.IDX_M_Branch = ''' + CAST(@IDX_M_Branch AS VARCHAR(30))
	END


	CREATE TABLE #Temp (
		SalesPersonName					VARCHAR(500),
		ItemCategoryName				VARCHAR(500),
		Quantity						DECIMAL(18,2),
		WeightNetto						DECIMAL(18,3),
		Amount							DECIMAL(18,3),
		NetPrice						DECIMAL(18,3)
	)


	SET @_SqlSelect = 'SELECT SP.SalesPersonName, MIC.Name AS ItemCategoryName, SUM(SID.Quantity) AS Quantity, 
		SUM(SID.Quantity * MI.WeightNetto) AS WeightNetto, SUM(SID.Quantity * SID.UnitPrice) AS Amount, ( SUM(SID.Quantity * SID.UnitPrice) / SUM(SID.Quantity * MI.WeightNetto) ) AS NetPrice '
	
	SET @_SqlFrom = ' FROM CM_T_SalesInvoiceHeader SIH WITH (NOLOCK)
		LEFT JOIN GN_M_Partner P WITH (NOLOCK) ON SIH.IDX_M_Partner = P.IDX_M_Partner
		LEFT JOIN GN_M_SalesPerson SP WITH (NOLOCK) ON SIH.IDX_M_SalesPerson = SP.IDX_M_SalesPerson
		LEFT JOIN CM_T_SalesInvoiceDetail SID WITH (NOLOCK) ON SIH.IDX_T_SalesInvoiceHeader = SID.IDX_T_SalesInvoiceHeader
		LEFT JOIN IN_M_Item MI WITH (NOLOCK) ON SID.IDX_M_Item = MI.IDX_M_Item
		LEFT JOIN IN_M_UoM U WITH (NOLOCK) ON MI.IDX_M_UoM = U.IDX_M_UoM 
		LEFT JOIN IN_M_ItemCategory MIC ON MIC.IDX_M_ItemCategory = MI.IDX_M_ItemCategory '

	SET @_SqlWhere = ' WHERE SIH.RecordStatus = ''A'' AND SIH.InvoiceStatus = ''A'' AND SIH.IDX_M_SalesPerson = ''' + 
		CAST(@IDX_SalesPerson AS VARCHAR(30)) + ''' AND SIH.ApprovedDate BETWEEN ''' + CAST(@StartDate AS VARCHAR(30)) + ''' AND ''' + CAST(@EndDate AS VARCHAR(30)) + @_IDX_M_Branch + ''' '
	
	SET @_SqlGroup = ' GROUP BY SP.SalesPersonName, MIC.Name '

	SET @_SqlOrder = ' ORDER BY SP.SalesPersonName ASC '

	--PRINT (@_SqlSelect + @_SqlFrom + @_SqlWhere)

	INSERT INTO #Temp
	EXEC (@_SqlSelect + @_SqlFrom + @_SqlWhere + @_SqlGroup + @_SqlOrder)

	-- =========================================================================================
	-- OUTPUT RESULT
	-- =========================================================================================
	
	SELECT * FROM #Temp 

	DROP TABLE #Temp

END


