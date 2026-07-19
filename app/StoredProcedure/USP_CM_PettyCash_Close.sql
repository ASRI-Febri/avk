USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================
-- Petty Cash (Imprest) - Close.
-- Settle the period and generate the reimbursement journal (imprest method):
--     (Dr) Expense COA per detail line (grouped by COA)   = total pengeluaran
--          (Cr) Petty Cash / Kas Kecil COA (header account)     = total pengeluaran
-- Posts to GL_T_JournalHeader / GL_T_JournalDetail with IDX_M_JournalType = 10 (Petty Cash).
-- Positional params from PettyCashController::save_close
-- =============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_CM_PettyCash_Close]
    @IDX_T_PettyCashHeader BIGINT,
    @ClosingDate  DATETIME,
    @ClosingNotes VARCHAR(500),
    @UserID       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @JournalType INT = 10;

    BEGIN TRY
        -- --------------------------------------------------------------------------------------
        -- VALIDATION
        -- --------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM CM_T_PettyCashHeader WITH(NOLOCK)
                       WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND PettyCashStatus = 'O')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, 'Petty Cash tidak dalam status Open.' AS LogDesc;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM CM_T_PettyCashDetail WITH(NOLOCK)
                       WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND RecordStatus = 'A')
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, 'Belum ada pengeluaran. Tidak dapat menutup Petty Cash kosong.' AS LogDesc;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM CM_T_PettyCashDetail WITH(NOLOCK)
                   WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND RecordStatus = 'A'
                     AND ISNULL(IDX_M_COA, 0) = 0)
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, 'Masih ada baris pengeluaran tanpa Account (COA). Lengkapi terlebih dahulu.' AS LogDesc;
            RETURN;
        END

        DECLARE @IDX_M_Company         BIGINT,
                @IDX_M_Branch          BIGINT,
                @IDX_M_FinancialAccount BIGINT,
                @TransactionID         VARCHAR(50),
                @TransactionDesc       VARCHAR(450),
                @CreditCOA             BIGINT,
                @Total                 DECIMAL(22,4),
                @BaseCurrency          INT,
                @JournalHeaderID       BIGINT;

        SELECT @IDX_M_Branch           = H.IDX_M_Branch,
               @IDX_M_FinancialAccount = H.IDX_M_FinancialAccount,
               @TransactionID          = RTRIM(H.TransactionID),
               @TransactionDesc        = RTRIM(ISNULL(H.TransactionDesc, '')),
               @IDX_M_Company          = COALESCE(H.IDX_M_Company, B.IDX_M_Company)
        FROM CM_T_PettyCashHeader H WITH(NOLOCK)
            LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON H.IDX_M_Branch = B.IDX_M_Branch
        WHERE H.IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader;

        IF ISNULL(@IDX_M_FinancialAccount, 0) = 0
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, 'Financial Account (Kas Kecil) belum diisi pada header.' AS LogDesc;
            RETURN;
        END

        SELECT @CreditCOA = IDX_M_COA
        FROM CM_M_FinancialAccount WITH(NOLOCK)
        WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND RecordStatus = 'A';

        IF ISNULL(@CreditCOA, 0) = 0
        BEGIN
            SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, 'Financial Account Kas Kecil tidak memiliki mapping COA.' AS LogDesc;
            RETURN;
        END

        SELECT @Total = SUM(PettyCashAmount)
        FROM CM_T_PettyCashDetail WITH(NOLOCK)
        WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND RecordStatus = 'A';

        -- Base currency (IDR), fallback to the lowest currency index
        SELECT TOP 1 @BaseCurrency = IDX_M_Currency
        FROM GN_M_Currency WITH(NOLOCK)
        WHERE RecordStatus = 'A' AND CurrencyID = 'IDR';
        IF @BaseCurrency IS NULL
            SELECT @BaseCurrency = MIN(IDX_M_Currency) FROM GN_M_Currency WITH(NOLOCK) WHERE RecordStatus = 'A';

        BEGIN TRANSACTION;

        -- --------------------------------------------------------------------------------------
        -- JOURNAL HEADER
        -- --------------------------------------------------------------------------------------
        INSERT INTO GL_T_JournalHeader
            (IDX_M_Company, IDX_M_Branch, IDX_M_JournalType, IDX_ReferenceNo, ReferenceNo, VoucherNo,
             JournalDate, RemarkHeader, PostingStatus, DebetAmount, CreditAmount, JournalSource,
             UCreate, DCreate, RecordStatus)
        VALUES
            (@IDX_M_Company, @IDX_M_Branch, @JournalType, @IDX_T_PettyCashHeader, @TransactionID, @TransactionID,
             @ClosingDate, 'Closing Petty Cash ' + @TransactionID + ISNULL(' - ' + NULLIF(@TransactionDesc, ''), ''),
             'U', @Total, @Total, 'S',
             @UserID, GETDATE(), 'A');

        SET @JournalHeaderID = SCOPE_IDENTITY();

        -- --------------------------------------------------------------------------------------
        -- JOURNAL DETAIL - DEBIT (expense accounts, grouped by COA)
        -- --------------------------------------------------------------------------------------
        INSERT INTO GL_T_JournalDetail
            (IDX_T_JournalHeader, IDX_M_COA, JournalSeqNo, COADescription, RemarkDetail,
             OriginalCurrencyID, ODebetAmount, OCreditAmount, ExchangeRate, BaseCurrencyID, BDebetAmount, BCreditAmount,
             UCreate, DCreate, RecordStatus)
        SELECT
            @JournalHeaderID,
            G.IDX_M_COA,
            ROW_NUMBER() OVER (ORDER BY G.IDX_M_COA) AS JournalSeqNo,
            LTRIM(RTRIM(ISNULL(COA.COAID, '') + ' - ' + ISNULL(COA.COADesc, ''))) AS COADescription,
            'Pengeluaran Petty Cash ' + @TransactionID AS RemarkDetail,
            @BaseCurrency, G.Amount, 0, 1, @BaseCurrency, G.Amount, 0,
            @UserID, GETDATE(), 'A'
        FROM (
            SELECT IDX_M_COA, SUM(PettyCashAmount) AS Amount
            FROM CM_T_PettyCashDetail WITH(NOLOCK)
            WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND RecordStatus = 'A'
            GROUP BY IDX_M_COA
        ) G
            LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON G.IDX_M_COA = COA.IDX_M_COA;

        -- --------------------------------------------------------------------------------------
        -- JOURNAL DETAIL - CREDIT (Petty Cash / Kas Kecil account)
        -- --------------------------------------------------------------------------------------
        INSERT INTO GL_T_JournalDetail
            (IDX_T_JournalHeader, IDX_M_COA, JournalSeqNo, COADescription, RemarkDetail,
             OriginalCurrencyID, ODebetAmount, OCreditAmount, ExchangeRate, BaseCurrencyID, BDebetAmount, BCreditAmount,
             UCreate, DCreate, RecordStatus)
        SELECT
            @JournalHeaderID,
            @CreditCOA,
            (SELECT COUNT(DISTINCT IDX_M_COA) FROM CM_T_PettyCashDetail WITH(NOLOCK)
             WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader AND RecordStatus = 'A') + 1,
            LTRIM(RTRIM(ISNULL(COA.COAID, '') + ' - ' + ISNULL(COA.COADesc, ''))),
            'Reimburse Petty Cash ' + @TransactionID,
            @BaseCurrency, 0, @Total, 1, @BaseCurrency, 0, @Total,
            @UserID, GETDATE(), 'A'
        FROM GL_M_COA COA WITH(NOLOCK)
        WHERE COA.IDX_M_COA = @CreditCOA;

        -- --------------------------------------------------------------------------------------
        -- CLOSE THE PETTY CASH HEADER
        -- --------------------------------------------------------------------------------------
        UPDATE CM_T_PettyCashHeader
        SET PettyCashStatus = 'C',
            ClosingDate     = @ClosingDate,
            ClosingBy       = @UserID,
            ClosingNotes    = @ClosingNotes,
            UModified       = @UserID,
            DModified       = GETDATE()
        WHERE IDX_T_PettyCashHeader = @IDX_T_PettyCashHeader;

        COMMIT TRANSACTION;

        SELECT 'success' AS Result, @IDX_T_PettyCashHeader AS ID,
               'Petty Cash berhasil ditutup. Jurnal pengeluaran (No Ref: ' + @TransactionID + ') telah dibuat.' AS LogDesc;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'error' AS Result, @IDX_T_PettyCashHeader AS ID, ERROR_MESSAGE() AS LogDesc;
    END CATCH
END
GO
