SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Laporan Daftar Aset Tetap per tanggal cut-off.
			  Akumulasi penyusutan = saldo awal migrasi + penyusutan posted
			  dengan periode <= bulan cut-off. Nilai buku = perolehan - akumulasi.

/*
	EXEC [dbo].[USP_FA_R_AssetList] 1, 0, '2026-07-31', 0
	EXEC [dbo].[USP_FA_R_AssetList] 1, 1, '2026-07-31', 2
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_R_AssetList]
	@IDX_M_Company			INT,
	@IDX_M_Branch			INT,			-- 0 = semua cabang
	@CutOffDate				DATE,
	@IDX_M_AssetCategory	INT				-- 0 = semua kategori
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_CutOffPeriod VARCHAR(6) = LEFT(CONVERT(VARCHAR, @CutOffDate, 112), 6)

	SELECT
		A.IDX_M_Asset,
		A.AssetCode,
		A.AssetName,
		CategoryName = RTRIM(ISNULL(AC.CategoryName,'-')),
		BranchName = RTRIM(ISNULL(B.BranchName,'-')),
		DepartmentName = RTRIM(ISNULL(DP.DepartmentName,'-')),
		A.AcquisitionDate,
		A.UsageStartDate,
		A.UsefulLifeMonth,
		A.DeprMethod,
		DeprMethodDesc = CASE A.DeprMethod WHEN 'SL' THEN 'Garis Lurus'
							WHEN 'DB' THEN 'Saldo Menurun' ELSE '-' END,
		AcquisitionCost = ISNULL(A.AcquisitionCost,0),
		ResidualValue = ISNULL(A.ResidualValue,0),
		AccumDepr = ISNULL(A.OpeningAccumDepr,0) + ISNULL(DP2.TotalDepr,0),
		BookValue = ISNULL(A.AcquisitionCost,0) - (ISNULL(A.OpeningAccumDepr,0) + ISNULL(DP2.TotalDepr,0)),
		A.AssetStatus,
		AssetStatusDesc = CASE A.AssetStatus
							WHEN 'D' THEN 'Draft'
							WHEN 'A' THEN 'Aktif'
							WHEN 'S' THEN 'Dijual'
							WHEN 'W' THEN 'Hapus Buku'
							WHEN 'H' THEN 'Hibah'
							ELSE '-' END,
		A.DisposalDate
	FROM FA_M_Asset A WITH(NOLOCK)
		LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
		LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON A.IDX_M_Branch = B.IDX_M_Branch
		LEFT JOIN GN_M_Department DP WITH(NOLOCK) ON A.IDX_M_Department = DP.IDX_M_Department
		LEFT JOIN (
			SELECT DD.IDX_M_Asset, TotalDepr = SUM(ISNULL(DD.DeprAmount,0))
			FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
				INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
			WHERE D.DeprStatus = 'P'
				AND D.RecordStatus = 'A'
				AND DD.RecordStatus = 'A'
				AND D.DeprPeriod <= @_CutOffPeriod
			GROUP BY DD.IDX_M_Asset
		) DP2 ON A.IDX_M_Asset = DP2.IDX_M_Asset
	WHERE A.RecordStatus = 'A'
		AND A.IDX_M_Company = @IDX_M_Company
		AND (@IDX_M_Branch = 0 OR A.IDX_M_Branch = @IDX_M_Branch)
		AND (@IDX_M_AssetCategory = 0 OR A.IDX_M_AssetCategory = @IDX_M_AssetCategory)
		AND A.AcquisitionDate <= @CutOffDate
	ORDER BY AC.CategoryName, A.AssetCode

END
GO
