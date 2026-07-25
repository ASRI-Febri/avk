SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Daftar kurs tengah BI tersimpan untuk satu tanggal.
--				@RateDate = '' mengambil tanggal tersimpan yang terbaru.
-- =============================================

-- EXEC USP_MC_BIMiddleRate_List '2026-03-31'
-- EXEC USP_MC_BIMiddleRate_List ''

CREATE PROCEDURE [dbo].[USP_MC_BIMiddleRate_List]
	@RateDate			VARCHAR(10) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_RateDate DATE

	IF RTRIM(@RateDate) = ''
		SELECT @_RateDate = MAX(RateDate) FROM MC_T_BIMiddleRate WHERE RTRIM(ISNULL(RecordStatus,'')) = 'A'
	ELSE
		SET @_RateDate = CONVERT(DATE, @RateDate)

	SELECT
		R.IDX_T_BIMiddleRate, R.RateDate,
		RTRIM(ISNULL(R.CurrencyID,'')) AS CurrencyID,
		RTRIM(ISNULL(C.CurrencyName,'')) AS CurrencyName,
		ISNULL(R.RateUnit,1) AS RateUnit,
		R.SellRate, R.BuyRate, R.MiddleRate,
		RTRIM(ISNULL(R.[FileName],'')) AS [FileName],
		R.DCreate
	FROM MC_T_BIMiddleRate R
	LEFT JOIN MC_M_Currency C ON RTRIM(ISNULL(C.CurrencyID,'')) = RTRIM(ISNULL(R.CurrencyID,''))
		AND RTRIM(ISNULL(C.Recordstatus,'')) = 'A'
	WHERE R.RateDate = @_RateDate
		AND RTRIM(ISNULL(R.RecordStatus,'')) = 'A'
	ORDER BY R.CurrencyID
END
GO
