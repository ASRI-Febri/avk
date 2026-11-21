-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 Januari 2019
-- Description:	List group user mapping with user id
-- =============================================

-- EXEC [dbo].[USP_SM_GroupByUser_List] 2 

CREATE PROCEDURE [dbo].[USP_SM_GroupByUser_List] 
	@IDX_M_User		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @_IDX_M_User	AS INT

	--SELECT @_IDX_M_User = IDX_M_User FROM SM_M_User WHERE RTRIM(LoginID) = RTRIM(@UserID)

    -- Insert statements for procedure here
	SELECT MG.IDX_M_Group, MG.GroupID, MG.GroupName, 
		IDX_M_User = ISNULL(UC.IDX_M_User,'0') 		
	FROM SM_M_Group MG			
	LEFT JOIN (SELECT * FROM SM_M_UserGroup WHERE IDX_M_User = @IDX_M_User) UC 
		ON MG.IDX_M_Group = UC.IDX_M_Group
	--WHERE RTRIM(MC.Alias) LIKE '%%' AND RTRIM(MC.Name) LIKE '%%' 
	ORDER BY MG.IDX_M_Group ASC
END

