
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Info Financial Account
-- =============================================

-- EXEC USP_CM_FinancialAccount_Info 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialAccount_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_FinancialAccount	BIGINT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
		
    -- Insert statements for procedure here
	SELECT MFA.*, MU.Name AS UserName, MCU.*, MBA.*,
		MC.CompanyAlias AS CompanyID, MC.CompanyName AS CompanyDesc, MB.BranchID, MB.BranchName, 
		COA.COAID, COA.COADesc, 
		StatusDesc = CASE MFA.RecordStatus WHEN 'I' THEN 'Inactive' WHEN 'A' THEN 'Active' END
		,MFA.UCreate AS CreateByID
		,MFA.DCreate AS CreateByDate
		,MU.Name AS CreateByName
		,MFA.UModified AS ModifiedByID
		,MFA.DModified AS ModifiedByDate
		,MUM.Name AS ModifiedByName
	FROM CM_M_FinancialAccount MFA
		LEFT JOIN GN_M_Company MC ON MFA.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN GN_M_Branch MB ON MFA.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Currency MCU ON MFA.IDX_M_Currency = MCU.IDX_M_Currency
		LEFT JOIN GN_M_Bank MBA ON MFA.IDX_M_Bank = MBA.IDX_M_Bank
		LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = MFA.IDX_M_COA
		LEFT JOIN SM_M_User MU ON MU.LoginID = MFA.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = MFA.UModified
	WHERE IDX_M_FinancialAccount =  @IDX_M_FinancialAccount

END


