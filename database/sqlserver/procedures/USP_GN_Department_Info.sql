
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get Department information
-- =============================================

-- EXEC [USP_GN_Department_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Department_Info]	
	@IDX_M_Department			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.IDX_M_Department, C.DepartmentID, C.DepartmentName, C.RecordStatus		
	FROM GN_M_Department C	
	WHERE IDX_M_Department = @IDX_M_Department
	
END



