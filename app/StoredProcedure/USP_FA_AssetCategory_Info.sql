SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Get single kategori aset tetap by IDX
-- =============================================

-- EXEC [dbo].[USP_FA_AssetCategory_Info] 1

CREATE PROCEDURE [dbo].[USP_FA_AssetCategory_Info]
	@IDX_M_AssetCategory	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		AC.IDX_M_AssetCategory,
		AC.IDX_M_Company,
		AC.CategoryCode,
		AC.CategoryName,
		AC.IDX_M_COA_Asset,
		AC.IDX_M_COA_AccumDepr,
		AC.IDX_M_COA_DeprExpense,
		AC.IDX_M_COA_GainDisposal,
		AC.IDX_M_COA_LossDisposal,
		AC.DefaultUsefulLifeMonth,
		AC.DefaultDeprMethod,
		AC.FiscalGroup,
		AC.RecordStatus,
		AC.UCreate,
		AC.DCreate,
		AC.UModified,
		AC.DModified
	FROM FA_M_AssetCategory AC WITH(NOLOCK)
	WHERE AC.IDX_M_AssetCategory = @IDX_M_AssetCategory

END
GO
