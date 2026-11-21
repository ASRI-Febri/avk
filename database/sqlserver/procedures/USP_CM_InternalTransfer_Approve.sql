CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Approve]
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
