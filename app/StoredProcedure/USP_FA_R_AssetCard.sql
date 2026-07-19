SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Kartu Aset - riwayat kronologis satu aset tetap:
			  perolehan, saldo awal migrasi, penyusutan per periode,
			  mutasi cabang/departemen, dan pelepasan.

/*
	EXEC [dbo].[USP_FA_R_AssetCard] 1
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_R_AssetCard]
	@IDX_M_Asset	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_Cost			DECIMAL(18,2)
	DECLARE @_Opening		DECIMAL(18,2)

	SELECT @_Cost = ISNULL(AcquisitionCost,0), @_Opening = ISNULL(OpeningAccumDepr,0)
	FROM FA_M_Asset WITH(NOLOCK)
	WHERE IDX_M_Asset = @IDX_M_Asset

	SELECT EventDate, EventSeq, EventType, EventDesc, Amount, AccumAfter, BookValueAfter
	FROM (
		-- 1. Perolehan
		SELECT
			EventDate = A.AcquisitionDate,
			EventSeq = 1,
			EventType = 'Perolehan',
			EventDesc = 'Perolehan aset' + CASE WHEN RTRIM(ISNULL(A.ReferenceNo,'')) <> ''
							THEN ' (Ref: ' + RTRIM(A.ReferenceNo) + ')' ELSE '' END,
			Amount = ISNULL(A.AcquisitionCost,0),
			AccumAfter = CONVERT(DECIMAL(18,2), NULL),
			BookValueAfter = ISNULL(A.AcquisitionCost,0)
		FROM FA_M_Asset A WITH(NOLOCK)
		WHERE A.IDX_M_Asset = @IDX_M_Asset

		UNION ALL

		-- 2. Saldo awal akumulasi penyusutan (migrasi aset lama)
		SELECT
			A.UsageStartDate, 2, 'Saldo Awal',
			'Akumulasi penyusutan saldo awal (migrasi)',
			ISNULL(A.OpeningAccumDepr,0),
			ISNULL(A.OpeningAccumDepr,0),
			ISNULL(A.AcquisitionCost,0) - ISNULL(A.OpeningAccumDepr,0)
		FROM FA_M_Asset A WITH(NOLOCK)
		WHERE A.IDX_M_Asset = @IDX_M_Asset AND ISNULL(A.OpeningAccumDepr,0) <> 0

		UNION ALL

		-- 3. Penyusutan per periode (posted)
		SELECT
			EOMONTH(CONVERT(DATE, D.DeprPeriod + '01', 112)), 3, 'Penyusutan',
			'Penyusutan periode ' + D.DeprPeriod,
			ISNULL(DD.DeprAmount,0),
			ISNULL(DD.AccumDeprAfter,0),
			ISNULL(DD.BookValueAfter,0)
		FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
			INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
		WHERE DD.IDX_M_Asset = @IDX_M_Asset
			AND D.DeprStatus = 'P' AND D.RecordStatus = 'A' AND DD.RecordStatus = 'A'

		UNION ALL

		-- 4. Mutasi
		SELECT
			M.MutationDate, 4, 'Mutasi',
			'Mutasi dari ' + RTRIM(ISNULL(BF.BranchName,'-')) + ' ke ' + RTRIM(ISNULL(BT.BranchName,'-'))
				+ CASE WHEN RTRIM(ISNULL(M.MutationNotes,'')) <> '' THEN ' - ' + RTRIM(M.MutationNotes) ELSE '' END,
			CONVERT(DECIMAL(18,2), NULL),
			CONVERT(DECIMAL(18,2), NULL),
			CONVERT(DECIMAL(18,2), NULL)
		FROM FA_T_AssetMutation M WITH(NOLOCK)
			LEFT JOIN GN_M_Branch BF WITH(NOLOCK) ON M.IDX_M_Branch_From = BF.IDX_M_Branch
			LEFT JOIN GN_M_Branch BT WITH(NOLOCK) ON M.IDX_M_Branch_To = BT.IDX_M_Branch
		WHERE M.IDX_M_Asset = @IDX_M_Asset AND M.RecordStatus = 'A'

		UNION ALL

		-- 5. Pelepasan
		SELECT
			DS.DisposalDate, 5,
			CASE DS.DisposalType WHEN 'S' THEN 'Dijual' WHEN 'W' THEN 'Hapus Buku' ELSE 'Hibah' END,
			'Pelepasan aset'
				+ CASE WHEN DS.DisposalType = 'S' THEN ' - harga jual ' + CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(DS.DisposalProceed,0)), 1) ELSE '' END
				+ CASE WHEN ISNULL(DS.GainLossAmount,0) > 0 THEN ' (laba ' + CONVERT(VARCHAR, CONVERT(MONEY, DS.GainLossAmount), 1) + ')'
					WHEN ISNULL(DS.GainLossAmount,0) < 0 THEN ' (rugi ' + CONVERT(VARCHAR, CONVERT(MONEY, ABS(DS.GainLossAmount)), 1) + ')'
					ELSE '' END,
			ISNULL(DS.DisposalProceed,0),
			ISNULL(DS.AccumDeprAtDisposal,0),
			CONVERT(DECIMAL(18,2), 0)
		FROM FA_T_AssetDisposal DS WITH(NOLOCK)
		WHERE DS.IDX_M_Asset = @IDX_M_Asset AND DS.RecordStatus = 'A'
	) X
	ORDER BY EventDate, EventSeq

END
GO
