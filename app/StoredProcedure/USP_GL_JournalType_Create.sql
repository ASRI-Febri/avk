SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Insert journal type baru
--				  AllowJournalEntry: Y = boleh dipakai/diedit via journal entry manual,
--				  N = hanya untuk jurnal yang digenerate sistem
-- =============================================

-- EXEC [dbo].[USP_GL_JournalType_Create] 'FA-DEPR','FA Depreciation','N','FA Depreciation','it_febry','A'

CREATE PROCEDURE [dbo].[USP_GL_JournalType_Create]
	@JournalTypeID			VARCHAR(32),
	@JournalTypeDesc		VARCHAR(64),
	@AllowJournalEntry		CHAR(1),
	@JournalLabel			VARCHAR(32),
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
		DECLARE @_IDX_M_JournalType AS BIGINT

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF RTRIM(ISNULL(@JournalTypeID,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Journal Type ID belum diisi!')
		END

		IF RTRIM(ISNULL(@JournalTypeDesc,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Journal Type Description belum diisi!')
		END

		IF RTRIM(ISNULL(@AllowJournalEntry,'')) NOT IN ('Y','N')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Allow Journal Entry tidak valid! Gunakan Y atau N.')
		END

		IF EXISTS (
			SELECT 1 FROM GL_M_JournalType
			WHERE RTRIM(ISNULL(JournalTypeID,'')) = RTRIM(@JournalTypeID)
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Journal Type ID ' + RTRIM(@JournalTypeID) + ' sudah terdaftar!')
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			INSERT INTO [dbo].[GL_M_JournalType]
				([JournalTypeID]
				,[JournalTypeDesc]
				,[AllowJournalEntry]
				,[JournalLabel]
				,[RecordStatus]
				,[UCreate]
				,[DCreate])
			VALUES
				(@JournalTypeID
				,@JournalTypeDesc
				,@AllowJournalEntry
				,@JournalLabel
				,@RecordStatus
				,@UserID
				,GETDATE())

			SET @_IDX_M_JournalType = SCOPE_IDENTITY()

			INSERT INTO @TableLog VALUES ('success', @_IDX_M_JournalType, 'Data berhasil disimpan.')
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
