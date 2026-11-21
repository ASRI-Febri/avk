-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Get detail info opening and closing daily
-- =============================================

-- EXEC [USP_MC_OpenCloseDailyDetail_Info] 3

CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDailyDetail_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_OpenCloseDailyDetail	    BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT OC.IDX_T_OpenCloseDaily, CONVERT(VARCHAR, OC.TransactionDate, 106) AS TransactionDate, 
        OC.TransactionStatus, StatusDesc = CASE OC.TransactionStatus WHEN 'O' THEN 'Open' ELSE 'Close' END,
        OC.TellerID, OC.RecordStatus,
        U.Name AS TellerName, 
        OCD.IDX_T_OpenCloseDailyDetail,
        OCD.IDX_M_Valas, OCD.OpenQty, OCD.InQty, OCD.OutQty, OCD.CloseQty, OCD.DiffQty, OCD.DetailNotes,
        V.ValasSKU, V.ValasName, V.IDX_M_ValasChange, 
        VC.ValasChangeID, VC.ValasChangeName, VC.ValasChangeNumber,
        CF.CurrencyID, CF.CurrencyName
	FROM MC_T_OpenCloseDailyDetail OCD
    LEFT JOIN MC_T_OpenCloseDaily OC ON OC.IDX_T_OpenCloseDaily = OCD.IDX_T_OpenCloseDaily
    LEFT JOIN SM_M_User U ON RTRIM(U.LoginID) = RTRIM(OC.TellerID)
    LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = OCD.IDX_M_Valas
    LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
    LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = V.IDX_M_Currency
	WHERE OCD.IDX_T_OpenCloseDailyDetail = @IDX_T_OpenCloseDailyDetail

END


