-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Check Access For User ID and Form ID
-- =============================================

/*	
	DECLARE @Output INT
	EXEC [USP_SM_CheckUserForm] '1406069','MS-COMP-003', @Output OUT
	
	PRINT @Output
	PRINT CONVERT(CHAR(1),@Output)
*/

CREATE PROCEDURE [dbo].[USP_SM_CheckUserForm]
	-- Add the parameters for the stored procedure here
	@UserID		VARCHAR(50),
	@FormID		VARCHAR(50),	
	@Output		INT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--DECLARE @_IDX_M_User	BIGINT

	--SELECT @_IDX_M_User = IDX_M_User FROM SM_M_User WHERE RTRIM(LoginID) = RTRIM(@UserID)
	
	IF EXISTS(	SELECT @UserID, MF.FormID
				FROM SM_M_GroupForm MUGF
					LEFT JOIN SM_M_Group MUG ON MUGF.IDX_M_Group = MUG.IDX_M_Group
					LEFT JOIN SM_M_UserGroup MU ON MUGF.IDX_M_Group = MU.IDX_M_Group 
					LEFT JOIN SM_M_User U ON U.IDX_M_User = MU.IDX_M_User 
					INNER JOIN SM_M_Form MF ON MUGF.IDX_M_Form = MF.IDX_M_Form
				WHERE RTRIM(U.LoginID) = RTRIM(@UserID) AND RTRIM(ISNULL(MF.FormID,'')) = RTRIM(@FormID))
	BEGIN		
		SET @Output = 1
	END
	ELSE
	BEGIN		
		SET @Output = 0
	END
	
END

