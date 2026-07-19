SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Rekonsiliasi register aset tetap vs saldo GL per kategori
			  per tanggal cut-off (untuk migrasi saldo awal / UAT go-live).

			  Sisi register:
				- RegisterCost  = total harga perolehan aset yang belum dilepas
				  s/d cut-off (aset yang dilepas <= cut-off dikeluarkan, sama
				  seperti perlakuan jurnal disposal di GL)
				- RegisterAccum = saldo awal migrasi + penyusutan posted
				  s/d bulan cut-off (aset belum dilepas)
			  Sisi GL:
				- GLAssetBalance = saldo (D - C) akun aset kategori tsb s/d cut-off
				- GLAccumBalance = saldo (C - D) akun akumulasi s/d cut-off
			  Selisih = Register - GL. Nol berarti register dan GL sinkron.

			  CATATAN: bila satu akun COA dipakai lebih dari satu kategori,
			  bandingkan gabungan kategori yang memakai akun tersebut.

/*
	EXEC [dbo].[USP_FA_R_Reconciliation] 1, '2026-07-31'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_R_Reconciliation]
	@IDX_M_Company		INT,
	@CutOffDate			DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_CutOffPeriod VARCHAR(6) = LEFT(CONVERT(VARCHAR, @CutOffDate, 112), 6)

	;WITH RegisterSide AS (
		SELECT
			A.IDX_M_AssetCategory,
			RegisterCost = SUM(ISNULL(A.AcquisitionCost,0)),
			RegisterAccum = SUM(ISNULL(A.OpeningAccumDepr,0) + ISNULL(PD.TotalDepr,0)),
			AssetCount = COUNT(*)
		FROM FA_M_Asset A WITH(NOLOCK)
			LEFT JOIN (
				SELECT DD.IDX_M_Asset, TotalDepr = SUM(ISNULL(DD.DeprAmount,0))
				FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
					INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
				WHERE D.DeprStatus = 'P' AND D.RecordStatus = 'A' AND DD.RecordStatus = 'A'
					AND D.DeprPeriod <= @_CutOffPeriod
				GROUP BY DD.IDX_M_Asset
			) PD ON A.IDX_M_Asset = PD.IDX_M_Asset
		WHERE A.RecordStatus = 'A'
			AND A.IDX_M_Company = @IDX_M_Company
			AND A.AcquisitionDate <= @CutOffDate
			AND A.AssetStatus <> 'D'
			-- aset yang dilepas s/d cut-off dikeluarkan (sudah keluar dari GL via jurnal disposal)
			AND NOT (A.AssetStatus IN ('S','W','H') AND ISNULL(A.DisposalDate, '9999-12-31') <= @CutOffDate)
		GROUP BY A.IDX_M_AssetCategory
	),
	GLBalance AS (
		SELECT
			JD.IDX_M_COA,
			NetDC = SUM(ISNULL(JD.BDebetAmount,0) - ISNULL(JD.BCreditAmount,0))
		FROM GL_T_JournalHeader JH WITH(NOLOCK)
			INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
		WHERE JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND JH.IDX_M_Company = @IDX_M_Company
			AND CONVERT(DATE, JH.JournalDate) <= @CutOffDate
		GROUP BY JD.IDX_M_COA
	)
	SELECT
		AC.IDX_M_AssetCategory,
		AC.CategoryCode,
		AC.CategoryName,
		AssetCount = ISNULL(RS.AssetCount, 0),
		---------------------------------------------------------------
		COAAsset = RTRIM(ISNULL(CA.COAID,'-')) + ' - ' + RTRIM(ISNULL(CA.COADesc,'')),
		RegisterCost = ISNULL(RS.RegisterCost, 0),
		GLAssetBalance = ISNULL(GA.NetDC, 0),
		DiffAsset = ISNULL(RS.RegisterCost, 0) - ISNULL(GA.NetDC, 0),
		---------------------------------------------------------------
		COAAccum = RTRIM(ISNULL(CD.COAID,'-')) + ' - ' + RTRIM(ISNULL(CD.COADesc,'')),
		RegisterAccum = ISNULL(RS.RegisterAccum, 0),
		GLAccumBalance = ISNULL(GD.NetDC, 0) * -1,	-- akumulasi bersaldo kredit -> tampil positif
		DiffAccum = ISNULL(RS.RegisterAccum, 0) - (ISNULL(GD.NetDC, 0) * -1)
	FROM FA_M_AssetCategory AC WITH(NOLOCK)
		LEFT JOIN RegisterSide RS ON AC.IDX_M_AssetCategory = RS.IDX_M_AssetCategory
		LEFT JOIN GL_M_COA CA WITH(NOLOCK) ON AC.IDX_M_COA_Asset = CA.IDX_M_COA
		LEFT JOIN GL_M_COA CD WITH(NOLOCK) ON AC.IDX_M_COA_AccumDepr = CD.IDX_M_COA
		LEFT JOIN GLBalance GA ON AC.IDX_M_COA_Asset = GA.IDX_M_COA
		LEFT JOIN GLBalance GD ON AC.IDX_M_COA_AccumDepr = GD.IDX_M_COA
	WHERE AC.RecordStatus = 'A'
		AND (ISNULL(RS.AssetCount,0) > 0 OR ISNULL(GA.NetDC,0) <> 0 OR ISNULL(GD.NetDC,0) <> 0)
	ORDER BY AC.CategoryCode

END
GO
