-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Delete Financial Payment Detail Allocation 
-- Modified		: 2024-03-25 by Anton --> Reset attribute on FP Detail
-- ==========================================================================================

/*		
	EXEC [dbo].[USP_CM_PaymentAllocation_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_Delete] 	
	@IDX_T_PaymentAllocation		BIGINT
	
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

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			DECLARE @IDX_T_FinancialPaymentHeader AS BIGINT
			SET @IDX_T_FinancialPaymentHeader = (
				SELECT IDX_T_FinancialPaymentHeader FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentDetail = 
				(
					SELECT IDX_T_FinancialPaymentDetail FROM CM_T_PaymentAllocation WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation	
				)
			)

			DECLARE @IDX_T_FinancialPaymentDetail AS BIGINT
			SET @IDX_T_FinancialPaymentDetail = (SELECT IDX_T_FinancialPaymentDetail FROM CM_T_PaymentAllocation WITH(NOLOCK) WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation)

			DELETE [dbo].[CM_T_PaymentAllocation] 
			WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation	
			
			UPDATE CM_T_FinancialPaymentDetail 
				SET IDX_DocumentNo = 0, DocumentNo = ''
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


