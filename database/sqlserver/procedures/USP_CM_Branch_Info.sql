-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	18 November 2016
-- Description	:	Get Detail Information for Master Branch
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add CreateByID, CreateByDate, CreateByName, ModifiedByID, ModifiedByDate, ModifiedByName Columns for LOG Tab
-- =============================================

-- EXEC USP_CM_Branch_Info 1

CREATE PROCEDURE [dbo].[USP_CM_Branch_Info]	
	@IDX_M_Branch		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MB.*, MU.Name AS UserName
		,MB.UCreate AS CreateByID
		,MB.DCreate AS CreateByDate
		,MU.Name AS CreateByName

		,MB.UModified AS ModifiedByID
		,MB.DModified AS ModifiedByDate
		,MUM.Name AS ModifiedByName
	FROM GN_M_Branch MB
	LEFT JOIN SM_M_User MU ON MU.LoginID = MB.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MB.UModified
	WHERE MB.IDX_M_Branch = @IDX_M_Branch 
	
END


