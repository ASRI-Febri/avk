/* =============================================

USP_CM_SalesInvoice_SalesRefund_OWN_List
Author			: Deva
Create date		: 27 Desember 2019
Description		: Sales Invoice especially for Sales Refund Show_Lookup (m_select_sales_invoice_list) List

/*	

	EXEC [PralonDB].[dbo].[USP_CM_SalesInvoice_SalesRefund_OWN_List] 
		 1
		,10
		,'InvoiceNo'
		,'asc'
		,'R'

		,1
		,0
		,1
		,'A'

		,''
		,''
		,''
		,''
		,''
		,''
		,''
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_SalesRefund_OWN_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	

	@FilterCompany			VARCHAR(20), --FOR SPECIFIC COMPANY. '' = ALLSTATUS
	@FilterBranch			VARCHAR(20), --FOR SPECIFIC BRANCH. '' = ALLSTATUS
	@FilterPartner			VARCHAR(20), --FOR SPECIFIC CUSTOMER/PARTNER. '' = ALLSTATUS
	@FilterStatus			CHAR(1), --FOR SPECIFIC RECEIVE STATUS. '' = ALLSTATUS
	------------------------------------------------------------------------------
	@InvoiceNo				VARCHAR(50),
	@PartnerName			VARCHAR(50),
	@PartnerAddress			VARCHAR(5000),
	@InvoiceDate			VARCHAR(20),
	@InvoiceDueDate			VARCHAR(20),
	@RemarkHeader			VARCHAR(128),
	@TotalInvoice			VARCHAR(20)
	
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
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_PartnerAddress		AS VARCHAR(50)
	DECLARE @_InvoiceDate			AS VARCHAR(5000)
	DECLARE @_InvoiceDueDate		AS VARCHAR(50)
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	DECLARE @_TotalInvoice			AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)
	-------------------------------------------------------------
	DECLARE @_FilterCompany			AS VARCHAR(5000) --FOR SPECIFIC Company
	DECLARE @_FilterBranch			AS VARCHAR(5000) --FOR SPECIFIC Branch
	DECLARE @_FilterPartner			AS VARCHAR(5000) --FOR SPECIFIC CUSTOMER/PARTNER
	DECLARE @_FilterStatus			AS VARCHAR(5000) --FOR SPECIFIC RECEIVE STATUS

	SET @_InvoiceNo			= '%' + RTRIM(@InvoiceNo) + '%'	
	SET @_PartnerName		= '%' + RTRIM(@PartnerName) + '%'
	SET @_PartnerAddress	= '%' + RTRIM(@PartnerAddress) + '%'	
	SET @_InvoiceDate		= '%' + RTRIM(@InvoiceDate) + '%'	
	SET @_InvoiceDueDate	= '%' + RTRIM(@InvoiceDueDate) + '%'	
	SET @_RemarkHeader		= '%' + RTRIM(@RemarkHeader) + '%'
	SET @_TotalInvoice		= '%' + RTRIM(@TotalInvoice) + '%'


	-- FILTER COMPANY
	IF @FilterCompany = '' OR @FilterCompany = 0
	BEGIN
		SET @_FilterCompany = ''
	END
	ELSE
	BEGIN
		SET @_FilterCompany = ''' AND SIH.IDX_M_Company = ''' + @FilterCompany
	END


	-- FILTER BRANCH
	IF @FilterBranch = '' OR @FilterBranch = 0
	BEGIN
		SET @_FilterBranch = ''
	END
	ELSE
	BEGIN
		SET @_FilterBranch = ''' AND SIH.IDX_M_Branch = ''' + @FilterBranch
	END


	-- FILTER PARTNER
	IF @FilterPartner = '' OR @FilterPartner = 0
	BEGIN
		SET @_FilterPartner = ''
	END
	ELSE
	BEGIN
		SET @_FilterPartner = ''' AND SIH.IDX_M_Partner = ''' + @FilterPartner
	END


	-- FILTER STATUS
	IF @FilterStatus = ''
	BEGIN
		SET @_FilterStatus = ''
	END
	ELSE
	BEGIN
		SET @_FilterStatus = ''' AND InvoiceStatus = ''' + @FilterStatus
	END
			

	IF @TotalInvoice = ''
	BEGIN
		SET @_TotalInvoice	 = '%' + CONVERT(VARCHAR,@TotalInvoice) + '%'
	END
	ELSE
	BEGIN
		SET @_TotalInvoice	 = CONVERT(VARCHAR,@TotalInvoice)
	END

	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' SIH.IDX_T_SalesInvoiceHeader ' + @SortDir
		SET @_Sort2 = ' IDX_T_SalesInvoiceHeader ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'PartnerName'
	BEGIN
		SET @_Sort1 = ' GMP.PartnerName ' + @SortDir
		SET @_Sort2 = ' GMP.PartnerName ' + @SortDir
	END		

	IF RTRIM(@SortBy) = 'PartnerAddress'
	BEGIN
		SET @_Sort1 = ' GMPA.Street ' + @SortDir
		SET @_Sort2 = ' GMPA.Street ' + @SortDir
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
								SIH.IDX_M_Company, GC.Name AS CompanyName, SIH.IDX_M_Branch, GMB.BranchName, SIH.IDX_T_SalesInvoiceHeader, SIH.InvoiceNo, SIH.ReferenceNo, SIH.TaxInvoiceNo, 
								SIH.IDX_M_Partner, ISNULL(GMP.PartnerID,'''') AS PartnerID, ISNULL(GMP.PartnerName,'''') AS PartnerName, ISNULL(GMPA.Street,'''') AS PartnerAddress, CONVERT(VARCHAR,SIH.InvoiceDate,23) AS InvoiceDate, 
								CONVERT(VARCHAR,SIH.InvoiceDueDate,23) AS InvoiceDueDate, RemarkHeader, SID.TotalInvoice, FR.ReceiveAmount, 
								SIH.IDX_M_Currency, GMC.Name AS CurrencyName, SIH.IDX_M_LocationInventory, MLI.Name AS LocationInventoryName, SIH.IDX_M_DocumentType, MDT.DocumentTypeDesc,
								SIH.IDX_M_SalesPerson, MSP.SalesPersonID, MSP.SalesPersonName, SIH.COAHeader, MCU.COAID, MCU.COADesc,
								InvoiceStatus, 
								StatusDesc = CASE InvoiceStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void'' 
								WHEN ''C'' THEN ''Cancel'' WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 							
	
	CREATE TABLE #SUMInvoice
	(IDX_T_SalesInvoiceHeader BIGINT, TotalInvoice DECIMAL(20,3))

	EXEC
	('
		INSERT INTO #SUMInvoice
			SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount + TaxAmount)) AS TotalInvoice 
			FROM CM_T_SalesInvoiceDetail SID
			GROUP BY IDX_T_SalesInvoiceHeader
	')

	SET @SqlFrom = 'FROM CM_T_SalesInvoiceHeader SIH
					LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = SIH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
					LEFT JOIN GN_M_PartnerAddress GMPA ON GMP.IDX_M_Partner = GMPA.IDX_M_Partner AND GMPA.IDX_M_AddressType = 1
					LEFT JOIN #SUMInvoice SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader 
					LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
								FROM CM_T_SalesInvoiceHeader SIH
								LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
								LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
								LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
								WHERE RA.AllocationStatus = ''A'' 
								GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
									ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader
					LEFT JOIN GN_M_Currency GMC ON GMC.IDX_M_Currency = SIH.IDX_M_Currency
					LEFT JOIN IN_M_LocationInventory MLI ON MLI.IDX_M_LocationInventory = SIH.IDX_M_LocationInventory
					LEFT JOIN GN_M_DocumentType MDT ON MDT.IDX_M_DocumentType = SIH.IDX_M_DocumentType 
					LEFT JOIN GN_M_SalesPerson MSP ON MSP.IDX_M_SalesPerson = SIH.IDX_M_SalesPerson
					LEFT JOIN GL_M_COA MCU ON MCU.IDX_M_COA = SIH.COAHeader
					LEFT JOIN GN_M_Branch GMB ON GMB.IDX_M_Branch = SIH.IDX_M_Branch '
	IF @TotalInvoice = ''
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(SIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
							'''	AND RTRIM(ISNULL(GMP.PartnerName,'''')) LIKE ''' + @_PartnerName +
							''' AND RTRIM(SIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
							''' AND RTRIM(ISNULL(GMPA.Street,'''')) LIKE ''' + @_PartnerAddress +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDate,23) LIKE ''' + @_InvoiceDate +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDueDate,23) LIKE ''' + @_InvoiceDueDate +
							'''	AND CONVERT(VARCHAR,ISNULL(SID.TotalInvoice,0)) LIKE ''' + @_TotalInvoice + @_FilterCompany + @_FilterBranch + @_FilterPartner + @_FilterStatus + ''''
	END
	ELSE
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(SIH.InvoiceNo,'''')  LIKE '''	+ @_InvoiceNo + 
							'''	AND RTRIM(ISNULL(GMP.PartnerName,'''')) LIKE ''' + @_PartnerName + 
							''' AND RTRIM(SIH.RemarkHeader) LIKE ''' + @_PartnerAddress	+ 
							''' AND RTRIM(ISNULL(GMPA.Street,'''')) LIKE ''' + @_InvoiceDate + 
							''' AND CONVERT(VARCHAR,SIH.InvoiceDate,23) LIKE ''' + @_InvoiceDueDate + 
							''' AND CONVERT(VARCHAR,SIH.InvoiceDueDate,23) LIKE ''' + @_RemarkHeader + 
							'''	AND CONVERT(VARCHAR,ISNULL(FLOOR(SID.TotalInvoice),0)) = ''' + @_TotalInvoice + @_FilterCompany + @_FilterBranch + @_FilterPartner + @_FilterStatus + ''''
	END

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
