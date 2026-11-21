

/*	
		EXEC [dbo].[USP_MC_OpenCloseDailyDetail_List] 2
*/
CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDailyDetail_List]
	@IDX_T_OpenCLoseDaily			BIGINT = 0

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT OC.IDX_T_OpenCloseDaily, OC.TransactionDate, OC.TransactionStatus, OC.TellerID, 
        OCD.IDX_T_OpenCloseDailyDetail,
        OCD.IDX_M_Valas, OCD.OpenQty, OCD.InQty, OCD.OutQty, OCD.CloseQty, OCD.DiffQty, 
        V.IDX_M_Currency, V.ValasSKU, V.ValasName, V.IDX_M_ValasChange, 
        VC.ValasChangeID, VC.ValasChangeName, VC.ValasChangeNumber,
        CF.CurrencyID, CF.CurrencyName, 
        OpenValue = OCD.OpenQty * VC.ValasChangeNumber,
        InValue = OCD.InQty * VC.ValasChangeNumber,
        OutValue = OCD.OutQty * VC.ValasChangeNumber,
        CloseValue = OCD.CloseQty * VC.ValasChangeNumber 
    FROM MC_T_OpenCloseDaily OC
    LEFT JOIN MC_T_OpenCloseDailyDetail OCD ON OCD.IDX_T_OpenCloseDaily = OC.IDX_T_OpenCloseDaily
    LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = OCD.IDX_M_Valas
    LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
    LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = V.IDX_M_Currency
    WHERE OC.IDX_T_OpenCloseDaily = @IDX_T_OpenCLoseDaily
    ORDER BY V.IDX_M_Currency, V.ValasSKU
END
