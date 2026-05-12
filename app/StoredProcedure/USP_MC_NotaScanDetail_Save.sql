SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 17 Apr 2026
-- Description	: Insert / update satu baris detail nota scan
-- =============================================

/*
	-- Insert baris baru
	EXEC [dbo].[USP_MC_NotaScanDetail_Save] 1,0,1,'PHP 100x3+50x1+20x2',390.00,289.0000,112710.00,'','it_febry'
	EXEC [dbo].[USP_MC_NotaScanDetail_Save] 1,0,2,'PHP',7000.00,289.0000,2023000.00,'Order PHP','it_febry'

	-- Update baris existing
	EXEC [dbo].[USP_MC_NotaScanDetail_Save] 1,2,2,'USD',100.00,15950.0000,1595000.00,'','it_febry'
*/

CREATE PROCEDURE [dbo].[USP_MC_NotaScanDetail_Save]
	@IDX_T_MC_NotaScan			BIGINT,
	@IDX_T_MC_NotaScanDetail	BIGINT,		-- 0 = Insert baru
	@Nomor						INT,
	@KeteranganValas			VARCHAR(200),
	@NilaiValas					DECIMAL(18,2),
	@NilaiTukar					DECIMAL(18,4),
	@TotalNilai					DECIMAL(18,2),
	@CatatanDetail				VARCHAR(500),
	@UserID						VARCHAR(50)
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

		DECLARE @_CountLog AS INT

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF @IDX_T_MC_NotaScan = 0 OR @IDX_T_MC_NotaScan IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Referensi header nota scan tidak valid!')
		END

		IF RTRIM(ISNULL(@KeteranganValas,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Keterangan valuta asing belum diisi!')
		END

		IF @NilaiValas <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nilai valuta asing harus lebih dari 0!')
		END

		IF @NilaiTukar <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nilai tukar (rate) harus lebih dari 0!')
		END

		-- Cek header masih Draft
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
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			-- Hitung ulang total jika 0
			IF @TotalNilai = 0
				SET @TotalNilai = @NilaiValas * @NilaiTukar

			IF @IDX_T_MC_NotaScanDetail = 0
			BEGIN
				-- INSERT
				INSERT INTO [dbo].[MC_T_NotaScanDetail]
					([IDX_T_MC_NotaScan]
					,[Nomor]
					,[KeteranganValas]
					,[NilaiValas]
					,[NilaiTukar]
					,[TotalNilai]
					,[CatatanDetail]
					,[RecordStatus]
					,[UCreate]
					,[DCreate])
				VALUES
					(@IDX_T_MC_NotaScan
					,@Nomor
					,@KeteranganValas
					,@NilaiValas
					,@NilaiTukar
					,@TotalNilai
					,@CatatanDetail
					,'A'
					,@UserID
					,GETDATE())

				SET @IDX_T_MC_NotaScanDetail = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				-- UPDATE
				UPDATE [dbo].[MC_T_NotaScanDetail] SET
					 [Nomor]			= @Nomor
					,[KeteranganValas]	= @KeteranganValas
					,[NilaiValas]		= @NilaiValas
					,[NilaiTukar]		= @NilaiTukar
					,[TotalNilai]		= @TotalNilai
					,[CatatanDetail]	= @CatatanDetail
				WHERE IDX_T_MC_NotaScanDetail = @IDX_T_MC_NotaScanDetail
					AND IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan
			END

			INSERT INTO @TableLog VALUES ('success', @IDX_T_MC_NotaScanDetail, 'Baris detail berhasil disimpan.')
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
