SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Membuat jurnal untuk baris rekening koran yang dipilih user,
--				satu jurnal per baris dengan COA lawan pilihan user:
--				  Kredit di bank (uang masuk)  : Dr COA Bank  / Cr COA lawan
--				  Debit di bank (uang keluar)  : Dr COA lawan / Cr COA Bank
--				COA Bank diambil dari Financial Account rekening koran.
--				Baris dikirim sebagai XML: <rows><r id="IDX_T_BankStatementDetail"
--				coa="IDX_M_COA" m="Keterangan jurnal"/></rows>
--				Semua baris berhasil atau tidak sama sekali.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_CreateJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_CreateJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_CreateJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@RowsXml					VARCHAR(MAX),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Xml XML = CAST(@RowsXml AS XML)
		DECLARE @BankCOA BIGINT, @CurrencyID VARCHAR(3)

		SELECT @BankCOA = FA.IDX_M_COA, @CurrencyID = RTRIM(H.CurrencyID)
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Rows TABLE (IDX_T_BankStatementDetail BIGINT, IDX_M_COA BIGINT, Remark VARCHAR(5000),
							 PostingDate DATETIME, DebitAmount DECIMAL(22,4), CreditAmount DECIMAL(22,4),
							 IDX_T_JournalHeader BIGINT, COAValid BIT)

		INSERT INTO @Rows
		SELECT SD.IDX_T_BankStatementDetail, X.IDX_M_COA, NULLIF(LTRIM(RTRIM(X.Remark)), ''),
			   SD.PostingDate, SD.DebitAmount, SD.CreditAmount, J.IDX_T_JournalHeader,
			   CASE WHEN COA.AllowJournalEntry = 'Y' AND COA.RecordStatus = 'A' THEN 1 ELSE 0 END
		FROM (SELECT R.value('@id', 'BIGINT') AS IDX_T_BankStatementDetail,
					 R.value('@coa', 'BIGINT') AS IDX_M_COA,
					 R.value('@m', 'VARCHAR(5000)') AS Remark
			  FROM @Xml.nodes('/rows/r') N(R)) X
			INNER JOIN CM_T_BankStatementDetail SD WITH(NOLOCK)
				ON X.IDX_T_BankStatementDetail = SD.IDX_T_BankStatementDetail
				AND SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
			LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
			LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON X.IDX_M_COA = COA.IDX_M_COA

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN ISNULL(@CurrencyID, 'IDR') <> 'IDR' THEN 'Jurnal otomatis hanya untuk rekening IDR.'
				 WHEN NOT EXISTS (SELECT 1 FROM @Rows) THEN 'Pilih minimal satu baris rekening koran.'
				 WHEN EXISTS (SELECT 1 FROM @Rows WHERE IDX_T_JournalHeader IS NOT NULL) THEN 'Ada baris yang sudah memiliki jurnal.'
				 WHEN EXISTS (SELECT 1 FROM @Rows WHERE COAValid = 0) THEN 'Setiap baris harus memiliki Chart of Account yang aktif dan boleh dijurnal.'
				 WHEN EXISTS (SELECT 1 FROM @Rows WHERE IDX_M_COA = @BankCOA) THEN 'Chart of Account lawan tidak boleh sama dengan COA bank.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		DECLARE @Detail BIGINT, @COA BIGINT, @Remark VARCHAR(5000), @Date DATETIME,
				@Debit DECIMAL(22,4), @Credit DECIMAL(22,4), @Amount DECIMAL(22,4), @Journal BIGINT, @DebitCOA BIGINT, @CreditCOA BIGINT,
				@Count INT = 0

		BEGIN TRANSACTION

		DECLARE RowCursor CURSOR LOCAL FAST_FORWARD FOR
			SELECT IDX_T_BankStatementDetail, IDX_M_COA, Remark, PostingDate, DebitAmount, CreditAmount FROM @Rows
		OPEN RowCursor
		FETCH NEXT FROM RowCursor INTO @Detail, @COA, @Remark, @Date, @Debit, @Credit
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Credit > 0
				SELECT @DebitCOA = @BankCOA, @CreditCOA = @COA
			ELSE
				SELECT @DebitCOA = @COA, @CreditCOA = @BankCOA

			SET @Amount = @Debit + @Credit

			IF @Remark IS NULL
				SELECT @Remark = RTRIM(Remark) FROM CM_T_BankStatementDetail WITH(NOLOCK)
				WHERE IDX_T_BankStatementDetail = @Detail

			EXEC [dbo].[USP_CM_BankStatement_InsertJournal] @IDX_T_BankStatementHeader, @Date, @Remark,
				@DebitCOA, @CreditCOA, @Amount, @UserID, @Journal OUTPUT

			UPDATE CM_T_BankStatementDetail
			SET IDX_T_JournalHeader = @Journal, UModified = @UserID, DModified = GETDATE()
			WHERE IDX_T_BankStatementDetail = @Detail

			SET @Count += 1
			FETCH NEXT FROM RowCursor INTO @Detail, @COA, @Remark, @Date, @Debit, @Credit
		END
		CLOSE RowCursor
		DEALLOCATE RowCursor

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @IDX_T_BankStatementHeader AS ID,
			   CONVERT(VARCHAR, @Count) + ' jurnal berhasil dibuat (status Unposted). Posting melalui menu Accounting > Journal.' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
