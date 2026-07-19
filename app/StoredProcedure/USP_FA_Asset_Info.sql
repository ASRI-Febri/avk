SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Get single register aset tetap by IDX
--				  Termasuk akumulasi penyusutan & nilai buku berjalan
-- =============================================

-- EXEC [dbo].[USP_FA_Asset_Info] 1

CREATE PROCEDURE [dbo].[USP_FA_Asset_Info]
	@IDX_M_Asset	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_TotalDepr		DECIMAL(18,2) = 0

	SELECT @_TotalDepr = ISNULL(SUM(ISNULL(DD.DeprAmount,0)),0)
	FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
		INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
	WHERE DD.IDX_M_Asset = @IDX_M_Asset
		AND D.DeprStatus = 'P'
		AND DD.RecordStatus = 'A'

	-- ==================================================================================================
	-- OUTPUT DATA
	-- ==================================================================================================
	SELECT
		A.IDX_M_Asset,
		A.IDX_M_Company,
		A.IDX_M_Branch,
		A.IDX_M_Department,
		A.IDX_M_AssetCategory,
		CategoryName = RTRIM(ISNULL(AC.CategoryName,'')),
		A.AssetCode,
		A.AssetName,
		A.AssetDesc,
		A.AcquisitionDate,
		A.UsageStartDate,
		A.AcquisitionCost,
		A.ResidualValue,
		A.UsefulLifeMonth,
		A.DeprMethod,
		A.FiscalGroup,
		A.FiscalDeprMethod,
		A.IDX_T_PurchaseInvoice,
		A.ReferenceNo,
		A.AssetStatus,
		AssetStatusDesc = CASE A.AssetStatus
							WHEN 'D' THEN 'Draft'
							WHEN 'A' THEN 'Aktif'
							WHEN 'S' THEN 'Dijual'
							WHEN 'W' THEN 'Hapus Buku'
							WHEN 'H' THEN 'Hibah'
							ELSE '-' END,
		A.DisposalDate,
		A.OpeningAccumDepr,
		AccumDepr = ISNULL(A.OpeningAccumDepr,0) + @_TotalDepr,
		BookValue = ISNULL(A.AcquisitionCost,0) - (ISNULL(A.OpeningAccumDepr,0) + @_TotalDepr),
		A.RecordStatus,
		A.UCreate,
		A.DCreate,
		A.UModified,
		A.DModified
	FROM FA_M_Asset A WITH(NOLOCK)
		LEFT JOIN FA_M_AssetCategory AC WITH(NOLOCK) ON A.IDX_M_AssetCategory = AC.IDX_M_AssetCategory
	WHERE A.IDX_M_Asset = @IDX_M_Asset

END
GO
