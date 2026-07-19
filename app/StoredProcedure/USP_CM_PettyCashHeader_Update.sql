USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Update Header
-- Positional params from PettyCashController::save (state = update)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashHeader_Update]
    @IDX_T_PettyCashHeader BIGINT,
    @IDX_M_Company          BIGINT,
    @IDX_M_Branch           BIGINT,
    @IDX_M_FinancialAccount BIGINT,
    @OpeningDate     DATETIME,
    @TransactionType CHAR(3),
    @TransactionDesc VARCHAR(450),
    @CashierID       INT,
    @PettyCashStatus CHAR(1),
    @UserID          VARCHAR(10),
    @RecordStatus    VARCHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM CM_T_PettyCashHeader WITH(NOLOCK)
                   WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND PettyCashStatus = 'C')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID,
                   'Petty Cash sudah ditutup (Closed) dan tidak dapat diubah.' AS LogDesc;
            RETURN;
        END

        UPDATE CM_T_PettyCashHeader
        SET IDX_M_Company   = @IDX_M_Company,
            IDX_M_Branch    = @IDX_M_Branch,
            IDX_M_FinancialAccount = @IDX_M_FinancialAccount,
            OpeningDate     = @OpeningDate,
            TransactionType = @TransactionType,
            TransactionDesc = @TransactionDesc,
            UModified       = @UserID,
            DModified       = GETDATE(),
            RecordStatus    = @RecordStatus
        WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader;

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID, 'Petty Cash berhasil diperbarui.' AS LogDesc;
    END TRY
    BEGIN CATCH
        SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
