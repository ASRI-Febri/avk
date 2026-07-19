USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Create Detail (a single expense line)
-- Positional params from PettyCashDetailController::save (state = create)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashDetail_Create]
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
                   'Petty Cash sudah ditutup. Tidak dapat menambah pengeluaran.' AS LogDesc;
            RETURN;
        END

        DECLARE @NewIDX BIGINT;
        SELECT @NewIDX = ISNULL(MAX(IDX_T_PettyCashDetail), 0) + 1 FROM CM_T_PettyCashDetail;

        INSERT INTO CM_T_PettyCashDetail
            (IDX_T_PettyCashDetail, IDX_T_PettyCashHeader, IDX_M_DocumentType, IDX_M_COA, IDX_M_Partner,
             IDX_Reference, ReferenceNo, TransactionDate, PartnerName, DetailDesc, PettyCashAmount,
             UCreate, DCreate, RecordStatus)
        VALUES
            (@NewIDX, @IDX_T_PettyCashHeader, @IDX_M_DocumentType, @IDX_M_COA, @IDX_M_Partner,
             @IDX_Reference, @ReferenceNo, @TransactionDate, @PartnerName, @DetailDesc, @PettyCashAmount,
             @UserID, GETDATE(), @RecordStatus);

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID, 'Pengeluaran berhasil disimpan.' AS LogDesc;
    END TRY
    BEGIN CATCH
        SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
