SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 17 Apr 2026
-- Description	: Insert / update header nota scan OCR
-- =============================================

/*
	-- Insert baru
	EXEC [dbo].[USP_MC_NotaScan_Save] 0,'J','2026-04-16','A-7800345','Albert BCY Situmorang','','','','','','foto.jpg','C:\...\foto.jpg','','it_febry'

	-- Update existing
	EXEC [dbo].[USP_MC_NotaScan_Save] 1,'B','2026-04-16','A-7800345','Albert BCY Situmorang','1234567890','0812345678','Tabungan pribadi','Kebutuhan bisnis','Catatan','foto.jpg','','','it_febry'
*/

CREATE PROCEDURE [dbo].[USP_MC_NotaScan_Save]
	@IDX_T_MC_NotaScan	BIGINT,
	@TipeTransaksi		CHAR(1),		-- J = Jual, B = Beli
	@TanggalNota		DATE,
	@NoNota				VARCHAR(100),
	@NamaKonsumen		VARCHAR(200),
	@NoKTP				VARCHAR(50),
	@NoTelp				VARCHAR(50),
	@SumberDana			VARCHAR(200),
	@TujuanTransaksi	VARCHAR(200),
	@Keterangan			VARCHAR(500),
	@FileName			VARCHAR(255),
	@FilePath			VARCHAR(1000),
	@OCRRawText			NVARCHAR(MAX),
	@UserID				VARCHAR(50)
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
		IF RTRIM(ISNULL(@TipeTransaksi,'')) NOT IN ('J','B')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tipe transaksi tidak valid! Gunakan J (Jual) atau B (Beli).')
		END

		IF @TanggalNota IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal nota belum diisi!')
		END

		-- Cek duplikasi NoNota (jika diisi)
		IF RTRIM(ISNULL(@NoNota,'')) <> ''
		BEGIN
			IF EXISTS (
				SELECT 1 FROM MC_T_NotaScan
				WHERE RTRIM(ISNULL(NoNota,'')) = RTRIM(@NoNota)
					AND IDX_T_MC_NotaScan <> @IDX_T_MC_NotaScan
					AND RecordStatus = 'A'
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'No kwitansi ' + RTRIM(@NoNota) + ' sudah pernah disimpan!')
			END
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			IF @IDX_T_MC_NotaScan = 0
			BEGIN
				-- INSERT
				INSERT INTO [dbo].[MC_T_NotaScan]
					([TipeTransaksi]
					,[TanggalNota]
					,[NoNota]
					,[NamaKonsumen]
					,[NoKTP]
					,[NoTelp]
					,[SumberDana]
					,[TujuanTransaksi]
					,[Keterangan]
					,[FileName]
					,[FilePath]
					,[OCRRawText]
					,[Status]
					,[RecordStatus]
					,[UCreate]
					,[DCreate])
				VALUES
					(@TipeTransaksi
					,@TanggalNota
					,@NoNota
					,@NamaKonsumen
					,@NoKTP
					,@NoTelp
					,@SumberDana
					,@TujuanTransaksi
					,@Keterangan
					,@FileName
					,@FilePath
					,@OCRRawText
					,'D'
					,'A'
					,@UserID
					,GETDATE())

				SET @IDX_T_MC_NotaScan = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				-- UPDATE
				UPDATE [dbo].[MC_T_NotaScan] SET
					 [TipeTransaksi]	= @TipeTransaksi
					,[TanggalNota]		= @TanggalNota
					,[NoNota]			= @NoNota
					,[NamaKonsumen]		= @NamaKonsumen
					,[NoKTP]			= @NoKTP
					,[NoTelp]			= @NoTelp
					,[SumberDana]		= @SumberDana
					,[TujuanTransaksi]	= @TujuanTransaksi
					,[Keterangan]		= @Keterangan
					,[FileName]			= CASE WHEN RTRIM(ISNULL(@FileName,'')) <> '' THEN @FileName ELSE FileName END
					,[FilePath]			= CASE WHEN RTRIM(ISNULL(@FilePath,'')) <> '' THEN @FilePath ELSE FilePath END
					,[OCRRawText]		= CASE WHEN RTRIM(ISNULL(@OCRRawText,'')) <> '' THEN @OCRRawText ELSE OCRRawText END
					,[UModified]		= @UserID
					,[DModified]		= GETDATE()
				WHERE IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan
			END

			INSERT INTO @TableLog VALUES ('success', @IDX_T_MC_NotaScan, 'Data berhasil disimpan.')
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
