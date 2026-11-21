-- ======================================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Update Table Sales Invoice Tax
-- Modified		: 2024-01-15 by Anton --> Adjust Tax Calculation (FLOOR)
--				  Anton 2024-07-18	  --> Added validation cannot added PPN from "Add Additional Tax" button. PPN must be selected directly in detail item
-- ======================================================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_SalesInvoiceTax_Update]
					2,
					1,					
					5183,
					1,
					0,
					'MAKITA 3709 profil',
					2,					
					800000,
					0,
					2,
					0,
					'',
					'admin',
					'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceTax_Update] 	
	@IDX_T_SalesInvoiceTax		BIGINT,
	@IDX_T_SalesInvoiceHeader	BIGINT,
	@IDX_T_SalesInvoiceDetail	BIGINT,	
	@IDX_M_Tax					BIGINT,
	@TaxAmount					DECIMAL(22,2),
	@TaxCOA						BIGINT,	
	-----------------------------------------------
	@UserID						VARCHAR(50),
	@RecordStatus				CHAR(1)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY		
		
		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/	
		
		DECLARE @_TaxFlag BIT
		SELECT @_TaxFlag = IsWithHoldingTax FROM GL_M_Tax WITH(NOLOCK) WHERE IDX_M_Tax = @IDX_M_Tax

		IF @_TaxFlag = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Please Select TAX PPN item Directly From Detail Item!')
		END

		/** Calculate Tax **/
		DECLARE @_TaxPercentage AS DECIMAL(18,2)
		DECLARE @_TaxID AS VARCHAR(20)
		DECLARE @_TaxDesc AS VARCHAR(50)
		DECLARE @_TaxRate AS DECIMAL(18,2)
			
		/** Get data from master tax **/
		SELECT @_TaxPercentage = TaxRate, @_TaxID = TaxID, @_TaxDesc = TaxName, @_TaxRate = TaxRate, @TaxCOA = COAIn 
		FROM GL_M_Tax WITH(NOLOCK)
		WHERE IDX_M_Tax = @IDX_M_Tax

		IF @TaxCOA = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Invalid Chart of Account')
		END

		IF (SELECT AllowEdit FROM CM_T_SalesInvoiceTax WITH(NOLOCK) WHERE IDX_T_SalesInvoiceTax = @IDX_T_SalesInvoiceTax) = 'N'
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Please Update From Detail Invoice Item!')
		END

		/** Get data from detail Sales invoice **/
		DECLARE @_UntaxedAmount AS DECIMAL(18,2)
		DECLARE @_DiscountAmount AS DECIMAL(18,2)
		DECLARE @_Quantity AS DECIMAL(18,2)

		SELECT @_UntaxedAmount = UntaxedAmount, @_DiscountAmount = DiscountAmount, @_Quantity = Quantity
		FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
		WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail

		--SET @TaxAmount = ((@_UntaxedAmount - @_DiscountAmount) * @_Quantity) * (@_TaxPercentage / 100)
		SET @TaxAmount = (@_UntaxedAmount - @_DiscountAmount) * (@_TaxPercentage / 100)

		IF @TaxAmount > 0
		BEGIN
			SET @TaxAmount = FLOOR(ISNULL(@TaxAmount,0))
		END
		ELSE
		BEGIN
			SET @TaxAmount = FLOOR(ISNULL(ABS(@TaxAmount),0))*-1
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			
			/** Update data **/
			UPDATE [dbo].[CM_T_SalesInvoiceTax] SET
				 [IDX_T_SalesInvoiceHeader] = @IDX_T_SalesInvoiceHeader
				,[IDX_T_SalesInvoiceDetail] = @IDX_T_SalesInvoiceDetail
				,[IDX_M_Tax] = @IDX_M_Tax
				,[TaxID] = @_TaxID
				,[TaxDesc] = @_TaxDesc
				,[TaxRate] = @_TaxRate
				,[TaxAmount] = @TaxAmount				
				,[TaxCOA] = @TaxCOA
				,[UModified] = @UserID
				,[DModified] = GETDATE()
				,[RecordStatus] = @RecordStatus
			WHERE IDX_T_SalesInvoiceTax = @IDX_T_SalesInvoiceTax	

			INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesInvoiceHeader, 'Data Sudah Disimpan')
							
		END

		COMMIT TRANSACTION;

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


