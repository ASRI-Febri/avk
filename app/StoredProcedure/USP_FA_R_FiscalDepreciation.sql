SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Daftar penyusutan fiskal per tahun pajak - format mengikuti
			  Lampiran Khusus 1A SPT Tahunan PPh Badan:
			  jenis/kelompok harta, bulan & tahun perolehan, harga perolehan,
			  nilai sisa buku fiskal awal tahun, metode penyusutan
			  (komersial & fiskal), penyusutan fiskal tahun berjalan.
			  Dasar penyusutan fiskal = harga perolehan penuh (tanpa residu).

/*
	EXEC [dbo].[USP_FA_R_FiscalDepreciation] 1, '2026'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_R_FiscalDepreciation]
	@IDX_M_Company		INT,
	@TaxYear			VARCHAR(4)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		A.IDX_M_Asset,
		A.AssetCode,
		A.AssetName,
		CategoryName = RTRIM(ISNULL(AC.CategoryName,'-')),
		A.FiscalGroup,
		FiscalGroupDesc = CASE A.FiscalGroup
							WHEN '1' THEN 'Kelompok 1 (4 th)'
							WHEN '2' THEN 'Kelompok 2 (8 th)'
							WHEN '3' THEN 'Kelompok 3 (16 th)'
							WHEN '4' THEN 'Kelompok 4 (20 th)'
							WHEN 'BP' THEN 'Bangunan Permanen (20 th)'
							WHEN 'BN' THEN 'Bangunan Non-Permanen (10 th)'
							ELSE '-' END,
		AcquisitionMonthYear = RIGHT('0' + CONVERT(VARCHAR, MONTH(A.AcquisitionDate)), 2)
			+ '/' + CONVERT(VARCHAR, YEAR(A.AcquisitionDate)),
		AcquisitionCost = ISNULL(A.AcquisitionCost,0),
		DeprMethodDesc = CASE A.DeprMethod WHEN 'SL' THEN 'Garis Lurus'
							WHEN 'DB' THEN 'Saldo Menurun' ELSE '-' END,
		FiscalMethodDesc = CASE ISNULL(A.FiscalDeprMethod,'SL') WHEN 'SL' THEN 'Garis Lurus'
							WHEN 'DB' THEN 'Saldo Menurun' ELSE '-' END,
		-- Akumulasi fiskal sebelum tahun pajak -> nilai sisa buku fiskal awal tahun
		FiscalAccumBefore = ISNULL(FB.FiscalAccum,0),
		FiscalBookValueBegin = ISNULL(A.AcquisitionCost,0) - ISNULL(FB.FiscalAccum,0),
		-- Penyusutan fiskal tahun berjalan
		FiscalDeprCurrentYear = ISNULL(FY.FiscalDepr,0),
		-- Nilai sisa buku fiskal akhir tahun
		FiscalBookValueEnd = ISNULL(A.AcquisitionCost,0) - ISNULL(FB.FiscalAccum,0) - ISNULL(FY.FiscalDepr,0)
	FROM FA_M_Asset A WITH(NOLOCK)
		LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
		LEFT JOIN (
			SELECT DD.IDX_M_Asset, FiscalAccum = SUM(ISNULL(DD.FiscalDeprAmount,0))
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
				INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
			WHERE D.DeprStatus = 'P' AND D.RecordStatus = 'A' AND DD.RecordStatus = 'A'
				AND LEFT(D.DeprPeriod, 4) < @TaxYear
			GROUP BY DD.IDX_M_Asset
		) FB ON A.IDX_M_Asset = FB.IDX_M_Asset
		LEFT JOIN (
			SELECT DD.IDX_M_Asset, FiscalDepr = SUM(ISNULL(DD.FiscalDeprAmount,0))
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
				INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
			WHERE D.DeprStatus = 'P' AND D.RecordStatus = 'A' AND DD.RecordStatus = 'A'
				AND LEFT(D.DeprPeriod, 4) = @TaxYear
			GROUP BY DD.IDX_M_Asset
		) FY ON A.IDX_M_Asset = FY.IDX_M_Asset
	WHERE A.RecordStatus = 'A'
		AND A.IDX_M_Company = @IDX_M_Company
		AND RTRIM(ISNULL(A.FiscalGroup,'')) <> ''
		AND YEAR(A.AcquisitionDate) <= CONVERT(INT, @TaxYear)
	ORDER BY A.FiscalGroup, A.AcquisitionDate, A.AssetCode

END
GO
