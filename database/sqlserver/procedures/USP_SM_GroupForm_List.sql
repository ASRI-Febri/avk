-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 27 Mar 2023
-- Description:	Show all form id based on IDX_M_Group
-- =============================================

-- USP_SM_GroupForm_List 51

CREATE PROCEDURE [dbo].[USP_SM_GroupForm_List]
	@IDX_M_Group		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT GF.IDX_M_GroupForm,  
		G.IDX_M_Group, G.GroupID, G.GroupName, G.Notes, 
		F.FormID, F.FormName, F.FormURL,
		GF.RecordStatus, StatusDesc = CASE GF.RecordStatus WHEN 'A' THEN 'Active' ELSE 'In-Active' END
	FROM SM_M_Group G
	INNER JOIN SM_M_GroupForm GF ON GF.IDX_M_Group = G.IDX_M_Group
	INNER JOIN SM_M_Form F ON F.IDX_M_Form  = GF.IDX_M_Form
	WHERE G.IDX_M_Group = @IDX_M_Group
END
