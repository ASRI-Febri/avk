-- ===========================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Create Table Purchase Invoice Header
-- Mod			: Anton 2020-03-30 --> Added mapping IDX_ReferenceNo (CM_T_PurchaseInvoiceHeader) from IDX_T_PurchaseOrder (PR_T_PurchaseOrder)
--				  Anton 2020-05-27 --> Added new variable @IsTaxChecked
-- ===========================================================================================================================================================

/*	
	BEGIN TRAN
		EXEC [dbo].[USP_ReceivingItemHeader_Create] 1,1,2,0,2,'','2017-01-06','SJ-001','Test','D','admin','A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoiceHeader_Create] 	
	@IDX_M_Company				BIGINT,
	@IDX_M_Branch				BIGINT,
	@IDX_M_Currency				BIGINT,
	@IDX_M_LocationInventory	BIGINT,
	@IDX_M_Partner				BIGINT,
	@IDX_M_DocumentType			BIGINT,
	@IDX_ReferenceNo			BIGINT,
	@ReferenceNo				VARCHAR(50),
	@InvoiceNo					VARCHAR(50),
	@InvoiceDate				DATETIME,
	@InvoiceDueDate				DATETIME,	
	@SupplierDeliveryNo			VARCHAR(500),
	@RemarkHeader				VARCHAR(8000),	
	@InvoiceStatus				CHAR(1),
	@COAHeader					BIGINT,
	@VendorInvoiceNo			VARCHAR(500),
	@FakturPajak				VARCHAR(500),
	@IsTaxChecked				CHAR(1),
	------------------------------------------------
	@UserID						VARCHAR(50),
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

		IF @COAHeader = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 'New Invoice', 'Invalid Chart of Account')
		END

		DECLARE @IDXGC_Branch BIGINT
		SET @IDXGC_Branch = (SELECT IDX_M_Company FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch)

		IF @IDX_M_Company <> @IDXGC_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 'New Invoice', 'Selected Branch Not Under The Same Group Company!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			--SELECT @_LocationID = RTRIM(LocationID) 
			--FROM IN_M_LocationInventory 
			--WHERE IDX_IN_M_LocationInventory = @IDX_IN_M_LocationInventory
		
			--SET @_LastNumber = 0		

			--IF EXISTS(	SELECT TOP 1 InvoiceNo
			--			FROM CM_T_PurchaseInvoiceH 
			--			WHERE IDX_IN_M_LocationInventory = @IDX_IN_M_LocationInventory
			--				AND MONTH(InvoiceDate) = MONTH(GETDATE()) AND YEAR(InvoiceDate) = YEAR(GETDATE())
			--			ORDER BY InvoiceNo DESC)
			--BEGIN

			--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(InvoiceNo),4))
			--	FROM CM_T_PurchaseInvoiceH 
			--	WHERE LEFT(InvoiceNo,3) = 'RNP'
			--		AND MONTH(InvoiceDate) = MONTH(GETDATE())
			--		AND YEAR(InvoiceDate) = YEAR(GETDATE())
			--	ORDER BY InvoiceNo DESC
			--END			
		
			---- ===============================
			---- Set ID 
			---- RNP : Receiving Non PO
			---- ===============================

			--SET @InvoiceNo = 'PINV-' + RIGHT('00' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2)
			--	+ RIGHT(CONVERT(VARCHAR,YEAR(GETDATE())),2) + '-' 
			--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

			--PRINT CONVERT(VARCHAR,@InvoiceNo)			

			INSERT INTO [dbo].[CM_T_PurchaseInvoiceHeader]
			   ([IDX_M_Company]
			   ,[IDX_M_Branch]
			   ,[IDX_M_Currency]
			   ,[IDX_M_LocationInventory]
			   ,[IDX_M_Partner]
			   ,[IDX_M_DocumentType]
			   ,[IDX_ReferenceNo]
			   ,[ReferenceNo]
			   ,[InvoiceNo]
			   ,[InvoiceDate]
			   ,[InvoiceDueDate]
			   ,[SupplierDeliveryNo]
			   ,[RemarkHeader]
			   ,[InvoiceStatus]			   
			   ,[COAHeader]
			   ,[VendorInvoiceNo]
			   ,[FakturPajak]
			   ,[IsTaxChecked]
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			VALUES
			   (@IDX_M_Company
			   ,@IDX_M_Branch
			   ,@IDX_M_Currency
			   ,@IDX_M_LocationInventory
			   ,@IDX_M_Partner
			   ,@IDX_M_DocumentType
			   ,@IDX_ReferenceNo
			   ,UPPER(@ReferenceNo)
			   ,@InvoiceNo
			   ,@InvoiceDate
			   ,@InvoiceDueDate
			   ,@SupplierDeliveryNo
			   ,@RemarkHeader
			   ,@InvoiceStatus
			   ,@COAHeader
			   ,@VendorInvoiceNo
			   ,@FakturPajak
			   ,@IsTaxChecked
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @IDX_T_PurchaseInvoiceHeader AS BIGINT
			SET @IDX_T_PurchaseInvoiceHeader = (SELECT SCOPE_IDENTITY())	
			
			/** Update Draft InvoiceNo **/
			UPDATE [dbo].[CM_T_PurchaseInvoiceHeader]
			SET InvoiceNo = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_PurchaseInvoiceHeader))
			WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

			IF EXISTS (SELECT IDX_T_PurchaseOrder FROM PR_T_PurchaseOrder WITH(NOLOCK) WHERE PONumber = RTRIM(LTRIM(@ReferenceNo)) AND POStatus <> 'D')
			BEGIN
				DECLARE @IDX_PO BIGINT
				SELECT @IDX_PO = IDX_T_PurchaseOrder FROM PR_T_PurchaseOrder WITH(NOLOCK) WHERE PONumber = RTRIM(LTRIM(@ReferenceNo)) AND POStatus <> 'D'
				
				UPDATE CM_T_PurchaseInvoiceHeader 
				SET IDX_ReferenceNo = @IDX_PO
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



