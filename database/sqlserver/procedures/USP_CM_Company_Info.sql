-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	18 November 2016
-- Description	:	Get Detail Information for Master Company
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add CreateByID, CreateByDate, CreateByName, ModifiedByID, ModifiedByDate, ModifiedByName Columns for LOG Tab
-- =============================================

-- EXEC USP_CM_Company_Info 1

CREATE PROCEDURE [dbo].[USP_CM_Company_Info]	
	@IDX_M_Company		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT GC.*, MU.Name AS UserName
		,GC.UCreate AS CreateByID
		,GC.DCreate AS CreateByDate
		,MU.Name AS CreateByName

		,GC.UModified AS ModifiedByID
		,GC.DModified AS ModifiedByDate
		,MUM.Name AS ModifiedByName
	FROM GN_M_Company GC
	LEFT JOIN SM_M_User MU ON MU.LoginID = GC.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = GC.UModified
	WHERE GC.IDX_M_Company = @IDX_M_Company 
	
END


