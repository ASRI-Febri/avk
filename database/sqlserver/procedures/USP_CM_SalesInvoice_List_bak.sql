/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Sales Invoice List
Mod date		: 2019-08-12
Mod desc		: Adjust logic for calculate total Invoice (using temp table #SUMInvoice)

/*	

	EXEC [PralonDB].[dbo].[USP_CM_SalesInvoice_List] 
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
		,''
		,''
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_List_bak]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@InvoiceNo				VARCHAR(50),
	@RemarkHeader			VARCHAR(128),
	@PartnerName			VARCHAR(50),
	@PartnerAddress			VARCHAR(5000),
	@InvoiceDate			VARCHAR(20),
	@DueDate				VARCHAR(20),
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
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_PartnerAddress		AS VARCHAR(5000)
	DECLARE @_InvoiceDate			AS VARCHAR(50)
	DECLARE @_DueDate				AS VARCHAR(50)
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

	SET @_InvoiceNo = '%' + RTRIM(@InvoiceNo) + '%'	
	SET @_RemarkHeader = '%' + RTRIM(@RemarkHeader) + '%'
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'	
	SET @_PartnerAddress = '%' + RTRIM(@PartnerAddress) + '%'	
	SET @_InvoiceDate = '%' + RTRIM(@InvoiceDate) + '%'	
	SET @_DueDate = '%' + RTRIM(@DueDate) + '%'		

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
								SIH.IDX_M_Company, GC.Name AS CompanyName, SIH.IDX_M_Branch, SIH.IDX_T_SalesInvoiceHeader, SIH.InvoiceNo, SIH.ReferenceNo, 
								ISNULL(GMP.PartnerID,'''') AS PartnerID, ISNULL(GMP.PartnerName,'''') AS PartnerName, ISNULL(GMPA.Street,'''') AS LegalAddress, CONVERT(VARCHAR,SIH.InvoiceDate,106) AS InvoiceDate, 
								CONVERT(VARCHAR,SIH.InvoiceDueDate,106) AS InvoiceDueDate, RemarkHeader, 
								SID.TotalInvoice, FR.ReceiveAmount, InvoiceStatus, 
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


	--SET @SqlFrom = 'FROM CM_T_SalesInvoiceHeader SIH
	--				LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = SIH.IDX_M_Company 
	--				LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
	--				LEFT JOIN GN_M_PartnerAddress GMPA ON GMP.IDX_M_Partner = GMPA.IDX_M_Partner AND GMPA.IDX_M_AddressType = 1
	--				LEFT JOIN (	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount + TaxAmount)) AS TotalInvoice 
	--							FROM CM_T_SalesInvoiceDetail SID
	--							GROUP BY IDX_T_SalesInvoiceHeader) SID ON SID.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader 
	--				LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
	--							FROM CM_T_SalesInvoiceHeader SIH
	--							LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
	--							LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
	--							LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
	--							WHERE RA.AllocationStatus = ''A'' 
	--							GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
	--								ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader '

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
									ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader '
	IF @TotalInvoice = ''
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(SIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
							''' AND RTRIM(SIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDate,106) LIKE ''' + @_InvoiceDate +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDueDate,106) LIKE ''' + @_DueDate +
							''' AND RTRIM(ISNULL(GMPA.Street,'''')) LIKE ''' + @_PartnerAddress +
							'''	AND RTRIM(ISNULL(GMP.PartnerName,'''')) LIKE ''' + @_PartnerName +
							'''	AND CONVERT(VARCHAR,ISNULL(SID.TotalInvoice,0)) LIKE ''' + @_TotalInvoice + ''''
	END
	ELSE
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(SIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
							''' AND RTRIM(SIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDate,106) LIKE ''' + @_InvoiceDate +
							''' AND CONVERT(VARCHAR,SIH.InvoiceDueDate,106) LIKE ''' + @_DueDate +
							''' AND RTRIM(ISNULL(GMPA.Street,'''')) LIKE ''' + @_PartnerAddress +
							'''	AND GMP.PartnerName LIKE ''' + @_PartnerName +
							'''	AND CONVERT(VARCHAR,ISNULL(FLOOR(SID.TotalInvoice),0)) = ''' + @_TotalInvoice + ''''
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
