-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	20 November 2016
-- Description	:	Info Master Form 
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add UserName, ModifiedName Columns for LOG Tab
-- =============================================

/*		
	EXEC [dbo].[USP_SM_Form_Info] 1
*/

CREATE PROCEDURE [dbo].[USP_SM_Form_Info] 			
	@IDX_M_Form		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT MF.IDX_M_Form, MF.IDX_M_Application, MF.IDX_M_Module, 
		MF.ApplicationID, MF.FormID, MF.FormName, MF.FormURL, MF.FormDescription, 
		MF.UCreate, MF.DCreate, MF.UModified, MF.DModified, MU.Name AS UserName,
		MF.UCreate AS CreateByID,
		MF.DCreate AS CreateByDate,
		MU.Name AS CreateByName,                                    
		MF.UModified AS ModifiedByID,
		MF.DModified AS ModifiedByDate,
		MUM.Name AS ModifiedByName,
		MF.RecordStatus, MF.IconClass1, MF.IconClass2, MF.IconClass3, MF.ShowInSidebar 
	FROM SM_M_Form MF
	LEFT JOIN SM_M_User MU ON MU.LoginID = MF.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MF.UModified
	WHERE MF.IDX_M_Form = @IDX_M_Form
	

END


