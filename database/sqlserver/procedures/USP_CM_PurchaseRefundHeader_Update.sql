-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update Purchase Refund Header
-- =============================================

/*		
	EXEC [dbo].[USP_CM_PurchaseRefundHeader_Update] 'Pcs','Pieces','admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefundHeader_Update] 	
	@IDX_T_PurchaseRefundHeader		BIGINT,
	@IDX_T_PurchaseInvoiceHeader	BIGINT,
	@IDX_M_Company					BIGINT,
	@IDX_M_Branch					BIGINT,
	@IDX_M_Currency					BIGINT,
	@IDX_M_LocationInventory		BIGINT,
	@IDX_M_Partner					BIGINT,
	@IDX_M_DocumentType				BIGINT,
	@IDX_ReferenceNo				BIGINT,
	@ReferenceNo					VARCHAR(50),
	@InvoiceNo						VARCHAR(50),
	@InvoiceDate					DATETIME,
	@InvoiceDueDate					DATETIME,		
	@RemarkHeader					VARCHAR(50),	
	@InvoiceStatus					CHAR(1),
	@COAHeader						BIGINT,		
	------------------------------------------------
	@UserID							VARCHAR(50),
	@RecordStatus					CHAR(1)	
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

		IF @COAHeader = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseRefundHeader, 'Invalid Chart of Account')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			UPDATE [dbo].[CM_T_PurchaseRefundHeader] SET
				[IDX_M_Company] = @IDX_M_Company
			   ,[IDX_M_Branch] = @IDX_M_Branch
			   ,[IDX_M_Currency] = @IDX_M_Currency
			   ,[IDX_M_LocationInventory] = @IDX_M_LocationInventory
			   ,[IDX_ReferenceNo] = @IDX_ReferenceNo
			   ,[IDX_M_Partner] = @IDX_M_Partner
			   ,[ReferenceNo] = @ReferenceNo
			   ,[InvoiceDate] = @InvoiceDate
			   ,[InvoiceDueDate] = @InvoiceDueDate
			   ,[InvoiceStatus] = @InvoiceStatus			   
			   ,[RemarkHeader] = @RemarkHeader
			   ,[COAHeader] = @COAHeader			  
			   ,[UModified] = @UserID
			   ,[DModified] = GETDATE()
			   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader	
	

			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseRefundHeader, 'Data Sudah Disimpan')
				
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



