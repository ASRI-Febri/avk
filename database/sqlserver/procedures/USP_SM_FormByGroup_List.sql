-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 Januari 2019
-- Description:	List group user mapping with form id
-- =============================================

-- EXEC [dbo].[USP_SM_FormByGroup_List] 2 

CREATE PROCEDURE [dbo].[USP_SM_FormByGroup_List] 
	@IDX_M_Group		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @_IDX_M_User	AS INT

	--SELECT @_IDX_M_User = IDX_M_User FROM SM_M_User WHERE RTRIM(LoginID) = RTRIM(@UserID)

    -- Insert statements for procedure here
	SELECT ISNULL(b.IDX_M_Group,0) AS IDX_M_Group, a.IDX_M_Form, ISNULL(c.GroupID,RTRIM('')) AS UserGroupID, 
		ISNULL(c.GroupName,'') AS UserGroupDesc, a.FormID, 
		a.ApplicationID, a.FormName  
	FROM SM_M_Form a 
	LEFT JOIN (SELECT *
		FROM SM_M_GroupForm
		WHERE IDX_M_Group = @IDX_M_Group) b ON a.IDX_M_Form = b.IDX_M_Form 
	LEFT JOIN SM_M_Group c ON b.IDX_M_Group = c.IDX_M_Group 				
	ORDER BY a.ApplicationID, a.FormID

END

