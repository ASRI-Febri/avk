SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Simpan satu baris (satu jenis valuta) Laporan Bulanan BI form B0001.
--				Saldo akhir valas = awal + beli - jual (rumus form B0001).
--				Saldo akhir rupiah = saldo akhir x kurs tengah (JPY dibagi 100,
--				karena kuotasi JPY per 100 unit - sama dengan rumus template BI).
-- =============================================

-- EXEC USP_MC_BIMonthly_Save '202603','JPY','1',1000,1000,1000,1000,1000,1000,123.4567,'admin'

CREATE PROCEDURE [dbo].[USP_MC_BIMonthly_Save]
	@ReportPeriod		VARCHAR(6),
	@CurrencyID			VARCHAR(3),
	@ProductType		CHAR(1),
	@OpeningForeign		DECIMAL(18,2),
	@OpeningIDR			DECIMAL(18,2),
	@BuyForeign			DECIMAL(18,2),
	@BuyIDR				DECIMAL(18,2),
	@SellForeign		DECIMAL(18,2),
	@SellIDR			DECIMAL(18,2),
	@MiddleRate			DECIMAL(18,4),
	@UserID				VARCHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ClosingForeign	DECIMAL(18,2) = @OpeningForeign + @BuyForeign - @SellForeign
	DECLARE @ClosingIDR		DECIMAL(18,2)

	IF RTRIM(@CurrencyID) = 'JPY'
		SET @ClosingIDR = (@ClosingForeign * @MiddleRate) / 100
	ELSE
		SET @ClosingIDR = @ClosingForeign * @MiddleRate

	INSERT INTO MC_T_BIMonthly (
		ReportPeriod, CurrencyID, ProductType,
		OpeningForeign, OpeningIDR, BuyForeign, BuyIDR, SellForeign, SellIDR,
		ClosingForeign, MiddleRate, ClosingIDR,
		UCreate, DCreate, RecordStatus
	)
	VALUES (
		@ReportPeriod, RTRIM(@CurrencyID), @ProductType,
		@OpeningForeign, @OpeningIDR, @BuyForeign, @BuyIDR, @SellForeign, @SellIDR,
		@ClosingForeign, @MiddleRate, @ClosingIDR,
		@UserID, SYSDATETIME(), 'A'
	)

	SELECT 'success' AS Result
END
GO
