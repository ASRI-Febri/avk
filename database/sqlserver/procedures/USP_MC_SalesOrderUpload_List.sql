

/*	
		EXEC [dbo].[USP_MC_SalesOrderUpload_List] 2
*/
CREATE PROCEDURE [dbo].[USP_MC_SalesOrderUpload_List]
	@IDX_T_SalesOrder			BIGINT = 0
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FPD.IDX_T_SalesOrderUpload AS IDX_T_SalesOrderUpload,
		FPD.IDX_T_SalesOrder AS IDX_T_SalesOrder,
		FPD.FileName,
		FPD.FilePath,
		FPD.FileDescription,
		FPD.UploadCategory,		
		SO.SONumber
	FROM MC_T_SalesOrderUpload FPD
	LEFT JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_T_SalesOrder	
	WHERE FPD.IDX_T_SalesOrder = @IDX_T_SalesOrder
	ORDER BY FPD.UploadCategory

END
