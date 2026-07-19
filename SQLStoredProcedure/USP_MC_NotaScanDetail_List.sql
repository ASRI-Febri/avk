SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 17 Apr 2026
-- Description	: List detail baris transaksi valas
--                untuk satu nota scan (by header IDX)
-- =============================================

-- EXEC [dbo].[USP_MC_NotaScanDetail_List] 1

CREATE PROCEDURE [dbo].[USP_MC_NotaScanDetail_List]
	@IDX_T_MC_NotaScan	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		NSD.IDX_T_MC_NotaScanDetail,
		NSD.IDX_T_MC_NotaScan,
		NSD.Nomor,
		NSD.KeteranganValas,
		NSD.NilaiValas,
		NSD.NilaiTukar,
		NSD.TotalNilai,
		NSD.CatatanDetail,
		NSD.RecordStatus,
		NSD.UCreate,
		NSD.DCreate
	FROM MC_T_NotaScanDetail NSD
	WHERE NSD.IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan
		AND NSD.RecordStatus = 'A'
	ORDER BY NSD.Nomor ASC

END
GO
