-- ===================================================================================================================================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Delete detail purchase order
-- ===================================================================================================================================================

/*		
	EXEC [dbo].[USP_MC_PurchaseOrderDetail_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrderDetail_Delete] 	
	@IDX_T_PurchaseOrderDetail		BIGINT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY		
		
		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/		

		DECLARE @IDX_T_PurchaseOrderHeader AS BIGINT

		SET @IDX_T_PurchaseOrderHeader = (
			SELECT IDX_T_PurchaseOrder FROM MC_T_PurchaseOrderDetail WITH(NOLOCK) 
			WHERE IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail
		)

		IF EXISTS(	SELECT IDX_T_PurchaseOrder 
					FROM MC_T_PurchaseOrder 
					WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrderHeader AND POStatus <> 'D')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrderHeader, 'Data sudah divalidasi, tidak bisa dihapus!')
		END

		-- ===========================================================
		-- IF NO ERRORS
		-- ===========================================================

		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			DELETE [dbo].[MC_T_PurchaseOrderDetail] 
			WHERE IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail		

			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseOrderHeader, 'Data Sudah Dihapus')
		END

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH       

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog
			
		-- Test XACT_STATE for 1 or -1.
		-- XACT_STATE = 0 means there is no transaction and
		-- a commit or rollback operation would generate an error.

		-- Test whether the transaction is uncommittable.
		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. ' +	'Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		-- Test whether the transaction is active and valid.
		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. ' + 'Committing transaction.'
			COMMIT TRANSACTION;   
		END;

	END CATCH;	


END



