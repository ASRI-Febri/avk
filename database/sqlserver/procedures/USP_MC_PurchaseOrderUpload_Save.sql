-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 Mar 2026
-- Description:	Save upload file for purchase order
-- =============================================

-- USP_MC_PurchaseOrderUpload_Save 32937


CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrderUpload_Save]
	@IDX_T_PurchaseOrder			BIGINT,
	@UploadCategory			VARCHAR(50),
	@FilePath				VARCHAR(500),
	@FileName				VARCHAR(500),
	@FileDescription		VARCHAR(500),
	@UserID					VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbo].[MC_T_PurchaseOrderUpload]
           ([IDX_T_PurchaseOrder]
           ,[UploadCategory]
           ,[FilePath]
           ,[FileName]
           ,[FileDescription]
           ,[DCreate]
           ,[UCreate]           
           ,[RecordStatus])
     VALUES (
			 @IDX_T_PurchaseOrder
			,@UploadCategory
			,@FilePath
			,@FileName
			,@FileDescription
			,GETDATE()
			,@UserID 
			,'A'
	 )

	 SELECT IDX_T_PurchaseOrderUpload, U.IDX_T_PurchaseOrder, UploadCategory, FilePath, [FileName], FileDescription, C.PONumber
	 FROM MC_T_PurchaseOrderUpload U
	 LEFT JOIN MC_T_PurchaseOrder C ON C.IDX_T_PurchaseOrder = U.IDX_T_PurchaseOrder
	 WHERE U.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder
	 ORDER BY IDX_T_PurchaseOrderUpload

END

