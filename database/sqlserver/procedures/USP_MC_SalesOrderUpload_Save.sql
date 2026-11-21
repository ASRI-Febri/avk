-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 Mar 2026
-- Description:	Save upload file for sales order
-- =============================================

-- USP_MC_SalesOrderUpload_Save 32937


CREATE PROCEDURE [dbo].[USP_MC_SalesOrderUpload_Save]
	@IDX_T_SalesOrder			BIGINT,
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

    INSERT INTO [dbo].[MC_T_SalesOrderUpload]
           ([IDX_T_SalesOrder]
           ,[UploadCategory]
           ,[FilePath]
           ,[FileName]
           ,[FileDescription]
           ,[DCreate]
           ,[UCreate]           
           ,[RecordStatus])
     VALUES (
			 @IDX_T_SalesOrder
			,@UploadCategory
			,@FilePath
			,@FileName
			,@FileDescription
			,GETDATE()
			,@UserID 
			,'A'
	 )

	 SELECT IDX_T_SalesOrderUpload, U.IDX_T_SalesOrder, UploadCategory, FilePath, [FileName], FileDescription, C.SONumber
	 FROM MC_T_SalesOrderUpload U
	 LEFT JOIN MC_T_SalesOrder C ON C.IDX_T_SalesOrder = U.IDX_T_SalesOrder
	 WHERE U.IDX_T_SalesOrder = @IDX_T_SalesOrder
	 ORDER BY IDX_T_SalesOrderUpload

END

