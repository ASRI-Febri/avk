SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Hapus kurs tengah BI satu tanggal sebelum disimpan ulang dari upload.
-- =============================================

-- EXEC USP_MC_BIMiddleRate_Clear '2026-03-31'

CREATE PROCEDURE [dbo].[USP_MC_BIMiddleRate_Clear]
	@RateDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM MC_T_BIMiddleRate WHERE RateDate = @RateDate

	SELECT 'success' AS Result
END
GO
