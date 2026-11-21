
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- USP_SM_ApplicationByUser_List ''

CREATE PROCEDURE [dbo].[USP_SM_ApplicationByUser_List] 
	@UserID			VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MA.IDX_M_Application, MA.ApplicationID, MA.ApplicationName, MA.ApplicationLabel, MA.ApplicationURL, 
		MA.IconClass1, MA.IconClass2, MA.IconClass2, MA.IconClass3
	FROM SM_M_Application MA
	ORDER BY ApplicationName

END
