SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Simpan satu baris kurs BI hasil upload file Kurs Transaksi.
--				Kurs tengah dihitung di sini: (Kurs Jual + Kurs Beli) / 2.
-- =============================================

-- EXEC USP_MC_BIMiddleRate_Save '2026-03-31','USD',1,16850.50,16682.90,'Kurs Transaksi 31-Mar-2026.xlsx','admin'

CREATE PROCEDURE [dbo].[USP_MC_BIMiddleRate_Save]
	@RateDate			DATE,
	@CurrencyID			VARCHAR(3),
	@RateUnit			INT,
	@SellRate			DECIMAL(18,4),
	@BuyRate			DECIMAL(18,4),
	@FileName			VARCHAR(256),
	@UserID				VARCHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO MC_T_BIMiddleRate (
		RateDate, CurrencyID, RateUnit, SellRate, BuyRate, MiddleRate,
		[FileName], UCreate, DCreate, RecordStatus
	)
	VALUES (
		@RateDate, RTRIM(@CurrencyID), @RateUnit, @SellRate, @BuyRate,
		(@SellRate + @BuyRate) / 2,
		@FileName, @UserID, SYSDATETIME(), 'A'
	)

	SELECT 'success' AS Result
END
GO
