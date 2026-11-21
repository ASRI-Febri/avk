
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 10 Jun 2026
-- Description	: Upsert satu baris Kurs Transaksi Bank Indonesia (per tanggal + mata uang).
--				  Dipanggil oleh App\Services\BIKursService saat sinkronisasi harian.
-- =============================================

/*
	EXEC [dbo].[USP_MC_KursBI_Save] '2026-06-10','USD',1,18067.53,18249.27,'SYSTEM'
	EXEC [dbo].[USP_MC_KursBI_Save] '2026-06-10','JPY',100,12345.67,12469.13,'SYSTEM'
*/

CREATE PROCEDURE [dbo].[USP_MC_KursBI_Save]
	@TanggalKurs	DATE,
	@CurrencyID		VARCHAR(10),
	@Nilai			DECIMAL(18,4),
	@KursBeli		DECIMAL(18,4),
	@KursJual		DECIMAL(18,4),
	@UserID			VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @TableLog TABLE (
			Result	VARCHAR(20),
			ID		BIGINT,
			LogDesc	VARCHAR(500)
		)

		SET @CurrencyID = UPPER(RTRIM(LTRIM(ISNULL(@CurrencyID,''))))

		IF @TanggalKurs IS NULL OR @CurrencyID = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal kurs / mata uang tidak valid!')
			SELECT * FROM @TableLog
			RETURN
		END

		IF EXISTS (
			SELECT 1 FROM MC_T_KursBI
			WHERE TanggalKurs = @TanggalKurs AND CurrencyID = @CurrencyID
		)
		BEGIN
			UPDATE MC_T_KursBI SET
				 Nilai			= @Nilai
				,KursBeli		= @KursBeli
				,KursJual		= @KursJual
				,RecordStatus	= 'A'
				,UModified		= @UserID
				,DModified		= GETDATE()
			WHERE TanggalKurs = @TanggalKurs AND CurrencyID = @CurrencyID
		END
		ELSE
		BEGIN
			INSERT INTO MC_T_KursBI
				(TanggalKurs, CurrencyID, Nilai, KursBeli, KursJual, RecordStatus, UCreate, DCreate)
			VALUES
				(@TanggalKurs, @CurrencyID, @Nilai, @KursBeli, @KursJual, 'A', @UserID, GETDATE())
		END

		INSERT INTO @TableLog VALUES ('success', 1, 'Kurs ' + @CurrencyID + ' tersimpan.')
		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH

		SELECT 'error' AS Result, 0 AS ID,
			CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE() AS LogDesc

	END CATCH;

END
