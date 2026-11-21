-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Get detail info opening and closing daily
-- =============================================

-- EXEC [USP_MC_OpenCloseDaily_Info] 3

CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDaily_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_OpenCloseDaily	BIGINT
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
		CompanyName = 'Audric Valasindo Kapital'
	FROM MC_T_OpenCloseDaily OC
    LEFT JOIN SM_M_User U ON RTRIM(U.LoginID) = RTRIM(OC.TellerID)
	WHERE OC.IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

END


