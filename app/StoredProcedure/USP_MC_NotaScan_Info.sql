SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 17 Apr 2026
-- Description	: Get single nota scan record by IDX
-- =============================================

-- EXEC [dbo].[USP_MC_NotaScan_Info] 1

CREATE PROCEDURE [dbo].[USP_MC_NotaScan_Info]
	@IDX_T_MC_NotaScan	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	-- Hitung total transaksi dari detail
	DECLARE @_TotalNilai	DECIMAL(18,2) = 0
	DECLARE @_JumlahDetail	INT = 0

	SELECT
		@_TotalNilai   = ISNULL(SUM(TotalNilai), 0),
		@_JumlahDetail = COUNT(*)
	FROM MC_T_NotaScanDetail
	WHERE IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan
		AND RecordStatus = 'A'

	-- ==================================================================================================
	-- OUTPUT DATA
	-- ==================================================================================================
	SELECT
		NS.IDX_T_MC_NotaScan,
		NS.TipeTransaksi,
		TipeTransaksiDesc = CASE NS.TipeTransaksi WHEN 'J' THEN 'Jual (SO)' WHEN 'B' THEN 'Beli (PO)' ELSE '-' END,
		NS.TanggalNota,
		NS.NoNota,
		NS.NamaKonsumen,
		NS.NoKTP,
		NS.NoTelp,
		NS.SumberDana,
		NS.TujuanTransaksi,
		NS.Keterangan,
		NS.FileName,
		NS.FilePath,
		NS.OCRRawText,
		NS.Status,
		StatusDesc = CASE NS.Status WHEN 'D' THEN 'Draft' ELSE 'Aktif' END,
		NS.RecordStatus,
		NS.UCreate,
		NS.DCreate,
		NS.UModified,
		NS.DModified,
		TotalNilaiTransaksi = @_TotalNilai,
		JumlahDetail        = @_JumlahDetail
	FROM MC_T_NotaScan NS
	WHERE NS.IDX_T_MC_NotaScan = @IDX_T_MC_NotaScan

END
GO
