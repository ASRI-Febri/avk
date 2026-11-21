
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Info valas
-- =============================================

-- EXEC USP_MC_Valas_Info 1

CREATE PROCEDURE [dbo].[USP_MC_Valas_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_Valas	BIGINT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
		
    -- Insert statements for procedure here
	SELECT [IDX_M_Valas],MV.[IDX_M_Currency],MV.[IDX_M_ValasChange],[EffectiveDate],
		MV.ValasSKU, MV.ValasName, 
	  C.CurrencyID, C.CurrencyName, MVC.ValasChangeID, MVC.ValasChangeName,
      [BuyValue],[SellValue],
      MV.[UCreate],MV.[DCreate],MV.[UModified],MV.[DModified],MV.[RecordStatus], 
      StatusDesc = CASE MV.RecordStatus WHEN 'A' THEN 'Active' ELSE 'Inactive' END
	FROM MC_M_Valas MV
	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
	LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
	WHERE IDX_M_Valas =  @IDX_M_Valas

END


