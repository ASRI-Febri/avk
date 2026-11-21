
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	18 November 2016
-- Description	:	Get Detail Information for Document Type
-- Mod			:	Deva
-- Mod Date		:	27 JANUARI 2019
-- Mod Desc		:	Add UserName, ModifiedName Columns for LOG Tab
-- =============================================

-- EXEC [USP_GN_DocumentType_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_DocumentType_Info]	
	@IDX_GN_M_DocumentType		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MDT.IDX_M_DocumentType,
			MDT.DocumentTypeCategory, 
			MDT.DocumentTypeID, 
			MDT.DocumentTypeDesc, 
			MDT.InFlag, 
			MDT.OutFlag, 
			MDT.ARAccount, 
			ARAccountDesc = CAR.COAID + ' - ' + CAR.COADesc, 
			MDT.APAccount, 
			APAccountDesc = CAP.COAID + ' - ' + CAP.COADesc, 
			MDT.UCreate,
			MDT.DCreate,
			MDT.UModified,
			MDT.DModified,
			MU.Name AS UserName,
			MDT.UCreate AS CreateByID,
			MDT.DCreate AS CreateByDate,
			MU.Name AS CreateByName,
                                    
			MDT.UModified AS ModifiedByID,
			MDT.DModified AS ModifiedByDate,
			MUM.Name AS ModifiedByName,
			MDT.RecordStatus
	FROM GN_M_DocumentType MDT
	LEFT JOIN GL_M_COA CAR ON CAR.IDX_M_COA = ARAccount
	LEFT JOIN GL_M_COA CAP ON CAP.IDX_M_COA = APAccount
	LEFT JOIN SM_M_User MU ON MU.LoginID = MDT.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = MDT.UModified
	WHERE IDX_M_DocumentType = @IDX_GN_M_DocumentType 
	
END



