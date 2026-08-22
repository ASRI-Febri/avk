SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 22 Aug 2026
-- Description	: Perbarui Rate Beli/Jual satu mata uang di MC_M_Currency dan
--				  simpan nilai LAMA-nya ke MC_T_CurrencyRateHistory.
--				  Dipakai layar Update Kurs (mc-currency-rate) yang mengirim
--				  seluruh mata uang sekaligus, satu baris satu pemanggilan.
--				  Baris yang nilainya tidak berubah tidak ditulis ulang dan
--				  tidak menambah riwayat (Result = 'nochange').
-- =============================================

/*
	EXEC [dbo].[USP_MC_CurrencyRate_Save] 1, 17960, 18010, 'MANUAL', 'it_febry'

	DECLARE @R VARCHAR(20)
	EXEC [dbo].[USP_MC_CurrencyRate_Save] 1, 17960, 18010, 'IMPORT-BCA', 'it_febry', 1, @R OUTPUT
*/

IF OBJECT_ID('[dbo].[USP_MC_CurrencyRate_Save]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_CurrencyRate_Save]
GO

CREATE PROCEDURE [dbo].[USP_MC_CurrencyRate_Save]
	@IDX_M_Currency	INT,
	@BuyRate		DECIMAL(18,4),
	@SellRate		DECIMAL(18,4),
	@ChangeSource	VARCHAR(32) = 'MANUAL',
	@UserID			VARCHAR(50) = '',
	@Silent			BIT = 0,				-- 1 = tanpa result set, status lewat @ResultOut
	@ResultOut		VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @CurrencyID		VARCHAR(3)
		DECLARE @OldBuyRate		DECIMAL(18,4)
		DECLARE @OldSellRate	DECIMAL(18,4)

		SELECT
			 @CurrencyID	= RTRIM(ISNULL(CurrencyID,''))
			,@OldBuyRate	= ISNULL(BuyRate,0)
			,@OldSellRate	= ISNULL(SellRate,0)
		FROM MC_M_Currency WITH(NOLOCK)
		WHERE IDX_M_Currency = @IDX_M_Currency
			AND ISNULL(Recordstatus,'A') = 'A'

		-- Semua cabang mengembalikan susunan kolom yang sama, supaya hasilnya
		-- bisa ditampung dengan INSERT INTO ... EXEC oleh SP pemanggil.
		IF @CurrencyID IS NULL
		BEGIN
			SET @ResultOut = 'notfound'
			IF @Silent = 1 RETURN

			SELECT 'notfound' AS Result, @IDX_M_Currency AS ID, '' AS CurrencyID,
				CONVERT(DECIMAL(18,4),0) AS OldBuyRate, CONVERT(DECIMAL(18,4),0) AS OldSellRate,
				CONVERT(DECIMAL(18,4),0) AS NewBuyRate, CONVERT(DECIMAL(18,4),0) AS NewSellRate,
				CONVERT(VARCHAR(1000),'Mata uang tidak ditemukan atau sudah tidak aktif.') AS LogDesc
			RETURN
		END

		IF ISNULL(@BuyRate,0) < 0 OR ISNULL(@SellRate,0) < 0
		BEGIN
			SET @ResultOut = 'error'
			IF @Silent = 1 RETURN

			SELECT 'error' AS Result, @IDX_M_Currency AS ID, @CurrencyID AS CurrencyID,
				@OldBuyRate AS OldBuyRate, @OldSellRate AS OldSellRate,
				@OldBuyRate AS NewBuyRate, @OldSellRate AS NewSellRate,
				CONVERT(VARCHAR(1000),'Rate tidak boleh negatif.') AS LogDesc
			RETURN
		END

		-- Rate yang sama persis tidak perlu ditulis: riwayat hanya berisi
		-- perubahan yang benar-benar terjadi, supaya mudah dibaca.
		IF @OldBuyRate = @BuyRate AND @OldSellRate = @SellRate
		BEGIN
			SET @ResultOut = 'nochange'
			IF @Silent = 1 RETURN

			SELECT 'nochange' AS Result, @IDX_M_Currency AS ID, @CurrencyID AS CurrencyID,
				@OldBuyRate AS OldBuyRate, @OldSellRate AS OldSellRate,
				@BuyRate AS NewBuyRate, @SellRate AS NewSellRate,
				CONVERT(VARCHAR(1000),'Rate tidak berubah.') AS LogDesc
			RETURN
		END

		BEGIN TRANSACTION

			-- Nilai lama disimpan lebih dulu, baru master diperbarui, keduanya
			-- dalam satu transaksi supaya riwayat tidak pernah kehilangan baris.
			INSERT INTO MC_T_CurrencyRateHistory
				(IDX_M_Currency, CurrencyID, BuyRate, SellRate,
				 NewBuyRate, NewSellRate, ChangeDate, ChangeSource, Remarks,
				 UCreate, DCreate, RecordStatus)
			VALUES
				(@IDX_M_Currency, @CurrencyID, @OldBuyRate, @OldSellRate,
				 @BuyRate, @SellRate, GETDATE(), ISNULL(NULLIF(RTRIM(@ChangeSource),''),'MANUAL'), '',
				 @UserID, GETDATE(), 'A')

			UPDATE MC_M_Currency SET
				 BuyRate	= @BuyRate
				,SellRate	= @SellRate
				,UModified	= @UserID
				,DModified	= GETDATE()
			WHERE IDX_M_Currency = @IDX_M_Currency

		COMMIT TRANSACTION

		SET @ResultOut = 'success'
		IF @Silent = 1 RETURN

		SELECT
			 'success'		AS Result
			,@IDX_M_Currency AS ID
			,@CurrencyID	AS CurrencyID
			,@OldBuyRate	AS OldBuyRate
			,@OldSellRate	AS OldSellRate
			,@BuyRate		AS NewBuyRate
			,@SellRate		AS NewSellRate
			,CONVERT(VARCHAR(1000),'') AS LogDesc

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION

		SET @ResultOut = 'error'
		IF @Silent = 1 RETURN

		SELECT 'error' AS Result, @IDX_M_Currency AS ID, '' AS CurrencyID,
			CONVERT(DECIMAL(18,4),0) AS OldBuyRate, CONVERT(DECIMAL(18,4),0) AS OldSellRate,
			CONVERT(DECIMAL(18,4),0) AS NewBuyRate, CONVERT(DECIMAL(18,4),0) AS NewSellRate,
			CONVERT(VARCHAR(1000), CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE()) AS LogDesc

	END CATCH;

END
GO
