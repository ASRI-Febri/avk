
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 10 Jun 2026
-- Description	: Ambil Kurs Transaksi Bank Indonesia untuk tanggal terbaru yang tersedia.
--				  Dipakai sebagai acuan tampilan kurs Money Changer (display_kurs_tv).
--				  MidPerUnit = kurs tengah BI per 1 unit valas (IDR per 1 unit).
-- =============================================

/*
	EXEC [dbo].[USP_MC_KursBI_Latest]
*/

CREATE PROCEDURE [dbo].[USP_MC_KursBI_Latest]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TanggalKurs DATE

	SELECT @TanggalKurs = MAX(TanggalKurs)
	FROM MC_T_KursBI
	WHERE RecordStatus = 'A'

	SELECT
		 CurrencyID
		,TanggalKurs
		,Nilai
		,KursBeli
		,KursJual
		,CASE WHEN ISNULL(Nilai,0) > 0
			THEN CAST(((ISNULL(KursBeli,0) + ISNULL(KursJual,0)) / 2.0) / Nilai AS DECIMAL(18,6))
			ELSE 0 END AS MidPerUnit
	FROM MC_T_KursBI
	WHERE RecordStatus = 'A'
		AND TanggalKurs = @TanggalKurs
	ORDER BY CurrencyID ASC

END
