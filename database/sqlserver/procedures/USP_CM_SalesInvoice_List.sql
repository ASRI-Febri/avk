/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Sales Invoice List
Mod date		: 2019-08-12 --> Adjust logic for calculate total Invoice (using temp table #SUMInvoice)
				  2023-10-03 by Anton --> Added column CompanyName
				  2024-04-30 by Anton --> Adjust logic amount for TotalInvoice

/*	

	EXEC [dbo].[USP_CM_SalesInvoice_List] 1,5000,'RowNumber','DESC','R','','','','','','','','',''
	EXEC [dbo].[USP_CM_SalesInvoice_List] 1,100,'RowNumber','DESC','R','','','SI-FJP-2401-0353','','','','','','1305276'
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@CompanyName			VARCHAR(128),
	@ProjectID				VARCHAR(128),
	@InvoiceNo				VARCHAR(50),
	@RemarkHeader			VARCHAR(128),
	@PartnerName			VARCHAR(50),
	@InvoiceDate			VARCHAR(20),
	@DueDate				VARCHAR(20),
	@TotalInvoice			VARCHAR(20),
	@UserID					VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_CompanyName			AS VARCHAR(128)
	DECLARE @_ProjectID				AS VARCHAR(128)
	DECLARE @_InvoiceNo				AS VARCHAR(50)
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
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

	SET @_CompanyName = '%' + RTRIM(@CompanyName) + '%'	
	SET @_ProjectID = '%' + RTRIM(@ProjectID) + '%'	
	SET @_InvoiceNo = '%' + RTRIM(@InvoiceNo) + '%'	
	SET @_RemarkHeader = '%' + RTRIM(@RemarkHeader) + '%'
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'	
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

	IF @SortBy = 'RowNumber' OR @SortBy = 'IDX_T_SalesInvoiceHeader'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.IDX_T_SalesInvoiceHeader ' + @SortDir
	END
	ELSE IF @SortBy = 'PartnerName'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t2.PartnerName ' + @SortDir
	END
	ELSE IF @SortBy = 'CompanyName'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t3.CompanyName ' + @SortDir
	END
	ELSE IF @SortBy = 'ProjectID'
	BEGIN
		SET @OrderBy1 = 'ORDER BY Project.ProjectID ' + @SortDir
	END
	ELSE IF @SortBy = 'InvoiceNo'
	BEGIN
		SET @OrderBy1 = 'ORDER BY t1.InvoiceNo ' + @SortDir
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
					DECLARE @CompanyName_			VARCHAR(128),
							@ProjectID_				VARCHAR(128),
							@InvoiceNo_				VARCHAR(64),
							@RemarkHeader_			VARCHAR(256),
							@PartnerName_			VARCHAR(64),
							@InvoiceDate_			VARCHAR(64),
							@DueDate_				VARCHAR(64),
							@TotalInvoice_			VARCHAR(64)
				

					CREATE TABLE #TempInvoice
					(IDX_T_SalesInvoiceHeader BIGINT, Total DECIMAL(18,2))

					CREATE CLUSTERED INDEX ix_tempCIndexBef ON #TempInvoice ([IDX_T_SalesInvoiceHeader]);

					INSERT INTO #TempInvoice
					SELECT SID.IDX_T_SalesInvoiceHeader, SUM(((SID.UntaxedAmount-SID.DiscountAmount) * SID.Quantity) + ((ISNULL(TAX.TaxAmount,0) * Quantity))) AS TotalInvoice 
					FROM CM_T_SalesInvoiceDetail SID WITH(NOLOCK)
						LEFT JOIN (SELECT IDX_T_SalesInvoiceDetail, SUM(ISNULL(TaxAmount,0)) AS TaxAmount 
									FROM CM_T_SalesInvoiceTax WITH(NOLOCK) 
									GROUP BY IDX_T_SalesInvoiceDetail) TAX ON SID.IDX_T_SalesInvoiceDetail = TAX.IDX_T_SalesInvoiceDetail
					GROUP BY IDX_T_SalesInvoiceHeader

					CREATE TABLE #TempReceive
					(IDX_T_SalesInvoiceHeader BIGINT, TotalReceive DECIMAL(18,2))

					CREATE CLUSTERED INDEX ix_tempCIndexBef ON #TempReceive ([IDX_T_SalesInvoiceHeader]);

					INSERT INTO #TempReceive
					SELECT SIH.IDX_T_SalesInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS ReceiveAmount
					FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
					LEFT JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
					LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					LEFT JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
					WHERE RA.AllocationStatus = ''A'' 
					GROUP BY SIH.IDX_T_SalesInvoiceHeader

					; WITH CTE_Results
					AS (
						SELECT	ROW_NUMBER() OVER (' + @OrderBy1 + ') AS RowNumber,
								t1.IDX_M_Company,
								t3.CompanyName AS CompanyName, 
								t1.IDX_M_Branch,
								t4.BranchID AS BranchID,
								t4.BranchName,
								Project.IDX_M_Project,
								Project.ProjectID,
								Project.ProjectName,
								t1.IDX_T_SalesInvoiceHeader,
								t1.InvoiceNo,
								t1.ReferenceNo,
								ISNULL(UPPER(t2.PartnerID),'''') AS PartnerID, 
								ISNULL(UPPER(t2.PartnerName),'''') AS PartnerName,
								CONVERT(VARCHAR,t1.InvoiceDate,106) AS InvoiceDate, 
								CONVERT(VARCHAR,t1.InvoiceDueDate,106) AS InvoiceDueDate,
								t1.RemarkHeader,
								--Project.RemarkDetail AS RemarkHeader,
								CASE WHEN ISNULL(t1.TotalSalesAmount,0) > 0 THEN t1.TotalSalesAmount ELSE ISNULL(t5.Total,0) END AS TotalInvoice,
								--CASE WHEN t1.RemarkHeader LIKE ''PENDAPATAN PARKIR%'' THEN 0 ELSE Project.DetailAmount END AS DetailAmount,
								ISNULL(t6.TotalReceive,0) As ReceiveAmount,
								CASE WHEN ISNULL(t1.TotalSalesAmount,0) > 0 THEN t1.TotalSalesAmount-ISNULL(t6.TotalReceive,0) 
																			ELSE ISNULL(t5.Total,0)-ISNULL(t6.TotalReceive,0)  END AS Outstanding,
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
							INNER JOIN ( SELECT TSID.IDX_T_SalesInvoiceHeader, TSID.IDX_M_Project, GMP.ProjectID, GMP.ProjectName--, TSID.RemarkDetail, SUM((TSID.Quantity * (TSID.UntaxedAmount-TSID.DiscountAmount+TSID.TaxAmount))) AS DetailAmount
										 FROM CM_T_SalesInvoiceDetail TSID WITH(NOLOCK)
											INNER JOIN GN_M_Project GMP WITH(NOLOCK) ON TSID.IDX_M_Project = GMP.IDX_M_Project
										 GROUP BY TSID.IDX_T_SalesInvoiceHeader, TSID.IDX_M_Project, GMP.ProjectID, GMP.ProjectName--, TSID.RemarkDetail
										) Project ON t1.IDX_T_SalesInvoiceHeader = Project.IDX_T_SalesInvoiceHeader
							LEFT JOIN GN_M_Partner t2 WITH (NOLOCK) ON t1.IDX_M_Partner = t2.IDX_M_Partner 
							LEFT JOIN GN_M_Company t3 WITH (NOLOCK) ON t1.IDX_M_Company = t3.IDX_M_Company 
							LEFT JOIN GN_M_Branch t4 WITH (NOLOCK) ON t1.IDX_M_Branch = t4.IDX_M_Branch
							LEFT JOIN #TempInvoice t5 ON t1.IDX_T_SalesInvoiceHeader = t5.IDX_T_SalesInvoiceHeader
							LEFT JOIN #TempReceive t6 ON t1.IDX_T_SalesInvoiceHeader = t6.IDX_T_SalesInvoiceHeader
							INNER JOIN ( SELECT B.IDX_M_Branch
										FROM SM_M_User A WITH(NOLOCK)
											INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
										WHERE B.RecordStatus = ''A'' AND RTRIM(A.LoginID) = ''' + @UserID + ''') UB ON t1.IDX_M_Branch = UB.IDX_M_Branch 
						WHERE	t1.RecordStatus<>''N''
						AND t1.InvoiceNo LIKE ''%' + COALESCE(@_InvoiceNo,'') + '%''
						AND t3.CompanyName LIKE ''%' + COALESCE(@_CompanyName,'') + '%''
						AND Project.ProjectID LIKE ''%' + COALESCE(@_ProjectID,'') + '%''
						AND CONVERT(VARCHAR,t1.InvoiceDate,106) LIKE ''%' + COALESCE(@_InvoiceDate,'') + '%''
						AND CONVERT(VARCHAR,t1.InvoiceDueDate,106) LIKE ''%' + COALESCE(@_DueDate,'') + '%''
						AND (ISNULL(t1.RemarkHeader,'''') LIKE ''%' + COALESCE(@_RemarkHeader,'') + '%'')	
						AND (ISNULL(t2.PartnerName,'''') LIKE ''%' + COALESCE(@_PartnerName,'') + '%'')	
						AND (ISNULL(t5.Total,''0'') LIKE ''%' + COALESCE(@_TotalInvoice,'') + '%'')	
					)
					SELECT
						RowNumber, 
						IDX_M_Company,
						CompanyName,
						IDX_M_Branch,
						BranchID,
						BranchName,
						IDX_M_Project,
						ProjectID,
						ProjectName,
						IDX_T_SalesInvoiceHeader,
						InvoiceNo,
						ReferenceNo,
						PartnerID,
						PartnerName,
						InvoiceDate,
						InvoiceDueDate,
						RemarkHeader,
						TotalInvoice,
						--DetailAmount,
						ReceiveAmount,
						Outstanding,
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
