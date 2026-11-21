-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 27 Mar 2023
-- Description:	Show all group user based on index user (IDX_M_User)
-- =============================================

-- USP_SM_UserGroup_List 51

CREATE PROCEDURE [dbo].[USP_SM_UserGroup_List]
	@IDX_M_User		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT U.IDX_M_User, UG.IDX_M_UserGroup, UG.IDX_M_Group, G.GroupID, G.GroupName, G.Notes, 
		UG.RecordStatus, StatusDesc = CASE UG.RecordStatus WHEN 'A' THEN 'Active' ELSE 'In-Active' END
	FROM SM_M_User U
	INNER JOIN SM_M_UserGroup UG ON UG.IDX_M_User = U.IDX_M_User
	INNER JOIN SM_M_Group G ON G.IDX_M_Group  = UG.IDX_M_Group
	WHERE U.IDX_M_User = @IDX_M_User
END
