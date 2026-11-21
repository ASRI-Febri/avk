/* =============================================
Author			: Anton
Create date		: 2021-01-12
Description		: Mapping Cashflow Transaction List
Mod date		:

/*	
	EXEC [dbo].[USP_CM_MappingCashflow_List] 
					 1
					,10000
					,'RowNumber'
					,'asc'
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

CREATE PROCEDURE [dbo].[USP_CM_MappingCashflow_List]
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count	
	--@IDX_M_Company			BIGINT,
	--@IDX_M_Branch			INT,
	@ReferenceNo			VARCHAR(50),
	@VoucherNo				VARCHAR(50),
	@PostingDate			VARCHAR(20),
	@PartnerDesc			VARCHAR(50),
	@COADescription			VARCHAR(200),
	@RemarkDetail			VARCHAR(5000),
	@DebetAmount			VARCHAR(20),
	@CreditAmount			VARCHAR(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow				AS INT
	DECLARE @ToRow					AS INT
	-------------------------------------------------------------
	DECLARE @_ReferenceNo			AS VARCHAR(50)
	DECLARE @_VoucherNo				AS VARCHAR(50)
	DECLARE @_PostingDate			AS VARCHAR(20)
	DECLARE @_PartnerDesc			AS VARCHAR(50)
	DECLARE @_COADescription		AS VARCHAR(200)
	DECLARE @_RemarkDetail			AS VARCHAR(5000)
	DECLARE @_DebetAmount			AS VARCHAR(20)
	DECLARE @_CreditAmount			AS VARCHAR(20)
	-------------------------------------------------------------
	DECLARE @_Sort1					AS VARCHAR(100)
	DECLARE @_Sort2					AS VARCHAR(100)
	-------------------------------------------------------------
	DECLARE @SqlSelect				AS VARCHAR(5000)
	DECLARE @SqlFrom				AS VARCHAR(5000)
	DECLARE @SqlWhere				AS VARCHAR(5000)
	DECLARE @SqlLimit				AS VARCHAR(5000)
	DECLARE @SqlOrder				AS VARCHAR(5000)

	SET @_ReferenceNo				= '%' + RTRIM(@ReferenceNo) + '%'	
	SET @_VoucherNo					= '%' + RTRIM(@VoucherNo) + '%'
	SET @_PostingDate				= '%' + RTRIM(@PostingDate) + '%'	
	SET @_PartnerDesc				= '%' + RTRIM(@PartnerDesc) + '%'	
	SET @_COADescription			= '%' + RTRIM(@COADescription) + '%'		
	SET @_RemarkDetail				= '%' + RTRIM(@RemarkDetail) + '%'
	
	IF @DebetAmount = ''
	BEGIN
		SET @_DebetAmount	 = '%' + CONVERT(VARCHAR,@DebetAmount) + '%'
	END
	ELSE
	BEGIN
		SET @_DebetAmount	 = CONVERT(VARCHAR,@DebetAmount)
	END

	IF @CreditAmount = ''
	BEGIN
		SET @_CreditAmount	 = '%' + CONVERT(VARCHAR,@CreditAmount) + '%'
	END
	ELSE
	BEGIN
		SET @_CreditAmount	 = CONVERT(VARCHAR,@CreditAmount)
	END

	SET @_Sort1 = @SortBy + ' ' + @SortDir
	SET @_Sort2 = @SortBy + ' ' + @SortDir

	IF RTRIM(@SortBy) = 'RowNumber' OR RTRIM(@SortBy) = 'ID'
	BEGIN
		SET @_Sort1 = ' JH.IDX_T_JournalHeader ' + @SortDir
		SET @_Sort2 = ' JH.IDX_T_JournalHeader ' + @SortDir
	END	
	
	--IF RTRIM(@SortBy) = 'PartnerName'
	--BEGIN
	--	SET @_Sort1 = ' GMP.PartnerName ' + @SortDir
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
								JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail, JH.IDX_M_JournalType, JH.IDX_ReferenceNo, JH.ReferenceNo, JH.VoucherNo, 
								CONVERT(VARCHAR,JH.PostingDate,106) AS PostingDate, 
								JH.PartnerDesc,
								CASE JH.IDX_M_JournalType WHEN 6 THEN FR.RemarkHeader WHEN 7 THEN FP.RemarkHeader END AS RemarkHeader,
								CASE JH.IDX_M_JournalType WHEN 6 THEN FR.ReceiveAmount WHEN 7 THEN FP.PaymentAmount END AS TransactionAmount,
								JD.COADescription, JD.RemarkDetail, JD.ODebetAmount, JD.OCreditAmount, 
								ISNULL(GROUP_JC.MappingAmount,0) AS MappingAmount,
								JH.RecordStatus, 
								StatusDesc = CASE JH.RecordStatus WHEN ''A'' THEN ''Active'' ELSE ''Unknown'' END ' 							
	
	SET @SqlFrom = 'FROM GL_T_JournalHeader JH WITH(NOLOCK)
						LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
						LEFT JOIN GL_T_JournalCashflow JC WITH(NOLOCK) ON JC.IDX_T_JournalDetail = JD.IDX_T_JournalDetail
						LEFT JOIN
								(	SELECT IDX_T_JournalDetail, SUM(Amount) AS MappingAmount 
									FROM GL_T_JournalCashflow WITH(NOLOCK)
									GROUP BY IDX_T_JournalDetail
								) GROUP_JC ON GROUP_JC.IDX_T_JournalDetail = JD.IDX_T_JournalDetail
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON COA.IDX_M_COA = JD.IDX_M_COA
						LEFT JOIN CM_M_CashflowID CFOUT WITH(NOLOCK) ON CFOUT.IDX_M_CashflowID = COA.IDX_M_CashflowOut
						LEFT JOIN CM_M_CashflowID CFIN WITH(NOLOCK) ON CFIN.IDX_M_CashflowID = COA.IDX_M_CashflowIn
						LEFT JOIN CM_M_FinancialAccount BANK WITH(NOLOCK) ON BANK.IDX_M_COA = COA.IDX_M_COA
						LEFT JOIN CM_T_FinancialReceiveHeader FR WITH(NOLOCK) ON JH.IDX_ReferenceNo = FR.IDX_T_FinancialReceiveHeader AND JH.IDX_M_JournalType = 6 AND FR.ReceiveStatus = ''A'' AND FR.RecordStatus = ''A''
						LEFT JOIN CM_T_FinancialPaymentHeader FP WITH(NOLOCK) ON JH.IDX_ReferenceNo = FP.IDX_T_FinancialPaymentHeader AND JH.IDX_M_JournalType = 7 AND FP.PaymentStatus = ''F'' AND FP.RecordStatus = ''A'' '

	--SET @SqlWhere = 'WHERE FPH.IDX_M_Branch = ' + CONVERT(VARCHAR,@IDX_M_Branch) + ' AND ISNULL(ReceiveID,'''')  LIKE ''' + @_ReceiveID + 

	IF @DebetAmount = '' OR @CreditAmount = ''
	BEGIN
		SET @SqlWhere = 'WHERE JH.IDX_M_JournalType IN (6,7) AND JH.JournalPeriod >= ''202101'' AND JH.PostingStatus = ''P'' AND JH.RecordStatus = ''A'' AND JD.RecordStatus = ''A'' 
						AND BANK.IDX_M_FinancialAccount IS NULL AND JD.IDX_M_CashflowID = 0
						AND ISNULL(JH.ReferenceNo,'''')  LIKE ''' + @_ReferenceNo + 
						''' AND ISNULL(JH.VoucherNo,'''') LIKE ''' + @_VoucherNo +
						''' AND CONVERT(VARCHAR,ISNULL(JH.PostingDate,''''),106) LIKE ''' + @_PostingDate +
						'''	AND RTRIM(ISNULL(JH.PartnerDesc,'''')) LIKE ''' + @_PartnerDesc +
						''' AND RTRIM(JD.COADescription) LIKE ''' + @_COADescription +
						''' AND RTRIM(JD.RemarkDetail) LIKE ''' + @_RemarkDetail +
						''' AND CONVERT(VARCHAR,ISNULL(JD.ODebetAmount,0)) LIKE ''' + @_DebetAmount +
						'''	AND CONVERT(VARCHAR,ISNULL(JD.OCreditAmount,0)) LIKE ''' + @_CreditAmount + ''''
	END
	ELSE
	BEGIN
		SET @SqlWhere = 'WHERE JH.IDX_M_JournalType IN (6,7) AND JH.JournalPeriod >= ''202101'' AND JH.PostingStatus = ''P'' AND JH.RecordStatus = ''A'' AND JD.RecordStatus = ''A'' 
						AND BANK.IDX_M_FinancialAccount IS NULL AND JD.IDX_M_CashflowID = 0
						AND ISNULL(JH.ReferenceNo,'''')  LIKE ''' + @_ReferenceNo + 
						''' AND ISNULL(JH.VoucherNo,'''') LIKE ''' + @_VoucherNo +
						''' AND CONVERT(VARCHAR,ISNULL(JH.PostingDate,''''),106) LIKE ''' + @_PostingDate +
						'''	AND RTRIM(ISNULL(JH.PartnerDesc,'''')) LIKE ''' + @_PartnerDesc +
						''' AND RTRIM(JD.COADescription) LIKE ''' + @_COADescription +
						''' AND RTRIM(JD.RemarkDetail) LIKE ''' + @_RemarkDetail +
						''' AND CONVERT(VARCHAR,ISNULL(FLOOR(JD.ODebetAmount),0)) = ''' + @_DebetAmount +
						'''	AND CONVERT(VARCHAR,ISNULL(FLOOR(JD.OCreditAmount),0)) = ''' + @_CreditAmount + ''''
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
