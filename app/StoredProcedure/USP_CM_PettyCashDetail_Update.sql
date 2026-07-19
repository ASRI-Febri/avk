USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Update Detail
-- Positional params from PettyCashDetailController::save (state = update)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashDetail_Update]
    @IDX_T_PettyCashDetail BIGINT,
    @IDX_T_PettyCashHeader BIGINT,
    @IDX_M_DocumentType INT,
    @IDX_M_COA          BIGINT,
    @IDX_M_Partner      INT,
    @IDX_Reference      BIGINT,
    @ReferenceNo        VARCHAR(50),
    @TransactionDate    DATE,
    @PartnerName        VARCHAR(250),
    @DetailDesc         VARCHAR(50),
    @PettyCashAmount    DECIMAL(20, 2),
    @UserID             VARCHAR(10),
    @RecordStatus       VARCHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM CM_T_PettyCashHeader WITH(NOLOCK)
                       WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND PettyCashStatus = 'O')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID,
                   'Petty Cash sudah ditutup. Tidak dapat mengubah pengeluaran.' AS LogDesc;
            RETURN;
        END

        UPDATE CM_T_PettyCashDetail
        SET IDX_M_DocumentType = @IDX_M_DocumentType,
            IDX_M_COA          = @IDX_M_COA,
            IDX_M_Partner      = @IDX_M_Partner,
            IDX_Reference      = @IDX_Reference,
            ReferenceNo        = @ReferenceNo,
            TransactionDate    = @TransactionDate,
            PartnerName        = @PartnerName,
            DetailDesc         = @DetailDesc,
            PettyCashAmount    = @PettyCashAmount,
            UModified          = @UserID,
            DModified          = GETDATE(),
            RecordStatus       = @RecordStatus
        WHERE IDX_T_PettyCashDetail = @IDX_T_PettyCashDetail;

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID, 'Pengeluaran berhasil diperbarui.' AS LogDesc;
    END TRY
    BEGIN CATCH
        SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
