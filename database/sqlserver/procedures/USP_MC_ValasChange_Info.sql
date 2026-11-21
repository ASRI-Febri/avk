
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Info valas change
-- =============================================

-- EXEC USP_MC_ValasChange_Info 1

CREATE PROCEDURE [dbo].[USP_MC_ValasChange_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_ValasChange	BIGINT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
		
    -- Insert statements for procedure here
	SELECT IDX_M_ValasChange, ValasChangeID, ValasChangeName, ValasChangeNumber, RecordStatus, 
        StatusDesc = CASE RecordStatus WHEN 'A' THEN 'Active' ELSE 'Inactive' END, 
		MFA.UCreate, MFA.DCreate, MFA.UModified, MFA.DModified
	FROM MC_M_ValasChange MFA		
	WHERE IDX_M_ValasChange =  @IDX_M_ValasChange

END


