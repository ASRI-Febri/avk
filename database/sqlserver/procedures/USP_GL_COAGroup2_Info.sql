
-- =============================================
-- Author		:	ANGGI
-- Create date	:	9 JANUARI 2019
-- Description  :	Get Detail Information for Master Coa Group 2 based on ID
-- =============================================

-- EXEC USP_GL_M_COAGroup2_Info 1

CREATE PROCEDURE [dbo].[USP_GL_COAGroup2_Info]
	-- Add the parameters for the stored procedure here
	@IDX_M_COAGroup2 BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	 IDX_M_COAGroup2
			,CG2.IDX_M_COAGroup1
			,CG1.COAGroup1Name1
			,COAGroup2ID
			,COAGroup2Name1
			,COAGroup2Name2
			,CG2.UCreate
			,CG2.DCreate
			,CG2.UModified
			,CG2.DModified
			,MU.Name AS UserName
			,CG2.UCreate AS CreateByID
			,CG2.DCreate AS CreateByDate
			,MU.Name AS CreateByName
			,CG2.UModified AS ModifiedByID
			,CG2.DModified AS ModifiedByDate
			,MUM.Name AS ModifiedByName
			,CG2.RecordStatus
	FROM [dbo].[GL_M_COAGroup2] CG2
	LEFT JOIN [dbo].[GL_M_COAGroup1] CG1 ON CG1.IDX_M_COAGroup1 = CG2.IDX_M_COAGroup1
	LEFT JOIN SM_M_User MU ON MU.LoginID = CG2.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = CG2.UModified
	WHERE CG2.IDX_M_COAGroup2 = @IDX_M_COAGroup2
	
END



