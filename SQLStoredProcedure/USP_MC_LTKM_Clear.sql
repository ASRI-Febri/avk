SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Hapus data LTKM satu periode sebelum disimpan ulang dari Proses LTKM.
-- =============================================

-- EXEC USP_MC_LTKM_Clear '202607'

CREATE PROCEDURE [dbo].[USP_MC_LTKM_Clear]
	@LTKMPeriod			VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM MC_T_LTKM WHERE LTKMPeriod = @LTKMPeriod

	SELECT 'success' AS Result
END
GO
