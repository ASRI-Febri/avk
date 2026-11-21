
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get Branch information
-- =============================================

-- EXEC [USP_GN_Branch_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Bank_Info]	
	@IDX_M_Bank			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.IDX_M_Bank, C.BankCode, C.BankName, C.BankAlias, C.RecordStatus		
	FROM GN_M_Bank C	
	WHERE IDX_M_Bank = @IDX_M_Bank
	
END



