SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Generate jurnal untuk SEMUA template recurring aktif pada
			  satu periode (YYYYMM). Dipanggil setiap akhir periode.

			  Per template: Debet akun debet, Kredit akun kredit sebesar
			  RecurringAmount. Jurnal langsung posted (pola jurnal penyusutan),
			  tanggal jurnal = akhir bulan periode,
			  ReferenceNo = 'RJ-{RecurringCode}-{periode}'.

			  Anti dobel: template yang sudah punya log aktif untuk periode
			  tsb dilewati (unique index di GL_T_RecurringJournalLog).

			  Contoh kasus: sewa kantor dibayar dimuka 58.000.000 sudah
			  dijurnal (D: Sewa Dibayar Dimuka, K: Bank). Template recurring
			  D: Biaya Sewa, K: Sewa Dibayar Dimuka sebesar nilai amortisasi
			  per bulan, periode mulai s/d akhir kontrak.

/*
	EXEC [dbo].[USP_GL_RecurringJournal_Generate] 1,'202607','it_febry'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_GL_RecurringJournal_Generate]
	@IDX_M_Company		INT,
	@Period				VARCHAR(6),
	@UserID				VARCHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	-- Sesuaikan dengan master Journal Type untuk jurnal recurring/memorial
	DECLARE @_IDX_M_JournalType		INT = 1

	BEGIN TRY

		BEGIN TRANSACTION;

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),
				ID			BIGINT,
				LogDesc		VARCHAR(500)
			)

			DECLARE @_CountLog				INT
			DECLARE @_JournalDate			DATE
			DECLARE @_CountGenerated		INT = 0
			DECLARE @_CountSkipped			INT = 0

			DECLARE @_IDX_M_RecurringJournal	BIGINT
			DECLARE @_IDX_M_Branch				INT
			DECLARE @_RecurringCode				VARCHAR(32)
			DECLARE @_RecurringName				VARCHAR(200)
			DECLARE @_RecurringDesc				VARCHAR(5000)
			DECLARE @_COA_Debet					BIGINT
			DECLARE @_COA_Credit				BIGINT
			DECLARE @_Amount					DECIMAL(18,2)
			DECLARE @_TotalAmount				DECIMAL(18,2)
			DECLARE @_AdjustLastPeriod			CHAR(1)
			DECLARE @_EndPeriod					VARCHAR(6)
			DECLARE @_GeneratedSoFar			DECIMAL(18,2)
			DECLARE @_AdjustInfo				VARCHAR(200)
			DECLARE @_IDX_T_JournalHeader		BIGINT
			DECLARE @_IDX_T_Log					BIGINT
			DECLARE @_ReferenceNo				VARCHAR(50)

			-- ==================================================
			-- VALIDASI PERIODE
			-- ==================================================
			IF LEN(RTRIM(ISNULL(@Period,''))) <> 6 OR ISNUMERIC(@Period) = 0
				OR CONVERT(INT, RIGHT(@Period,2)) NOT BETWEEN 1 AND 12
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Periode tidak valid! Gunakan format YYYYMM.')
			END
			ELSE
			BEGIN
				SET @_JournalDate = EOMONTH(CONVERT(DATE, @Period + '01', 112))
			END

			IF NOT EXISTS (
				SELECT 1 FROM GL_M_RecurringJournal WITH(NOLOCK)
				WHERE IDX_M_Company = @IDX_M_Company AND RecordStatus = 'A' AND RecurringStatus = 'A'
					AND StartPeriod <= @Period
					AND (EndPeriod IS NULL OR EndPeriod >= @Period)
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tidak ada template recurring aktif untuk periode ' + @Period + '!')
			END

			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				-- ==================================================
				-- LOOP TEMPLATE AKTIF YANG BELUM DIGENERATE
				-- ==================================================
				DECLARE crs CURSOR LOCAL FOR
				SELECT RJ.IDX_M_RecurringJournal, RJ.IDX_M_Branch, RTRIM(RJ.RecurringCode),
					RTRIM(RJ.RecurringName), RJ.RecurringDesc,
					RJ.IDX_M_COA_Debet, RJ.IDX_M_COA_Credit, RJ.RecurringAmount,
					ISNULL(RJ.TotalAmount,0), ISNULL(RJ.AdjustLastPeriod,'N'), RTRIM(ISNULL(RJ.EndPeriod,''))
				FROM GL_M_RecurringJournal RJ WITH(NOLOCK)
				WHERE RJ.IDX_M_Company = @IDX_M_Company
					AND RJ.RecordStatus = 'A'
					AND RJ.RecurringStatus = 'A'
					AND RJ.StartPeriod <= @Period
					AND (RJ.EndPeriod IS NULL OR RJ.EndPeriod >= @Period)
				ORDER BY RJ.RecurringCode

				OPEN crs
				FETCH NEXT FROM crs INTO @_IDX_M_RecurringJournal, @_IDX_M_Branch, @_RecurringCode,
					@_RecurringName, @_RecurringDesc, @_COA_Debet, @_COA_Credit, @_Amount,
					@_TotalAmount, @_AdjustLastPeriod, @_EndPeriod

				WHILE @@FETCH_STATUS = 0
				BEGIN

					-- Skip bila periode ini sudah pernah digenerate
					IF EXISTS (
						SELECT 1 FROM GL_T_RecurringJournalLog WITH(NOLOCK)
						WHERE IDX_M_RecurringJournal = @_IDX_M_RecurringJournal
							AND RecurringPeriod = @Period AND RecordStatus = 'A'
					)
					BEGIN
						SET @_CountSkipped = @_CountSkipped + 1
						INSERT INTO @TableLog VALUES ('success', @_IDX_M_RecurringJournal,
							'[SKIP] ' + @_RecurringCode + ' sudah pernah digenerate untuk periode ' + @Period + '.')
					END
					ELSE
					BEGIN

						SET @_ReferenceNo = 'RJ-' + @_RecurringCode + '-' + @Period
						SET @_AdjustInfo = ''

						-- ==========================================================
						-- PENYESUAIAN PERIODE TERAKHIR (hindari sisa pembulatan)
						-- Contoh: sewa 58.000.000 / 12 bulan = 4.833.333,33/bulan.
						-- 11 bulan pertama = 53.166.666,63; periode ke-12 dihitung
						-- ulang = 58.000.000 - 53.166.666,63 = 4.833.333,37.
						-- ==========================================================
						IF @_AdjustLastPeriod = 'Y' AND @_EndPeriod = @Period AND @_TotalAmount > 0
						BEGIN
							SELECT @_GeneratedSoFar = ISNULL(SUM(ISNULL(GeneratedAmount,0)),0)
							FROM GL_T_RecurringJournalLog WITH(NOLOCK)
							WHERE IDX_M_RecurringJournal = @_IDX_M_RecurringJournal
								AND RecordStatus = 'A'

							SET @_Amount = @_TotalAmount - @_GeneratedSoFar
							SET @_AdjustInfo = ' (penyesuaian periode terakhir: total '
								+ CONVERT(VARCHAR, CONVERT(MONEY, @_TotalAmount), 1)
								+ ' - sudah digenerate '
								+ CONVERT(VARCHAR, CONVERT(MONEY, @_GeneratedSoFar), 1) + ')'
						END

						IF @_Amount <= 0
						BEGIN
							SET @_CountSkipped = @_CountSkipped + 1
							INSERT INTO @TableLog VALUES ('success', @_IDX_M_RecurringJournal,
								'[SKIP] ' + @_RecurringCode + ' - nilai penyesuaian periode terakhir '
								+ CONVERT(VARCHAR, CONVERT(MONEY, @_Amount), 1)
								+ ' (total kontrak sudah habis teramortisasi), tidak ada jurnal dibuat.')

							FETCH NEXT FROM crs INTO @_IDX_M_RecurringJournal, @_IDX_M_Branch, @_RecurringCode,
								@_RecurringName, @_RecurringDesc, @_COA_Debet, @_COA_Credit, @_Amount,
								@_TotalAmount, @_AdjustLastPeriod, @_EndPeriod
							CONTINUE
						END

						-- ==========================================================
						-- INSERT JOURNAL HEADER (langsung posted, pola jurnal FA)
						-- ==========================================================
						INSERT INTO [dbo].[GL_T_JournalHeader]
							([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]
							,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
							,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
							,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
							,[JournalSource],[UCreate],[DCreate],[RecordStatus])
						VALUES
							(@IDX_M_Company, @_IDX_M_Branch, @_IDX_M_JournalType, NULL,
							0, @_IDX_M_RecurringJournal, @_ReferenceNo, @_ReferenceNo,
							@_JournalDate,
							@_RecurringName + ' periode ' + @Period, '', 'P',
							@_JournalDate, @UserID, 0, 0,
							'S', @UserID, GETDATE(), 'A')

						SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

						-- DEBET
						INSERT INTO [dbo].[GL_T_JournalDetail]
							([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
							,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
							,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
							,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
						SELECT
							@_IDX_T_JournalHeader, 99, 99, @_COA_Debet, NULL,
							0, C.COADesc, @_RecurringName + ' periode ' + @Period,
							1, @_Amount, 0, 1,
							1, @_Amount, 0, @UserID, GETDATE(), 'A'
						FROM GL_M_COA C WITH(NOLOCK)
						WHERE C.IDX_M_COA = @_COA_Debet

						-- KREDIT
						INSERT INTO [dbo].[GL_T_JournalDetail]
							([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
							,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
							,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
							,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
						SELECT
							@_IDX_T_JournalHeader, 99, 99, @_COA_Credit, NULL,
							0, C.COADesc, @_RecurringName + ' periode ' + @Period,
							1, 0, @_Amount, 1,
							1, 0, @_Amount, @UserID, GETDATE(), 'A'
						FROM GL_M_COA C WITH(NOLOCK)
						WHERE C.IDX_M_COA = @_COA_Credit

						-- LOG ANTI DOBEL
						INSERT INTO [dbo].[GL_T_RecurringJournalLog]
							([IDX_M_RecurringJournal]
							,[RecurringPeriod]
							,[IDX_T_JournalHeader]
							,[GeneratedAmount]
							,[RecordStatus]
							,[UCreate]
							,[DCreate])
						VALUES
							(@_IDX_M_RecurringJournal, @Period, @_IDX_T_JournalHeader,
							@_Amount, 'A', @UserID, GETDATE())

						SET @_IDX_T_Log = SCOPE_IDENTITY()
						SET @_CountGenerated = @_CountGenerated + 1

						INSERT INTO @TableLog VALUES ('success', @_IDX_T_Log,
							'[OK] ' + @_RecurringCode + ' - jurnal ' + @_ReferenceNo + ' sebesar '
							+ CONVERT(VARCHAR, CONVERT(MONEY, @_Amount), 1) + @_AdjustInfo + '.')
					END

					FETCH NEXT FROM crs INTO @_IDX_M_RecurringJournal, @_IDX_M_Branch, @_RecurringCode,
						@_RecurringName, @_RecurringDesc, @_COA_Debet, @_COA_Credit, @_Amount,
						@_TotalAmount, @_AdjustLastPeriod, @_EndPeriod
				END

				CLOSE crs
				DEALLOCATE crs

				INSERT INTO @TableLog VALUES ('success', 0,
					'Selesai. ' + CONVERT(VARCHAR, @_CountGenerated) + ' jurnal digenerate, '
					+ CONVERT(VARCHAR, @_CountSkipped) + ' template dilewati (sudah pernah digenerate).')
			END

			SELECT * FROM @TableLog

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())

		SELECT * FROM @TableLog

		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. Committing transaction.'
			COMMIT TRANSACTION;
		END;

	END CATCH;

END
GO
