

/* =====================================================================================
   5. SP: USP_CM_InternalTransferHeader_Create
   Param order MUST match InternalTransferController::save (create branch):
   IDX_M_Company, IDX_M_Branch, IDX_M_DocumentType, IDX_M_FromFinancialAccount,
   IDX_M_ToFinancialAccount, FromCOA, ToCOA, TransferID, VoucherNoManual, TransferDate,
   RemarkHeader, TransferStatus, TransferAmount, UserID, RecordStatus
   ===================================================================================== */
CREATE PROCEDURE [dbo].[USP_CM_InternalTransferHeader_Create]
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
