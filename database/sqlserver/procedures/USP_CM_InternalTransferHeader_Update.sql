

/* =====================================================================================
   6. SP: USP_CM_InternalTransferHeader_Update
   Param order MUST match save (update branch):
   IDX_T_InternalTransferHeader, then same as create.
   ===================================================================================== */
CREATE PROCEDURE [dbo].[USP_CM_InternalTransferHeader_Update]
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
