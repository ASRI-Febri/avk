
-- =============================================
-- Author		:	ANGGI
-- Create date	:	9 JANUARI 2019
-- Description  :	Get Detail Information for Master Coa Group 1 based on ID
-- =============================================

-- EXEC USP_GL_M_COAGroup1_Info 1

CREATE PROCEDURE [dbo].[USP_GL_COAGroup1_Info]
	-- Add the parameters for the stored procedure here
	@IDX_M_COAGroup1 BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	 IDX_M_COAGroup1
			,CG1.IDX_M_COAType
			,CT.COATypeDesc
			,COAGroup1ID
			,COAGroup1Name1
			,COAGroup1Name2
			,CG1.UCreate
			,CG1.DCreate
			,CG1.UModified
			,CG1.DModified
			,MU.Name AS UserName
			,CG1.UCreate AS CreateByID
			,CG1.DCreate AS CreateByDate
			,MU.Name AS CreateByName
			,CG1.UModified AS ModifiedByID
			,CG1.DModified AS ModifiedByDate
			,MUM.Name AS ModifiedByName
			,CG1.RecordStatus
	FROM [dbo].[GL_M_COAGroup1] CG1
	LEFT JOIN [dbo].[GL_M_COAType] CT ON CT.IDX_M_COAType = CG1.IDX_M_COAType
	LEFT JOIN SM_M_User MU ON MU.LoginID = CG1.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = CG1.UModified
	WHERE CG1.IDX_M_COAGroup1 = @IDX_M_COAGroup1
	
END



