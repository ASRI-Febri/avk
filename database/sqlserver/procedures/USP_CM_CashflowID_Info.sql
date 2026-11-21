
-- =============================================
-- Author		: Anton
-- Create date	: 2021-10-19
-- Description	: Info CashflowID
-- =============================================

-- EXEC USP_CM_CashflowID_Info 2

CREATE PROCEDURE [dbo].[USP_CM_CashflowID_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_CashflowID	BIGINT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
		
    -- Insert statements for procedure here
	SELECT MFA.IDX_M_CashflowID, MFA.IDX_ParentCashflowID AS ParentID
		,MFA.CategoryType
		,MFA.CashflowID
		,MFA.CashflowDesc
		,ParentDesc = CASE MFA.IDX_ParentCashflowID WHEN 0 THEN '-' ELSE (MFA2.CashflowID + ' - ' + MFA2.CashflowDesc) END
		,StatusDesc = CASE MFA.RecordStatus WHEN 'I' THEN 'Inactive' WHEN 'A' THEN 'Active' END
		,MFA.UCreate AS CreateByID
		,MFA.DCreate AS CreateByDate
		,MU.Name AS CreateByName
		,MFA.UModified AS ModifiedByID
		,MFA.DModified AS ModifiedByDate
		,MUM.Name AS ModifiedByName
		,MFA.RecordStatus
	FROM CM_M_CashflowID MFA
		LEFT JOIN CM_M_CashflowID MFA2 ON MFA.IDX_ParentCashflowID = MFA2.IDX_M_CashflowID
		LEFT JOIN SM_M_User MU ON MU.LoginID = MFA.UCreate
		LEFT JOIN SM_M_User MUM ON MUM.LoginID = MFA.UModified
	WHERE MFA.IDX_M_CashflowID =  @IDX_M_CashflowID

END

