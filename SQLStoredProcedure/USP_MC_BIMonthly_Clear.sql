SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Hapus data Laporan Bulanan BI satu periode sebelum disimpan ulang.
-- =============================================

-- EXEC USP_MC_BIMonthly_Clear '202603'

CREATE PROCEDURE [dbo].[USP_MC_BIMonthly_Clear]
	@ReportPeriod		VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM MC_T_BIMonthly WHERE ReportPeriod = @ReportPeriod

	SELECT 'success' AS Result
END
GO
