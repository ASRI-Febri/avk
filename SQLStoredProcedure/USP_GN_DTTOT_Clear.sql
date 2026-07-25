SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Kosongkan tabel DTTOT sebelum upload renewal
--				(setiap file DTTOT berisi daftar lengkap terbaru).
-- =============================================

-- EXEC USP_GN_DTTOT_Clear

CREATE PROCEDURE [dbo].[USP_GN_DTTOT_Clear]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM GN_M_DTTOT

	SELECT 'success' AS Result
END
GO
