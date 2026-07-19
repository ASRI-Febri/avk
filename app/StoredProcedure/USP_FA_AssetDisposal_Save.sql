SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Pelepasan aset tetap (PSAK 16 - penghentian pengakuan)
			  + generate jurnal GL otomatis (langsung posted, pola
			  USP_FA_GenerateJournalDepreciation).

			  Jurnal yang dibentuk:
				Debet  : Akun penerima hasil (kas/bank) sebesar harga jual (tipe S)
				Debet  : Akumulasi Penyusutan (akumulasi s/d pelepasan)
				Debet  : Rugi Pelepasan (bila rugi)
				Kredit : Aset Tetap (harga perolehan)
				Kredit : Laba Pelepasan (bila laba)

			  Setelah sukses: FA_M_Asset.AssetStatus = S/W/H + DisposalDate terisi,
			  sehingga aset otomatis berhenti disusutkan.

/*
	-- Jual
	EXEC [dbo].[USP_FA_AssetDisposal_Save] 1,'2026-07-19','S',150000000,5,'Dijual tunai','it_febry'
	-- Hapus buku
	EXEC [dbo].[USP_FA_AssetDisposal_Save] 1,'2026-07-19','W',0,0,'Rusak total','it_febry'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_AssetDisposal_Save]
	@IDX_M_Asset		BIGINT,
	@DisposalDate		DATE,
	@DisposalType		CHAR(1),		-- S = Dijual, W = Hapus Buku, H = Hibah
	@DisposalProceed	DECIMAL(18,2),
	@IDX_M_COA_Proceed	BIGINT,			-- akun kas/bank penerima hasil (wajib utk tipe S)
	@DisposalNotes		VARCHAR(5000),
	@UserID				VARCHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	-- Sesuaikan dengan master Journal Type untuk jurnal fixed asset
	-- (konstanta sama dengan USP_FA_GenerateJournalDepreciation)
	DECLARE @_IDX_M_JournalType		INT = 7

	BEGIN TRY

		BEGIN TRANSACTION;

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),
				ID			BIGINT,
				LogDesc		VARCHAR(500)
			)

			DECLARE @_CountLog				INT
			DECLARE @_IDX_T_AssetDisposal	BIGINT
			DECLARE @_IDX_T_JournalHeader	BIGINT
			DECLARE @_ReferenceNo			VARCHAR(50)

			DECLARE @_IDX_M_Company			INT
			DECLARE @_IDX_M_Branch			INT
			DECLARE @_AssetStatus			CHAR(1)
			DECLARE @_AssetCode				VARCHAR(50)
			DECLARE @_AssetName				VARCHAR(200)
			DECLARE @_UsageStartDate		DATE
			DECLARE @_Cost					DECIMAL(18,2)
			DECLARE @_AccumDepr				DECIMAL(18,2)
			DECLARE @_BookValue				DECIMAL(18,2)
			DECLARE @_GainLoss				DECIMAL(18,2)
			DECLARE @_LastDeprPeriod		VARCHAR(6)

			DECLARE @_COA_Asset				BIGINT
			DECLARE @_COA_AccumDepr			BIGINT
			DECLARE @_COA_Gain				BIGINT
			DECLARE @_COA_Loss				BIGINT
			DECLARE @_CategoryName			VARCHAR(100)

			-- ==================================================
			-- AMBIL DATA ASET + KATEGORI
			-- ==================================================
			SELECT
				@_IDX_M_Company = A.IDX_M_Company,
				@_IDX_M_Branch = A.IDX_M_Branch,
				@_AssetStatus = A.AssetStatus,
				@_AssetCode = RTRIM(ISNULL(A.AssetCode,'')),
				@_AssetName = RTRIM(ISNULL(A.AssetName,'')),
				@_UsageStartDate = A.UsageStartDate,
				@_Cost = ISNULL(A.AcquisitionCost,0),
				@_AccumDepr = ISNULL(A.OpeningAccumDepr,0),
				@_COA_Asset = AC.IDX_M_COA_Asset,
				@_COA_AccumDepr = AC.IDX_M_COA_AccumDepr,
				@_COA_Gain = AC.IDX_M_COA_GainDisposal,
				@_COA_Loss = AC.IDX_M_COA_LossDisposal,
				@_CategoryName = RTRIM(ISNULL(AC.CategoryName,''))
			FROM FA_M_Asset A WITH(NOLOCK)
				LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
			WHERE A.IDX_M_Asset = @IDX_M_Asset AND A.RecordStatus = 'A'

			-- Akumulasi penyusutan tercatat (posted)
			SELECT @_AccumDepr = @_AccumDepr + ISNULL(SUM(ISNULL(DD.DeprAmount,0)),0)
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
				INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
			WHERE DD.IDX_M_Asset = @IDX_M_Asset
				AND D.DeprStatus = 'P'
				AND D.RecordStatus = 'A'
				AND DD.RecordStatus = 'A'

			SET @_BookValue = @_Cost - @_AccumDepr
			SET @_GainLoss = ISNULL(@DisposalProceed,0) - @_BookValue

			-- ==================================================
			-- VALIDASI
			-- ==================================================
			IF @_AssetStatus IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Aset tidak ditemukan!')
			END
			ELSE IF @_AssetStatus IN ('S','W','H')
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Aset sudah pernah dilepas!')
			END
			ELSE IF @_AssetStatus <> 'A'
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Hanya aset berstatus Aktif yang dapat dilepas!')
			END

			IF RTRIM(ISNULL(@DisposalType,'')) NOT IN ('S','W','H')
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tipe pelepasan tidak valid! Gunakan S (Dijual), W (Hapus Buku), atau H (Hibah).')
			END

			IF @DisposalDate IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal pelepasan belum diisi!')
			END

			IF @DisposalDate < @_UsageStartDate
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal pelepasan tidak boleh sebelum tanggal mulai pakai aset!')
			END

			IF @DisposalType = 'S'
			BEGIN
				IF ISNULL(@DisposalProceed,0) < 0
				BEGIN
					INSERT INTO @TableLog VALUES ('error', 0, 'Harga jual tidak boleh negatif!')
				END

				IF ISNULL(@IDX_M_COA_Proceed,0) = 0
				BEGIN
					INSERT INTO @TableLog VALUES ('error', 0, 'Akun penerima hasil penjualan (kas/bank) belum dipilih!')
				END
			END
			ELSE
			BEGIN
				-- Hapus buku / hibah tidak ada hasil penjualan
				SET @DisposalProceed = 0
				SET @IDX_M_COA_Proceed = NULL
				SET @_GainLoss = 0 - @_BookValue
			END

			-- Tidak boleh ada perhitungan penyusutan yang belum digenerate jurnalnya
			IF EXISTS (
				SELECT 1 FROM FA_T_Depreciation WITH(NOLOCK)
				WHERE IDX_M_Company = @_IDX_M_Company AND DeprStatus = 'C' AND RecordStatus = 'A'
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Masih ada perhitungan penyusutan berstatus Calculated! Generate jurnal atau batalkan dulu sebelum melepas aset.')
			END

			-- Tanggal pelepasan tidak boleh mundur dari periode penyusutan terakhir yang diposting
			SELECT @_LastDeprPeriod = MAX(D.DeprPeriod)
			FROM FA_T_Depreciation D WITH(NOLOCK)
				INNER JOIN FA_T_DepreciationDetail DD WITH(NOLOCK) ON D.IDX_T_Depreciation = DD.IDX_T_Depreciation
			WHERE DD.IDX_M_Asset = @IDX_M_Asset
				AND D.DeprStatus = 'P' AND D.RecordStatus = 'A' AND DD.RecordStatus = 'A'

			IF @_LastDeprPeriod IS NOT NULL
				AND LEFT(CONVERT(VARCHAR, @DisposalDate, 112), 6) < @_LastDeprPeriod
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal pelepasan tidak boleh lebih kecil dari periode penyusutan terakhir ('
					+ @_LastDeprPeriod + ')!')
			END

			-- Mapping akun kategori
			IF ISNULL(@_COA_Asset,0) = 0 OR ISNULL(@_COA_AccumDepr,0) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Mapping akun Aset / Akumulasi Penyusutan pada kategori aset belum lengkap!')
			END

			IF @_GainLoss > 0 AND ISNULL(@_COA_Gain,0) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Pelepasan menghasilkan laba tetapi akun Laba Pelepasan belum di-mapping pada kategori aset!')
			END

			IF @_GainLoss < 0 AND ISNULL(@_COA_Loss,0) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Pelepasan menghasilkan rugi tetapi akun Rugi Pelepasan belum di-mapping pada kategori aset!')
			END

			-- ==================================================
			-- PROSES SIMPAN + GENERATE JOURNAL
			-- ==================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				INSERT INTO [dbo].[FA_T_AssetDisposal]
					([IDX_M_Asset]
					,[DisposalDate]
					,[DisposalType]
					,[DisposalProceed]
					,[IDX_M_COA_Proceed]
					,[AccumDeprAtDisposal]
					,[BookValueAtDisposal]
					,[GainLossAmount]
					,[DisposalNotes]
					,[IDX_T_JournalHeader]
					,[DisposalStatus]
					,[RecordStatus]
					,[UCreate]
					,[DCreate])
				VALUES
					(@IDX_M_Asset
					,@DisposalDate
					,@DisposalType
					,ISNULL(@DisposalProceed,0)
					,@IDX_M_COA_Proceed
					,@_AccumDepr
					,@_BookValue
					,@_GainLoss
					,@DisposalNotes
					,NULL
					,'A'
					,'A'
					,@UserID
					,GETDATE())

				SET @_IDX_T_AssetDisposal = SCOPE_IDENTITY()
				SET @_ReferenceNo = 'FA-DISP-' + RIGHT('000000' + CONVERT(VARCHAR, @_IDX_T_AssetDisposal), 6)

				-- ======================================================================================================
				-- INSERT JOURNAL HEADER (langsung posted, pola jurnal penyusutan)
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalHeader]
					([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]
					,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
					,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
					,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
					,[JournalSource],[UCreate],[DCreate],[RecordStatus])
				VALUES
					(@_IDX_M_Company, @_IDX_M_Branch, @_IDX_M_JournalType, NULL,
					0, @_IDX_T_AssetDisposal, @_ReferenceNo, @_ReferenceNo,
					@DisposalDate,
					'Pelepasan aset ' + @_AssetCode + ' - ' + @_AssetName
						+ CASE @DisposalType WHEN 'S' THEN ' (dijual)' WHEN 'W' THEN ' (hapus buku)' ELSE ' (hibah)' END,
					'', 'P', @DisposalDate, @UserID, 0, 0,
					'S', @UserID, GETDATE(), 'A')

				SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ======================================================================================================
				-- JOURNAL DETAIL
				-- ======================================================================================================

				-- 1. DEBET: akun penerima hasil penjualan (hanya tipe S dengan harga jual > 0)
				IF @DisposalType = 'S' AND ISNULL(@DisposalProceed,0) > 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
						([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
						,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
						,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
						,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
					SELECT
						@_IDX_T_JournalHeader, 99, 99, @IDX_M_COA_Proceed, NULL,
						0, C.COADesc, 'Hasil penjualan aset ' + @_AssetCode,
						1, @DisposalProceed, 0, 1,
						1, @DisposalProceed, 0, @UserID, GETDATE(), 'A'
					FROM GL_M_COA C WITH(NOLOCK)
					WHERE C.IDX_M_COA = @IDX_M_COA_Proceed
				END

				-- 2. DEBET: akumulasi penyusutan (mengeluarkan akumulasi)
				IF @_AccumDepr <> 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
						([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
						,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
						,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
						,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
					SELECT
						@_IDX_T_JournalHeader, 99, 99, @_COA_AccumDepr, NULL,
						0, C.COADesc, 'Akumulasi penyusutan aset ' + @_AssetCode,
						1, @_AccumDepr, 0, 1,
						1, @_AccumDepr, 0, @UserID, GETDATE(), 'A'
					FROM GL_M_COA C WITH(NOLOCK)
					WHERE C.IDX_M_COA = @_COA_AccumDepr
				END

				-- 3. DEBET: rugi pelepasan (bila rugi)
				IF @_GainLoss < 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
						([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
						,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
						,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
						,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
					SELECT
						@_IDX_T_JournalHeader, 99, 99, @_COA_Loss, NULL,
						0, C.COADesc, 'Rugi pelepasan aset ' + @_AssetCode,
						1, ABS(@_GainLoss), 0, 1,
						1, ABS(@_GainLoss), 0, @UserID, GETDATE(), 'A'
					FROM GL_M_COA C WITH(NOLOCK)
					WHERE C.IDX_M_COA = @_COA_Loss
				END

				-- 4. KREDIT: aset tetap (mengeluarkan harga perolehan)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT
					@_IDX_T_JournalHeader, 99, 99, @_COA_Asset, NULL,
					0, C.COADesc, 'Pelepasan aset ' + @_AssetCode + ' (' + @_CategoryName + ')',
					1, 0, @_Cost, 1,
					1, 0, @_Cost, @UserID, GETDATE(), 'A'
				FROM GL_M_COA C WITH(NOLOCK)
				WHERE C.IDX_M_COA = @_COA_Asset

				-- 5. KREDIT: laba pelepasan (bila laba)
				IF @_GainLoss > 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
						([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
						,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
						,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
						,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
					SELECT
						@_IDX_T_JournalHeader, 99, 99, @_COA_Gain, NULL,
						0, C.COADesc, 'Laba pelepasan aset ' + @_AssetCode,
						1, 0, @_GainLoss, 1,
						1, 0, @_GainLoss, @UserID, GETDATE(), 'A'
					FROM GL_M_COA C WITH(NOLOCK)
					WHERE C.IDX_M_COA = @_COA_Gain
				END

				-- ======================================================================================================
				-- UPDATE DISPOSAL + STATUS ASET
				-- ======================================================================================================
				UPDATE [dbo].[FA_T_AssetDisposal] SET
					 [IDX_T_JournalHeader]	= @_IDX_T_JournalHeader
					,[UModified]			= @UserID
					,[DModified]			= GETDATE()
				WHERE IDX_T_AssetDisposal = @_IDX_T_AssetDisposal

				UPDATE [dbo].[FA_M_Asset] SET
					 [AssetStatus]	= @DisposalType
					,[DisposalDate]	= @DisposalDate
					,[UModified]	= @UserID
					,[DModified]	= GETDATE()
				WHERE IDX_M_Asset = @IDX_M_Asset

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_AssetDisposal,
					'Pelepasan aset ' + @_AssetCode + ' berhasil. Jurnal ' + @_ReferenceNo
					+ CASE WHEN @_GainLoss > 0 THEN ' (laba ' + CONVERT(VARCHAR, CONVERT(MONEY, @_GainLoss), 1) + ')'
						WHEN @_GainLoss < 0 THEN ' (rugi ' + CONVERT(VARCHAR, CONVERT(MONEY, ABS(@_GainLoss)), 1) + ')'
						ELSE '' END + '.')
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
