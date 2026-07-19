USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Reopen a closed record.
-- Positional params from PettyCashController::save_reopen
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCash_Reopen]
    @IDX_T_PettyCashHeader BIGINT,
    @ClosingNotes VARCHAR(500),
    @UserID       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @JournalType INT = 10;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM CM_T_PettyCashHeader WITH(NOLOCK)
                       WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND PettyCashStatus = 'C')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID,
                   'Petty Cash tidak dalam status Closed.' AS LogDesc;
            RETURN;
        END

        -- A journal that is already posted to GL ('P') cannot be unwound here.
        IF EXISTS (SELECT 1 FROM GL_T_JournalHeader WITH(NOLOCK)
                   WHERE IDX_M_JournalType = @JournalType
                     AND IDX_ReferenceNo = @IDX_T_PettyCashHeader
                     AND PostingStatus = 'P' AND RecordStatus = 'A')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID,
                   'Jurnal Petty Cash sudah diposting ke GL. Tidak dapat dibuka kembali.' AS LogDesc;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Remove the unposted closing journal (header + detail).
        DELETE JD
        FROM GL_T_JournalDetail JD
            INNER JOIN GL_T_JournalHeader JH ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
        WHERE JH.IDX_M_JournalType = @JournalType
          AND JH.IDX_ReferenceNo = @IDX_T_PettyCashHeader
          AND JH.PostingStatus <> 'P';

        DELETE FROM GL_T_JournalHeader
        WHERE IDX_M_JournalType = @JournalType
          AND IDX_ReferenceNo = @IDX_T_PettyCashHeader
          AND PostingStatus <> 'P';

        UPDATE CM_T_PettyCashHeader
        SET PettyCashStatus = 'O',
            ClosingDate     = NULL,
            ClosingBy       = NULL,
            ClosingNotes    = @ClosingNotes,
            UModified       = @UserID,
            DModified       = GETDATE()
        WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader;

        COMMIT TRANSACTION;

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID, 'Petty Cash berhasil dibuka kembali. Jurnal closing telah dibatalkan.' AS LogDesc;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
