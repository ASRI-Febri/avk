SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Update template journal recurring.
--				  Jurnal yang sudah tergenerate periode sebelumnya tidak
--				  ikut berubah - perubahan hanya berlaku untuk generate
--				  periode berikutnya.
-- =============================================

-- EXEC [dbo].[USP_GL_RecurringJournal_Update] 1,1,2,'RJ-SEWA','Amortisasi sewa kantor','Sewa kantor 12 bulan',10,20,4833333.33,'202607','202706','A','it_febry','A'

CREATE PROCEDURE [dbo].[USP_GL_RecurringJournal_Update]
	@IDX_M_RecurringJournal	BIGINT,
	@IDX_M_Company			INT,
	@IDX_M_Branch			INT,
	@RecurringCode			VARCHAR(32),
	@RecurringName			VARCHAR(200),
	@RecurringDesc			VARCHAR(5000),
	@IDX_M_COA_Debet		BIGINT,
	@IDX_M_COA_Credit		BIGINT,
	@RecurringAmount		DECIMAL(18,2),
	@TotalAmount			DECIMAL(18,2),	-- nilai total kontrak (wajib bila AdjustLastPeriod = Y)
	@AdjustLastPeriod		CHAR(1),		-- Y = periode terakhir dihitung ulang dari TotalAmount - akumulasi
	@StartPeriod			VARCHAR(6),
	@EndPeriod				VARCHAR(6),
	@RecurringStatus		CHAR(1),
	@UserID					VARCHAR(36),
	@RecordStatus			VARCHAR(1)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF NOT EXISTS (SELECT 1 FROM GL_M_RecurringJournal WHERE IDX_M_RecurringJournal = @IDX_M_RecurringJournal)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Template recurring tidak ditemukan!')
		END

		IF RTRIM(ISNULL(@RecurringCode,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode recurring belum diisi!')
		END

		IF RTRIM(ISNULL(@RecurringName,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nama recurring belum diisi!')
		END

		IF ISNULL(@IDX_M_COA_Debet,0) = 0 OR ISNULL(@IDX_M_COA_Credit,0) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Akun debet dan kredit wajib dipilih!')
		END

		IF ISNULL(@IDX_M_COA_Debet,0) = ISNULL(@IDX_M_COA_Credit,0) AND ISNULL(@IDX_M_COA_Debet,0) <> 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Akun debet dan kredit tidak boleh sama!')
		END

		IF ISNULL(@RecurringAmount,0) <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nilai per periode harus lebih dari 0!')
		END

		IF LEN(RTRIM(ISNULL(@StartPeriod,''))) <> 6 OR ISNUMERIC(@StartPeriod) = 0
			OR CONVERT(INT, RIGHT(@StartPeriod,2)) NOT BETWEEN 1 AND 12
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Periode mulai tidak valid! Gunakan format YYYYMM.')
		END

		IF RTRIM(ISNULL(@EndPeriod,'')) <> ''
		BEGIN
			IF LEN(RTRIM(@EndPeriod)) <> 6 OR ISNUMERIC(@EndPeriod) = 0
				OR CONVERT(INT, RIGHT(@EndPeriod,2)) NOT BETWEEN 1 AND 12
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Periode akhir tidak valid! Gunakan format YYYYMM atau kosongkan.')
			END
			ELSE IF @EndPeriod < @StartPeriod
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Periode akhir tidak boleh lebih kecil dari periode mulai!')
			END
		END

		IF EXISTS (
			SELECT 1 FROM GL_M_RecurringJournal
			WHERE RTRIM(ISNULL(RecurringCode,'')) = RTRIM(@RecurringCode)
				AND IDX_M_RecurringJournal <> @IDX_M_RecurringJournal
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode recurring ' + RTRIM(@RecurringCode) + ' sudah terdaftar!')
		END

		-- Validasi opsi penyesuaian periode terakhir
		IF RTRIM(ISNULL(@AdjustLastPeriod,'')) NOT IN ('Y','N','')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Opsi penyesuaian periode terakhir tidak valid! Gunakan Y atau N.')
		END

		IF RTRIM(ISNULL(@AdjustLastPeriod,'')) = 'Y'
		BEGIN
			IF RTRIM(ISNULL(@EndPeriod,'')) = ''
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Penyesuaian periode terakhir membutuhkan Periode Akhir!')
			END

			IF ISNULL(@TotalAmount,0) <= 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Nilai total kontrak harus diisi bila penyesuaian periode terakhir aktif!')
			END

			IF ISNULL(@TotalAmount,0) > 0 AND ISNULL(@TotalAmount,0) < ISNULL(@RecurringAmount,0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Nilai total kontrak tidak boleh lebih kecil dari nilai per periode!')
			END

			-- Bila periode terakhir sudah pernah digenerate, penyesuaian tidak lagi relevan diubah
			IF EXISTS (
				SELECT 1 FROM GL_T_RecurringJournalLog WITH(NOLOCK)
				WHERE IDX_M_RecurringJournal = @IDX_M_RecurringJournal
					AND RecurringPeriod = RTRIM(@EndPeriod) AND RecordStatus = 'A'
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Periode terakhir (' + RTRIM(@EndPeriod) + ') sudah pernah digenerate! Perubahan penyesuaian tidak berlaku lagi.')
			END
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			UPDATE [dbo].[GL_M_RecurringJournal] SET
				 [IDX_M_Company]	= @IDX_M_Company
				,[IDX_M_Branch]		= @IDX_M_Branch
				,[RecurringCode]	= @RecurringCode
				,[RecurringName]	= @RecurringName
				,[RecurringDesc]	= @RecurringDesc
				,[IDX_M_COA_Debet]	= @IDX_M_COA_Debet
				,[IDX_M_COA_Credit]	= @IDX_M_COA_Credit
				,[RecurringAmount]	= @RecurringAmount
				,[TotalAmount]		= NULLIF(@TotalAmount,0)
				,[AdjustLastPeriod]	= CASE WHEN RTRIM(ISNULL(@AdjustLastPeriod,'')) = 'Y' THEN 'Y' ELSE 'N' END
				,[StartPeriod]		= @StartPeriod
				,[EndPeriod]		= NULLIF(RTRIM(ISNULL(@EndPeriod,'')),'')
				,[RecurringStatus]	= @RecurringStatus
				,[RecordStatus]		= @RecordStatus
				,[UModified]		= @UserID
				,[DModified]		= GETDATE()
			WHERE IDX_M_RecurringJournal = @IDX_M_RecurringJournal

			INSERT INTO @TableLog VALUES ('success', @IDX_M_RecurringJournal, 'Data berhasil disimpan.')
		END

		SELECT * FROM @TableLog

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
