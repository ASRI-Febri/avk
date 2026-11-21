-- =========================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Delete Financial Payment Detail
-- Mod			: 2020-07-16 by Anton --> Added validation for delete detail allocation first before delete detail item FP
-- =========================================================================================================================

/*		
	EXEC [dbo].[USP_CM_FinancialPaymentDetail_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPaymentDetail_Delete] 	
	@IDX_T_FinancialPaymentDetail		BIGINT
	
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
		
		DECLARE @IDX_T_FinancialPaymentHeader AS BIGINT

			SET @IDX_T_FinancialPaymentHeader = (
				SELECT IDX_T_FinancialPaymentHeader FROM CM_T_FinancialPaymentDetail WITH(NOLOCK) WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail
				)

		IF EXISTS(
		SELECT	1 
		FROM CM_T_PaymentAllocation PA WITH(NOLOCK)
		WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Please delete detail allocation first!')
			END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			DELETE [dbo].[CM_T_FinancialPaymentDetail] 
			WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail		
			
			INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Dihapus')
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



