-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 27 Mar 2023
-- Description:	Show all branch based on index user (IDX_M_User)
-- =============================================

-- USP_SM_UserBranch_List 51

CREATE PROCEDURE [dbo].[USP_SM_UserBranch_List]
	@IDX_M_User		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT U.IDX_M_User, UG.IDX_M_UserBranch, UG.IDX_M_Branch, G.BranchID, G.BranchName, G.BranchRemark, 
		UG.RecordStatus, StatusDesc = CASE UG.RecordStatus WHEN 'A' THEN 'Active' ELSE 'In-Active' END
	FROM SM_M_User U
	INNER JOIN SM_M_UserBranch UG ON UG.IDX_M_User = U.IDX_M_User
	INNER JOIN GN_M_Branch G ON G.IDX_M_Branch  = UG.IDX_M_Branch
	WHERE U.IDX_M_User = @IDX_M_User
END
