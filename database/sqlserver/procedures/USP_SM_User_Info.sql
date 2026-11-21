-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	20 November 2016
-- Description	:	Info Master User
-- =============================================

/*		
	EXEC [dbo].[USP_SM_User_Info] 'admin',0
*/

CREATE PROCEDURE [dbo].[USP_SM_User_Info] 		
	@UserID			VARCHAR(50),
	@IDX_M_User		BIGINT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @IDX_M_User = 0
	BEGIN
		SELECT MU.*, MU2.Name AS UserName,
			MU.UCreate AS CreateByID,
			MU.DCreate AS CreateByDate,
			MU2.Name AS CreateByName,
                                    
			MU.UModified AS ModifiedByID,
			MU.DModified AS ModifiedByDate,
			MUM.Name AS ModifiedByName

		FROM SM_M_User MU			
		LEFT JOIN SM_M_User MU2 ON MU.LoginID = MU.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = MU.UModified
		WHERE MU.LoginID = RTRIM(1009095)
	END
	ELSE
	BEGIN
		SELECT MU.*, MU2.Name AS UserName,
			MU.UCreate AS CreateByID,
			MU.DCreate AS CreateByDate,
			MU2.Name AS CreateByName,
                                    
			MU.UModified AS ModifiedByID,
			MU.DModified AS ModifiedByDate,
			MUM.Name AS ModifiedByName

		FROM SM_M_User MU			
		LEFT JOIN SM_M_User MU2 ON MU2.LoginID = MU.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = MU.UModified
		WHERE MU.IDX_M_User = @IDX_M_User
	END

END




