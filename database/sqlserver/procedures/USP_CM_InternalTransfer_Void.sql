

/* =====================================================================================
   9. SP: USP_CM_InternalTransfer_Void   (Approved -> Void, hapus jurnal)
   Param order: IDX_T_InternalTransferHeader, VoidDate, VoidReason, UserID
   ===================================================================================== */
CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Void]
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
