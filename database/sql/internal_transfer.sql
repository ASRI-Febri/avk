/* =====================================================================================
   INTERNAL TRANSFER (Finance > Transaksi > Internal Transfer)
   -------------------------------------------------------------------------------------
   Transfer dana antar financial account, mis. setoran tunai (Cash -> Bank) atau
   tarik tunai (Bank -> Cash).

   Workflow: Draft (D) -> Approved (A) -> Reverse to Draft (D) / Void (V)
   Pada saat Approve, sistem posting jurnal:
        Dr  COA financial account TUJUAN  (uang masuk ke account tujuan)
        Cr  COA financial account ASAL    (uang keluar dari account asal)

   Run order: tables first, then stored procedures.

   NOTE FOR DBA / REVIEWER:
   - Nama kolom tabel GL_T_JournalHeader / GL_T_JournalDetail dan GL_M_JournalType
     pada lingkungan produksi WAJIB diverifikasi. Bagian yang menyentuh jurnal sudah
     ditandai dengan komentar "-- VERIFY".
   - @_IDX_M_JournalType untuk Internal Transfer perlu didaftarkan di GL_M_JournalType
     dan disesuaikan (lihat komentar "-- VERIFY JOURNAL TYPE").
   - Hak akses menu (FormID: FM-IT-R / FM-IT-C / FM-IT-U / FM-IT-A) didaftarkan di
     SM_M_Form lalu di-assign ke group user (lihat bagian paling bawah).
   ===================================================================================== */


/* =====================================================================================
   1. TABLE: CM_T_InternalTransferHeader
   ===================================================================================== */
IF OBJECT_ID('dbo.CM_T_InternalTransferHeader', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CM_T_InternalTransferHeader](
        [IDX_T_InternalTransferHeader]  BIGINT IDENTITY(1,1) NOT NULL,
        [IDX_M_Company]                 INT             NULL,
        [IDX_M_Branch]                  INT             NULL,
        [IDX_M_DocumentType]            INT             NULL,
        [IDX_M_FromFinancialAccount]    BIGINT          NULL,
        [IDX_M_ToFinancialAccount]      BIGINT          NULL,
        [FromCOA]                       BIGINT          NULL,   -- IDX_M_COA financial account asal
        [ToCOA]                         BIGINT          NULL,   -- IDX_M_COA financial account tujuan
        [TransferID]                    VARCHAR(50)     NULL,   -- nomor dokumen (auto)
        [VoucherNoManual]               VARCHAR(50)     NULL,
        [TransferDate]                  DATE            NULL,
        [TransferAmount]                DECIMAL(22,2)   NULL,
        [RemarkHeader]                  VARCHAR(500)    NULL,
        [TransferStatus]                CHAR(1)         NULL,   -- D=Draft, A=Approved, V=Void
        [ApprovalDate]                  DATE            NULL,
        [ApprovalRemark]                VARCHAR(500)    NULL,
        [ApprovalBy]                    VARCHAR(50)     NULL,
        [VoidDate]                      DATE            NULL,
        [VoidReason]                    VARCHAR(500)    NULL,
        [VoidBy]                        VARCHAR(50)     NULL,
        [UCreate]                       VARCHAR(50)     NULL,
        [DCreate]                       DATETIME        NULL,
        [UModified]                     VARCHAR(50)     NULL,
        [DModified]                     DATETIME        NULL,
        [RecordStatus]                  CHAR(1)         NULL,
        CONSTRAINT [PK_CM_T_InternalTransferHeader] PRIMARY KEY CLUSTERED ([IDX_T_InternalTransferHeader] ASC)
    )
END
GO


/* =====================================================================================
   2. TABLE: CM_T_InternalTransferLog
   ===================================================================================== */
IF OBJECT_ID('dbo.CM_T_InternalTransferLog', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CM_T_InternalTransferLog](
        [IDX_T_InternalTransferLog]     BIGINT IDENTITY(1,1) NOT NULL,
        [IDX_T_InternalTransferHeader]  BIGINT          NULL,
        [LogType]                       VARCHAR(20)     NULL,   -- Approve / Reverse / Void
        [LogDate]                       DATETIME        NULL,
        [LogRemark]                     VARCHAR(500)    NULL,
        [UCreate]                       VARCHAR(50)     NULL,
        [DCreate]                       DATETIME        NULL,
        [RecordStatus]                  CHAR(1)         NULL,
        CONSTRAINT [PK_CM_T_InternalTransferLog] PRIMARY KEY CLUSTERED ([IDX_T_InternalTransferLog] ASC)
    )
END
GO


/* =====================================================================================
   3. SP: USP_CM_InternalTransfer_List   (DataTables server-side)
   Param order MUST match MyController::get_datatables + controller array_filter:
   @Page,@Row,@SortBy,@SortDir,@ReturnType, then filters..., @UserID
   ===================================================================================== */
/*
    EXEC [dbo].[USP_CM_InternalTransfer_List] 1,10,'RowNumber','asc','R','','','','','','','','','','','it_febry'
*/
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_List]
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
GO


/* =====================================================================================
   4. SP: USP_CM_InternalTransfer_Info   (single record by id; @IDX from get_detail_by_id)
   ===================================================================================== */
-- EXEC [dbo].[USP_CM_InternalTransfer_Info] 1
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_Info]
    @IDX    BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IT.IDX_T_InternalTransferHeader,
        IT.IDX_M_Company, IT.IDX_M_Branch, IT.IDX_M_DocumentType,
        IT.IDX_M_FromFinancialAccount, IT.IDX_M_ToFinancialAccount,
        IT.FromCOA, IT.ToCOA,
        IT.TransferID, IT.VoucherNoManual,
        CONVERT(VARCHAR(10), IT.TransferDate, 120) AS TransferDate,
        ISNULL(IT.TransferAmount,0) AS TransferAmount,
        IT.RemarkHeader, IT.TransferStatus,
        CONVERT(VARCHAR(10), IT.ApprovalDate, 120) AS ApprovalDate,
        IT.ApprovalRemark, IT.ApprovalBy,
        CONVERT(VARCHAR(10), IT.VoidDate, 120) AS VoidDate,
        IT.VoidReason, IT.VoidBy,
        IT.UCreate, IT.DCreate, IT.UModified, IT.DModified, IT.RecordStatus,
        StatusDesc = CASE IT.TransferStatus
            WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved'
            WHEN 'V' THEN 'Void' ELSE 'Unknown' END,
        C.CompanyID, C.CompanyName, C.CompanyName AS CompanyDesc,
        ISNULL(C.Phone,'') AS CompanyPhone,
        B.BranchID, B.BranchName,
        FA.FinancialAccountID AS FromAccountID, FA.FinancialAccountDesc AS FromAccountDesc,
        TA.FinancialAccountID AS ToAccountID,   TA.FinancialAccountDesc AS ToAccountDesc
    FROM CM_T_InternalTransferHeader IT WITH(NOLOCK)
        LEFT JOIN GN_M_Company C WITH(NOLOCK) ON C.IDX_M_Company = IT.IDX_M_Company
        LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON B.IDX_M_Branch = IT.IDX_M_Branch
        LEFT JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FA.IDX_M_FinancialAccount = IT.IDX_M_FromFinancialAccount
        LEFT JOIN CM_M_FinancialAccount TA WITH(NOLOCK) ON TA.IDX_M_FinancialAccount = IT.IDX_M_ToFinancialAccount
    WHERE IT.IDX_T_InternalTransferHeader = @IDX
END
GO


/* =====================================================================================
   5. SP: USP_CM_InternalTransferHeader_Create
   Param order MUST match InternalTransferController::save (create branch):
   IDX_M_Company, IDX_M_Branch, IDX_M_DocumentType, IDX_M_FromFinancialAccount,
   IDX_M_ToFinancialAccount, FromCOA, ToCOA, TransferID, VoucherNoManual, TransferDate,
   RemarkHeader, TransferStatus, TransferAmount, UserID, RecordStatus
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransferHeader_Create]
    @IDX_M_Company                  INT,
    @IDX_M_Branch                   INT,
    @IDX_M_DocumentType             INT,
    @IDX_M_FromFinancialAccount     BIGINT,
    @IDX_M_ToFinancialAccount       BIGINT,
    @FromCOA                        BIGINT,
    @ToCOA                          BIGINT,
    @TransferID                     VARCHAR(50),
    @VoucherNoManual                VARCHAR(50),
    @TransferDate                   DATE,
    @RemarkHeader                   VARCHAR(500),
    @TransferStatus                 CHAR(1),
    @TransferAmount                 DECIMAL(22,2),
    @UserID                         VARCHAR(50),
    @RecordStatus                   CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @_CountLog INT
            DECLARE @TableLog TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
            DECLARE @_IDX_T_InternalTransferHeader BIGINT

            IF ISNULL(@IDX_M_Company,0) = 0
                INSERT INTO @TableLog VALUES ('error',0,'Perusahaan belum diisi!')
            IF ISNULL(@IDX_M_Branch,0) = 0
                INSERT INTO @TableLog VALUES ('error',0,'Profit center belum diisi!')
            IF ISNULL(@IDX_M_FromFinancialAccount,0) = 0
                INSERT INTO @TableLog VALUES ('error',0,'Financial account asal belum diisi!')
            IF ISNULL(@IDX_M_ToFinancialAccount,0) = 0
                INSERT INTO @TableLog VALUES ('error',0,'Financial account tujuan belum diisi!')
            IF @IDX_M_FromFinancialAccount = @IDX_M_ToFinancialAccount
                INSERT INTO @TableLog VALUES ('error',0,'Financial account asal dan tujuan tidak boleh sama!')
            IF ISNULL(@TransferAmount,0) <= 0
                INSERT INTO @TableLog VALUES ('error',0,'Jumlah transfer harus lebih dari 0!')

            SELECT @_CountLog = COUNT(*) FROM @TableLog

            IF @_CountLog = 0
            BEGIN
                INSERT INTO [dbo].[CM_T_InternalTransferHeader]
                    ([IDX_M_Company],[IDX_M_Branch],[IDX_M_DocumentType],
                     [IDX_M_FromFinancialAccount],[IDX_M_ToFinancialAccount],[FromCOA],[ToCOA],
                     [TransferID],[VoucherNoManual],[TransferDate],[TransferAmount],
                     [RemarkHeader],[TransferStatus],[UCreate],[DCreate],[RecordStatus])
                VALUES
                    (@IDX_M_Company,@IDX_M_Branch,@IDX_M_DocumentType,
                     @IDX_M_FromFinancialAccount,@IDX_M_ToFinancialAccount,@FromCOA,@ToCOA,
                     @TransferID,@VoucherNoManual,@TransferDate,@TransferAmount,
                     @RemarkHeader,'D',@UserID,GETDATE(),@RecordStatus)

                SET @_IDX_T_InternalTransferHeader = SCOPE_IDENTITY()

                -- Auto document number: IT/{Company}/{yyyyMM}/{6-digit id}
                UPDATE [dbo].[CM_T_InternalTransferHeader]
                SET TransferID = 'IT/' + RTRIM(CONVERT(VARCHAR,@IDX_M_Company)) + '/'
                                 + FORMAT(@TransferDate,'yyyyMM') + '/'
                                 + RIGHT('000000' + CONVERT(VARCHAR,@_IDX_T_InternalTransferHeader),6)
                WHERE IDX_T_InternalTransferHeader = @_IDX_T_InternalTransferHeader

                INSERT INTO @TableLog VALUES ('success', @_IDX_T_InternalTransferHeader, 'Data Sudah Disimpan')
            END

            SELECT * FROM @TableLog
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @Log2 TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
        INSERT INTO @Log2 VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
        SELECT * FROM @Log2
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
        IF (XACT_STATE()) = 1 COMMIT TRANSACTION;
    END CATCH;
END
GO


/* =====================================================================================
   6. SP: USP_CM_InternalTransferHeader_Update
   Param order MUST match save (update branch):
   IDX_T_InternalTransferHeader, then same as create.
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransferHeader_Update]
    @IDX_T_InternalTransferHeader   BIGINT,
    @IDX_M_Company                  INT,
    @IDX_M_Branch                   INT,
    @IDX_M_DocumentType             INT,
    @IDX_M_FromFinancialAccount     BIGINT,
    @IDX_M_ToFinancialAccount       BIGINT,
    @FromCOA                        BIGINT,
    @ToCOA                          BIGINT,
    @TransferID                     VARCHAR(50),
    @VoucherNoManual                VARCHAR(50),
    @TransferDate                   DATE,
    @RemarkHeader                   VARCHAR(500),
    @TransferStatus                 CHAR(1),
    @TransferAmount                 DECIMAL(22,2),
    @UserID                         VARCHAR(50),
    @RecordStatus                   CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @_CountLog INT
            DECLARE @TableLog TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )

            IF EXISTS(SELECT 1 FROM CM_T_InternalTransferHeader
                      WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus <> 'D')
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Hanya transaksi berstatus Draft yang dapat diubah!')
            IF @IDX_M_FromFinancialAccount = @IDX_M_ToFinancialAccount
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Financial account asal dan tujuan tidak boleh sama!')
            IF ISNULL(@TransferAmount,0) <= 0
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Jumlah transfer harus lebih dari 0!')

            SELECT @_CountLog = COUNT(*) FROM @TableLog

            IF @_CountLog = 0
            BEGIN
                UPDATE [dbo].[CM_T_InternalTransferHeader] SET
                     [IDX_M_Company] = @IDX_M_Company
                    ,[IDX_M_Branch] = @IDX_M_Branch
                    ,[IDX_M_DocumentType] = @IDX_M_DocumentType
                    ,[IDX_M_FromFinancialAccount] = @IDX_M_FromFinancialAccount
                    ,[IDX_M_ToFinancialAccount] = @IDX_M_ToFinancialAccount
                    ,[FromCOA] = @FromCOA
                    ,[ToCOA] = @ToCOA
                    ,[VoucherNoManual] = @VoucherNoManual
                    ,[TransferDate] = @TransferDate
                    ,[TransferAmount] = @TransferAmount
                    ,[RemarkHeader] = @RemarkHeader
                    ,[UModified] = @UserID
                    ,[DModified] = GETDATE()
                    ,[RecordStatus] = @RecordStatus
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Data Sudah Disimpan')
            END

            SELECT * FROM @TableLog
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @Log2 TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
        INSERT INTO @Log2 VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
        SELECT * FROM @Log2
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
        IF (XACT_STATE()) = 1 COMMIT TRANSACTION;
    END CATCH;
END
GO


/* =====================================================================================
   7. SP: USP_CM_InternalTransfer_Approve   (approve + posting jurnal)
   Param order: IDX_T_InternalTransferHeader, ApprovalDate, ApprovalRemark, UserID
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_Approve]
    @IDX_T_InternalTransferHeader   BIGINT,
    @ApprovalDate                   DATE,
    @ApprovalRemark                 VARCHAR(500),
    @UserID                         VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @_CountLog INT
            DECLARE @TableLog TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )

            -- VERIFY JOURNAL TYPE: daftarkan tipe jurnal "Internal Transfer" di GL_M_JournalType
            -- lalu set IDX yang sesuai di sini.
            DECLARE @_IDX_M_JournalType INT = 9   -- VERIFY

            DECLARE @_IDX_M_Company INT, @_IDX_M_Branch INT
            DECLARE @_FromCOA BIGINT, @_ToCOA BIGINT
            DECLARE @_TransferID VARCHAR(50), @_TransferAmount DECIMAL(22,2)
            DECLARE @_RemarkHeader VARCHAR(500)
            DECLARE @_FromCOADesc VARCHAR(256), @_ToCOADesc VARCHAR(256)

            IF NOT EXISTS(SELECT 1 FROM CM_T_InternalTransferHeader
                          WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus = 'D')
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Transaksi tidak ditemukan atau sudah di-approve!')

            SELECT @_CountLog = COUNT(*) FROM @TableLog

            IF @_CountLog = 0
            BEGIN
                SELECT @_IDX_M_Company = IDX_M_Company, @_IDX_M_Branch = IDX_M_Branch,
                       @_FromCOA = FromCOA, @_ToCOA = ToCOA,
                       @_TransferID = TransferID, @_TransferAmount = TransferAmount,
                       @_RemarkHeader = RemarkHeader
                FROM CM_T_InternalTransferHeader
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                SELECT @_FromCOADesc = ISNULL(COADesc,'') FROM GL_M_COA WHERE IDX_M_COA = @_FromCOA
                SELECT @_ToCOADesc   = ISNULL(COADesc,'') FROM GL_M_COA WHERE IDX_M_COA = @_ToCOA

                -- ============================================================
                -- POST JOURNAL (columns mirror USP_CM_FinancialReceive_CreateJournal)
                --   Dr  account tujuan (ToCOA)
                --   Cr  account asal   (FromCOA)
                -- ============================================================
                DECLARE @_IDX_T_JournalHeader BIGINT

                INSERT INTO [dbo].[GL_T_JournalHeader]
                    ([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]
                    ,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
                    ,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
                    ,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
                    ,[JournalSource],[UCreate],[DCreate],[RecordStatus])
                VALUES
                    (@_IDX_M_Company,@_IDX_M_Branch,@_IDX_M_JournalType,0
                    ,0,@IDX_T_InternalTransferHeader,@_TransferID,@_TransferID
                    ,@ApprovalDate,@_RemarkHeader,'','P'
                    ,@ApprovalDate,@UserID,@_TransferAmount,@_TransferAmount
                    ,'S',@UserID,GETDATE(),'A')

                SET @_IDX_T_JournalHeader = SCOPE_IDENTITY()

                -- Debit account tujuan
                INSERT INTO [dbo].[GL_T_JournalDetail]
                    ([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
                    ,[IDX_M_Partner]
                    ,[JournalSeqNo],[COADescription],[RemarkDetail]
                    ,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
                    ,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
                VALUES
                    (@_IDX_T_JournalHeader,99,99,@_ToCOA
                    ,0
                    ,1,@_ToCOADesc,'Internal Transfer ' + @_TransferID
                    ,1,@_TransferAmount,0,1
                    ,1,@_TransferAmount,0,@UserID,GETDATE(),'A')

                -- Credit account asal
                INSERT INTO [dbo].[GL_T_JournalDetail]
                    ([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
                    ,[IDX_M_Partner]
                    ,[JournalSeqNo],[COADescription],[RemarkDetail]
                    ,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
                    ,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
                VALUES
                    (@_IDX_T_JournalHeader,99,99,@_FromCOA
                    ,0
                    ,2,@_FromCOADesc,'Internal Transfer ' + @_TransferID
                    ,1,0,@_TransferAmount,1
                    ,1,0,@_TransferAmount,@UserID,GETDATE(),'A')

                -- ============================================================
                -- UPDATE HEADER STATUS
                -- ============================================================
                UPDATE [dbo].[CM_T_InternalTransferHeader] SET
                     TransferStatus = 'A'
                    ,ApprovalDate = @ApprovalDate
                    ,ApprovalRemark = @ApprovalRemark
                    ,ApprovalBy = @UserID
                    ,UModified = @UserID
                    ,DModified = GETDATE()
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                INSERT INTO [dbo].[CM_T_InternalTransferLog]
                    (IDX_T_InternalTransferHeader,LogType,LogDate,LogRemark,UCreate,DCreate,RecordStatus)
                VALUES
                    (@IDX_T_InternalTransferHeader,'Approve',GETDATE(),@ApprovalRemark,@UserID,GETDATE(),'A')

                INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Transaksi berhasil di-approve')
            END

            SELECT * FROM @TableLog
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @Log2 TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
        INSERT INTO @Log2 VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
        SELECT * FROM @Log2
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
        IF (XACT_STATE()) = 1 COMMIT TRANSACTION;
    END CATCH;
END
GO


/* =====================================================================================
   8. SP: USP_CM_InternalTransfer_ReverseValidate   (Approved -> Draft, hapus jurnal)
   Param order: IDX_T_InternalTransferHeader, ApprovalRemark, ApprovalBy
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_ReverseValidate]
    @IDX_T_InternalTransferHeader   BIGINT,
    @ApprovalRemark                 VARCHAR(500),
    @ApprovalBy                     VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @_CountLog INT
            DECLARE @TableLog TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
            DECLARE @_IDX_M_JournalType INT = 9   -- VERIFY (samakan dengan Approve)
            DECLARE @_TransferID VARCHAR(50)
            DECLARE @_IDX_T_JournalHeader BIGINT

            IF NOT EXISTS(SELECT 1 FROM CM_T_InternalTransferHeader
                          WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus = 'A')
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Hanya transaksi berstatus Approved yang dapat di-reverse!')

            SELECT @_CountLog = COUNT(*) FROM @TableLog

            IF @_CountLog = 0
            BEGIN
                SELECT @_TransferID = TransferID
                FROM CM_T_InternalTransferHeader
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                -- DELETE JOURNAL  -- VERIFY
                SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader
                FROM GL_T_JournalHeader
                WHERE IDX_ReferenceNo = @IDX_T_InternalTransferHeader
                    AND RTRIM(ReferenceNo) = RTRIM(@_TransferID)
                    AND IDX_M_JournalType = @_IDX_M_JournalType

                IF @_IDX_T_JournalHeader IS NOT NULL
                BEGIN
                    DELETE GL_T_JournalDetail WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
                    DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
                END

                UPDATE [dbo].[CM_T_InternalTransferHeader] SET
                     TransferStatus = 'D'
                    ,ApprovalDate = NULL
                    ,ApprovalBy = NULL
                    ,UModified = @ApprovalBy
                    ,DModified = GETDATE()
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                INSERT INTO [dbo].[CM_T_InternalTransferLog]
                    (IDX_T_InternalTransferHeader,LogType,LogDate,LogRemark,UCreate,DCreate,RecordStatus)
                VALUES
                    (@IDX_T_InternalTransferHeader,'Reverse',GETDATE(),@ApprovalRemark,@ApprovalBy,GETDATE(),'A')

                INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Transaksi dikembalikan ke Draft')
            END

            SELECT * FROM @TableLog
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @Log2 TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
        INSERT INTO @Log2 VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
        SELECT * FROM @Log2
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
        IF (XACT_STATE()) = 1 COMMIT TRANSACTION;
    END CATCH;
END
GO


/* =====================================================================================
   9. SP: USP_CM_InternalTransfer_Void   (Approved -> Void, hapus jurnal)
   Param order: IDX_T_InternalTransferHeader, VoidDate, VoidReason, UserID
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_Void]
    @IDX_T_InternalTransferHeader   BIGINT,
    @VoidDate                       DATE,
    @VoidReason                     VARCHAR(500),
    @UserID                         VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @_CountLog INT
            DECLARE @TableLog TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
            DECLARE @_IDX_M_JournalType INT = 9   -- VERIFY (samakan dengan Approve)
            DECLARE @_TransferID VARCHAR(50)
            DECLARE @_IDX_T_JournalHeader BIGINT

            IF NOT EXISTS(SELECT 1 FROM CM_T_InternalTransferHeader
                          WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus = 'A')
                INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Hanya transaksi berstatus Approved yang dapat di-void!')

            SELECT @_CountLog = COUNT(*) FROM @TableLog

            IF @_CountLog = 0
            BEGIN
                SELECT @_TransferID = TransferID
                FROM CM_T_InternalTransferHeader
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                -- DELETE JOURNAL  -- VERIFY
                SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader
                FROM GL_T_JournalHeader
                WHERE IDX_ReferenceNo = @IDX_T_InternalTransferHeader
                    AND RTRIM(ReferenceNo) = RTRIM(@_TransferID)
                    AND IDX_M_JournalType = @_IDX_M_JournalType

                IF @_IDX_T_JournalHeader IS NOT NULL
                BEGIN
                    DELETE GL_T_JournalDetail WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
                    DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
                END

                UPDATE [dbo].[CM_T_InternalTransferHeader] SET
                     TransferStatus = 'V'
                    ,VoidDate = @VoidDate
                    ,VoidReason = @VoidReason
                    ,VoidBy = @UserID
                    ,UModified = @UserID
                    ,DModified = GETDATE()
                WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

                INSERT INTO [dbo].[CM_T_InternalTransferLog]
                    (IDX_T_InternalTransferHeader,LogType,LogDate,LogRemark,UCreate,DCreate,RecordStatus)
                VALUES
                    (@IDX_T_InternalTransferHeader,'Void',GETDATE(),@VoidReason,@UserID,GETDATE(),'A')

                INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Transaksi berhasil di-void')
            END

            SELECT * FROM @TableLog
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @Log2 TABLE ( Result VARCHAR(20), ID BIGINT, LogDesc VARCHAR(500) )
        INSERT INTO @Log2 VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
        SELECT * FROM @Log2
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
        IF (XACT_STATE()) = 1 COMMIT TRANSACTION;
    END CATCH;
END
GO


/* =====================================================================================
   10. SP: USP_CM_InternalTransfer_Journal_List   (untuk tab Journal & PDF)
   Param: IDX_T_InternalTransferHeader
   -- VERIFY kolom GL_T_JournalHeader / GL_T_JournalDetail / GL_M_COA
   ===================================================================================== */
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_InternalTransfer_Journal_List]
    @IDX_T_InternalTransferHeader   BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @_IDX_M_JournalType INT = 9   -- VERIFY (samakan dengan Approve)

    SELECT
        ISNULL(JH.ReferenceNo,'') AS VoucherNo,
        CONVERT(VARCHAR(10), JH.JournalDate, 120) AS JournalDate,
        'Internal Transfer' AS JournalType,
        COA.COAID, COA.COADesc,
        '' AS ProjectID,
        ISNULL(JD.RemarkDetail,'') AS JournalDesc,
        ISNULL(JD.RemarkDetail,'') AS RemarkDetail,
        ISNULL(JD.BDebetAmount,0) AS BDebetAmount,
        ISNULL(JD.BCreditAmount,0) AS BCreditAmount
    FROM GL_T_JournalHeader JH WITH(NOLOCK)
        INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
        INNER JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
    WHERE JH.IDX_ReferenceNo = @IDX_T_InternalTransferHeader
        AND JH.IDX_M_JournalType = @_IDX_M_JournalType
        AND ISNULL(JH.RecordStatus,'A') = 'A'
        AND ISNULL(JD.RecordStatus,'A') = 'A'
    ORDER BY JD.BDebetAmount DESC, JD.IDX_T_JournalDetail
END
GO


/* =====================================================================================
   11. HAK AKSES MENU (FormID)
   -------------------------------------------------------------------------------------
   Menu Internal Transfer dilindungi oleh MyController::check_permission menggunakan
   FormID berikut. Daftarkan di SM_M_Form lalu assign ke group lewat menu
   User Management (atau langsung via SM_M_GroupForm):

        FM-IT-R   -> Internal Transfer (Read / List)
        FM-IT-C   -> Internal Transfer Create
        FM-IT-U   -> Internal Transfer Update
        FM-IT-A   -> Internal Transfer Approve / Void

   Contoh (sesuaikan kolom dengan definisi SM_M_Form di lingkungan Anda):

        INSERT INTO SM_M_Form (FormID, FormName, RecordStatus)
        VALUES ('FM-IT-R','Internal Transfer List','A'),
               ('FM-IT-C','Internal Transfer Create','A'),
               ('FM-IT-U','Internal Transfer Update','A'),
               ('FM-IT-A','Internal Transfer Approve','A')

   Catatan: Approve/Reverse/Void pada controller di-hardcode access=TRUE (mengikuti pola
   modul Financial Receive), namun inquiry/create/update tetap memeriksa FormID di atas.
   ===================================================================================== */
