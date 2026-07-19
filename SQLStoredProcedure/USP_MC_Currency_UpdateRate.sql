SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 10 Jun 2026
-- Description	: Perbarui Rate Beli/Jual satu mata uang di MC_M_Currency.
--				  Dipakai oleh tool import kurs Bank Panin (paste tabel kurs).
--				  Hanya menyentuh kolom rate, hanya untuk mata uang aktif yang
--				  sudah terdaftar; mata uang tak dikenal diabaikan (Affected = 0).
-- =============================================

/*
	EXEC [dbo].[USP_MC_Currency_UpdateRate] 'USD',17960,18010,'it_febry'
*/

CREATE PROCEDURE [dbo].[USP_MC_Currency_UpdateRate]
	@CurrencyID	VARCHAR(10),
	@BuyRate	DECIMAL(18,4),
	@SellRate	DECIMAL(18,4),
	@UserID		VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Affected INT = 0
		SET @CurrencyID = UPPER(LTRIM(RTRIM(ISNULL(@CurrencyID,''))))

		IF @CurrencyID <> '' AND @BuyRate > 0 AND @SellRate > 0
		BEGIN
			UPDATE MC_M_Currency SET
				 BuyRate	= @BuyRate
				,SellRate	= @SellRate
				,UModified	= @UserID
				,DModified	= GETDATE()
			WHERE UPPER(LTRIM(RTRIM(CurrencyID))) = @CurrencyID
				AND ISNULL(Recordstatus,'A') = 'A'

			SET @Affected = @@ROWCOUNT
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
