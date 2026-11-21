-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Purchase Refund Header
-- =============================================

/*	
	BEGIN TRAN
		EXEC USP_CM_PurchaseRefundHeader_Create 1,1,1,1,9,7,0,'','','2018-10-02','2018-10-26','','',72,1406069,'A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefundHeader_Create] 	
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
	@UserID							VARCHAR(10),
	@RecordStatus					CHAR(1)	
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

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			--SELECT @_LocationID = RTRIM(LocationID) 
			--FROM IN_M_LocationInventory 
			--WHERE IDX_IN_M_LocationInventory = @IDX_IN_M_LocationInventory
		
			--SET @_LastNumber = 0		

			--IF EXISTS(	SELECT TOP 1 InvoiceNo
			--			FROM CM_T_PurchaseRefundH 
			--			WHERE IDX_IN_M_LocationInventory = @IDX_IN_M_LocationInventory
			--				AND MONTH(InvoiceDate) = MONTH(GETDATE()) AND YEAR(InvoiceDate) = YEAR(GETDATE())
			--			ORDER BY InvoiceNo DESC)
			--BEGIN

			--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(InvoiceNo),4))
			--	FROM CM_T_PurchaseRefundH 
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

			INSERT INTO [dbo].[CM_T_PurchaseRefundHeader]
			   ([IDX_T_PurchaseInvoiceHeader]
			   ,[IDX_M_Company]
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
			   ,[RemarkHeader]
			   ,[InvoiceStatus]			   
			   ,[COAHeader]			  
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			VALUES
			   (@IDX_T_PurchaseInvoiceHeader
			   ,@IDX_M_Company
			   ,@IDX_M_Branch
			   ,@IDX_M_Currency
			   ,@IDX_M_LocationInventory
			   ,@IDX_M_Partner
			   ,@IDX_M_DocumentType
			   ,@IDX_ReferenceNo
			   ,@ReferenceNo
			   ,@InvoiceNo
			   ,@InvoiceDate
			   ,@InvoiceDueDate			  
			   ,@RemarkHeader
			   ,@InvoiceStatus
			   ,@COAHeader			  
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @IDX_T_PurchaseRefundHeader AS BIGINT
			SET @IDX_T_PurchaseRefundHeader = (SELECT SCOPE_IDENTITY())	
			
			/** Update Draft InvoiceNo **/
			UPDATE [dbo].[CM_T_PurchaseRefundHeader]
			SET InvoiceNo = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_PurchaseRefundHeader))
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



