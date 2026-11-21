/* =============================================================================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Financial Payment List
Mod				: 2019-08-08 --> Additional filter by amount 
				  2020-08-03 by Anton --> Added for filter by FinancialAccountID & PDCNo
				  2023-10-03 by Anton --> Added column Group Company
=============================================================================================
EXEC USP_CM_FinancialPayment_List 1,10,'RowNumber','asc','R',1,1,'','','','','','','','',''
EXEC USP_CM_FinancialPayment_List 1,10,'RowNumber','asc','R',1,1,'','','','','','','','',''
EXEC USP_CM_FinancialPayment_List 1,10,'RowNumber','asc','R',1,1,'','','','','','','','71132150',''
============================================================================================= */

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	@IDX_M_Company			BIGINT,
	@IDX_M_Branch			INT,
	@CompanyName			VARCHAR(50),
	@PaymentID				VARCHAR(50),
	@VoucherNoManual		VARCHAR(50),
	@FinancialAccountID		VARCHAR(50),
	@PDCNo					VARCHAR(50),
	@RemarkHeader			VARCHAR(128),
	@PartnerName			VARCHAR(50),
	@PaymentDate			VARCHAR(20),
	@PaymentAmount			VARCHAR(20),
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
	DECLARE @_PaymentID				AS VARCHAR(50)
	DECLARE @_VoucherNoManual		AS VARCHAR(50)
	DECLARE @_RemarkHeader			AS VARCHAR(50)
	DECLARE @_PartnerName			AS VARCHAR(50)
	DECLARE @_PaymentDate			AS VARCHAR(50)
	DECLARE @_PaymentAmount			AS VARCHAR(100)
	DECLARE @_PDCNo					AS VARCHAR(50)
	DECLARE @_FinancialAccountID	AS VARCHAR(50)
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
	SET @_PaymentID = '%' + RTRIM(@PaymentID) + '%'	
	SET @_VoucherNoManual = '%' + RTRIM(@VoucherNoManual) + '%'	
	SET @_RemarkHeader = '%' + RTRIM(@RemarkHeader) + '%'
	SET @_PartnerName = '%' + RTRIM(@PartnerName) + '%'	
	SET @_PaymentDate = '%' + RTRIM(@PaymentDate) + '%'	
	SET @_PDCNo = '%' + RTRIM(@PDCNo) + '%'	
	SET @_FinancialAccountID = '%' + RTRIM(@FinancialAccountID) + '%'	

	IF @PaymentAmount = ''
	BEGIN
		SET @_PaymentAmount = '%' + CONVERT(VARCHAR,@PaymentAmount) + '%'	
	END
	ELSE
	BEGIN
		SET @_PaymentAmount = CONVERT(VARCHAR,@PaymentAmount)
	END

	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' IDX_T_FinancialPaymentHeader ' + @SortDir
		SET @_Sort2 = ' IDX_T_FinancialPaymentHeader ' + @SortDir
	END	

	IF RTRIM(@SortBy) = 'CompanyName'
	BEGIN
		SET @_Sort1 = ' MC.CompanyName ' + @SortDir
		SET @_Sort2 = ' CompanyName ' + @SortDir
	END	
	
	--IF RTRIM(@SortBy) = 'PartnerName'
	--BEGIN
	--	SET @_Sort1 = ' GMP.Name ' + @SortDir
	--	SET @_Sort2 = ' GMP.Name ' + @SortDir
	--END		

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
								FPH.IDX_M_Company, FPH.IDX_M_Branch, MC.CompanyName AS CompanyName, MB.BranchName, FPH.IDX_T_FinancialPaymentHeader, 
								FPH.PaymentID, FPH.VoucherNoManual, MFA.FinancialAccountID, FPH.PDCNo, CONVERT(VARCHAR,FPH.PaymentDate,106) AS PaymentDate, 
								MDT.DocumentTypeDesc, 
								MU.Name AS UserCreate, MBP.PartnerID, MBP.PartnerName AS PartnerName, FPH.PaymentAmount, FPH.RemarkHeader, PaymentStatus, 
								StatusDesc = CASE PaymentStatus WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved'' WHEN ''H'' THEN ''Handover'' WHEN ''V'' THEN ''Void'' 
								WHEN ''F'' THEN ''Validate'' ELSE ''Unknown'' END ' 							
	
	SET @SqlFrom = 'FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
					LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON FPH.IDX_M_Company = MC.IDX_M_Company
					LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON FPH.IDX_M_Branch = MB.IDX_M_Branch
					LEFT JOIN GN_M_Partner MBP WITH(NOLOCK) ON FPH.IDX_M_Partner = MBP.IDX_M_Partner
					LEFT JOIN SM_M_User MU WITH(NOLOCK) ON RTRIM(FPH.UCreate) = RTRIM(MU.LoginID)
					LEFT JOIN GN_M_DocumentType MDT WITH(NOLOCK) ON FPH.IDX_M_DocumentType = MDT.IDX_M_DocumentType
					LEFT JOIN CM_M_FinancialAccount MFA WITH(NOLOCK) ON MFA.IDX_M_FinancialAccount = FPH.IDX_M_FinancialAccount
					LEFT JOIN GN_M_Bank BNK WITH(NOLOCK) ON BNK.IDX_M_Bank = MFA.IDX_M_Bank 
					INNER JOIN (SELECT B.IDX_M_Branch
								FROM SM_M_User A WITH(NOLOCK)
									INNER JOIN SM_M_UserBranch B WITH(NOLOCK) ON A.IDX_M_User = B.IDX_M_User
								WHERE B.RecordStatus = ''A'' AND RTRIM(A.LoginID) = ''' + @UserID + ''') UB ON FPH.IDX_M_Branch = UB.IDX_M_Branch '

	IF @PaymentAmount = ''
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(PaymentID,'''')  LIKE ''' + @_PaymentID + 
						''' AND RTRIM(MC.CompanyName) LIKE ''' + @_CompanyName +
						''' AND RTRIM(FPH.VoucherNoManual) LIKE ''' + @_VoucherNoManual +
						''' AND RTRIM(MFA.FinancialAccountID) LIKE ''' + @_FinancialAccountID +
						''' AND RTRIM(FPH.PDCNo) LIKE ''' + @_PDCNo +
						''' AND RTRIM(RemarkHeader) LIKE ''' + @_RemarkHeader +
						''' AND CONVERT(VARCHAR,ISNULL(FPH.PaymentDate,''''),106) LIKE ''' + @_PaymentDate +
						'''	AND RTRIM(MBP.PartnerName) LIKE ''' + @_PartnerName +
						'''	AND CONVERT(VARCHAR,ISNULL(FPH.PaymentAmount,0)) LIKE ''' + @_PaymentAmount + ''''
	END
	ELSE
	BEGIN
		SET @SqlWhere = 'WHERE ISNULL(PaymentID,'''')  LIKE ''' + @_PaymentID + 
						''' AND RTRIM(MC.CompanyName) LIKE ''' + @_CompanyName +
						''' AND RTRIM(FPH.VoucherNoManual) LIKE ''' + @_VoucherNoManual +
						''' AND RTRIM(MFA.FinancialAccountID) LIKE ''' + @_FinancialAccountID +
						''' AND RTRIM(FPH.PDCNo) LIKE ''' + @_PDCNo +
						''' AND RTRIM(RemarkHeader) LIKE ''' + @_RemarkHeader +
						''' AND CONVERT(VARCHAR,ISNULL(FPH.PaymentDate,''''),106) LIKE ''' + @_PaymentDate +
						'''	AND RTRIM(MBP.PartnerName) LIKE ''' + @_PartnerName +
						'''	AND CONVERT(VARCHAR,ISNULL(FLOOR(FPH.PaymentAmount),0)) = ''' + @_PaymentAmount + ''''
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

-- USE [TunasDB]
