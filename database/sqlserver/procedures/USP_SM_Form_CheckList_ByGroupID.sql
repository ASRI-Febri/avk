-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 24 Maret 2023
-- Description:	Display all master form and check list by group id
--              If user already have access, show 'Y' otherwise show 'N'
-- =============================================

-- USP_SM_Form_CheckList_ByGroupID 0, 'admin'

CREATE PROCEDURE [dbo].[USP_SM_Form_CheckList_ByGroupID]
	@IDX_M_Application		INT,
	@GroupID				VARCHAR(20)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
    SELECT MF.IDX_M_Form, MA.ApplicationName, MF.FormID, MF.FormName, 
		CheckList = CASE WHEN RTRIM(ISNULL(G.GroupID,'')) <> RTRIM(@GroupID) THEN '' ELSE 'Checked' END, 
		GF.IDX_M_GroupForm, GF.IDX_M_Group, G.GroupID, G.GroupName
	FROM SM_M_Form MF
	LEFT JOIN SM_M_Application MA ON MA.IDX_M_Application = MF.IDX_M_Application	
	LEFT JOIN SM_M_GroupForm GF ON GF.IDX_M_Form = MF.IDX_M_Form
	--LEFT JOIN SM_M_UserGroup UG ON UG.IDX_M_Group = GF.IDX_M_Group
	LEFT JOIN SM_M_Group G ON G.IDX_M_Group = GF.IDX_M_Group
	--LEFT JOIN SM_M_User U ON U.IDX_M_User = UG.IDX_M_User
	--WHERE RTRIM(ISNULL(U.LoginID,'')) = RTRIM(@UserID)
	ORDER BY MA.ApplicationName, MF.FormName
END
