
-- =============================================
-- Author		:	Anton
-- Create date	:	11 JANUARI 2019
-- Description  :	Get Detail Information for Master CoaGroup 3 based on ID
-- =============================================

-- EXEC USP_GL_M_COAGroup3_Info 1

CREATE PROCEDURE [dbo].[USP_GL_COAGroup3_Info]
	-- Add the parameters for the stored procedure here
	@IDX_M_COAGroup3 BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	 IDX_M_COAGroup3
			,CG3.IDX_M_COAGroup2
			,CG2.COAGroup2Name1
			,COAGroup3ID
			,COAGroup3Name1
			,COAGroup3Name2
			,CG3.UCreate
			,CG3.DCreate
			,CG3.UModified
			,CG3.DModified
			,MU.Name AS UserName
			,CG3.UCreate AS CreateByID
			,CG3.DCreate AS CreateByDate
			,MU.Name AS CreateByName
			,CG3.UModified AS ModifiedByID
			,CG3.DModified AS ModifiedByDate
			,MUM.Name AS ModifiedByName
			,CG3.RecordStatus
	FROM [dbo].[GL_M_COAGroup3] CG3
	LEFT JOIN [dbo].[GL_M_COAGroup2] CG2 ON CG2.IDX_M_COAGroup2 = CG3.IDX_M_COAGroup2
	LEFT JOIN SM_M_User MU ON MU.LoginID = CG3.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = CG3.UModified
	WHERE CG3.IDX_M_COAGroup3 = @IDX_M_COAGroup3
	
END



