
-- ====================================================
-- Author		: Deva
-- Create date	: 21 November 2019
-- Description	: Show Sales Refund Header Records List
-- ====================================================

/*	

	EXEC [PralonDB].[dbo].[USP_CM_SalesRefund_List] 
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

CREATE PROCEDURE [dbo].[USP_CM_SalesRefund_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@RefundNo				VARCHAR(50),
	@InvoiceReferenceNo		VARCHAR(50),
	@PartnerName			VARCHAR(50),
	@LegalAddress			VARCHAR(5000),
	@RefundDate				VARCHAR(20),
	@RefundDueDate			VARCHAR(20),
	@RemarkHeader			VARCHAR(128)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_RefundNo				AS VARCHAR(50)
	DECLARE @_InvoiceReferenceNo	AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_LegalAddress			AS VARCHAR(5000)
	DECLARE @_RefundDate			AS VARCHAR(50)
	DECLARE @_RefundDueDate			AS VARCHAR(50)
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_RefundNo = '%' + RTRIM(@RefundNo) + '%'	
	SET @_InvoiceReferenceNo = '%' + RTRIM(@InvoiceReferenceNo) + '%'	
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'	
	SET @_LegalAddress = '%' + RTRIM(@LegalAddress) + '%'	
	SET @_RefundDate = '%' + RTRIM(@RefundDate) + '%'	
	SET @_RefundDueDate = '%' + RTRIM(@RefundDueDate) + '%'		
	SET @_RemarkHeader = '%' + RTRIM(@RemarkHeader) + '%'


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

	IF RTRIM(@SortBy) = 'LegalAddress'
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
								ROW_NUMBER() OVER (ORDER BY ' + @_Sort1 + ') AS RowNumber, SRH.IDX_T_SalesRefundHeader,
								SRH.RefundNo, SRH.IDX_T_SalesInvoiceHeader, SRH.InvoiceReferenceNo,  SRH.IDX_M_Company, GC.Name AS CompanyName, SRH.IDX_M_Branch, SRH.ReferenceNo, 
								ISNULL(GMP.PartnerID,'''') AS PartnerID, ISNULL(GMP.PartnerName,'''') AS PartnerName, ISNULL(GMPA.Street,'''') AS LegalAddress, CONVERT(VARCHAR,SRH.RefundDate,106) AS RefundDate, 
								CONVERT(VARCHAR,SRH.RefundDueDate,106) AS RefundDueDate, SRH.RemarkHeader, 
								RefundStatus, 
								StatusDesc = CASE RefundStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void'' 
								WHEN ''C'' THEN ''Cancel'' WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 							


	SET @SqlFrom = 'FROM CM_T_SalesRefundHeader SRH
					LEFT JOIN CM_T_SalesInvoiceHeader SIH ON SIH.IDX_T_SalesInvoiceHeader = SRH.IDX_T_SalesInvoiceHeader
					LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = SIH.IDX_M_Company 
					LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = SIH.IDX_M_Partner 
					LEFT JOIN GN_M_PartnerAddress GMPA ON GMP.IDX_M_Partner = GMPA.IDX_M_Partner AND GMPA.IDX_M_AddressType = 1
					LEFT JOIN (	SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
								FROM CM_T_SalesInvoiceHeader SIH
								LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
								LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
								LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
								WHERE RA.AllocationStatus = ''A'' 
								GROUP BY SIH.IDX_T_SalesInvoiceHeader) FR 
									ON FR.IDX_T_SalesInvoiceHeader = SIH.IDX_T_SalesInvoiceHeader '

	SET @SqlWhere = 'WHERE ISNULL(SRH.RefundNo,'''')  LIKE ''' + @_RefundNo + 
						''' AND ISNULL(SRH.InvoiceReferenceNo,'''')  LIKE ''' + @_InvoiceReferenceNo + 
						'''	AND RTRIM(ISNULL(GMP.PartnerName,'''')) LIKE ''' + @_PartnerName + 
						''' AND RTRIM(ISNULL(GMPA.Street,'''')) LIKE ''' + @_LegalAddress +
						''' AND CONVERT(VARCHAR,SRH.RefundDate,106) LIKE ''' + @_RefundDate +
						''' AND CONVERT(VARCHAR,SRH.RefundDueDate,106) LIKE ''' + @_RefundDueDate +
						''' AND RTRIM(SRH.RemarkHeader) LIKE ''' + @_RemarkHeader + ''''


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
