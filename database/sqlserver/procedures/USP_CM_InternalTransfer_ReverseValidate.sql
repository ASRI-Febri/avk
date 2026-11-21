

/* =====================================================================================
   8. SP: USP_CM_InternalTransfer_ReverseValidate   (Approved -> Draft, hapus jurnal)
   Param order: IDX_T_InternalTransferHeader, ApprovalRemark, ApprovalBy
   ===================================================================================== */
CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_ReverseValidate]
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
