-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update Table CM_SalesInvoiceHeader
-- =============================================

/*		
	EXEC [dbo].[USP_CM_SalesInvoiceHeader_Update] 'Pcs','Pieces','admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceHeader_Update] 	
	@IDX_T_SalesInvoiceHeader		BIGINT,
	@IDX_M_Company					BIGINT,
	@IDX_M_Branch					BIGINT,
	@IDX_M_Currency					BIGINT,
	@IDX_M_LocationInventory		BIGINT,
	@IDX_M_Partner					BIGINT,
	@IDX_M_DocumentType				BIGINT,
	@IDX_ReferenceNo				BIGINT,
	@IDX_M_SalesPerson				BIGINT,
	@ReferenceNo					VARCHAR(50),
	@TaxInvoiceNo					VARCHAR(64),
	@InvoiceNo						VARCHAR(50),
	@InvoiceDate					DATETIME,
	@InvoiceDueDate					DATETIME,		
	@RemarkHeader					VARCHAR(1024),	
	@AuditNotes						VARCHAR(1024),	
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
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Invalid Chart of Account')
		END

		IF (SELECT DISTINCT(IDX_M_Branch) FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) <> @IDX_M_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Please Delete All Detail Transactions First Before Changing BranchID!')
		END

		DECLARE @IDXGC_Branch BIGINT
		SET @IDXGC_Branch = (SELECT IDX_M_Company FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch)

		IF @IDX_M_Company <> @IDXGC_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, 'Selected Branch Not Under The Same Group Company!')
		END

		DECLARE @CurrentReferenceNo VARCHAR(50) = (SELECT ReferenceNo FROM CM_T_SalesInvoiceHeader WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)

		IF EXISTS (	SELECT 1 FROM X_MemberSummary_Quality WITH(NOLOCK) WHERE UploadID = @CurrentReferenceNo )
		BEGIN
			IF @CurrentReferenceNo <> @ReferenceNo
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Change Sales Order No Information From Uploaded Source Member Data Transaction!')
			END
		END

		IF EXISTS (	SELECT 1 FROM X_SalesSummary_Quality WITH(NOLOCK) WHERE UploadID = @CurrentReferenceNo )
		BEGIN
			IF @CurrentReferenceNo <> @ReferenceNo
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Change Sales Order No Information From Uploaded Source Sales Data Transaction!')
			END
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			UPDATE [dbo].[CM_T_SalesInvoiceHeader] SET
				[IDX_M_Company] = @IDX_M_Company
			   ,[IDX_M_Branch] = @IDX_M_Branch
			   ,[IDX_M_Currency] = @IDX_M_Currency
			   ,[IDX_M_LocationInventory] = @IDX_M_LocationInventory
			   ,[IDX_ReferenceNo] = @IDX_ReferenceNo
			   ,[IDX_M_Partner] = @IDX_M_Partner
			   ,[ReferenceNo] = @ReferenceNo
			   ,[TaxInvoiceNo] = @TaxInvoiceNo
			   ,[IDX_M_SalesPerson] = @IDX_M_SalesPerson
			   ,[InvoiceDate] = @InvoiceDate
			   ,[InvoiceDueDate] = @InvoiceDueDate
			   ,[InvoiceStatus] = @InvoiceStatus			   
			   ,[RemarkHeader] = @RemarkHeader
			   ,[AuditNotes] = @AuditNotes
			   ,[COAHeader] = @COAHeader			  
			   ,[UModified] = @UserID
			   ,[DModified] = GETDATE()
			   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	

			/** Check detail data **/
			SELECT @_CountDetail = COUNT(*) 
			FROM CM_T_SalesInvoiceDetail
			WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

			/** Insert detail from PO, if no data exists in detail table **/
			IF @_CountDetail = 0 AND @IDX_M_DocumentType = 700
			BEGIN

				INSERT INTO [dbo].[CM_T_SalesInvoiceDetail]
				   ([IDX_T_SalesInvoiceHeader]
				   ,[IDX_M_Item]
				   ,[Quantity]
				   ,[IDX_M_UOM]
				   ,[UntaxedAmount]
				   ,[DiscountAmount]
				   ,[IDX_M_Tax]
				   ,[TaxAmount]
				   ,[ItemDesc]
				   ,[RemarkDetail]  
				   ,[IDX_M_COA]        
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus])
				SELECT 
					 @IDX_T_SalesInvoiceHeader
					,PRD.IDX_M_Item
					,PRD.Qty
					,MI.IDX_M_UoM
					,PRD.AmountUntaxed
					,PRD.Discount
					,MI.ValueVAT
					,PRD.AmountTax
					,MI.ItemName
					,''
					,MI.ExpenseAccount
					,@UserID
					,GETDATE()
					,'A'
				FROM PS_T_PosOrderLine PRD
					LEFT JOIN IN_M_Item MI ON PRD.IDX_M_Item = MI.IDX_M_Item
				WHERE PRD.IDX_T_PosOrderLine = @IDX_ReferenceNo
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



