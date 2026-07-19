SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Generate jurnal penyusutan dari hasil kalkulasi (status C)
			  Satu jurnal per periode per company:
				Debet  : Beban Penyusutan (per kategori aset)
				Kredit : Akumulasi Penyusutan (per kategori aset)
			  Jurnal langsung PostingStatus = 'P' (pola USP_CM_FinancialReceive_CreateJournal),
			  JournalDate = akhir bulan periode.
			  Setelah sukses, run diupdate ke status P + link IDX_T_JournalHeader.

/*
	EXEC [dbo].[USP_FA_GenerateJournalDepreciation] 1,2,'202607','it_febry'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_GenerateJournalDepreciation]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,			-- Cabang pembukuan jurnal penyusutan
	@DeprPeriod			VARCHAR(6),
	@UserID				VARCHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	-- Sesuaikan dengan master Journal Type untuk "FA Depreciation"
	-- (pola sama dengan @_IDX_M_JournalType = 6 di USP_CM_FinancialReceive_CreateJournal)
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
			DECLARE @_IDX_T_Depreciation	BIGINT
			DECLARE @_DeprStatus			CHAR(1)
			DECLARE @_IDX_T_JournalHeader	BIGINT
			DECLARE @_JournalDate			DATE
			DECLARE @_ReferenceNo			VARCHAR(50)
			DECLARE @_TotalDepr				DECIMAL(18,2)
			DECLARE @_CountNoMapping		INT

			-- ==================================================
			-- VALIDASI
			-- ==================================================
			SELECT @_IDX_T_Depreciation = IDX_T_Depreciation, @_DeprStatus = DeprStatus
			FROM FA_T_Depreciation WITH(NOLOCK)
			WHERE IDX_M_Company = @IDX_M_Company AND DeprPeriod = @DeprPeriod AND RecordStatus = 'A'

			IF @_IDX_T_Depreciation IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Penyusutan periode ' + @DeprPeriod + ' belum dihitung!')
			END
			ELSE IF @_DeprStatus = 'P'
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Jurnal penyusutan periode ' + @DeprPeriod + ' sudah pernah digenerate!')
			END

			IF ISNULL(@IDX_M_Branch,0) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Cabang pembukuan jurnal belum dipilih!')
			END

			SET @_ReferenceNo = 'FA-DEPR-' + @DeprPeriod

			IF EXISTS (
				SELECT 1 FROM GL_T_JournalHeader WITH(NOLOCK)
				WHERE IDX_ReferenceNo = ISNULL(@_IDX_T_Depreciation,0)
					AND RTRIM(ReferenceNo) = @_ReferenceNo
					AND RecordStatus = 'A'
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Jurnal ' + @_ReferenceNo + ' sudah ada di GL!')
			END

			-- Semua kategori aset yang terlibat harus punya mapping akun lengkap
			SELECT @_CountNoMapping = COUNT(DISTINCT A.IDX_M_AssetCategory)
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
				INNER JOIN FA_M_Asset A WITH(NOLOCK) ON DD.IDX_M_Asset = A.IDX_M_Asset
				LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
			WHERE DD.IDX_T_Depreciation = ISNULL(@_IDX_T_Depreciation,0)
				AND DD.RecordStatus = 'A'
				AND DD.DeprAmount > 0
				AND (ISNULL(AC.IDX_M_COA_DeprExpense,0) = 0 OR ISNULL(AC.IDX_M_COA_AccumDepr,0) = 0)

			IF @_CountNoMapping > 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Ada ' + CONVERT(VARCHAR,@_CountNoMapping)
					+ ' kategori aset yang mapping akun beban/akumulasi penyusutannya belum lengkap!')
			END

			SELECT @_TotalDepr = ISNULL(SUM(ISNULL(DD.DeprAmount,0)),0)
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
			WHERE DD.IDX_T_Depreciation = ISNULL(@_IDX_T_Depreciation,0)
				AND DD.RecordStatus = 'A'

			IF @_TotalDepr <= 0 AND @_IDX_T_Depreciation IS NOT NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Total penyusutan komersial periode ' + @DeprPeriod + ' adalah 0, tidak ada jurnal yang perlu dibuat!')
			END

			-- ==================================================
			-- GENERATE JOURNAL
			-- ==================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				SET @_JournalDate = EOMONTH(CONVERT(DATE, @DeprPeriod + '01', 112))

				-- ======================================================================================================
				-- INSERT JOURNAL HEADER
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalHeader]
					([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]
					,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
					,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
					,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
					,[JournalSource],[UCreate],[DCreate],[RecordStatus])
				VALUES
					(@IDX_M_Company, @IDX_M_Branch, @_IDX_M_JournalType, NULL,
					0, @_IDX_T_Depreciation, @_ReferenceNo, @_ReferenceNo,
					@_JournalDate, 'Penyusutan aset tetap periode ' + @DeprPeriod, '', 'P',
					@_JournalDate, @UserID, 0, 0,
					'S', @UserID, GETDATE(), 'A')

				SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ======================================================================================================
				-- INSERT JOURNAL DETAIL PER KATEGORI ASET
				-- BEBAN PENYUSUTAN (DEBET)
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT
					@_IDX_T_JournalHeader, 99, 99, AC.IDX_M_COA_DeprExpense,
					NULL,
					0, CE.COADesc, 'Beban penyusutan ' + RTRIM(AC.CategoryName) + ' periode ' + @DeprPeriod,
					1, SUM(ISNULL(DD.DeprAmount,0)), 0, 1,
					1, SUM(ISNULL(DD.DeprAmount,0)), 0, @UserID, GETDATE(), 'A'
				FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
					INNER JOIN FA_M_Asset A WITH(NOLOCK) ON DD.IDX_M_Asset = A.IDX_M_Asset
					INNER JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
					LEFT JOIN GL_M_COA CE WITH(NOLOCK) ON AC.IDX_M_COA_DeprExpense = CE.IDX_M_COA
				WHERE DD.IDX_T_Depreciation = @_IDX_T_Depreciation
					AND DD.RecordStatus = 'A'
					AND DD.DeprAmount > 0
				GROUP BY AC.IDX_M_COA_DeprExpense, CE.COADesc, AC.CategoryName

				-- ======================================================================================================
				-- AKUMULASI PENYUSUTAN (KREDIT)
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT
					@_IDX_T_JournalHeader, 99, 99, AC.IDX_M_COA_AccumDepr,
					NULL,
					0, CD.COADesc, 'Akumulasi penyusutan ' + RTRIM(AC.CategoryName) + ' periode ' + @DeprPeriod,
					1, 0, SUM(ISNULL(DD.DeprAmount,0)), 1,
					1, 0, SUM(ISNULL(DD.DeprAmount,0)), @UserID, GETDATE(), 'A'
				FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
					INNER JOIN FA_M_Asset A WITH(NOLOCK) ON DD.IDX_M_Asset = A.IDX_M_Asset
					INNER JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
					LEFT JOIN GL_M_COA CD WITH(NOLOCK) ON AC.IDX_M_COA_AccumDepr = CD.IDX_M_COA
				WHERE DD.IDX_T_Depreciation = @_IDX_T_Depreciation
					AND DD.RecordStatus = 'A'
					AND DD.DeprAmount > 0
				GROUP BY AC.IDX_M_COA_AccumDepr, CD.COADesc, AC.CategoryName

				-- ======================================================================================================
				-- UPDATE STATUS RUN PENYUSUTAN
				-- ======================================================================================================
				UPDATE [dbo].[FA_T_Depreciation] SET
					 [DeprStatus]			= 'P'
					,[IDX_T_JournalHeader]	= @_IDX_T_JournalHeader
					,[UModified]			= @UserID
					,[DModified]			= GETDATE()
				WHERE IDX_T_Depreciation = @_IDX_T_Depreciation

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_Depreciation,
					'Jurnal penyusutan ' + @_ReferenceNo + ' berhasil digenerate. Total: '
					+ CONVERT(VARCHAR, CONVERT(MONEY, @_TotalDepr), 1))
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
