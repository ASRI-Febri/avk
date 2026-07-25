SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Data Laporan Bulanan BI tersimpan untuk satu periode
--				(sumber tampilan layar edit dan generate file txt).
-- =============================================

-- EXEC USP_MC_BIMonthly_List '202603'

CREATE PROCEDURE [dbo].[USP_MC_BIMonthly_List]
	@ReportPeriod		VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		M.IDX_T_BIMonthly, M.ReportPeriod,
		RTRIM(ISNULL(M.CurrencyID,'')) AS CurrencyID,
		RTRIM(ISNULL(C.CurrencyName,'')) AS CurrencyName,
		ISNULL(M.ProductType,'1') AS ProductType,
		M.OpeningForeign, M.OpeningIDR,
		M.BuyForeign, M.BuyIDR,
		M.SellForeign, M.SellIDR,
		M.ClosingForeign, M.MiddleRate, M.ClosingIDR,
		M.DCreate, M.UCreate
	FROM MC_T_BIMonthly M
	LEFT JOIN MC_M_Currency C ON RTRIM(ISNULL(C.CurrencyID,'')) = RTRIM(ISNULL(M.CurrencyID,''))
		AND RTRIM(ISNULL(C.Recordstatus,'')) = 'A'
	WHERE M.ReportPeriod = @ReportPeriod
		AND RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	ORDER BY M.CurrencyID
END
GO
