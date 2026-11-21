

/* =====================================================================================
   3. SP: USP_CM_InternalTransfer_List   (DataTables server-side)
   Param order MUST match MyController::get_datatables + controller array_filter:
   @Page,@Row,@SortBy,@SortDir,@ReturnType, then filters..., @UserID
   ===================================================================================== */
/*
    EXEC [dbo].[USP_CM_InternalTransfer_List] 1,10,'RowNumber','asc','R','','','','','','','','','','','it_febry'
*/
CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_List]
    @Page               INT,
    @Row                INT,
    @SortBy             VARCHAR(50),
    @SortDir            VARCHAR(50),
    @ReturnType         CHAR(1),            -- R = Record, C = Count
    ----------------------------------------------------------------
    @IDX_M_Company      VARCHAR(50),
    @IDX_M_Branch       VARCHAR(50),
    @CompanyName        VARCHAR(50),
    @TransferID         VARCHAR(50),
    @VoucherNoManual    VARCHAR(50),
    @FromAccountID      VARCHAR(50),
    @ToAccountID        VARCHAR(50),
    @TransferDate       VARCHAR(50),
    @TransferAmount     VARCHAR(50),
    @RemarkHeader       VARCHAR(50),
    @UserID             VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FromRow            INT
    DECLARE @ToRow              INT
    DECLARE @_Sort             VARCHAR(100)

    DECLARE @SqlSelect          VARCHAR(MAX)
    DECLARE @SqlFrom            VARCHAR(MAX)
    DECLARE @SqlWhere           VARCHAR(MAX)
    DECLARE @SqlLimit           VARCHAR(MAX)

    SET @_Sort = @SortBy + ' ' + @SortDir
    IF RTRIM(@SortBy) IN ('RowNumber','ID','IDX_T_InternalTransferHeader')
        SET @_Sort = ' IT.IDX_T_InternalTransferHeader ' + @SortDir
    IF RTRIM(@SortBy) = 'CompanyName'
        SET @_Sort = ' C.CompanyName ' + @SortDir

    IF @Page = 1
    BEGIN
        SET @FromRow = 1
        SET @ToRow = @Row
    END
    ELSE
    BEGIN
        SET @FromRow = ((@Page * @Row) - @Row) + 1
        SET @ToRow = @FromRow + @Row - 1
    END

    SET @SqlSelect = '
        SELECT * FROM (
            SELECT
                ROW_NUMBER() OVER (ORDER BY ' + @_Sort + ') AS RowNumber,
                IT.IDX_T_InternalTransferHeader,
                IT.IDX_M_Company, IT.IDX_M_Branch,
                ISNULL(C.CompanyName,'''') AS CompanyName,
                ISNULL(IT.TransferID,'''') AS TransferID,
                ISNULL(IT.VoucherNoManual,'''') AS VoucherNoManual,
                ISNULL(FA.FinancialAccountID,'''') AS FromAccountID,
                ISNULL(TA.FinancialAccountID,'''') AS ToAccountID,
                CONVERT(VARCHAR(10), IT.TransferDate, 120) AS TransferDate,
                ISNULL(IT.TransferAmount,0) AS TransferAmount,
                ISNULL(IT.RemarkHeader,'''') AS RemarkHeader,
                StatusDesc = CASE IT.TransferStatus
                    WHEN ''D'' THEN ''Draft'' WHEN ''A'' THEN ''Approved''
                    WHEN ''V'' THEN ''Void'' ELSE ''Unknown'' END '

    SET @SqlFrom = '
        FROM CM_T_InternalTransferHeader IT WITH(NOLOCK)
            LEFT JOIN GN_M_Company C WITH(NOLOCK) ON C.IDX_M_Company = IT.IDX_M_Company
            LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON B.IDX_M_Branch = IT.IDX_M_Branch
            LEFT JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FA.IDX_M_FinancialAccount = IT.IDX_M_FromFinancialAccount
            LEFT JOIN CM_M_FinancialAccount TA WITH(NOLOCK) ON TA.IDX_M_FinancialAccount = IT.IDX_M_ToFinancialAccount
            INNER JOIN ( SELECT UB.IDX_M_Branch
                         FROM SM_M_User U WITH(NOLOCK)
                            INNER JOIN SM_M_UserBranch UB WITH(NOLOCK) ON U.IDX_M_User = UB.IDX_M_User
                         WHERE UB.RecordStatus = ''A'' AND RTRIM(U.LoginID) = ''' + @UserID + ''') UBR ON IT.IDX_M_Branch = UBR.IDX_M_Branch '

    SET @SqlWhere = '
        WHERE ISNULL(IT.RecordStatus,''A'') = ''A''
            AND ( ''' + @IDX_M_Company + ''' = '''' OR IT.IDX_M_Company = ''' + @IDX_M_Company + ''' )
            AND ( ''' + @IDX_M_Branch + ''' = '''' OR IT.IDX_M_Branch = ''' + @IDX_M_Branch + ''' )
            AND ISNULL(C.CompanyName,'''') LIKE ''%' + RTRIM(@CompanyName) + '%''
            AND RTRIM(ISNULL(IT.TransferID,'''')) LIKE ''%' + RTRIM(@TransferID) + '%''
            AND RTRIM(ISNULL(IT.VoucherNoManual,'''')) LIKE ''%' + RTRIM(@VoucherNoManual) + '%''
            AND RTRIM(ISNULL(FA.FinancialAccountID,'''')) LIKE ''%' + RTRIM(@FromAccountID) + '%''
            AND RTRIM(ISNULL(TA.FinancialAccountID,'''')) LIKE ''%' + RTRIM(@ToAccountID) + '%''
            AND CONVERT(VARCHAR(10), IT.TransferDate, 120) LIKE ''%' + RTRIM(@TransferDate) + '%''
            AND RTRIM(ISNULL(IT.RemarkHeader,'''')) LIKE ''%' + RTRIM(@RemarkHeader) + '%'' '

    SET @SqlLimit = ' ) AS DerivedTable WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR, @FromRow) + ' AND ' + CONVERT(VARCHAR, @ToRow)

    IF @ReturnType = 'R'
        EXEC(@SqlSelect + @SqlFrom + @SqlWhere + @SqlLimit)

    IF @ReturnType = 'C'
        EXEC('SELECT COUNT(*) AS TotalRows ' + @SqlFrom + @SqlWhere)
END
