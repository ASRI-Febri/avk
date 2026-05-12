SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*		
	EXEC [dbo].[USP_MC_SalesOrderDetail_Save] 3,1,3,0,2,5,100,16450,'Test stok minus','it_febry','A'
*/

CREATE PROCEDURE [dbo].[USP_MC_SalesOrderDetail_Save] 
	@IDX_T_SalesOrderDetail		BIGINT,
	@IDX_T_SalesOrder			BIGINT, 
	@IDX_M_Valas				BIGINT, 
	@IDX_M_Tax					INT,	
	@IDX_M_TransactionType		INT,
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
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrderDetail, 'Invalid Chart of Account')
		END

		IF @IncludeTax = 1 AND @IDX_M_Tax = 0
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrderDetail, 'Invalid Tax')
		END
		**/

		-- =======================================
		-- Validate and check Unique Item Desc
		-- =======================================
		IF EXISTS(	SELECT IDX_M_Valas 
					FROM MC_T_SalesOrderDetail WITH(NOLOCK)
					WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND IDX_M_Valas = @IDX_M_Valas 
						AND IDX_T_SalesOrderDetail <> @IDX_T_SalesOrderDetail )
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'This item already exists!')
		END		

		-- =======================================
		-- Check Unit Price Can't 0.00
		-- =======================================
		--IF EXISTS(	SELECT ForeignAmount
		--			FROM MC_T_SalesOrderDetail WITH(NOLOCK)
		--			WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND @ForeignAmount = 0.00 )
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrderDetail,'Unit price must be > 0!')
		--END		

		IF @Quantity = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrderDetail,'Quantity pembelian harus lebih dari 0!')
		END

		IF @ExchangeRate = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrderDetail,'Exchange rate must be > 0!')
		END	

		IF @IDX_M_TransactionType = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrderDetail,'Jenis transaksi belum diisi!')
		END


		-- VALIDASI STOK
		DECLARE @_SODate			DATE
		DECLARE @_IDX_M_Branch		INT
		DECLARE @_CurrentStock		DECIMAL(18,4)

		SELECT @_IDX_M_Branch = IDX_M_Branch, @_SODate = SODate 
		FROM MC_T_SalesOrder 
		WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

		SELECT @_CurrentStock = SUM(StockInQty) - SUM(StockOutQty) 
		FROM MC_T_StockCardValas 
		WHERE IDX_M_Branch = @_IDX_M_Branch AND IDX_M_Valas = @IDX_M_Valas
			AND CONVERT(DATE, TransactionDate) <= @_SODate
			--AND YEAR(TransactionDate) = YEAR(@_SODate)
			--AND MONTH(TransactionDate) = MONTH(@_SODate)
		GROUP BY IDX_M_Branch, IDX_M_Valas

		
		IF @_CurrentStock IS NULL	
			SET @_CurrentStock = 0

		--PRINT 'Stok ' + CONVERT(VARCHAR, @_CurrentStock)
		--PRINT 'Quantity ' + CONVERT(VARCHAR, @Quantity)

		-- VALIDASI UNTUK TRANSAKSI JUAL
		IF (@_CurrentStock < @Quantity) AND @IDX_M_TransactionType = 2 
		BEGIN 
			--PRINT 'Error'
			INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrderDetail,'Tidak ada stok valas!')
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
		FROM MC_T_SalesOrderDetail WITH(NOLOCK)
		WHERE IDX_T_SalesOrderDetail = @IDX_T_SalesOrderDetail

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

			IF @IDX_T_SalesOrderDetail = 0
			BEGIN

				INSERT INTO [dbo].[MC_T_SalesOrderDetail]
				   ([IDX_T_SalesOrder]
				   ,[IDX_M_Valas]				   
				   ,[IDX_M_Tax]
				   ,[IDX_M_TransactionType]
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
				   (@IDX_T_SalesOrder
				   ,@IDX_M_Valas	
				   ,@IDX_M_Tax		
				   ,@IDX_M_TransactionType	
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
			
				SET @IDX_T_SalesOrderDetail = (SELECT SCOPE_IDENTITY())	

			END
			ELSE
			BEGIN
			
				UPDATE [dbo].[MC_T_SalesOrderDetail] SET
					 [IDX_T_SalesOrder]			= @IDX_T_SalesOrder
					,[IDX_M_Valas]					= @IDX_M_Valas
					,[IDX_M_Tax]					= @IDX_M_Tax
					,[IDX_M_TransactionType]		= @IDX_M_TransactionType
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
				WHERE IDX_T_SalesOrderDetail = @IDX_T_SalesOrderDetail
			END


			-- =============================================
			--			Delete Tax, If TaxAmount = 0
			-- =============================================	
					
			--IF @_TaxAmount = 0
			--BEGIN
			--	DELETE PR_T_SalesOrderTax
			--	WHERE IDX_T_SalesOrderHeader = @IDX_T_SalesOrder AND 
			--		IDX_T_SalesOrderDetail = @IDX_T_SalesOrderDetail AND
			--		IDX_M_Tax = @_Prev_IDX_M_Tax
			--END

			-- =============================================
			--			Insert Tax, If TaxAmount <> 0
			-- =============================================

			--IF @_TaxAmount <> 0
			--BEGIN
						
			--	DELETE PR_T_SalesOrderTax
			--	WHERE IDX_T_SalesOrderHeader = @IDX_T_SalesOrder AND 
			--		IDX_T_SalesOrderDetail = @IDX_T_SalesOrderDetail AND
			--		IDX_M_Tax = @IDX_M_Tax
					
			--	INSERT INTO [dbo].[PR_T_SalesOrderTax]
			--	   ([IDX_T_SalesOrderHeader]
			--	   ,[IDX_T_SalesOrderDetail]
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
			--	SELECT @IDX_T_SalesOrder, @IDX_T_SalesOrderDetail, @IDX_M_Tax,
			--		@_TaxID, @_TaxDesc, @_TaxRate, @_TaxAmount, @_TaxCOA, 'N', @UserID, GETDATE(), 'A'			
			--END

			-- OUTPUT
			INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesOrder, 'Data Sudah Disimpan')
				
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
