-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- USP_SM_FormByUser_List ''

CREATE PROCEDURE [dbo].[USP_SM_FormByUser_List]
	@UserID			VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	SELECT MA.IDX_M_Application, MA.ApplicationID, MA.ApplicationName, MA.ApplicationLabel, MA.ApplicationURL, 
		MA.IconClass1, MA.IconClass2, MA.IconClass2, MA.IconClass3, 
		MF.IDX_M_Form, MF.FormID, MF.FormName, MF.FormURL
	FROM SM_M_Form MF  
		LEFT JOIN SM_M_Application MA ON MA.IDX_M_Application = MF.IDX_M_Application
		LEFT JOIN SM_M_Module MM ON MM.IDX_M_Application = MF.IDX_M_Application
	ORDER BY ApplicationName, MM.ModuleName, MF.FormName
END
