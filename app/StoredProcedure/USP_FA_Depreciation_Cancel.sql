SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Batalkan run penyusutan satu periode (soft delete)
			  Hanya boleh bila status masih C (jurnal belum digenerate).
			  Bila sudah P, jurnal GL harus di-unposting/dibatalkan dulu
			  melalui proses terpisah.

/*
	EXEC [dbo].[USP_FA_Depreciation_Cancel] 1,'202607','it_febry'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_Depreciation_Cancel]
	@IDX_M_Company		INT,
	@DeprPeriod			VARCHAR(6),
	@UserID				VARCHAR(36)
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

			DECLARE @_CountLog				INT
			DECLARE @_IDX_T_Depreciation	BIGINT
			DECLARE @_DeprStatus			CHAR(1)

			-- ==================================================
			-- VALIDASI
			-- ==================================================
			SELECT @_IDX_T_Depreciation = IDX_T_Depreciation, @_DeprStatus = DeprStatus
			FROM FA_T_Depreciation WITH(NOLOCK)
			WHERE IDX_M_Company = @IDX_M_Company AND DeprPeriod = @DeprPeriod AND RecordStatus = 'A'

			IF @_IDX_T_Depreciation IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Penyusutan periode ' + @DeprPeriod + ' tidak ditemukan!')
			END
			ELSE IF @_DeprStatus = 'P'
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Jurnal penyusutan periode ' + @DeprPeriod + ' sudah digenerate! Batalkan jurnal GL dulu sebelum membatalkan perhitungan.')
			END

			-- ==================================================
			-- PROSES BATAL (SOFT DELETE)
			-- ==================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				UPDATE [dbo].[FA_T_DepreciationDetail] SET
					 [RecordStatus]	= 'I'
					,[UModified]	= @UserID
					,[DModified]	= GETDATE()
				WHERE IDX_T_Depreciation = @_IDX_T_Depreciation

				UPDATE [dbo].[FA_T_Depreciation] SET
					 [RecordStatus]	= 'I'
					,[UModified]	= @UserID
					,[DModified]	= GETDATE()
				WHERE IDX_T_Depreciation = @_IDX_T_Depreciation

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_Depreciation,
					'Perhitungan penyusutan periode ' + @DeprPeriod + ' berhasil dibatalkan.')
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
