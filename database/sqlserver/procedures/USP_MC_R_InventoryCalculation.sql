-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026-01-12
-- Description:	Laporan perhitungan persediaan dengan metode average
-- =============================================

-- USP_MC_R_InventoryCalculation '202601'

CREATE PROCEDURE USP_MC_R_InventoryCalculation
	@Period			VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC [dbo].[USP_MC_InventoryCalculation] 1,@Period,'it_febry'

    -- Insert statements for procedure here
	SELECT [IDX_T_InventoryCalculation]
      ,S.[IDX_M_Company]
	  ,MC.CompanyID
	  ,MC.CompanyName
      ,S.[IDX_M_Valas]
      ,[CalculationPeriod]
	  --------------------------------------------------
	  ,C.CurrencyID, C.CurrencyName,
		MV.ValasSKU, MV.ValasName, MVC.ValasChangeName, MVC.ValasChangeNumber
		--------------------------------------------------
      ,[OpeningQty]
      ,[OpeningValue]
      ,[InQty]
      ,[InValue]
      ,[OutQty]
      ,[OutValue]
      ,[ClosingQty]
      ,[AverageValue]
      ,[COGSValue]
      ,[InventoryValue]
	FROM MC_T_InventoryCalculation S
	LEFT JOIN GN_M_Company MC ON MC.IDX_M_Company = S.IDX_M_Company
	LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = S.IDX_M_Valas
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	WHERE CalculationPeriod = @Period
	ORDER BY C.CurrencyID, S.IDX_M_Valas

END
