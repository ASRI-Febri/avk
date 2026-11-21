-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	20 November 2016
-- Description	:	Info Master Group User
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add UserName, ModifiedName Columns for LOG Tab
-- =============================================

/*		
	EXEC [dbo].[USP_SM_Group_Info] 1
*/

CREATE PROCEDURE [dbo].[USP_SM_Group_Info] 			
	@IDX_M_Group		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT MG.IDX_M_Group, MG.GroupID, MG.GroupName, MG.Notes, MG.UCreate, MG.DCreate, MG.UModified, MG.DModified, MU.Name AS UserName, 
	MG.UCreate AS CreateByID,
	MG.DCreate AS CreateByDate,
	MU.Name AS CreateByName,
                                    
	MG.UModified AS ModifiedByID,
	MG.DModified AS ModifiedByDate,
	MUM.Name AS ModifiedByName,

	MG.RecordStatus
	FROM SM_M_Group MG
	LEFT JOIN SM_M_User MU ON MU.LoginID = MG.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MG.UModified
	WHERE MG.IDX_M_Group = @IDX_M_Group
	

END


