-- ===============================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Update Table Sales Invoice Detail
-- Mod			: 2022-03-23 by Anton --> Added calculation for tax 11%
--				  2023-02-09 by Anton --> Adjust bug occur when update detail tax
--				  2023-08-25 by Anton --> Adjust TotalSalesAmount on Header for Upload Excel Transaction when update amount on detail item occur
--				  2024-01-15 by Anton --> Adjust Tax Calculation (FLOOR)
-- ===============================================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_SalesInvoiceDetail_Update]
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

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceDetail_Update] 	
	@IDX_T_SalesInvoiceDetail			BIGINT,
	@IDX_T_SalesInvoiceHeader			BIGINT,	
	@IDX_M_Project						BIGINT,
	@IDX_M_Item							BIGINT,
	@IDX_M_UoM							BIGINT,	
	@IDX_M_COA							BIGINT,
	@IDX_M_Tax							INT,
	@IncludeTax							BIT,
	@ItemDesc							VARCHAR(150),
	@Quantity							INT,	
	@UnitPrice							DECIMAL(22,3),
	@UntaxedAmount						DECIMAL(22,3),
	@DiscountAmount						DECIMAL(18,3),	
	@TaxAmount							DECIMAL(18,3),		
	@RemarkDetail						VARCHAR(500),	
	------------------------------------------------
	@UserID								VARCHAR(50),
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

		IF @IDX_M_COA = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Invalid Chart of Account')
		END

		IF @IncludeTax = 1 AND @IDX_M_Tax = 0
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Invalid Tax')
		END

		IF @IDX_M_Item = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Master Item Not Exists!')
		END
		ELSE
		BEGIN
			SET @ItemDesc = (SELECT UPPER(ItemName) FROM IN_M_Item WHERE IDX_M_Item = @IDX_M_Item)
		END

		/** Calculate Tax **/
		DECLARE @_Prev_IDX_M_Tax AS INT
		DECLARE @_TaxPercentage AS DECIMAL(18,3)
		DECLARE @_TaxID AS VARCHAR(20)
		DECLARE @_TaxDesc AS VARCHAR(50)
		DECLARE @_TaxRate AS DECIMAL(18,3)
		DECLARE @_TaxCOA AS BIGINT
		DECLARE @_TotalSalesAmount AS DECIMAL(18,2)

		-- Get Previous Tax ID From Sales Invoice Detail
		SELECT @_Prev_IDX_M_Tax = IDX_M_Tax 
		FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
		WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail

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
			SELECT @_TaxPercentage = TaxRate, @_TaxID = TaxID, @_TaxDesc = TaxName, @_TaxRate = TaxRate, @_TaxCOA = COAIn 
			FROM GL_M_Tax WITH(NOLOCK)
			WHERE IDX_M_Tax = @IDX_M_Tax
		END
		

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
				SET @UntaxedAmount = CONVERT(DECIMAL(18,2),(@UnitPrice - @DiscountAmount) / 1.11)
				SET @UntaxedAmount = ROUND(@UntaxedAmount,0)
				SET @TaxAmount = @UnitPrice - @DiscountAmount - @UntaxedAmount
			END
		END
		ELSE
		BEGIN
			SET @UntaxedAmount = @UnitPrice
			SET @TaxAmount = ((@UntaxedAmount - @DiscountAmount)) * (@_TaxPercentage / 100)
			IF @TaxAmount > 0
			BEGIN
				SET @TaxAmount = FLOOR(ISNULL(@TaxAmount,0))
			END
			ELSE
			BEGIN
				SET @TaxAmount = FLOOR(ISNULL(ABS(@TaxAmount),0))*-1
			END
			--SET @TaxAmount = ISNULL(CONVERT(DECIMAL(18,3),@TaxAmount),0) --mod by Anton 2020-02-19, added ISNULL condition
		END

		-- ================================================================================================
		-- Branch vs Project
		-- ================================================================================================

		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END

		-- ================================================================================================
		-- Uploaded Data Transaction
		-- ================================================================================================
		IF ( SELECT LEN(ReferenceNo) FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader ) = 13
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Cannot Modified Detail Information From Excel Uploaded Data Transaction!')
		END

		-- ================================================================================================================
		-- If no error occured
		-- ================================================================================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			
			/** Update data **/
			UPDATE [dbo].[CM_T_SalesInvoiceDetail] SET
			   [IDX_T_SalesInvoiceHeader] = @IDX_T_SalesInvoiceHeader,
			   [IDX_M_Branch] = @IDX_Branch,
			   [IDX_M_Project] = @IDX_M_Project,
			   [IDX_M_Item] = @IDX_M_Item,
			   [IDX_M_UoM] = @IDX_M_UoM,
			   [IDX_M_COA] = @IDX_M_COA,
			   [IDX_M_Tax] = @IDX_M_Tax,
			   [IncludeTax] = @IncludeTax,
			   [ItemDesc] = @ItemDesc,
			   [Quantity] = @Quantity,
			   [UnitPrice] = @UnitPrice,			   
			   [UntaxedAmount] = @UntaxedAmount,
			   [DiscountAmount] = @DiscountAmount,			   
			   [TaxAmount] = @TaxAmount,
			   [RemarkDetail] = @RemarkDetail,				   	              
			   [UModified] = @UserID,
			   [DModified] = GETDATE(),
			   [RecordStatus] = @RecordStatus
			WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail	

			-- =============================================
			-- Delete Tax, If TaxAmount = 0
			-- =============================================	
					
			IF @TaxAmount = 0
			BEGIN
				DELETE CM_T_SalesInvoiceTax
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND 
					IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail AND
					IDX_M_Tax = @_Prev_IDX_M_Tax
			END

			-- =============================================
			-- Insert Tax, If TaxAmount <> 0
			-- =============================================

			IF @TaxAmount <> 0
			BEGIN
				--UPDATE [dbo].[CM_T_SalesInvoiceTax] SET
				--    [IDX_M_Tax] = @IDX_M_Tax
				--   ,[TaxID] = @_TaxID
				--   ,[TaxRate] = @_TaxRate 
				--   ,[TaxAmount] = @TaxAmount			   
				--   ,[TaxCOA] = @_TaxCOA       
				--   ,[UModified] = @UserID
				--   ,[DModified] = GETDATE()
				--   ,[RecordStatus] = @RecordStatus
				--WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND 
				--	IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail

				IF EXISTS (	SELECT 1
							FROM CM_T_SalesInvoiceTax SIT WITH(NOLOCK) 
							WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail	)
				BEGIN						
					DELETE CM_T_SalesInvoiceTax
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail
				END
					
				INSERT INTO [dbo].[CM_T_SalesInvoiceTax]
				   ([IDX_T_SalesInvoiceHeader]
				   ,[IDX_T_SalesInvoiceDetail]
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
				SELECT @IDX_T_SalesInvoiceHeader, @IDX_T_SalesInvoiceDetail, @IDX_M_Tax,
					@_TaxID, @_TaxDesc, @_TaxRate, @TaxAmount, @_TaxCOA, 'N', @UserID, GETDATE(), 'A'			
			END

			IF	(	SELECT ISNULL(TotalSalesAmount,0) 
					FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	) > 0 
			BEGIN

				DECLARE @_CurrentIDX_M_Tax		INT	
				DECLARE @_CurrentIncludeTax		BIT	
				DECLARE @_CurrentQuantity		DECIMAL(18,2)	
				DECLARE @_CurrentUnitPrice		DECIMAL(18,3)	
				DECLARE @_CurrentUntaxedAmount	DECIMAL(20,3)	
				DECLARE @_CurrentDiscountAmount	DECIMAL(20,3)	
				DECLARE @_CurrentTaxAmount		DECIMAL(20,3)	

				SELECT @_CurrentIDX_M_Tax = IDX_M_Tax,
					   @_CurrentIncludeTax = IncludeTax,
					   @_CurrentQuantity = Quantity,		
					   @_CurrentUnitPrice = UnitPrice,	
					   @_CurrentUntaxedAmount = UntaxedAmount,
					   @_CurrentDiscountAmount = DiscountAmount,
					   @_CurrentTaxAmount = TaxAmount	
				FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
				WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail

				IF ( @_CurrentIDX_M_Tax <> @IDX_M_Tax OR @_CurrentIncludeTax <> @IncludeTax OR @_CurrentQuantity <> @Quantity OR @_CurrentUnitPrice <> @UnitPrice OR
					 @_CurrentUntaxedAmount <> @UntaxedAmount OR @_CurrentDiscountAmount <> @DiscountAmount OR @_CurrentTaxAmount <> @TaxAmount )
				BEGIN

					SET @_TotalSalesAmount = ( SELECT SUM(((UntaxedAmount - DiscountAmount + TaxAmount) * Quantity))
											   FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
											   WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader )

					UPDATE CM_T_SalesInvoiceHeader SET TotalSalesAmount = @_TotalSalesAmount WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				END

				--IF	(	SELECT TotalSalesAmount 
				--		FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
				--		WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	) <>
				--	(	SELECT SUM(UnitPrice)
				--		FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
				--		WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice > 0 AND RecordStatus = 'A'	)
				--BEGIN
				--	UPDATE A
				--		SET A.TotalSalesAmount = X.NewUnitPrice
				--	FROM CM_T_SalesInvoiceHeader A WITH(NOLOCK)
				--		INNER JOIN 
				--		(	SELECT IDX_T_SalesInvoiceHeader, SUM(UnitPrice) AS NewUnitPrice
				--			FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) 
				--			WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice > 0 AND RecordStatus = 'A'
				--			GROUP BY IDX_T_SalesInvoiceHeader
				--		) X ON A.IDX_T_SalesInvoiceHeader = X.IDX_T_SalesInvoiceHeader
				--	WHERE A.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND A.RecordStatus = 'A' 
				--END
			END

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



