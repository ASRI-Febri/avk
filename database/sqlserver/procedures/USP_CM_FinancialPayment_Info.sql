-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Financial Payment Header by ID
-- =============================================

-- EXEC USP_CM_FinancialPayment_Info 1

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialPaymentHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT FRH.*,  MFA.FinancialAccountID, MFA.FinancialAccountDesc, 
		MC.CompanyAlias AS CompanyID, MC.Companyname AS CompanyDesc, MB.BranchID, MB.BranchName, MBP.PartnerID, MBP.PartnerName, MC.Phone AS CompanyPhone, 
		UC.Name AS UserCreate, UC.DCreate AS DateCreate, UM.Name AS UserModified, UM.DCreate AS DateModified, 
		UC.Name AS UserName	,FRH.UCreate AS CreateByID, FRH.DCreate AS CreateByDate, UC.Name AS CreateByName, 
		FRH.UModified AS ModifiedByID, FRH.DModified AS ModifiedByDate, MUM.Name AS ModifiedByName, 
		FRH.ApprovedBy AS ApprovedByID, FRH.ApprovalDate AS ApprovedByDate, MUA.Name AS ApprovedByName, 
		FRH.VoidBy AS VoidByID, FRH.VoidDate AS VoidByDate, MUV.Name AS VoidByName, 
		FRH.HandoverBy AS HandoverByID, FRH.HandoverDate AS HandoverByDate, MUH.Name AS HandoverByName,
		FRH.ValidateBy AS PostedByID, FRH.ValidationDate AS PostedByDate, MUP.Name AS PostedByName,
		StatusDesc = CASE FRH.PaymentStatus WHEN 'D' THEN 'Draft' WHEN 'A' THEN 'Approved' WHEN 'H' THEN 'Handover' WHEN 'C' THEN 'Cancel' WHEN 'F' THEN 'Validate' WHEN 'V' THEN 'Void' END			
	FROM CM_T_FinancialPaymentHeader FRH
		LEFT JOIN GN_M_Company MC ON FRH.IDX_M_Company = MC.IDX_M_Company
		LEFT JOIN GN_M_Branch MB ON FRH.IDX_M_Branch = MB.IDX_M_Branch
		LEFT JOIN GN_M_Partner MBP ON FRH.IDX_M_Partner = MBP.IDX_M_Partner
		LEFT JOIN SM_M_User UC ON FRH.UCreate = UC.LoginID
		LEFT JOIN SM_M_User UM ON FRH.UModified = UM.LoginID		
		LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = FRH.IDX_M_FinancialAccount 
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = FRH.UModified
		LEFT JOIN SM_M_User MUA ON MUA.LoginID = FRH.ApprovedBy
		LEFT JOIN SM_M_User MUV ON MUV.LoginID = FRH.VoidBy
		LEFT JOIN SM_M_User MUH ON MUH.LoginID = FRH.HandoverBy
		LEFT JOIN SM_M_User MUP ON MUP.LoginID = FRH.ValidateBy
	WHERE FRH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

END


