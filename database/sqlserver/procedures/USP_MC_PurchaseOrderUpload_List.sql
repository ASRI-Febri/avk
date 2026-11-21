

/*	
		EXEC [dbo].[USP_MC_PurchaseOrderUpload_List] 2
*/
CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrderUpload_List]
	@IDX_T_PurchaseOrder			BIGINT = 0
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		FPD.IDX_T_PurchaseOrderUpload AS IDX_T_PurchaseOrderUpload,
		FPD.IDX_T_PurchaseOrder AS IDX_T_PurchaseOrder,
		FPD.FileName,
		FPD.FilePath,
		FPD.FileDescription,
		FPD.UploadCategory,		
		PO.PONumber AS PONumber
	FROM MC_T_PurchaseOrderUpload FPD
	LEFT JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_T_PurchaseOrder	
	WHERE FPD.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder
	ORDER BY FPD.UploadCategory

END
