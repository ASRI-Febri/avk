SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Oct 2026
-- Description:	Menggabungkan beberapa baris rekening koran pilihan user menjadi
--				satu jurnal dengan total nilainya, mis. transfer gaji ke beberapa
--				karyawan yang dijurnal sebagai satu beban gaji:
--				  Semua debit (uang keluar) : Dr @IDX_M_COA / Cr COA Bank
--				  Semua kredit (uang masuk) : Dr COA Bank   / Cr @IDX_M_COA
--				Baris campuran debit dan kredit ditolak karena tidak jelas sisi
--				jurnalnya. Baris dikirim sebagai XML: <rows><r id="..."/></rows>.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_CreateMergedJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_CreateMergedJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_CreateMergedJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@RowsXml					VARCHAR(MAX),
	@IDX_M_COA					BIGINT,
	@JournalDate				DATETIME,
	@Remark						VARCHAR(5000),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Xml XML = CAST(@RowsXml AS XML)
		DECLARE @BankCOA BIGINT, @CurrencyID VARCHAR(3), @Debit DECIMAL(22,4), @Credit DECIMAL(22,4),
				@Count INT, @Journal BIGINT

		SELECT @BankCOA = FA.IDX_M_COA, @CurrencyID = RTRIM(H.CurrencyID)
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Rows TABLE (IDX_T_BankStatementDetail BIGINT, DebitAmount DECIMAL(22,4), CreditAmount DECIMAL(22,4),
							 IDX_T_JournalHeader BIGINT)

		INSERT INTO @Rows
		SELECT SD.IDX_T_BankStatementDetail, SD.DebitAmount, SD.CreditAmount, J.IDX_T_JournalHeader
		FROM (SELECT DISTINCT R.value('@id', 'BIGINT') AS IDX_T_BankStatementDetail FROM @Xml.nodes('/rows/r') N(R)) X
			INNER JOIN CM_T_BankStatementDetail SD WITH(NOLOCK)
				ON X.IDX_T_BankStatementDetail = SD.IDX_T_BankStatementDetail
				AND SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
			LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'

		SELECT @Count = COUNT(*), @Debit = SUM(DebitAmount), @Credit = SUM(CreditAmount) FROM @Rows

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN ISNULL(@CurrencyID, 'IDR') <> 'IDR' THEN 'Jurnal otomatis hanya untuk rekening IDR.'
				 WHEN @Count < 2 THEN 'Pilih minimal dua baris untuk digabung menjadi satu jurnal.'
				 WHEN EXISTS (SELECT 1 FROM @Rows WHERE IDX_T_JournalHeader IS NOT NULL) THEN 'Ada baris yang sudah memiliki jurnal.'
				 WHEN @Debit > 0 AND @Credit > 0 THEN 'Baris debit (uang keluar) dan kredit (uang masuk) tidak bisa digabung dalam satu jurnal.'
				 WHEN NOT EXISTS (SELECT 1 FROM GL_M_COA WITH(NOLOCK)
								  WHERE IDX_M_COA = @IDX_M_COA AND AllowJournalEntry = 'Y' AND RecordStatus = 'A')
					THEN 'Pilih Chart of Account yang aktif dan boleh dijurnal.'
				 WHEN @IDX_M_COA = @BankCOA THEN 'Chart of Account lawan tidak boleh sama dengan COA bank.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		DECLARE @Amount DECIMAL(22,4) = @Debit + @Credit

		CREATE TABLE #BankStatementJournalLine (SeqNo INT, IDX_M_COA BIGINT,
			Debit DECIMAL(22,4), Credit DECIMAL(22,4), Remark VARCHAR(5000))

		IF @Credit > 0
			INSERT INTO #BankStatementJournalLine VALUES (1, @BankCOA, @Amount, 0, NULL), (2, @IDX_M_COA, 0, @Amount, NULL)
		ELSE
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
			   'Jurnal gabungan dari ' + CONVERT(VARCHAR, @Count) + ' baris sebesar '
			   + REPLACE(CONVERT(VARCHAR, CAST(@Amount AS MONEY), 1), '.00', '')
			   + ' berhasil dibuat (status Unposted).' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
