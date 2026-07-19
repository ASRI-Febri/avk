SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Rekap penyusutan per periode (YYYYMM) per aset:
			  penyusutan komersial & fiskal, akumulasi dan nilai buku
			  setelah periode tersebut.

/*
	EXEC [dbo].[USP_FA_R_DepreciationSchedule] 1, '202607'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_R_DepreciationSchedule]
	@IDX_M_Company		INT,
	@DeprPeriod			VARCHAR(6)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		A.IDX_M_Asset,
		A.AssetCode,
		A.AssetName,
		CategoryName = RTRIM(ISNULL(AC.CategoryName,'-')),
		BranchName = RTRIM(ISNULL(B.BranchName,'-')),
		A.UsefulLifeMonth,
		A.DeprMethod,
		DeprMethodDesc = CASE A.DeprMethod WHEN 'SL' THEN 'Garis Lurus'
							WHEN 'DB' THEN 'Saldo Menurun' ELSE '-' END,
		AcquisitionCost = ISNULL(A.AcquisitionCost,0),
		DeprAmount = ISNULL(DD.DeprAmount,0),
		FiscalDeprAmount = ISNULL(DD.FiscalDeprAmount,0),
		AccumDeprAfter = ISNULL(DD.AccumDeprAfter,0),
		BookValueAfter = ISNULL(DD.BookValueAfter,0),
		D.DeprPeriod,
		DeprStatusDesc = CASE D.DeprStatus WHEN 'C' THEN 'Calculated'
							WHEN 'P' THEN 'Journal Posted' ELSE '-' END
	FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
		INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
		INNER JOIN FA_M_Asset A WITH(NOLOCK) ON DD.IDX_M_Asset = A.IDX_M_Asset
		LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
		LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON A.IDX_M_Branch = B.IDX_M_Branch
	WHERE D.IDX_M_Company = @IDX_M_Company
		AND D.DeprPeriod = @DeprPeriod
		AND D.RecordStatus = 'A'
		AND DD.RecordStatus = 'A'
	ORDER BY AC.CategoryName, A.AssetCode

END
GO
