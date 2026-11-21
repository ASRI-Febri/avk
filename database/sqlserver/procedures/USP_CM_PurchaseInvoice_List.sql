/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Purchase Invoice List
Mod date		: 2019-08-12 --> Adjust cara searching amount
				  2023-10-03 by Anton --> Added display column GroupCompany

/*
	EXEC [dbo].[USP_CM_PurchaseInvoice_List] 1,10,'CompanyName','asc','R','','','','','','','',''
	EXEC [dbo].[USP_CM_PurchaseInvoice_List] 1,100,'CompanyName','asc','R','Citra Pusaka Mandiri','','','','','','','','1305276'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@CompanyName			VARCHAR(50),
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
	DECLARE @_CompanyName			AS VARCHAR(50)
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
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

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
	
	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID' OR RTRIM(@SortBy) = 'IDX_T_PurchaseInvoiceHeader'
	BEGIN
		SET @_Sort1 = ' PIH.IDX_T_PurchaseInvoiceHeader ' + @SortDir
		SET @_Sort2 = ' PIH.IDX_T_PurchaseInvoiceHeader ' + @SortDir
	END	
	
	IF RTRIM(@SortBy) = 'PartnerName'
	BEGIN
		SET @_Sort1 = ' GMP.PartnerName ' + @SortDir
		SET @_Sort2 = ' GMP.PartnerName ' + @SortDir
	END		

	IF RTRIM(@SortBy) = 'CompanyName'
	BEGIN
		SET @_Sort1 = ' CompanyName ' + @SortDir
		SET @_Sort2 = ' CompanyName ' + @SortDir
	END	

	IF RTRIM(@SortBy) = 'ProjectID'
	BEGIN
		SET @_Sort1 = ' ProjectID ' + @SortDir
		SET @_Sort2 = ' Project.ProjectID ' + @SortDir
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
								PIH.IDX_M_Company, CompanyName, PIH.IDX_M_Branch, GMB.BranchID, GMB.BranchName, Project.IDX_M_Project, Project.ProjectID, Project.ProjectName, 
								PIH.IDX_T_PurchaseInvoiceHeader AS IDX_T_PurchaseInvoiceHeader, PIH.InvoiceNo, PIH.ReferenceNo, 
								GMP.PartnerID, GMP.PartnerName AS PartnerName, CONVERT(VARCHAR,PIH.InvoiceDate,106) AS InvoiceDate, 
								CONVERT(VARCHAR,PIH.InvoiceDueDate,106) AS InvoiceDueDate, Project.RemarkDetail AS RemarkHeader, 
								ISNULL(Project.DetailAmount,0) AS DetailAmount,
								ISNULL(PID.TotalInvoice,0) AS TotalInvoice, ISNULL(FP.PaymentAmount,0) AS PaymentAmount, 
								CASE WHEN ISNULL(Project.DetailAmount,0) - ISNULL(FP.PaymentAmount,0) < 1 THEN 0
										  ELSE ISNULL(PID.TotalInvoice,0) - ISNULL(FP.PaymentAmount,0) 
								END AS Outstanding,
								InvoiceStatus, 
								StatusDesc = CASE InvoiceStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''V'' THEN ''Void''
								WHEN ''C'' THEN ''Cancel'' WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 			
								
	CREATE TABLE #SUMInvoice
	(IDX_T_PurchaseInvoiceHeader BIGINT, TotalInvoice DECIMAL(20,3))

	EXEC
	('
		INSERT INTO #SUMInvoice
			SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount + TaxAmount) ) AS TotalInvoice 
			FROM CM_T_PurchaseInvoiceDetail PID
			GROUP BY PID.IDX_T_PurchaseInvoiceHeader
	')
	
	--SET @SqlFrom = 'FROM CM_T_PurchaseInvoiceHeader PIH
	--				LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = PIH.IDX_M_Company 
	--				LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
	--				LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount + TaxAmount) ) AS TotalInvoice 
	--							FROM CM_T_PurchaseInvoiceDetail PID
	--							GROUP BY IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
	--				LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount
	--							FROM CM_T_PurchaseInvoiceHeader PIH
	--							LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
	--							LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
	--							LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	--							WHERE RA.AllocationStatus = ''A'' 
	--							GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FP 
	--								ON FP.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader '

	SET @SqlFrom = 'FROM CM_T_PurchaseInvoiceHeader PIH
						INNER JOIN ( SELECT TSID.IDX_T_PurchaseInvoiceHeader, TSID.IDX_M_Project, GMP.ProjectID, GMP.ProjectName, TSID.RemarkDetail, SUM((TSID.Quantity * (TSID.UntaxedAmount-TSID.DiscountAmount+TSID.TaxAmount))) AS DetailAmount
													 FROM CM_T_PurchaseInvoiceDetail TSID WITH(NOLOCK)
														INNER JOIN GN_M_Project GMP WITH(NOLOCK) ON TSID.IDX_M_Project = GMP.IDX_M_Project
													 GROUP BY TSID.IDX_T_PurchaseInvoiceHeader, TSID.IDX_M_Project, GMP.ProjectID, GMP.ProjectName, TSID.RemarkDetail
													) Project ON PIH.IDX_T_PurchaseInvoiceHeader = Project.IDX_T_PurchaseInvoiceHeader
						LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = PIH.IDX_M_Company 
						LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = PIH.IDX_M_Partner 
						LEFT JOIN GN_M_Branch GMB WITH (NOLOCK) ON PIH.IDX_M_Branch = GMB.IDX_M_Branch
						LEFT JOIN #SUMInvoice PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
						LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount
									FROM CM_T_PurchaseInvoiceHeader PIH
									LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
									LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
									LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
									WHERE RA.AllocationStatus = ''A'' 
									GROUP BY PIH.IDX_T_PurchaseInvoiceHeader) FP 
										ON FP.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
						INNER JOIN ( SELECT B.IDX_M_Branch
									FROM SM_M_User A WITH(NOLOCK)
										INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
									WHERE B.RecordStatus = ''A'' AND RTRIM(A.LoginID) = ''' + @UserID + ''') UB ON PIH.IDX_M_Branch = UB.IDX_M_Branch '

	IF @TotalInvoice = ''
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(PIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
						''' AND RTRIM(CompanyName) LIKE ''' + @_CompanyName +
						''' AND RTRIM(PIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
						''' AND RTRIM(Project.ProjectID) LIKE ''' + @_ProjectID +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDate,106) LIKE ''' + @_InvoiceDate +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDueDate,106) LIKE ''' + @_DueDate +
						'''	AND RTRIM(GMP.PartnerName) LIKE ''' + @_PartnerName +
						'''	AND CONVERT(VARCHAR,ISNULL(PID.TotalInvoice,0)) LIKE ''' + @_TotalInvoice + ''''
	END
	ELSE
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(PIH.InvoiceNo,'''')  LIKE ''' + @_InvoiceNo + 
						''' AND RTRIM(CompanyName) LIKE ''' + @_CompanyName +
						''' AND RTRIM(PIH.RemarkHeader) LIKE ''' + @_RemarkHeader +
						''' AND RTRIM(Project.ProjectID) LIKE ''' + @_ProjectID +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDate,106) LIKE ''' + @_InvoiceDate +
						''' AND CONVERT(VARCHAR,PIH.InvoiceDueDate,106) LIKE ''' + @_DueDate +
						'''	AND RTRIM(GMP.PartnerName) LIKE ''' + @_PartnerName +
						'''	AND CONVERT(VARCHAR,ISNULL(FLOOR(PID.TotalInvoice),0)) = ''' + @_TotalInvoice + ''''
	END

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
