
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	20 Oktober 2016
-- Description	:	Get detail Business Partner
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add CreateByID, CreateByDate, CreateByName, ModifiedByID, ModifiedByDate, ModifiedByName Columns for LOG Tab
-- =============================================

-- EXEC [USP_CM_Partner_Info] 1

CREATE PROCEDURE [dbo].[USP_CM_Partner_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_Partner	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MBP.*, MU.Name AS UserName,
		ARAccountDesc = AR.COAID + ' - ' + AR.COADesc,
		APAccountDesc = AP.COAID + ' - ' + AP.COADesc,
		MBP.UCreate AS CreateByID,
		MBP.DCreate AS CreateByDate,
		MU.Name AS CreateByName,
                                    
		MBP.UModified AS ModifiedByID,
		MBP.DModified AS ModifiedByDate,
		MUM.Name AS ModifiedByName
	FROM GN_M_Partner MBP
	LEFT JOIN GL_M_COA AR ON MBP.ARAccount = AR.IDX_M_COA
	LEFT JOIN GL_M_COA AP ON MBP.APAccount = AP.IDX_M_COA
	LEFT JOIN SM_M_User MU ON MU.LoginID = MBP.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MBP.UModified
	WHERE MBP.IDX_M_Partner = @IDX_M_Partner

END



