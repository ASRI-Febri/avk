-- ===================================================================================================================================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Delete Purchase Invoice Detail
--				Anton 2020-05-27 --> Added validation that transaction can't be modified if Checklist Tax is checked
-- ===================================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_PurchaseInvoiceDetail_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceDetail_Delete] 	
	@IDX_T_PurchaseInvoiceDetail		BIGINT
	
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

		DECLARE @IDX_T_PurchaseInvoiceHeader AS BIGINT

			SET @IDX_T_PurchaseInvoiceHeader = (
				SELECT IDX_T_PurchaseInvoiceHeader FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail
				)

		IF (SELECT PIH.IsTaxChecked 
			FROM CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) 
				INNER JOIN CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
			WHERE PID.IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail) = '1'
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Checlist Tax Status Already Checked!')
		END
		

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			
			DELETE [dbo].[CM_T_PurchaseInvoiceTax] WHERE IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail		

			DELETE [dbo].[CM_T_PurchaseInvoiceDetail] 
			WHERE IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail		

			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseInvoiceHeader, 'Data Sudah Dihapus')
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



