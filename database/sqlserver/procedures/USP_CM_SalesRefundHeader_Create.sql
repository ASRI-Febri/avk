-- ===================================================
-- Author		: Deva
-- Create date	: 21 November 2019
-- Description	: Create Sales Refund Header Record
-- ===================================================

/*	
	BEGIN TRAN
		EXEC [dbo].[USP_CM_SalesRefundHeader_Create] 5, 1, 1, 1, 1, 3, 1, 1, 'Draft-1', '', '2019-11-18 15:47:19.780', '2019-11-19 15:47:19.780', 'ReferenceNumber', 'DeliveryNo' ,'Remark Header','D', 1, 0, 0, 'admin','A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesRefundHeader_Create]
	@IDX_T_SalesInvoiceHeader	BIGINT, 	
	@IDX_M_Company				BIGINT,
	@IDX_M_Branch				BIGINT,
	@IDX_M_Currency				BIGINT,
	@IDX_M_LocationInventory	BIGINT,
	@IDX_M_Partner				BIGINT,
	@IDX_M_DocumentType			BIGINT,
	@IDX_M_SalesPerson			BIGINT,
	@InvoiceReferenceNo			VARCHAR(50),
	@TaxInvoiceNo				VARCHAR(50),
	@RefundNo					VARCHAR(50),
	@RefundDate					DATETIME,
	@RefundDueDate				DATETIME,
	@ReferenceNo				VARCHAR(50),
	@DeliveryNo					VARCHAR(50),
	@RemarkHeader				VARCHAR(50),	
	@RefundStatus				CHAR(1),
	@COAHeader					BIGINT,	
	@IsProforma					CHAR(1),
	@IsCreateJournal			CHAR(1),
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

		DECLARE @_LocationID AS VARCHAR(50)
		DECLARE @_ItemSKU AS VARCHAR(10)
		DECLARE @_LastNumber AS INTEGER

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		DECLARE @_CountDetail AS INT

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
		
		-- =======================================
		-- Validation Process - START
		-- =======================================

		IF @COAHeader = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Please entry COA!')
		END

		IF @RefundDate > @RefundDueDate
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Refund date must be less than refund due date!')
		END
		
		IF EXISTS
			(SELECT '' FROM CM_T_SalesRefundHeader WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND RefundStatus = 'A')
			BEGIN
				INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'This sales invoice has been refund!')
			END

		-- =======================================
		-- Validation Process - END
		-- =======================================

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN	

			INSERT INTO [dbo].[CM_T_SalesRefundHeader]
			   ([IDX_T_SalesInvoiceHeader]
			   ,[IDX_M_Company]
			   ,[IDX_M_Branch]		
			   ,[IDX_M_Currency]
			   ,[IDX_M_LocationInventory]
			   ,[IDX_M_Partner]
			   ,[IDX_M_DocumentType]	
			   ,[IDX_M_SalesPerson]
			   ,[InvoiceReferenceNo]
			   ,[TaxInvoiceNo]
			   ,[RefundNo]
			   ,[RefundDate]
			   ,[RefundDueDate]
			   ,[ReferenceNo]
			   ,[DeliveryNo]
			   ,[RemarkHeader]
			   ,[RefundStatus]
			   ,[COAHeader]
			   ,[IsProforma]
			   ,[IsCreateJournal]
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			VALUES
			   (@IDX_T_SalesInvoiceHeader
			   ,@IDX_M_Company			
			   ,@IDX_M_Branch			
			   ,@IDX_M_Currency			
			   ,@IDX_M_LocationInventory
			   ,@IDX_M_Partner			
			   ,@IDX_M_DocumentType		
			   ,@IDX_M_SalesPerson		
			   ,@InvoiceReferenceNo
			   ,@TaxInvoiceNo		
			   ,@RefundNo				
			   ,@RefundDate				
			   ,@RefundDueDate			
			   ,@ReferenceNo
			   ,@DeliveryNo			  
			   ,@RemarkHeader			
			   ,@RefundStatus			
			   ,@COAHeader	
			   ,@IsProforma		
			   ,@IsCreateJournal			
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @IDX_T_SalesRefundHeader AS BIGINT
			SET @IDX_T_SalesRefundHeader = (SELECT SCOPE_IDENTITY())	
			
			/** Update Draft RefundNo **/
			UPDATE [dbo].[CM_T_SalesRefundHeader]
			SET RefundNo = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_SalesRefundHeader))
			WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

			/** Check detail data **/
			SELECT @_CountDetail = COUNT(*) 
			FROM CM_T_SalesRefundDetail
			WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

			/** Insert detail from SalesRefund, if no data exists in detail table **/
			IF @_CountDetail = 0 AND @IDX_M_DocumentType = 10
			BEGIN     

				/**----------------------------------------------------------------------------- 
							CREATE Sales Refund Detail IF EXISTS IDX_T_SalesInvoiceHeader
				--------------------------------------------------------------------------------**/
				IF EXISTS (	
					SELECT '' FROM CM_T_SalesRefundHeader
					WHERE IDX_T_SalesInvoiceHeader= @IDX_T_SalesInvoiceHeader
				)
				BEGIN			
					/**----------------------------------------------------------------------------- 
													Insert Sales Refund Detail 
					--------------------------------------------------------------------------------**/
					INSERT INTO [dbo].[CM_T_SalesRefundDetail]
						([IDX_T_SalesInvoiceDetail]
						,[IDX_T_SalesRefundHeader]
						,[IDX_M_Item]
						,[IDX_M_UoM]
						,[IDX_M_COA]
						,[IncludeTax]
						,[ItemDesc]
						,[Quantity]
						,[UnitPrice]
						,[UntaxedAmount]
						,[DiscountAmount]
						,[IDX_M_Tax]
						,[TaxAmount]
						,[RemarkDetail]
						,[DCreate]
						,[UCreate]		   
						,[RecordStatus])

					SELECT  TSID.IDX_T_SalesInvoiceDetail,
							@IDX_T_SalesRefundHeader,
							TSID.IDX_M_Item,
							TSID.IDX_M_UoM, 
							TSID.IDX_M_COA, 
							TSID.IncludeTax,
							TSID.ItemDesc, 
							TSID.Quantity, 
							TSID.UnitPrice,
							TSID.UntaxedAmount,
							TSID.DiscountAmount,
							TSID.IDX_M_Tax,
							TSID.TaxAmount,
							TSID.RemarkDetail,
							GETDATE(), 
							@UserID, 
							@RecordStatus

					FROM	CM_T_SalesInvoiceDetail TSID
					WHERE	IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader


					/**----------------------------------------------------------------------------- 
													Insert Sales Refund Tax 
					--------------------------------------------------------------------------------**/
					INSERT INTO [dbo].[CM_T_SalesRefundTax]
							([IDX_T_SalesRefundHeader]
							,[IDX_T_SalesRefundDetail]
							,[IDX_M_Tax]
							,[TaxID]
							,[TaxDesc]
							,[TaxRate]
							,[TaxAmount]
							,[TaxCOA]
							,[AllowEdit]
							,[DCreate]
							,[UCreate]		   
							,[RecordStatus])

					SELECT	@IDX_T_SalesRefundHeader,
							TSRD.IDX_T_SalesRefundDetail,
							TSIT.IDX_M_Tax,
							TSIT.TaxID,
							TSIT.TaxDesc,
							TSIT.TaxRate,
							TSIT.TaxAmount,
							TSIT.TaxCOA,
							TSIT.AllowEdit,
							GETDATE(), 
							@UserID, 
							@RecordStatus
					FROM CM_T_SalesInvoiceTax TSIT
					LEFT JOIN CM_T_SalesRefundDetail TSRD ON TSRD.IDX_T_SalesInvoiceDetail = TSIT.IDX_T_SalesInvoiceDetail
					WHERE TSIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				END	
			END

			INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesRefundHeader, 'Data Sudah Disimpan')
				
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



