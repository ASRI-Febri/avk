SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Jurnal penyesuaian dari halaman Rekonsiliasi Ledger untuk
--				transaksi pilihan user (baris rekening koran dan/atau baris ledger
--				COA bank), mis. bank menerima 1.500.000 tetapi ledger mencatat
--				1.497.950 -> Dr Bank 2.050 / Cr COA pilihan user 2.050.
--
--				User menentukan baris jurnal lawan (COA, debit atau kredit, nilai).
--				Baris COA bank dihitung otomatis sebagai penyeimbang:
--				  total kredit lawan - total debit lawan > 0 : Dr Bank
--				  < 0 : Cr Bank;  = 0 : tanpa baris bank (reklasifikasi saja)
--
--				@SourceXml : <rows><r t="B|L" id="..."/></rows>
--				@LinesXml  : <lines><l coa="..." d="..." c="..." m="..."/></lines>
--				Transaksi yang sudah punya jurnal penyesuaian aktif ditolak.
-- Mod			:	Samuel Febrianto, 31 Oct 2026
-- Mod Desc		:	Tolak transaksi yang sudah ditandai cocok manual.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_CreateAdjustmentJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_CreateAdjustmentJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_CreateAdjustmentJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@SourceXml					VARCHAR(MAX),
	@LinesXml					VARCHAR(MAX),
	@JournalDate				DATETIME,
	@Remark						VARCHAR(5000),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Sources XML = CAST(@SourceXml AS XML), @LinesX XML = CAST(@LinesXml AS XML)
		DECLARE @BankCOA BIGINT, @CurrencyID VARCHAR(3), @Company BIGINT, @Journal BIGINT,
				@Requested INT, @BankAmount DECIMAL(22,4)

		SELECT @BankCOA = FA.IDX_M_COA, @CurrencyID = RTRIM(H.CurrencyID), @Company = H.IDX_M_Company
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Requests TABLE (SourceType CHAR(1), SourceID BIGINT)
		INSERT INTO @Requests
		SELECT DISTINCT R.value('@t', 'CHAR(1)'), R.value('@id', 'BIGINT') FROM @Sources.nodes('/rows/r') N(R)

		SELECT @Requested = COUNT(*) FROM @Requests

		-- HANYA BARIS MILIK REKENING KORAN INI / BARIS LEDGER COA BANK PERUSAHAAN YANG SAMA
		DECLARE @Rows TABLE (SourceType CHAR(1), SourceID BIGINT)
		INSERT INTO @Rows
		SELECT Q.SourceType, Q.SourceID
		FROM @Requests Q
			INNER JOIN CM_T_BankStatementDetail SD WITH(NOLOCK)
				ON Q.SourceType = 'B' AND Q.SourceID = SD.IDX_T_BankStatementDetail
				AND SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
		UNION ALL
		SELECT Q.SourceType, Q.SourceID
		FROM @Requests Q
			INNER JOIN GL_T_JournalDetail D WITH(NOLOCK)
				ON Q.SourceType = 'L' AND Q.SourceID = D.IDX_T_JournalDetail AND D.RecordStatus = 'A' AND D.IDX_M_COA = @BankCOA
			INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON D.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A' AND J.IDX_M_Company = @Company

		CREATE TABLE #BankStatementJournalLine (SeqNo INT, IDX_M_COA BIGINT,
			Debit DECIMAL(22,4), Credit DECIMAL(22,4), Remark VARCHAR(5000))

		INSERT INTO #BankStatementJournalLine
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 1,
			   L.value('@coa', 'BIGINT'),
			   ROUND(ISNULL(L.value('@d', 'DECIMAL(22,4)'), 0), 2),
			   ROUND(ISNULL(L.value('@c', 'DECIMAL(22,4)'), 0), 2),
			   NULLIF(LTRIM(RTRIM(L.value('@m', 'VARCHAR(5000)'))), '')
		FROM @LinesX.nodes('/lines/l') N(L)

		SELECT @BankAmount = SUM(Credit) - SUM(Debit) FROM #BankStatementJournalLine

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN ISNULL(@CurrencyID, 'IDR') <> 'IDR' THEN 'Jurnal otomatis hanya untuk rekening IDR.'
				 WHEN @Requested = 0 THEN 'Pilih minimal satu transaksi.'
				 WHEN (SELECT COUNT(*) FROM @Rows) <> @Requested THEN 'Ada transaksi yang tidak ditemukan atau bukan milik rekening ini.'
				 WHEN EXISTS (SELECT 1 FROM @Rows R
								INNER JOIN CM_T_BankStatementAdjustment A WITH(NOLOCK)
									ON R.SourceType = A.SourceType AND R.SourceID = A.SourceID AND A.RecordStatus = 'A'
								INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
									ON A.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A')
					THEN 'Ada transaksi yang sudah memiliki jurnal penyesuaian.'
				 WHEN EXISTS (SELECT 1 FROM @Rows R
								INNER JOIN CM_T_BankStatementMatchDetail MD WITH(NOLOCK)
									ON R.SourceType = MD.SourceType AND R.SourceID = MD.SourceID
								INNER JOIN CM_T_BankStatementMatch M WITH(NOLOCK)
									ON MD.IDX_T_BankStatementMatch = M.IDX_T_BankStatementMatch AND M.RecordStatus = 'A')
					THEN 'Ada transaksi yang sudah ditandai cocok.'
				 WHEN NOT EXISTS (SELECT 1 FROM #BankStatementJournalLine) THEN 'Isi minimal satu baris jurnal.'
				 WHEN EXISTS (SELECT 1 FROM #BankStatementJournalLine
							  WHERE Debit < 0 OR Credit < 0 OR (Debit > 0 AND Credit > 0) OR (Debit = 0 AND Credit = 0))
					THEN 'Setiap baris jurnal harus berisi nilai debit atau kredit (salah satu).'
				 WHEN EXISTS (SELECT 1 FROM #BankStatementJournalLine L
							  WHERE NOT EXISTS (SELECT 1 FROM GL_M_COA C WITH(NOLOCK)
												WHERE C.IDX_M_COA = L.IDX_M_COA AND C.AllowJournalEntry = 'Y' AND C.RecordStatus = 'A'))
					THEN 'Pilih Chart of Account yang aktif dan boleh dijurnal.'
				 WHEN EXISTS (SELECT 1 FROM #BankStatementJournalLine WHERE IDX_M_COA = @BankCOA)
					THEN 'Baris COA bank dibuat otomatis; pilih COA lawan yang lain.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		IF @BankAmount <> 0
			INSERT INTO #BankStatementJournalLine VALUES
				(1, @BankCOA, CASE WHEN @BankAmount > 0 THEN @BankAmount ELSE 0 END,
				 CASE WHEN @BankAmount < 0 THEN -@BankAmount ELSE 0 END, NULL)

		BEGIN TRANSACTION

		EXEC [dbo].[USP_CM_BankStatement_InsertJournal] @IDX_T_BankStatementHeader, @JournalDate, NULL, @Remark,
			@UserID, @Journal OUTPUT

		INSERT INTO CM_T_BankStatementAdjustment
			(IDX_T_BankStatementHeader, IDX_T_JournalHeader, SourceType, SourceID, UCreate, DCreate, RecordStatus)
		SELECT @IDX_T_BankStatementHeader, @Journal, SourceType, SourceID, @UserID, GETDATE(), 'A'
		FROM @Rows

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @IDX_T_BankStatementHeader AS ID,
			   'Jurnal penyesuaian DRAFT-' + CONVERT(VARCHAR, @Journal) + ' berhasil dibuat (status Unposted).' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
