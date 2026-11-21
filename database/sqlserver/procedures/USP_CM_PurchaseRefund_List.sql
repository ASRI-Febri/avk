/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Purchase Invoice List

/*	
	EXEC [dbo].[USP_CM_PurchaseRefund_List] 
					 1
					,10
					,'RowNumber'
					,'asc'
					,'R'
					,''
					,''
					,''
					,''
					,''
		
	EXEC [CoreDB].[dbo].[USP_CM_PurchaseRefund_List] 
		1
		,10
		,'RowNumber'
		,'asc'
		,'C'
		,''
		,'test'
		,''
		,''
		,''
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefund_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@InvoiceNo				VARCHAR(50),
	@RemarkHeader			VARCHAR(128),
	@PartnerName			VARCHAR(50),
	@InvoiceDate			VARCHAR(20),
	@DueDate				VARCHAR(20)
	
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
	DECLARE @_InvoiceDate			AS VARCHAR(50)
	DECLARE @_DueDate				AS VARCHAR(50)
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
	SET @_InvoiceDate = '%' + RTRIM(@InvoiceDate) + '%'	
	SET @_DueDate = '%' + RTRIM(@DueDate) + '%'		
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' PIH.IDX_T_PurchaseRefundHeader ' + @SortDir
		SET @_Sort2 = ' PIH.IDX_T_PurchaseRefundHeader ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'PartnerName'
	BEGIN
		SET @_Sort1 = ' GMP.Name ' + @SortDir
		SET @_Sort2 = ' GMP.Name ' + @SortDir
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
								PIH.IDX_M_Company, GC.Name AS CompanyName, PIH.IDX_M_Branch, PIH.IDX_T_PurchaseRefundHeader, PIH.InvoiceNo, PIH.ReferenceNo, 
								GMP.PartnerID, GMP.Name AS PartnerName, CONVERT(VARCHAR,PIH.InvoiceDate,106) AS InvoiceDate, 
								CONVERT(VARCHAR,PIH.InvoiceDueDate,106) AS InvoiceDueDate, RemarkHeader, 
								PID.TotalInvoice, FP.ReceiveAmount, InvoiceStatus, 
								StatusDesc = CASE InvoiceStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void''
								WHEN ''C'' THEN ''Cancel'' WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 							
	
	SET @SqlFrom = 'FROM CM_T_PurchaseRefundHeader PIH
					LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = PIH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
					LEFT JOIN (	SELECT PID.IDX_T_PurchaseRefundHeader, SUM(Quantity * UnitPrice) AS TotalInvoice 
								FROM CM_T_PurchaseRefundDetail PID
								GROUP BY IDX_T_PurchaseRefundHeader) PID ON PID.IDX_T_PurchaseRefundHeader = PIH.IDX_T_PurchaseRefundHeader 
					LEFT JOIN (	SELECT PIH.IDX_T_PurchaseRefundHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
								FROM CM_T_PurchaseRefundHeader PIH
								LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseRefundHeader
								LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
								LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
								WHERE RA.AllocationStatus = ''A'' 
								GROUP BY PIH.IDX_T_PurchaseRefundHeader) FP 
									ON FP.IDX_T_PurchaseRefundHeader = PIH.IDX_T_PurchaseRefundHeader '

	SET @SqlWhere = 'WHERE ISNULL(PIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
						''' AND RTRIM(PIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDate,106) LIKE ''' + @_InvoiceDate +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDueDate,106) LIKE ''' + @_DueDate +
						'''	AND RTRIM(GMP.Name) LIKE ''' + @_PartnerName + ''''

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ' ORDER BY ' + @_Sort2

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








