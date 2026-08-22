SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 22 Aug 2026
-- Description	: Riwayat perubahan Rate Beli/Jual dari MC_T_CurrencyRateHistory.
--				  @IDX_M_Currency = 0 berarti seluruh mata uang (dipakai panel
--				  "Perubahan Terakhir" pada layar Update Kurs).
-- =============================================

/*
	EXEC [dbo].[USP_MC_CurrencyRate_History_List] 0, 50
	EXEC [dbo].[USP_MC_CurrencyRate_History_List] 1, 100
*/

IF OBJECT_ID('[dbo].[USP_MC_CurrencyRate_History_List]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_CurrencyRate_History_List]
GO

CREATE PROCEDURE [dbo].[USP_MC_CurrencyRate_History_List]
	@IDX_M_Currency	INT = 0,
	@Row			INT = 50
AS
BEGIN
	SET NOCOUNT ON;

	IF ISNULL(@Row,0) <= 0 SET @Row = 50

	SELECT TOP (@Row)
		 HS.IDX_T_CurrencyRateHistory
		,HS.IDX_M_Currency
		,CurrencyID		= RTRIM(ISNULL(HS.CurrencyID,''))
		,CurrencyName	= RTRIM(ISNULL(CU.CurrencyName,''))
		,OldBuyRate		= ISNULL(HS.BuyRate,0)
		,OldSellRate	= ISNULL(HS.SellRate,0)
		,NewBuyRate		= ISNULL(HS.NewBuyRate,0)
		,NewSellRate	= ISNULL(HS.NewSellRate,0)
		,HS.ChangeDate
		,ChangeSource	= RTRIM(ISNULL(HS.ChangeSource,''))
		,UCreate		= RTRIM(ISNULL(HS.UCreate,''))
	FROM MC_T_CurrencyRateHistory HS WITH(NOLOCK)
		LEFT JOIN MC_M_Currency CU WITH(NOLOCK) ON CU.IDX_M_Currency = HS.IDX_M_Currency
	WHERE ISNULL(HS.RecordStatus,'A') = 'A'
		AND (@IDX_M_Currency = 0 OR HS.IDX_M_Currency = @IDX_M_Currency)
	ORDER BY HS.ChangeDate DESC, HS.IDX_T_CurrencyRateHistory DESC

END
GO
