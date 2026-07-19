USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Delete Detail (hard delete of a single expense line)
-- Positional params from PettyCashDetailController::save_delete
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashDetail_Delete]
    @IDX_T_PettyCashDetail BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IDX_T_PettyCashHeader BIGINT;

        SELECT @IDX_T_PettyCashHeader = IDX_T_PettyCashHeader
        FROM CM_T_PettyCashDetail WITH(NOLOCK)
        WHERE IDX_T_PettyCashDetail = @IDX_T_PettyCashDetail;

        IF EXISTS (SELECT 1 FROM CM_T_PettyCashHeader WITH(NOLOCK)
                   WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND PettyCashStatus = 'C')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID,
                   'Petty Cash sudah ditutup. Tidak dapat menghapus pengeluaran.' AS LogDesc;
            RETURN;
        END

        DELETE FROM CM_T_PettyCashDetail WHERE IDX_T_PettyCashDetail = @IDX_T_PettyCashDetail;

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID, 'Pengeluaran berhasil dihapus.' AS LogDesc;
    END TRY
    BEGIN CATCH
        SELECT 'error' AS Result, 0 AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
