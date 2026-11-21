-- ====================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Create Table Purchase Invoice Tax
-- Modified		: Anton 2020-05-27 --> Added validation that transaction can't be modified if Checklist Tax is checked
--				  Anton 2024-01-15 --> Adjust Tax Calculation (FLOOR)
--				  Anton 2024-07-18 --> Added validation cannot added PPN from "Add Additional Tax" button. PPN must be selected directly in detail item
-- ====================================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_PurchaseInvoiceTax_Create] 'Pcs','Pieces','admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceTax_Create] 	
	@IDX_T_PurchaseInvoiceHeader		BIGINT,
	@IDX_T_PurchaseInvoiceDetail		BIGINT,		
	@IDX_M_Tax							BIGINT,
	@TaxAmount							DECIMAL(22,2),
	@TaxCOA								BIGINT,
	------------------------------------------------
	@UserID								VARCHAR(100),
	@RecordStatus						CHAR(1)	
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

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'CM-PINV-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		--------------------------------------------------------------------------------------

		DECLARE @_TaxFlag BIT
		SELECT @_TaxFlag = IsWithHoldingTax FROM GL_M_Tax WITH(NOLOCK) WHERE IDX_M_Tax = @IDX_M_Tax

		IF @_TaxFlag = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Please Select TAX PPN item Directly From Detail Item!')
		END

		--IF (SELECT IsTaxChecked FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) = '1'
		--BEGIN 
		--	INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Checlist Tax Status Already Checked!')
		--END
	
		--IF @TaxCOA = 0
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Invalid Chart of Account')
		--END

		/** Calculate Tax **/
		DECLARE @_TaxPercentage AS DECIMAL(18,2)
		DECLARE @_TaxID AS VARCHAR(20)
		DECLARE @_TaxDesc AS VARCHAR(50)
		DECLARE @_TaxRate AS DECIMAL(18,2)
		
		/** Get data from master tax **/
		SELECT @_TaxPercentage = TaxRate, @_TaxID = TaxID, @_TaxDesc = TaxName, @_TaxRate = TaxRate, @TaxCOA = COAOut 
		FROM GL_M_Tax WITH(NOLOCK)
		WHERE IDX_M_Tax = @IDX_M_Tax

		/** Get data from detail purchase invoice **/
		DECLARE @_UntaxedAmount AS DECIMAL(18,2)
		DECLARE @_DiscountAmount AS DECIMAL(18,2)
		DECLARE @_Quantity AS DECIMAL(18,2)

		SELECT @_UntaxedAmount = UntaxedAmount, @_DiscountAmount = DiscountAmount, @_Quantity = Quantity
		FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
		WHERE IDX_T_PurchaseInvoiceDetail = @IDX_T_PurchaseInvoiceDetail

		--SET @TaxAmount = ((@_UntaxedAmount - @_DiscountAmount) * @_Quantity) * (@_TaxPercentage / 100)
		SET @TaxAmount = ((@_UntaxedAmount - @_DiscountAmount)) * @_TaxPercentage / 100
		
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
			INSERT INTO [dbo].[CM_T_PurchaseInvoiceTax]
			   ([IDX_T_PurchaseInvoiceHeader]
			   ,[IDX_T_PurchaseInvoiceDetail]
			   ,[IDX_M_Tax]
			   ,[TaxID]
			   ,[TaxDesc]
			   ,[TaxRate]
			   ,[TaxAmount]			   
			   ,[TaxCOA]
			   ,[AllowEdit]        
			   ,[UCreate]
			   ,[DCreate]
			   ,[RecordStatus])
			 VALUES
			   (@IDX_T_PurchaseInvoiceHeader
			   ,@IDX_T_PurchaseInvoiceDetail
			   ,@IDX_M_Tax
			   ,@_TaxID
			   ,@_TaxDesc
			   ,@_TaxRate
			   ,@TaxAmount
			   ,@TaxCOA
			   ,'Y'
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @IDX_T_PurchaseInvoiceTax AS BIGINT
			SET @IDX_T_PurchaseInvoiceTax = (SELECT SCOPE_IDENTITY())	

			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseInvoiceHeader, 'Data Sudah Disimpan')
						
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



