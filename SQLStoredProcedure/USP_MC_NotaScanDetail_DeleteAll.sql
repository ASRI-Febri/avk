SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 17 Apr 2026
-- Description	: Hapus semua baris detail nota scan
--                untuk satu header (dipakai sebelum re-insert
--                saat update agar data selalu sinkron dengan
--                hasil edit di form)
-- =============================================

/*
	EXEC [dbo].[USP_MC_NotaScanDetail_DeleteAll] 1,'it_febry'
*/

CREATE PROCEDURE [dbo].[USP_MC_NotaScanDetail_DeleteAll]
	@IDX_T_MC_NotaScan	BIGINT,
	@UserID				VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_RowsDeleted AS INT = 0

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF @IDX_T_MC_NotaScan = 0 OR @IDX_T_MC_NotaScan IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Referensi header nota scan tidak valid!')
		END

		-- Pastikan header masih Draft sebelum boleh dihapus
		IF NOT EXISTS (
			SELECT 1 FROM MC_T_NotaScan
			WHERE IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan
				AND Status = 'D'
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Header nota scan tidak ditemukan atau sudah bukan Draft!')
		END

		-- ==================================================
		-- HAPUS SEMUA BARIS DETAIL
		-- ==================================================
		DECLARE @_CountLog AS INT
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			DELETE FROM MC_T_NotaScanDetail
			WHERE IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan

			SET @_RowsDeleted = @@ROWCOUNT

			INSERT INTO @TableLog VALUES (
				'success',
				@IDX_T_MC_NotaScan,
				CONVERT(VARCHAR, @_RowsDeleted) + ' baris detail berhasil dihapus.'
			)
		END

		COMMIT TRANSACTION;

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
