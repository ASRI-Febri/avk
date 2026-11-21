/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Sales Invoice List
Mod date		: 2019-08-12
Mod desc		: Adjust logic for calculate total Invoice (using temp table #SUMInvoice)

/*	

	EXEC [PralonDB].[dbo].[USP_CM_SalesInvoice_Faktur_List]
		 1
		,50
		,'RowNumber'
		,'DESC'
		,'R'
		,''
		,''
		,''
		,''
		,''
		,''
		,''
		,''
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Faktur_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@InvoiceNo				VARCHAR(50),
	@TaxInvoiceNo			VARCHAR(50),
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
	DECLARE @_TaxInvoiceNo			AS VARCHAR(50)
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_PartnerAddress		AS VARCHAR(5000)
	DECLARE @_InvoiceDate			AS VARCHAR(50)
	DECLARE @_DueDate				AS VARCHAR(50)
	DECLARE @_TotalInvoice			AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	DECLARE @OrderBy1				AS VARCHAR(256)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)
	DECLARE @Query					AS VARCHAR(8000)

	SET @_InvoiceNo = '%' + RTRIM(@InvoiceNo) + '%'	
	SET @_TaxInvoiceNo = '%' + RTRIM(@TaxInvoiceNo) + '%'	
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

	IF @SortBy = 'RowNumber'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.IDX_T_SalesInvoiceHeader ' + @SortDir
	END
	ELSE IF @SortBy = 'PartnerName'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t2.PartnerName ' + @SortDir
	END
	ELSE IF @SortBy = 'LegalAddress'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t4.Street ' + @SortDir
	END
	ELSE IF @SortBy = 'InvoiceNo'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.InvoiceNo ' + @SortDir
	END
	ELSE IF @SortBy = 'TaxInvoiceNo'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.TaxInvoiceNo' + @SortDir
	END
	ELSE IF @SortBy = 'InvoiceDate'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.InvoiceDate ' + @SortDir
	END
	ELSE IF @SortBy = 'InvoiceDueDate'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.InvoiceDueDate ' + @SortDir
	END
	ELSE IF @SortBy = 'RemarkHeader'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.RemarkHeader ' + @SortDir
	END
	ELSE IF @SortBy = 'TotalInvoice'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t5.Total ' + @SortDir
	END
	ELSE IF @SortBy = 'StatusDesc'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.InvoiceStatus ' + @SortDir
	END

	

	SET @Query = '
					DECLARE @InvoiceNo_				VARCHAR(64),
							@TaxInvoiceNo_			VARCHAR(64),
							@RemarkHeader_			VARCHAR(256),
							@PartnerName_			VARCHAR(64),
							@PartnerAddress_		VARCHAR(64),
							@InvoiceDate_			VARCHAR(64),
							@DueDate_				VARCHAR(64),
							@TotalInvoice_			VARCHAR(64)
				

					CREATE TABLE #TempInvoice
					(IDX_T_SalesInvoiceHeader BIGINT, Total DECIMAL(18,2))

					CREATE CLUSTERED INDEX ix_tempCIndexBef ON #TempInvoice ([IDX_T_SalesInvoiceHeader]);

					INSERT INTO #TempInvoice
					SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount + TaxAmount)) AS TotalInvoice 
					FROM CM_T_SalesInvoiceDetail SID
					GROUP BY IDX_T_SalesInvoiceHeader



					CREATE TABLE #TempReceive
					(IDX_T_SalesInvoiceHeader BIGINT, TotalReceive DECIMAL(18,2))

					CREATE CLUSTERED INDEX ix_tempCIndexBef ON #TempReceive ([IDX_T_SalesInvoiceHeader]);

					INSERT INTO #TempReceive
					SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
					FROM CM_T_SalesInvoiceHeader SIH
					LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
					LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
					WHERE RA.AllocationStatus = ''A'' 
					GROUP BY SIH.IDX_T_SalesInvoiceHeader



					; WITH CTE_Results
					AS (
						SELECT	ROW_NUMBER() OVER (' + @OrderBy1 + ') AS RowNumber,
								t1.IDX_M_Company,
								t3.Name AS CompanyName, 
								t1.IDX_M_Branch,
								t1.IDX_T_SalesInvoiceHeader,
								t1.InvoiceNo,
								t1.ReferenceNo,
								t1.TaxInvoiceNo,
								ISNULL(UPPER(t2.PartnerID),'''') AS PartnerID, 
								ISNULL(UPPER(t2.PartnerName),'''') AS PartnerName,
								ISNULL(UPPER(t4.Street),'''') AS LegalAddress,
							
								CONVERT(VARCHAR,t1.InvoiceDate,106) AS InvoiceDate, 
								CONVERT(VARCHAR,t1.InvoiceDueDate,106) AS InvoiceDueDate,
								t1.RemarkHeader,
								ISNULL(t5.Total,0) As TotalInvoice,
								ISNULL(t6.TotalReceive,0) As ReceiveAmount,

								t1.InvoiceStatus,
								CASE t1.InvoiceStatus 
									WHEN ''D'' THEN ''Draft''
									WHEN ''A'' THEN ''Approved'' 
									WHEN ''V'' THEN ''Void'' 
									WHEN ''C'' THEN ''Cancel'' 
									WHEN ''F'' THEN ''Validate'' 
									ELSE ''Unknown'' 
								END As StatusDesc
						FROM	CM_T_SalesInvoiceHeader t1 WITH (NOLOCK)
						LEFT JOIN GN_M_Partner t2 ON t1.IDX_M_Partner = t2.IDX_M_Partner 
						LEFT JOIN GN_M_Company t3 ON t1.IDX_M_Company = t3.IDX_M_Company 
						LEFT JOIN GN_M_PartnerAddress t4 ON t2.IDX_M_Partner = t4.IDX_M_Partner AND t4.IDX_M_AddressType = 1
						LEFT JOIN #TempInvoice t5 ON t1.IDX_T_SalesInvoiceHeader = t5.IDX_T_SalesInvoiceHeader
						LEFT JOIN #TempReceive t6 ON t1.IDX_T_SalesInvoiceHeader = t6.IDX_T_SalesInvoiceHeader
						LEFT JOIN CM_T_FakturPajak t7 ON t1.IDX_T_SalesInvoiceHeader = t7.IDX_T_Transaction
						WHERE	t1.RecordStatus<>''N''
						AND t7.IDX_T_Faktur IS NULL
						AND t1.InvoiceNo LIKE ''%' + COALESCE(@_InvoiceNo,'') + '%''
						AND t1.TaxInvoiceNo LIKE ''%' + COALESCE(@_TaxInvoiceNo,'') + '%''
						AND CONVERT(VARCHAR,t1.InvoiceDate,106) LIKE ''%' + COALESCE(@_InvoiceDate,'') + '%''
						AND CONVERT(VARCHAR,t1.InvoiceDueDate,106) LIKE ''%' + COALESCE(@_DueDate,'') + '%''
						AND (ISNULL(t1.RemarkHeader,'''') LIKE ''%' + COALESCE(@_RemarkHeader,'') + '%'')	
						AND (t2.PartnerName LIKE ''%' + COALESCE(@_PartnerName,'') + '%'')	
						AND (ISNULL(t4.Street,'''') LIKE ''%' + COALESCE(@_PartnerAddress,'') + '%'')
						AND (ISNULL(t5.Total,''0'') LIKE ''%' + COALESCE(@_TotalInvoice,'') + '%'')	
						AND t1.InvoiceStatus = ''A''
					)
					SELECT
						RowNumber, 
						IDX_M_Company,
						CompanyName,
						IDX_M_Branch,
						IDX_T_SalesInvoiceHeader,
						InvoiceNo,
						TaxInvoiceNo,
						ReferenceNo,
						PartnerID,
						PartnerName,
						LegalAddress,
					
						InvoiceDate,
						InvoiceDueDate,
						RemarkHeader,
						TotalInvoice,
						ReceiveAmount,
						InvoiceStatus,
						StatusDesc
					INTO #temp
					FROM CTE_Results AS CPC
					'


	DECLARE @QueryR VARCHAR(8000)
			
	SET	@QueryR = '		SELECT * FROM #temp
						ORDER BY RowNumber ASC		
						OFFSET (('+CONVERT(VARCHAR,@Page)+' - 1) * '+CONVERT(VARCHAR,@Row)+') ROWS
						FETCH NEXT ' + CONVERT(VARCHAR,@Row) + ' ROWS ONLY
				'
	
	DECLARE @QueryC VARCHAR(8000)

	SET @QueryC =	'SELECT COUNT(*) As TotalRows FROM #temp'
			

				
	DECLARE @QueryDrop VARCHAR(8000)		

				
	SET @QueryDrop = '	DROP TABLE #temp
						DROP TABLE #TempInvoice
						DROP TABLE #TempReceive
					 ' 		
				
	IF @ReturnType = 'R'
	BEGIN
				
					exec (@Query + @QueryR  +@QueryDrop)
	END

	IF @ReturnType = 'C'
	BEGIN
				exec (@Query + @QueryC  +@QueryDrop)
	END

END
