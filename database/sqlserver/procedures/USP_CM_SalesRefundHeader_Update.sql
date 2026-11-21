-- ===================================================
-- Author		: Deva
-- Create date	: 21 November 2019
-- Description	: Update Sales Refund Header Record
-- ===================================================

/*		
	EXEC [dbo].[USP_CM_SalesRefundHeader_Update] 1, 1, 1, 1, 1, 1, 3, 1, 1, 'Invoice-002', '', '2019-11-18 15:47:19.780', '2019-11-19 15:47:19.780', 'ReferenceNumber', 'Remark Header','D', 1, 'admin','A'
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesRefundHeader_Update] 	
	@IDX_T_SalesRefundHeader	BIGINT,
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
		--SET @_FormID = 'CM-PINV-002' -- Receiving item 

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

			UPDATE [dbo].[CM_T_SalesRefundHeader] SET
				[IDX_T_SalesInvoiceHeader]	= @IDX_T_SalesInvoiceHeader
				,[IDX_M_Company]			= @IDX_M_Company			
				,[IDX_M_Branch]				= @IDX_M_Branch			
				,[IDX_M_Currency]			= @IDX_M_Currency			
				,[IDX_M_LocationInventory]	= @IDX_M_LocationInventory
				,[IDX_M_Partner]			= @IDX_M_Partner			
				,[IDX_M_DocumentType]		= @IDX_M_DocumentType		
				,[IDX_M_SalesPerson]		= @IDX_M_SalesPerson		
				,[InvoiceReferenceNo]		= @InvoiceReferenceNo
				,[TaxInvoiceNo]				= @TaxInvoiceNo
				,[RefundNo]					= @RefundNo				
				,[RefundDate]				= @RefundDate				
				,[RefundDueDate]			= @RefundDueDate			
				,[ReferenceNo]				= @ReferenceNo	
				,[DeliveryNo]				= @DeliveryNo
				,[RemarkHeader]				= @RemarkHeader			
				,[RefundStatus]				= @RefundStatus			
				,[COAHeader]				= @COAHeader
				,[IsProforma]				= @IsProforma		
				,[IsCreateJournal]			= @IsCreateJournal	
				,[UModified]				= @UserID
				,[DModified]				= GETDATE()
				,[RecordStatus]				= @RecordStatus
			WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader	

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



