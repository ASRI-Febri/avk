USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Create Header
-- Positional params from PettyCashController::save (state = create)
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCashHeader_Create]
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
        DECLARE @NewIDX  BIGINT,
                @TransID VARCHAR(50),
                @BranchID VARCHAR(20),
                @Period   VARCHAR(6),
                @Seq      INT;

        SELECT @NewIDX = ISNULL(MAX(IDX_T_PettyCashHeader), 0) + 1 FROM CM_T_PettyCashHeader;

        SELECT @BranchID = RTRIM(ISNULL(BranchID, 'XX')) FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch;
        SET @Period = FORMAT(@OpeningDate, 'yyyyMM');

        SELECT @Seq = ISNULL(COUNT(*), 0) + 1
        FROM CM_T_PettyCashHeader WITH(NOLOCK)
        WHERE IDX_M_Branch = @IDX_M_Branch
          AND FORMAT(OpeningDate, 'yyyyMM') = @Period;

        SET @TransID = 'PC-' + @BranchID + '-' + @Period + '-' + RIGHT('0000' + CAST(@Seq AS VARCHAR(4)), 4);

        INSERT INTO CM_T_PettyCashHeader
            (IDX_T_PettyCashHeader, IDX_M_Company, IDX_M_Branch, IDX_M_FinancialAccount, OpeningDate, TransactionType,
             TransactionID, TransactionDesc, CashierID, PettyCashStatus, UCreate, DCreate, RecordStatus)
        VALUES
            (@NewIDX, @IDX_M_Company, @IDX_M_Branch, @IDX_M_FinancialAccount, @OpeningDate, @TransactionType,
             @TransID, @TransactionDesc, @CashierID, @PettyCashStatus, @UserID, GETDATE(), @RecordStatus);

        SELECT 'success' AS Result, @NewIDX AS ID, 'Petty Cash berhasil disimpan.' AS LogDesc;
    END TRY
    BEGIN CATCH
        SELECT 'error' AS Result, 0 AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
