SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Simpan mutasi aset tetap (pindah cabang / departemen).
--				  Insert riwayat ke FA_T_AssetMutation lalu update posisi
--				  terkini di FA_M_Asset. Tidak membuat jurnal (nilai buku
--				  aset tidak berubah; akuntansi antar cabang di luar scope).
-- =============================================

-- EXEC [dbo].[USP_FA_AssetMutation_Save] 1,'2026-07-19',2,3,'Pindah ke cabang baru','it_febry'

CREATE PROCEDURE [dbo].[USP_FA_AssetMutation_Save]
	@IDX_M_Asset			BIGINT,
	@MutationDate			DATE,
	@IDX_M_Branch_To		INT,
	@IDX_M_Department_To	INT,
	@MutationNotes			VARCHAR(5000),
	@UserID					VARCHAR(36)
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
			DECLARE @_IDX_T_AssetMutation	BIGINT
			DECLARE @_AssetStatus			CHAR(1)
			DECLARE @_BranchFrom			INT
			DECLARE @_DeptFrom				INT

			-- ==================================================
			-- VALIDASI
			-- ==================================================
			SELECT @_AssetStatus = AssetStatus, @_BranchFrom = IDX_M_Branch, @_DeptFrom = IDX_M_Department
			FROM FA_M_Asset WITH(NOLOCK)
			WHERE IDX_M_Asset = @IDX_M_Asset AND RecordStatus = 'A'

			IF @_AssetStatus IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Aset tidak ditemukan!')
			END
			ELSE IF @_AssetStatus IN ('S','W','H')
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Aset sudah dilepas (dijual/hapus buku/hibah), tidak dapat dimutasi!')
			END

			IF @MutationDate IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal mutasi belum diisi!')
			END

			IF ISNULL(@IDX_M_Branch_To,0) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Cabang tujuan belum dipilih!')
			END

			IF ISNULL(@IDX_M_Branch_To,0) = ISNULL(@_BranchFrom,0)
				AND ISNULL(NULLIF(@IDX_M_Department_To,0), ISNULL(@_DeptFrom,0)) = ISNULL(@_DeptFrom,0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Cabang / departemen tujuan sama dengan posisi aset saat ini, tidak ada yang dimutasi!')
			END

			-- ==================================================
			-- PROSES SIMPAN
			-- ==================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				INSERT INTO [dbo].[FA_T_AssetMutation]
					([IDX_M_Asset]
					,[MutationDate]
					,[IDX_M_Branch_From]
					,[IDX_M_Branch_To]
					,[IDX_M_Department_From]
					,[IDX_M_Department_To]
					,[MutationNotes]
					,[RecordStatus]
					,[UCreate]
					,[DCreate])
				VALUES
					(@IDX_M_Asset
					,@MutationDate
					,@_BranchFrom
					,@IDX_M_Branch_To
					,@_DeptFrom
					,NULLIF(@IDX_M_Department_To,0)
					,@MutationNotes
					,'A'
					,@UserID
					,GETDATE())

				SET @_IDX_T_AssetMutation = SCOPE_IDENTITY()

				UPDATE [dbo].[FA_M_Asset] SET
					 [IDX_M_Branch]		= @IDX_M_Branch_To
					,[IDX_M_Department]	= NULLIF(@IDX_M_Department_To,0)
					,[UModified]		= @UserID
					,[DModified]		= GETDATE()
				WHERE IDX_M_Asset = @IDX_M_Asset

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_AssetMutation, 'Mutasi aset berhasil disimpan.')
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
