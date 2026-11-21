
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Get Detail Information for COA based on ID
-- =============================================

-- EXEC USP_GL_COA_Info 2

CREATE PROCEDURE [dbo].[USP_GL_COA_Info]
	-- Add the parameters for the stored procedure here
	@IDX_GL_M_COA BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COA.*, MU.Name AS UserName,
		ParentDesc = (Parent.COAID + ' - ' + Parent.COADesc),
		CFINDesc = (CFIN.CashflowID + ' - ' + CFIN.CashflowDesc),
		CFOUTDesc = (CFOUT.CashflowID + ' - ' + CFOUT.CashflowDesc),
		COAFlagDesc = CASE COA.COAFlag WHEN 'A' THEN 'Account' WHEN 'H' THEN 'Header' END,
		COA.COAGroup1 AS IDX_M_COAGroup1, COA.COAGroup2 AS IDX_M_COAGroup2, COA.COAGroup3 AS IDX_M_COAGroup3, 
		CG.COACategoryID, CG.COACategoryDesc,
		CT.COATypeID, CT.COATypeDesc,
		COA.UCreate AS CreateByID,
		COA.DCreate AS CreateByDate,
		MU.Name AS CreateByName,
		COA.UModified AS ModifiedByID,
		COA.DModified AS ModifiedByDate,
		MUM.Name AS ModifiedByName,
		StatusDesc = CASE COA.RecordStatus WHEN 'A' THEN 'Active' WHEN 'I' THEN 'Inactive' END
	FROM GL_M_COA COA
		LEFT JOIN GL_M_COACategory CG ON COA.IDX_M_COACategory = CG.IDX_M_COACategory
		LEFT JOIN GL_M_COAType CT ON COA.IDX_M_COAType = CT.IDX_M_COAType
		LEFT JOIN GL_M_COA Parent ON COA.ParentID = Parent.IDX_M_COA
		LEFT JOIN CM_M_CashflowID CFIN ON COA.IDX_M_CashflowIn = CFIN.IDX_M_CashflowID
		LEFT JOIN CM_M_CashflowID CFOUT ON COA.IDX_M_CashflowOut = CFOUT.IDX_M_CashflowID
		LEFT JOIN SM_M_User MU ON MU.LoginID = COA.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = COA.UModified
	WHERE COA.IDX_M_COA = @IDX_GL_M_COA 
	
END


