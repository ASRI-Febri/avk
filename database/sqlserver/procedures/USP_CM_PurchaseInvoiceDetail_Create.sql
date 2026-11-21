-- ==================================================================================================================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Purchase Invoice Detail
--				Anton 2020-05-27 --> Added validation that transaction can't be modified if Checklist Tax is checked
--				Anton 2021-01-18 --> Adjust Tax CoaOut information
--				Anton 2021-01-26 --> Adjust @TaxAmount from DECIMAL(18,3) to DECIMAL(18,2) --> same with PO/SPK @TaxAmount data type
--				Anton 2022-03-23 --> Added calculation for tax 11%
--				Anton 2024-01-15 --> Adjust Tax Calculation (FLOOR)
-- ==================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_PurchaseInvoiceDetail_Create] 'Pcs','Pieces','admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceDetail_Create] 	
	@IDX_T_PurchaseInvoiceHeader		BIGINT,	
	@IDX_M_Project						BIGINT,
	@IDX_M_Item							BIGINT,
	@IDX_M_UoM							BIGINT,	
	@IDX_M_COA							BIGINT,
	@IDX_M_Tax							INT,
	@IncludeTax							BIT,
	@ItemDesc							VARCHAR(150),
	@Quantity							INT,	
	@UnitPrice							DECIMAL(22,2),
	@UntaxedAmount						DECIMAL(22,2),
	@DiscountAmount						DECIMAL(18,2),	
	@TaxAmount							DECIMAL(18,2),		
	@RemarkDetail						VARCHAR(500),	
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

		/** Calculate Tax **/
		DECLARE @_TaxPercentage AS DECIMAL(18,2)
		DECLARE @_TaxID AS VARCHAR(20)
		DECLARE @_TaxDesc AS VARCHAR(50)
		DECLARE @_TaxRate AS DECIMAL(18,2)
		DECLARE @_TaxCOA AS BIGINT

		IF @IDX_M_COA = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Invalid Chart of Account')
		END

		IF @IncludeTax = 1 AND @IDX_M_Tax = 0
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Invalid Tax')
		END

		--IF (SELECT IsTaxChecked FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) = '1'
		--BEGIN 
		--	INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Checlist Tax Status Already Checked!')
		--END

		IF @IDX_M_Item = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Master Item Not Exists!')
		END
		ELSE
		BEGIN
			SET @ItemDesc = (SELECT UPPER(ItemName) FROM IN_M_Item WHERE IDX_M_Item = @IDX_M_Item)
		END

		IF (SELECT IsWithHoldingTax FROM GL_M_Tax WITH(NOLOCK) WHERE IDX_M_Tax = @IDX_M_Tax) = 1
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Please Add PPH TAX Category on Additional Tax Section!')
		END

		-- ================================================================================================
		-- Get data from master tax
		-- ================================================================================================
		SELECT @_TaxPercentage = TaxRate, @_TaxID = TaxID, @_TaxDesc = TaxName, @_TaxRate = TaxRate, @_TaxCOA = COAOut 
			FROM GL_M_Tax WITH(NOLOCK)
			WHERE IDX_M_Tax = @IDX_M_Tax

		-- ================================================================================================
		-- Unit Price is include tax
		-- ================================================================================================
		IF @IncludeTax = 1 
		BEGIN
			IF @_TaxPercentage = 10.00
			BEGIN
				--SET @UntaxedAmount = CONVERT(DECIMAL(18,2),(@UnitPrice - @DiscountAmount) / 1.1)
				--SET @TaxAmount = @UnitPrice - @UntaxedAmount
				SET @UntaxedAmount = CONVERT(DECIMAL(18,2),(@UnitPrice - @DiscountAmount) / 1.1)
				SET @UntaxedAmount = ROUND(@UntaxedAmount,0)
				SET @TaxAmount = @UnitPrice - @DiscountAmount - @UntaxedAmount
			END
			ELSE IF @_TaxPercentage = 11.00
			BEGIN
				--SET @UntaxedAmount = CONVERT(DECIMAL(18,2),(@UnitPrice - @DiscountAmount) / 1.11)
				--SET @TaxAmount = @UnitPrice - @UntaxedAmount
				SET @UntaxedAmount = CONVERT(DECIMAL(18,2),(@UnitPrice - @DiscountAmount) / 1.11)
				SET @UntaxedAmount = ROUND(@UntaxedAmount,0)
				SET @TaxAmount = @UnitPrice - @DiscountAmount - @UntaxedAmount
			END
		END
		ELSE
		BEGIN
			SET @UntaxedAmount = @UnitPrice
			SET @TaxAmount = ((@UntaxedAmount - @DiscountAmount)) * (ISNULL(@_TaxPercentage,0) / 100)
			IF @TaxAmount > 0
			BEGIN
				SET @TaxAmount = FLOOR(ISNULL(@TaxAmount,0))
			END
			ELSE
			BEGIN
				SET @TaxAmount = FLOOR(ISNULL(ABS(@TaxAmount),0))*-1
			END
			--SET @TaxAmount = CONVERT(DECIMAL(18,3),@TaxAmount)
		END

		-- ================================================================================================
		-- Branch vs Project
		-- ================================================================================================

		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END
			
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			INSERT INTO [dbo].[CM_T_PurchaseInvoiceDetail]
			   ([IDX_T_PurchaseInvoiceHeader]
			   ,[IDX_M_Branch]
			   ,[IDX_M_Project]
			   ,[IDX_M_Item]
			   ,[IDX_M_UoM]
			   ,[IDX_M_COA]
			   ,[IDX_M_Tax]
			   ,[IncludeTax]
			   ,[ItemDesc]
			   ,[Quantity]			   
			   ,[UnitPrice]
			   ,[UntaxedAmount]
			   ,[DiscountAmount]			   
			   ,[TaxAmount]			   
			   ,[RemarkDetail]  			           
			   ,[UCreate]
			   ,[DCreate]
			   ,[RecordStatus])
			 VALUES
			   (@IDX_T_PurchaseInvoiceHeader
			   ,@IDX_Branch
			   ,@IDX_M_Project
			   ,@IDX_M_Item
			   ,@IDX_M_UoM
			   ,@IDX_M_COA
			   ,@IDX_M_Tax
			   ,@IncludeTax
			   ,@ItemDesc
			   ,@Quantity
			   ,@UnitPrice
			   ,@UntaxedAmount
			   ,@DiscountAmount			   
			   ,ISNULL(@TaxAmount,0)			   
			   ,@RemarkDetail			   
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @IDX_T_PurchaseInvoiceDetail AS BIGINT
			SET @IDX_T_PurchaseInvoiceDetail = (SELECT SCOPE_IDENTITY())	

			/** Insert Tax **/
			IF @TaxAmount <> 0
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
				SELECT 
					 @IDX_T_PurchaseInvoiceHeader
					,@IDX_T_PurchaseInvoiceDetail
					,@IDX_M_Tax
					,@_TaxID
					,@_TaxDesc
					,@_TaxRate
					,@TaxAmount
					,@_TaxCOA
					,'N'
					,@UserID
					,GETDATE()
					,'A' 
			END

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



