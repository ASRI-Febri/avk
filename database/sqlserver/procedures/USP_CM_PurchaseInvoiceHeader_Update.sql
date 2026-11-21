-- =========================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Update Table CM_PurchaseInvoiceHeader
-- Mod			: - Anton 2020-03-23 --> Added validation for column [IDX_ReferenceNo]
--				  - Anton 2020-05-27 --> Added new variable @IsTaxChecked
--									 --> Added validation that transaction can't be changed if Checklist Tax is checked
-- =========================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_PurchaseInvoiceHeader_Update] 'Pcs','Pieces','admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceHeader_Update] 	
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
	@SupplierDeliveryNo				VARCHAR(500),
	@RemarkHeader					VARCHAR(8000),	
	@InvoiceStatus					CHAR(1),
	@COAHeader						BIGINT,	
	@VendorInvoiceNo				VARCHAR(500),
	@FakturPajak					VARCHAR(500),
	@IsTaxChecked					CHAR(1),
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
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Invalid Chart of Account')
		END

		--IF (SELECT IsTaxChecked FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) = '1' AND @IsTaxChecked = '1'
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Checlist Tax Status Already Checked, Please Un-checked First!')
		--END

		IF (SELECT DISTINCT(IDX_M_Branch) FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) <> @IDX_M_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Please Delete All Detail Transactions First Before Changing BranchID!')
		END

		DECLARE @IDXGC_Branch BIGINT
		SET @IDXGC_Branch = (SELECT IDX_M_Company FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch)

		IF @IDX_M_Company <> @IDXGC_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, 'Selected Branch Not Under The Same Group Company!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			IF NOT EXISTS(SELECT IDX_T_PurchaseOrder FROM PR_T_PurchaseOrder WITH(NOLOCK) WHERE PONumber = RTRIM(LTRIM(@ReferenceNo)) AND POStatus = 'D')
			BEGIN

				DECLARE @IDX_PO_Existing BIGINT
				SET @IDX_PO_Existing = ( SELECT IDX_ReferenceNo 
										 FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) 
										 WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader )

				UPDATE [dbo].[CM_T_PurchaseInvoiceHeader] SET
					[IDX_M_Company] = @IDX_M_Company
				   ,[IDX_M_Branch] = @IDX_M_Branch
				   ,[IDX_M_Currency] = @IDX_M_Currency
				   ,[IDX_M_LocationInventory] = @IDX_M_LocationInventory
				   ,[IDX_ReferenceNo] = @IDX_PO_Existing
				   ,[IDX_M_Partner] = @IDX_M_Partner
				   ,[ReferenceNo] = @ReferenceNo
				   ,[InvoiceDate] = @InvoiceDate
				   ,[InvoiceDueDate] = @InvoiceDueDate
				   ,[InvoiceStatus] = @InvoiceStatus
				   ,[SupplierDeliveryNo] = @SupplierDeliveryNo
				   ,[RemarkHeader] = @RemarkHeader
				   ,[COAHeader] = @COAHeader
				   ,[VendorInvoiceNo] = @VendorInvoiceNo
				   ,[FakturPajak] = @FakturPajak
				   ,[IsTaxChecked] = @IsTaxChecked
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()
				   ,[RecordStatus] = @RecordStatus
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader	
			END
			ELSE
			BEGIN
				DECLARE @IDX_PO BIGINT
				SELECT @IDX_PO = IDX_T_PurchaseOrder FROM PR_T_PurchaseOrder WITH(NOLOCK) WHERE PONumber = RTRIM(LTRIM(@ReferenceNo)) AND POStatus <> 'D'

				UPDATE [dbo].[CM_T_PurchaseInvoiceHeader] SET
					[IDX_M_Company] = @IDX_M_Company
				   ,[IDX_M_Branch] = @IDX_M_Branch
				   ,[IDX_M_Currency] = @IDX_M_Currency
				   ,[IDX_M_LocationInventory] = @IDX_M_LocationInventory
				   ,[IDX_ReferenceNo] = @IDX_PO
				   ,[IDX_M_Partner] = @IDX_M_Partner
				   ,[ReferenceNo] = @ReferenceNo
				   ,[InvoiceDate] = @InvoiceDate
				   ,[InvoiceDueDate] = @InvoiceDueDate
				   ,[InvoiceStatus] = @InvoiceStatus
				   ,[SupplierDeliveryNo] = @SupplierDeliveryNo
				   ,[RemarkHeader] = @RemarkHeader
				   ,[COAHeader] = @COAHeader
				   ,[VendorInvoiceNo] = @VendorInvoiceNo
				   ,[FakturPajak] = @FakturPajak
				   ,[IsTaxChecked] = @IsTaxChecked
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()
				   ,[RecordStatus] = @RecordStatus
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader	
			END

			/** Check detail data **/
			--SELECT @_CountDetail = COUNT(*) 
			--FROM CM_T_PurchaseInvoiceDetail
			--WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

			/** Insert detail from PO, if no data exists in detail table **/
			--IF @_CountDetail = 0 AND @IDX_M_DocumentType = 700
			--BEGIN

			--	INSERT INTO [dbo].[CM_T_PurchaseInvoiceDetail]
			--	   ([IDX_T_PurchaseInvoiceHeader]
			--	   ,[IDX_M_Item]
			--	   ,[Quantity]
			--	   ,[IDX_M_UOM]
			--	   ,[UntaxedAmount]
			--	   ,[DiscountAmount]
			--	   ,[IDX_M_Tax]
			--	   ,[TaxAmount]
			--	   ,[ItemDesc]
			--	   ,[RemarkDetail]  
			--	   ,[IDX_M_COA]        
			--	   ,[UCreate]
			--	   ,[DCreate]
			--	   ,[RecordStatus])
			--	SELECT 
			--		 @IDX_T_PurchaseInvoiceHeader
			--		,PRD.IDX_M_Item
			--		,PRD.Qty
			--		,MI.IDX_M_UoM
			--		,PRD.AmountUntaxed
			--		,PRD.Discount
			--		,PRD.ValueVAT
			--		,PRD.AmountTax
			--		,MI.Name
			--		,PRD.Notes
			--		,MI.ExpenseAccount
			--		,@UserID
			--		,GETDATE()
			--		,'A'
			--	FROM PM_T_PurchaseOrderLine PRD
			--		LEFT JOIN IN_M_Item MI ON PRD.IDX_M_Item = MI.IDX_M_Item
			--	WHERE PRD.IDX_T_PurchaseOrder = @IDX_ReferenceNo
			--END

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



