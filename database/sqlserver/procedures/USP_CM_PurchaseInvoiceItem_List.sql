/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Purchase Invoice List

/*	
	EXEC [dbo].[USP_CM_PurchaseInvoiceItem_List] 
		 1
		,10
		,'InvoiceNo'
		,'asc'
		,'R'
		,''
		,''
		,''
		,''
		,''
		
		
	EXEC [dbo].[USP_CM_PurchaseInvoiceItem_List] 
		1
		,10
		,'InvoiceNo'
		,'asc'
		,'C'
		,''
		,'test'
		,''
		,''
		
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceItem_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@InvoiceNo				VARCHAR(50),
	@RemarkDetail			VARCHAR(128),
	@ItemSKU				VARCHAR(50),
	@ItemName				VARCHAR(50),
	@InvoiceDate			VARCHAR(20)	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_InvoiceNo				AS VARCHAR(50)
	DECLARE @_RemarkDetail			AS VARCHAR(50)
	DECLARE @_ItemSKU				AS VARCHAR(50)
	DECLARE @_ItemName				AS VARCHAR(50)
	DECLARE @_InvoiceDate			AS VARCHAR(50)	
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_InvoiceNo = '%' + RTRIM(@InvoiceNo) + '%'	
	SET @_RemarkDetail = '%' + RTRIM(@RemarkDetail) + '%'
	SET @_ItemSKU = '%' + RTRIM(@ItemSKU) + '%'
	SET @_ItemName = '%' + RTRIM(@ItemName) + '%'	
	SET @_InvoiceDate = '%' + RTRIM(@InvoiceDate) + '%'		
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' PIH.IDX_T_PurchaseInvoiceHeader ' + @SortDir
		SET @_Sort2 = ' IDX_T_PurchaseInvoiceHeader ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'ItemName'
	BEGIN
		SET @_Sort1 = ' MI.Name ' + @SortDir
		SET @_Sort2 = ' MI.Name ' + @SortDir
	END		

	-- SET Paging and Row Number
	IF @Page = 1
	BEGIN
		SET @FromRow = 1
		SET @ToRow = @Row
	END

	IF @Page > 1
	BEGIN
		SET @FromRow = ((@Page * @Row) - @Row) + 1
		SET @ToRow = @FromRow + @Row - 1		
	END

	SET @SqlSelect = '	SELECT * FROM (
							SELECT 
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, 
								PID.IDX_T_PurchaseInvoiceDetail, PID.IDX_T_PurchaseInvoiceHeader, 
								PIH.InvoiceNo, CONVERT(VARCHAR,PIH.InvoiceDate,106) AS InvoiceDate, 
								MI.SKUCode, MI.Name AS ItemName, 
								PID.UnitPrice, PID.Quantity, PID.RemarkDetail, 								
								InvoiceStatus, StatusDesc = CASE InvoiceStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void'' 
								WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 					
	
	SET @SqlFrom = 'FROM CM_T_PurchaseInvoiceDetail PID
					LEFT JOIN CM_T_PurchaseInvoiceHeader PIH ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader 
					LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = PIH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
					LEFT JOIN IN_M_Item MI ON MI.IDX_M_Item = PID.IDX_M_Item '

	SET @SqlWhere = 'WHERE ISNULL(PIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
						''' AND RTRIM(ISNULL(PID.RemarkDetail,'''')) LIKE ''' + @_RemarkDetail +
						''' AND CONVERT(VARCHAR,ISNULL(PIH.InvoiceDate,''''),106) LIKE ''' + @_InvoiceDate +	
						''' AND RTRIM(ISNULL(MI.SKUCode,'''')) LIKE ''' + @_ItemSKU +					
						'''	AND RTRIM(ISNULL(MI.Name,'''')) LIKE ''' + @_ItemName + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	--SET @SqlOrder = ' ORDER BY ' + @_Sort2

	-- ==================================================
	-- Output
	-- ==================================================

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END

END








