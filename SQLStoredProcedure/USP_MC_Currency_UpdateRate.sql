SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 10 Jun 2026
-- Description	: Perbarui Rate Beli/Jual satu mata uang di MC_M_Currency.
--				  Dipakai oleh tool import kurs Bank Panin / BCA (paste tabel kurs).
--				  Hanya menyentuh kolom rate, hanya untuk mata uang aktif yang
--				  sudah terdaftar; mata uang tak dikenal diabaikan (Affected = 0).
-- Update		: 22 Aug 2026 - nilai lama ikut dicatat ke MC_T_CurrencyRateHistory
--				  lewat USP_MC_CurrencyRate_Save, supaya riwayat kurs lengkap
--				  baik yang diubah manual maupun hasil import.
-- =============================================

/*
	EXEC [dbo].[USP_MC_Currency_UpdateRate] 'USD',17960,18010,'it_febry'
	EXEC [dbo].[USP_MC_Currency_UpdateRate] 'USD',17960,18010,'it_febry','IMPORT-BCA'
*/

IF OBJECT_ID('[dbo].[USP_MC_Currency_UpdateRate]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_Currency_UpdateRate]
GO

CREATE PROCEDURE [dbo].[USP_MC_Currency_UpdateRate]
	@CurrencyID		VARCHAR(10),
	@BuyRate		DECIMAL(18,4),
	@SellRate		DECIMAL(18,4),
	@UserID			VARCHAR(50),
	@ChangeSource	VARCHAR(32) = 'IMPORT'
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Affected INT = 0
		DECLARE @IDX_M_Currency INT = 0
		SET @CurrencyID = UPPER(LTRIM(RTRIM(ISNULL(@CurrencyID,''))))

		IF @CurrencyID <> '' AND @BuyRate > 0 AND @SellRate > 0
		BEGIN
			SELECT TOP 1 @IDX_M_Currency = IDX_M_Currency
			FROM MC_M_Currency WITH(NOLOCK)
			WHERE UPPER(LTRIM(RTRIM(CurrencyID))) = @CurrencyID
				AND ISNULL(Recordstatus,'A') = 'A'
			ORDER BY IDX_M_Currency
		END

		IF ISNULL(@IDX_M_Currency,0) > 0
		BEGIN
			-- Penulisan master + riwayat dipusatkan di satu SP supaya nilai lama
			-- tidak pernah hilang, dari sumber perubahan mana pun. Mode @Silent
			-- dipakai agar hasil SP ini tetap satu result set seperti sebelumnya.
			DECLARE @Hasil VARCHAR(20) = ''

			EXEC [dbo].[USP_MC_CurrencyRate_Save]
				 @IDX_M_Currency = @IDX_M_Currency
				,@BuyRate		 = @BuyRate
				,@SellRate		 = @SellRate
				,@ChangeSource	 = @ChangeSource
				,@UserID		 = @UserID
				,@Silent		 = 1
				,@ResultOut		 = @Hasil OUTPUT

			-- Rate yang sama dengan yang tersimpan tetap dihitung berhasil:
			-- bagi operator import, "tidak berubah" bukan kegagalan.
			IF @Hasil IN ('success','nochange') SET @Affected = 1
		END

		SELECT
			 CASE WHEN @Affected > 0 THEN 'success' ELSE 'notfound' END AS Result
			,@Affected AS Affected
			,@CurrencyID AS CurrencyID

	END TRY

	BEGIN CATCH

		SELECT 'error' AS Result, 0 AS Affected, @CurrencyID AS CurrencyID,
			CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE() AS LogDesc

	END CATCH;

END
GO
