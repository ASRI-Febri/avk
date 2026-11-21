
-- ==========================================================================================
-- Author		:	Anton
-- Create date	:	2021-10-05
-- Description  :	Get Detail Information for Master Project based on ID
-- ==========================================================================================

-- EXEC USP_GN_Project_Info 1

CREATE PROCEDURE [dbo].[USP_GN_Project_Info]
	-- Add the parameters for the stored procedure here
	@IDX_M_Project BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MP.IDX_M_Project
		  ,MP.ProjectID
		  ,MP.ProjectName
		  ,MP.ProjectDesc
		  ,MP.DCreate
		  ,MP.UCreate
		  ,MP.DModified
		  ,MP.UModified
		  ,MP.RecordStatus
		  ,MU.Name AS UserName
		,MP.UCreate AS CreateByID
		,MP.DCreate AS CreateByDate
		,MU.Name AS CreateByName

		,MP.UModified AS ModifiedByID
		,MP.DModified AS ModifiedByDate
		,MUM.Name AS ModifiedByName
	FROM dbo.GN_M_Project MP WITH(NOLOCK)
	LEFT JOIN SM_M_User MU WITH(NOLOCK) ON MU.LoginID = MP.UCreate
	LEFT JOIN SM_M_User MUM WITH(NOLOCK) ON MUM.LoginID = MP.UModified
	WHERE IDX_M_Project = @IDX_M_Project
	
END



