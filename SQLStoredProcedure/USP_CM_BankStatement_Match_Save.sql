SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Menandai transaksi pilihan user di halaman Rekonsiliasi Ledger
--				sebagai satu pasangan yang cocok, tanpa jurnal. Syarat: ada baris
--				rekening koran dan baris ledger, total mutasi keduanya sama
--				(uang masuk bank = debit COA bank), dan belum ada di pasangan
--				manual atau jurnal penyesuaian lain yang masih aktif.
--				@SourceXml : <rows><r t="B|L" id="..."/></rows>
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_Match_Save') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_Match_Save]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_Match_Save]
	@IDX_T_BankStatementHeader	BIGINT,
	@SourceXml					VARCHAR(MAX),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Sources XML = CAST(@SourceXml AS XML)
		DECLARE @BankCOA BIGINT, @Company BIGINT, @Requested INT, @Match BIGINT

		SELECT @BankCOA = FA.IDX_M_COA, @Company = H.IDX_M_Company
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Requests TABLE (SourceType CHAR(1), SourceID BIGINT)
		INSERT INTO @Requests
		SELECT DISTINCT R.value('@t', 'CHAR(1)'), R.value('@id', 'BIGINT') FROM @Sources.nodes('/rows/r') N(R)

		SELECT @Requested = COUNT(*) FROM @Requests

		-- Amount = mutasi bersih dari sisi bank (masuk positif)
		DECLARE @Rows TABLE (SourceType CHAR(1), SourceID BIGINT, Amount DECIMAL(22,4))
		INSERT INTO @Rows
		SELECT Q.SourceType, Q.SourceID, SD.CreditAmount - SD.DebitAmount
		FROM @Requests Q
			INNER JOIN CM_T_BankStatementDetail SD WITH(NOLOCK)
				ON Q.SourceType = 'B' AND Q.SourceID = SD.IDX_T_BankStatementDetail
				AND SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
		UNION ALL
		SELECT Q.SourceType, Q.SourceID, D.BDebetAmount - D.BCreditAmount
		FROM @Requests Q
			INNER JOIN GL_T_JournalDetail D WITH(NOLOCK)
				ON Q.SourceType = 'L' AND Q.SourceID = D.IDX_T_JournalDetail AND D.RecordStatus = 'A' AND D.IDX_M_COA = @BankCOA
			INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON D.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A' AND J.IDX_M_Company = @Company

		DECLARE @Difference DECIMAL(22,4) =
			ISNULL((SELECT SUM(Amount) FROM @Rows WHERE SourceType = 'B'), 0)
			- ISNULL((SELECT SUM(Amount) FROM @Rows WHERE SourceType = 'L'), 0)

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN (SELECT COUNT(*) FROM @Rows) <> @Requested THEN 'Ada transaksi yang tidak ditemukan atau bukan milik rekening ini.'
				 WHEN NOT EXISTS (SELECT 1 FROM @Rows WHERE SourceType = 'B')
				   OR NOT EXISTS (SELECT 1 FROM @Rows WHERE SourceType = 'L')
					THEN 'Pilih minimal satu transaksi rekening koran dan satu transaksi ledger.'
				 WHEN ABS(@Difference) >= 0.005
					THEN 'Total transaksi bank dan ledger belum sama (selisih '
						 + CONVERT(VARCHAR, CAST(@Difference AS MONEY), 1) + '). Gunakan Jurnal Penyesuaian untuk selisihnya.'
				 WHEN EXISTS (SELECT 1 FROM @Rows R
								INNER JOIN CM_T_BankStatementMatchDetail MD WITH(NOLOCK)
									ON R.SourceType = MD.SourceType AND R.SourceID = MD.SourceID
								INNER JOIN CM_T_BankStatementMatch M WITH(NOLOCK)
									ON MD.IDX_T_BankStatementMatch = M.IDX_T_BankStatementMatch AND M.RecordStatus = 'A')
					THEN 'Ada transaksi yang sudah ditandai cocok.'
				 WHEN EXISTS (SELECT 1 FROM @Rows R
								INNER JOIN CM_T_BankStatementAdjustment A WITH(NOLOCK)
									ON R.SourceType = A.SourceType AND R.SourceID = A.SourceID AND A.RecordStatus = 'A'
								INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
									ON A.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A')
					THEN 'Ada transaksi yang sudah memiliki jurnal penyesuaian.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		BEGIN TRANSACTION

		INSERT INTO CM_T_BankStatementMatch (IDX_T_BankStatementHeader, UCreate, DCreate, RecordStatus)
		VALUES (@IDX_T_BankStatementHeader, @UserID, GETDATE(), 'A')

		SET @Match = SCOPE_IDENTITY()

		INSERT INTO CM_T_BankStatementMatchDetail (IDX_T_BankStatementMatch, SourceType, SourceID)
		SELECT @Match, SourceType, SourceID FROM @Rows

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @IDX_T_BankStatementHeader AS ID,
			   CONVERT(VARCHAR, @Requested) + ' transaksi ditandai cocok.' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
