-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Financial Receive Header by ID
-- =============================================

-- EXEC USP_CM_FinancialReceive_Info 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialReceiveHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT FRH.*, MFA.FinancialAccountID, MFA.FinancialAccountDesc, 
		MC.CompanyID AS CompanyID, MC.CompanyName AS CompanyDesc, MB.BranchID, MB.BranchName, MBP.PartnerID, MBP.PartnerName, MC.Phone AS CompanyPhone,
		MU.Name AS UserName	,FRH.UCreate AS CreateByID, FRH.DCreate AS CreateByDate, MU.Name AS CreateByName, 
		FRH.UModified AS ModifiedByID, FRH.DModified AS ModifiedByDate, MUM.Name AS ModifiedByName, 
		FRH.ApprovedBy AS ApprovedByID, FRH.ApprovalDate AS ApprovedByDate, MUA.Name AS ApprovedByName, 
		FRH.VoidBy AS VoidByID, FRH.VoidDate AS VoidByDate, MUV.Name AS VoidByName, 
		StatusDesc = CASE FRH.ReceiveStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'C' THEN 'Cancel' WHEN 'F' THEN 'Validate' WHEN 'V' THEN 'Void' END			
	FROM CM_T_FinancialReceiveHeader FRH
		LEFT JOIN GN_M_Company MC ON FRH.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN GN_M_Branch MB ON FRH.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Partner MBP ON FRH.IDX_M_Partner = MBP.IDX_M_Partner	
		LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = FRH.IDX_M_FinancialAccount 
		LEFT JOIN SM_M_User MU ON MU.LoginID = FRH.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = FRH.UModified
		LEFT JOIN SM_M_User MUA ON MUA.LoginID = FRH.ApprovedBy
		LEFT JOIN SM_M_User MUV ON MUV.LoginID = FRH.VoidBy
		LEFT JOIN SM_M_User MUVA ON MUVA.LoginID = FRH.ValidateBy
	WHERE FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

END



