SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Menjumlahkan seluruh baris biaya admin (IsAdminFee = 1) yang belum
--				dijurnal pada satu rekening koran menjadi satu jurnal penyesuaian:
--				  Dr @IDX_M_COA (mis. Biaya Admin Bank) / Cr COA Bank
--				Semua baris yang dijumlahkan ditautkan ke jurnal tersebut.
-- Mod			:	Samuel Febrianto, 22 Oct 2026
-- Mod Desc		:	Baris jurnal lewat #BankStatementJournalLine.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_CreateAdminFeeJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_CreateAdminFeeJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_CreateAdminFeeJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@IDX_M_COA					BIGINT,
	@JournalDate				DATETIME,
	@Remark						VARCHAR(5000),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @BankCOA BIGINT, @CurrencyID VARCHAR(3), @Amount DECIMAL(22,4), @Count INT, @Journal BIGINT

		SELECT @BankCOA = FA.IDX_M_COA, @CurrencyID = RTRIM(H.CurrencyID)
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Rows TABLE (IDX_T_BankStatementDetail BIGINT)

		INSERT INTO @Rows
		SELECT SD.IDX_T_BankStatementDetail
		FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
			LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
		WHERE SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
			AND SD.IsAdminFee = 1 AND SD.DebitAmount > 0 AND J.IDX_T_JournalHeader IS NULL

		SELECT @Count = COUNT(*), @Amount = SUM(SD.DebitAmount)
		FROM @Rows R INNER JOIN CM_T_BankStatementDetail SD WITH(NOLOCK)
			ON R.IDX_T_BankStatementDetail = SD.IDX_T_BankStatementDetail

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN ISNULL(@CurrencyID, 'IDR') <> 'IDR' THEN 'Jurnal otomatis hanya untuk rekening IDR.'
				 WHEN @Count = 0 THEN 'Tidak ada baris biaya admin yang belum dijurnal.'
				 WHEN NOT EXISTS (SELECT 1 FROM GL_M_COA WITH(NOLOCK)
								  WHERE IDX_M_COA = @IDX_M_COA AND AllowJournalEntry = 'Y' AND RecordStatus = 'A')
					THEN 'Pilih Chart of Account yang aktif dan boleh dijurnal.'
				 WHEN @IDX_M_COA = @BankCOA THEN 'Chart of Account biaya tidak boleh sama dengan COA bank.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		CREATE TABLE #BankStatementJournalLine (SeqNo INT, IDX_M_COA BIGINT,
			Debit DECIMAL(22,4), Credit DECIMAL(22,4), Remark VARCHAR(5000))
		INSERT INTO #BankStatementJournalLine VALUES (1, @IDX_M_COA, @Amount, 0, NULL), (2, @BankCOA, 0, @Amount, NULL)

		BEGIN TRANSACTION

		EXEC [dbo].[USP_CM_BankStatement_InsertJournal] @IDX_T_BankStatementHeader, @JournalDate, NULL, @Remark,
			@UserID, @Journal OUTPUT

		UPDATE SD
		SET IDX_T_JournalHeader = @Journal, UModified = @UserID, DModified = GETDATE()
		FROM CM_T_BankStatementDetail SD
			INNER JOIN @Rows R ON SD.IDX_T_BankStatementDetail = R.IDX_T_BankStatementDetail

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @IDX_T_BankStatementHeader AS ID,
			   'Jurnal biaya admin dari ' + CONVERT(VARCHAR, @Count) + ' baris sebesar '
			   + REPLACE(CONVERT(VARCHAR, CAST(@Amount AS MONEY), 1), '.00', '')
			   + ' berhasil dibuat (status Unposted).' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
