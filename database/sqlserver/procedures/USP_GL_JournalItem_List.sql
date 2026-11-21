-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal Item
-- =============================================

/*	
	EXEC [dbo].[USP_GL_JournalItem_List] 1,10,'RowNumber','asc','R',1,1,'','','','','','','','',''
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalItem_List] 
	@Page					INT,	
	@Row					INT,
	@SortBy					VARCHAR(50),
	@SortDir				VARCHAR(50),
	@ReturnType				CHAR(1), --R = Record, C = Count
	---------------------------------------------
	@IDX_M_Company			BIGINT,
	@IDX_M_Branch			BIGINT,
	@COAID					VARCHAR(50),
	@COADesc				VARCHAR(50),	
	@VoucherNo				VARCHAR(50),
	@RemarkHeader			VARCHAR(50),
	@PostingStatus			VARCHAR(1),
	@PartnerDesc			VARCHAR(50),	
	@RemarkDetail			VARCHAR(50),
	@BDebetAmount			VARCHAR(50),
	@BCreditAmount			VARCHAR(50)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @FromRow			AS INT
	DECLARE @ToRow				AS INT

	DECLARE @_COAID				AS VARCHAR(50)
	DECLARE @_COADesc			AS VARCHAR(50)
	DECLARE @_VoucherNo			AS VARCHAR(50)
	DECLARE @_RemarkHeader		AS VARCHAR(50)
	DECLARE @_PostingStatus		AS VARCHAR(50)
	DECLARE @_PartnerDesc		AS VARCHAR(50)	
	DECLARE @_Sort				AS VARCHAR(100)
	DECLARE @_RemarkDetail		AS VARCHAR(50)
	DECLARE @_BDebetAmount		AS VARCHAR(50)
	DECLARE @_BCreditAmount		AS VARCHAR(50)

	DECLARE @SqlSelect			AS VARCHAR(5000)
	DECLARE @SqlFrom			AS VARCHAR(5000)
	DECLARE @SqlWhere			AS VARCHAR(5000)
	DECLARE @SqlLimit			AS VARCHAR(5000)
	DECLARE @SqlOrder			AS VARCHAR(5000)

	SET @_COAID = '%' + RTRIM(@COAID) + '%'
	SET @_COADesc = '%' + RTRIM(@COADesc) + '%'
	SET @_VoucherNo = '%' + RTRIM(@VoucherNo) + '%'
	SET @_RemarkHeader = '%' + RTRIM(@RemarkHeader) + '%'
	SET @_PostingStatus = '%' + RTRIM(@PostingStatus) + '%'
	SET @_PartnerDesc = '%' + RTRIM(@PartnerDesc) + '%'	
	SET @_RemarkDetail = '%' + RTRIM(@RemarkDetail) + '%'
	SET @_BDebetAmount = '%' + RTRIM(@BDebetAmount) + '%'
	SET @_BCreditAmount = '%' + RTRIM(@BCreditAmount) + '%'

	IF RTRIM(@SortBy) = 'RowNumber'
		SET @SortBy = 'IDX_T_JournalDetail'

	IF RTRIM(@SortBy) = 'IDX_M_Company'
		SET @SortBy = 'IDX_T_JournalDetail'

	SET @_Sort = @SortBy + ' ' + @SortDir

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

	SET @SqlSelect = 'SELECT * FROM (
						SELECT ROW_NUMBER() OVER (ORDER BY ' + @_Sort + ') AS RowNumber, 
							JH.IDX_M_Company, MC.CompanyName, JH.IDX_M_Branch, MB.BranchName, 
							JD.IDX_T_JournalHeader, JD.IDX_T_JournalDetail, JD.IDX_M_Partner, PartnerDesc, 
							VoucherNo, CONVERT(VARCHAR,JournalDate,106) AS JournalDate, RemarkHeader, PostingStatus,
							PostingStatusDesc = CASE PostingStatus WHEN ''P'' THEN ''Posted'' WHEN ''U'' THEN ''Unposted'' END, 
							COA.COAID, COA.COADesc, COA.COADesc2, JD.RemarkDetail, JD.OriginalCurrencyID, JD.ODebetAmount, JD.OCreditAmount, 
							JD.BaseCurrencyID, JD.BDebetAmount, JD.BCreditAmount '
								
	SET @SqlFrom = ' FROM GL_T_JournalDetail JD (NOLOCK) 
							LEFT JOIN GL_T_JournalHeader JH (NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
							LEFT JOIN GN_M_Company MC ON JH.IDX_M_Company = MC.IDX_M_Company
							LEFT JOIN GN_M_Branch MB ON JH.IDX_M_Branch = MB.IDX_M_Branch 
							LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA '

	SET @SqlWhere = ' WHERE RTRIM(ISNULL(COA.COAID,'''')) LIKE ''' + @_COAID + 
						''' AND RTRIM(ISNULL(COA.COADesc,'''')) LIKE ''' + @_COADesc + 
						''' AND RTRIM(ISNULL(JH.VoucherNo,'''')) LIKE ''' + @_VoucherNo + 
						''' AND RTRIM(ISNULL(JH.RemarkHeader,'''')) LIKE ''' + @_RemarkHeader + 
						''' AND RTRIM(ISNULL(JH.PartnerDesc,'''')) LIKE ''' + @_PartnerDesc + 
						''' AND RTRIM(ISNULL(JH.PostingStatus,'''')) LIKE ''' + @_PostingStatus + 
						''' AND RTRIM(ISNULL(JD.RemarkDetail,'''')) LIKE ''' + @_RemarkDetail + 
						''' AND RTRIM(ISNULL(CONVERT(VARCHAR,JD.BDebetAmount),'''')) LIKE ''' + @_BDebetAmount + 
						''' AND RTRIM(ISNULL(CONVERT(VARCHAR,JD.BCreditAmount),'''')) LIKE ''' + @_BCreditAmount + '''' 						

	SET @SqlLimit = ') AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR,@FromRow) + ' AND ' + CONVERT(VARCHAR,@ToRow) 

	SET @SqlOrder = ' ORDER BY ' + @_Sort

    IF @ReturnType = 'R'
	BEGIN
		--PRINT(@SqlSelect + @SqlFrom  + @SqlWhere + @SqlLimit + @SqlOrder)
		EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit + @SqlOrder)
	END
	
	IF @ReturnType = 'C'
	BEGIN
		--PRINT ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
		EXEC ('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)		
	END
END



