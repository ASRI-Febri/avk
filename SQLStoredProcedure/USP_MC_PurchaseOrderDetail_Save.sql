USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Definisi hidup dari AVKDB per 15 Agustus 2026.
-- Perubahan terakhir: pecahan yang sama boleh berulang dalam satu nota.


/*		
	SELECT * FROM MC_T_PurchaseOrderDetail

	EXEC [dbo].[USP_PR_PurchaseOrderDetail_Save] 
					 13
					 ,20
					 ,1
					 ,1
					 ,1
					 ,8
					 ,10000
					 ,'50000'
					 ,'20000'
					 ,'10000'
					 ,'RemarkDetail'
					 ,'Deva'
					 ,'A'
*/
ALTER PROCEDURE [dbo].[USP_MC_PurchaseOrderDetail_Save] 
	@IDX_T_PurchaseOrderDetail	BIGINT,
	@IDX_T_PurchaseOrder		BIGINT, 
	@IDX_M_Valas				BIGINT, 
	@IDX_M_Tax					INT,	
	@Quantity					INT,
	@ForeignAmount				DECIMAL(22, 4),	
	@ExchangeRate				DECIMAL(22, 4),	
	@DetailNotes				VARCHAR(1000),
	------------------------------------------------
	@UserID						VARCHAR(10),
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

		/** 
		IF @IDX_M_COA = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrderDetail, 'Invalid Chart of Account')
		END

		IF @IncludeTax = 1 AND @IDX_M_Tax = 0
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrderDetail, 'Invalid Tax')
		END
		**/

		-- =======================================
		-- Pecahan yang sama boleh muncul lebih dari sekali dalam satu nota.
		-- Dulu di sini ada larangan 'This item already exists!', padahal satu
		-- nota memang bisa memuat pecahan yang sama dengan nilai tukar berbeda,
		-- misalnya sebagian uang mulus dan sebagian rusak.
		-- =======================================

		-- =======================================
		-- Check Unit Price Can't 0.00
		-- =======================================
		--IF EXISTS(	SELECT ForeignAmount
		--			FROM MC_T_PurchaseOrderDetail WITH(NOLOCK)
		--			WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder AND @ForeignAmount = 0.00 )
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrderDetail,'Unit price must be > 0!')
		--END		

		IF @Quantity = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrderDetail,'Quantity pembelian harus lebih dari 0!')
		END

		IF @ExchangeRate = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrderDetail,'Exchange rate must be > 0!')
		END	


		--DECLARE @_IDX_M_Tax			INT = 14 -- DEFAULT INDEX UNTUK PPN 11%
		DECLARE @_Prev_IDX_M_Tax	INT
		DECLARE @_TaxPercentage		DECIMAL(18,2)
		DECLARE @_TaxID				VARCHAR(20)
		DECLARE @_TaxDesc			VARCHAR(50)
		DECLARE @_TaxRate			DECIMAL(18,2)
		DECLARE @_TaxCOA			BIGINT

		DECLARE @_UntaxedAmount		DECIMAL(18,2) = 0
		DECLARE @_TaxAmount			DECIMAL(18,2) = 0

		-- Get Previous Tax ID From Purchase Order Detail
		SELECT @_Prev_IDX_M_Tax = IDX_M_Tax 
		FROM MC_T_PurchaseOrderDetail WITH(NOLOCK)
		WHERE IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail

		-- ================================================================================================
		-- Get data from master tax
		-- ================================================================================================
		IF @IDX_M_Tax = 0
		BEGIN
			SET @_TaxPercentage = 0
			SET @_TaxID = ''
			SET @_TaxDesc = ''
			SET @_TaxRate = 0
			SET @_TaxCOA = 0
		END
		ELSE
		BEGIN
			SELECT @_TaxPercentage = TaxRate, @_TaxID = TaxID, @_TaxDesc = TaxName, @_TaxCOA = COAIn 
			FROM GL_M_Tax WITH(NOLOCK)
			WHERE IDX_M_Tax = @IDX_M_Tax
		END
		

		-- ================================================================================================
		-- Unit Price
		-- ================================================================================================
		DECLARE @_CountLog AS INT
		DECLARE @_CountDetail AS INT

		--IF @IncludeTax = 1
		--BEGIN
		--	SET @_UntaxedAmount = (@ForeignAmount - @DiscountAmount) / ( 1 + (@_TaxPercentage / 100))
		--	SET @_TaxAmount = @_UntaxedAmount * (@_TaxPercentage / 100)
		--	SET @_TaxAmount = CONVERT(DECIMAL(18,2),@_TaxAmount)
		--END
		--ELSE
		--BEGIN
		--	SET @_UntaxedAmount = (@ForeignAmount - @DiscountAmount)
		--	SET @_TaxAmount = @_UntaxedAmount * (@_TaxPercentage / 100)
		--	SET @_TaxAmount = CONVERT(DECIMAL(18,2),@_TaxAmount)
		--END		

		-- ================================================================================================================
		-- If no error occured
		-- ================================================================================================================	
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			DECLARE	@_ForeignCurrency				INT
			DECLARE @_BaseCurrency					INT = 1 -- IDR
			DECLARE @_BaseCurrencyAmount			DECIMAL(18,2)	
			DECLARE @_IDX_M_ValasChange				INT
			DECLARE @_ValasChangeNumber				INT -- VALUE VALAS
 
			SELECT @_ForeignCurrency = IDX_M_Currency, @_IDX_M_ValasChange = IDX_M_ValasChange 
			FROM MC_M_Valas
			WHERE IDX_M_Valas = @IDX_M_Valas

			SELECT @_ValasChangeNumber = ValasChangeNumber 
			FROM MC_M_ValasChange
			WHERE IDX_M_ValasChange = @_IDX_M_ValasChange

			SET @ForeignAmount = @_ValasChangeNumber * @Quantity

			SET @_BaseCurrencyAmount = CONVERT(DECIMAL(18,2), @ForeignAmount * @ExchangeRate)

			IF @IDX_T_PurchaseOrderDetail = 0
			BEGIN

				INSERT INTO [dbo].[MC_T_PurchaseOrderDetail]
				   ([IDX_T_PurchaseOrder]
				   ,[IDX_M_Valas]				   
				   ,[IDX_M_Tax]
				   ,[ForeignCurrency]
				   ,[Quantity]
				   ,[ForeignAmount]
				   ,[ExchangeRate]
				   ,[BaseCurrency]
				   ,[BaseCurrencyAmount]				   
				   ,[DetailNotes]
				   ,[UCreate]
				   ,[DCreate]			   
				   ,[RecordStatus])
				VALUES
				   (@IDX_T_PurchaseOrder
				   ,@IDX_M_Valas	
				   ,@IDX_M_Tax			
				   ,@_ForeignCurrency	
				   ,@Quantity	
				   ,@ForeignAmount
				   ,@ExchangeRate
				   ,@_BaseCurrency	
				   ,@_BaseCurrencyAmount	
				   ,@DetailNotes		
				   ,@UserID
				   ,GETDATE()
				   ,@RecordStatus)
			
				SET @IDX_T_PurchaseOrderDetail = (SELECT SCOPE_IDENTITY())	

			END
			ELSE
			BEGIN
			
				UPDATE [dbo].[MC_T_PurchaseOrderDetail] SET
					 [IDX_T_PurchaseOrder]			= @IDX_T_PurchaseOrder
					,[IDX_M_Valas]					= @IDX_M_Valas
					,[IDX_M_Tax]					= @IDX_M_Tax
					,[ForeignCurrency]				= @_ForeignCurrency
					,[Quantity]						= @Quantity
					,[ForeignAmount]				= @ForeignAmount
					,[ExchangeRate]					= @ExchangeRate
					,[BaseCurrency]					= @_BaseCurrency
					,[BaseCurrencyAmount]			= @_BaseCurrencyAmount
					,[DetailNotes]					= @DetailNotes
					-----------------------------------------------------
					,[UModified]					= @UserID
					,[DModified]					= GETDATE()	  
					,[RecordStatus]					= @RecordStatus
				WHERE IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail
			END


			-- =============================================
			--			Delete Tax, If TaxAmount = 0
			-- =============================================	
					
			--IF @_TaxAmount = 0
			--BEGIN
			--	DELETE PR_T_PurchaseOrderTax
			--	WHERE IDX_T_PurchaseOrderHeader = @IDX_T_PurchaseOrder AND 
			--		IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail AND
			--		IDX_M_Tax = @_Prev_IDX_M_Tax
			--END

			-- =============================================
			--			Insert Tax, If TaxAmount <> 0
			-- =============================================

			--IF @_TaxAmount <> 0
			--BEGIN
						
			--	DELETE PR_T_PurchaseOrderTax
			--	WHERE IDX_T_PurchaseOrderHeader = @IDX_T_PurchaseOrder AND 
			--		IDX_T_PurchaseOrderDetail = @IDX_T_PurchaseOrderDetail AND
			--		IDX_M_Tax = @IDX_M_Tax
					
			--	INSERT INTO [dbo].[PR_T_PurchaseOrderTax]
			--	   ([IDX_T_PurchaseOrderHeader]
			--	   ,[IDX_T_PurchaseOrderDetail]
			--	   ,[IDX_M_Tax]
			--	   ,[TaxID]
			--	   ,[TaxDesc]
			--	   ,[TaxRate]
			--	   ,[TaxAmount]			   
			--	   ,[TaxCOA]   
			--	   ,[AllowEdit]
			--	   ,[UCreate]
			--	   ,[DCreate]
			--	   ,[RecordStatus])
			--	SELECT @IDX_T_PurchaseOrder, @IDX_T_PurchaseOrderDetail, @IDX_M_Tax,
			--		@_TaxID, @_TaxDesc, @_TaxRate, @_TaxAmount, @_TaxCOA, 'N', @UserID, GETDATE(), 'A'			
			--END

			-- OUTPUT
			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseOrder, 'Data Sudah Disimpan')
				
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




GO
