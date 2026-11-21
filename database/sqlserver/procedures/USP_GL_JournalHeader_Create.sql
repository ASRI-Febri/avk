-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Create Table Journal Header
-- =============================================

/*	
	BEGIN TRAN
		EXEC [dbo].[USP_GL_JournalHeader_Create] 1,1,2,0,2,'','2017-01-06','SJ-001','Test','D','admin','A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalHeader_Create] 	
	@IDX_M_Company				BIGINT,
	@IDX_M_Branch				BIGINT,	
	@IDX_M_JournalType			BIGINT,
	@IDX_M_Partner				BIGINT,
	@ApplicationID				BIGINT,
	@IDX_ReferenceNo			BIGINT,
	@ReferenceNo				VARCHAR(50),
	@VoucherNo					VARCHAR(50),
	@JournalDate				DATETIME,
	@RemarkHeader				VARCHAR(5000),
	@PartnerDesc				VARCHAR(50),
	@PostingStatus				CHAR(1),
	--@PostingDate				DATETIME NULL,	
	--@PostedBy					VARCHAR(50),
	@DebetAmount				DECIMAL(24,4),
	@CreditAmount				DECIMAL(24,4),
	@JournalSource				CHAR(1),
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
		--SET @_FormID = 'GL-JOUR-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		--------------------------------------------------------------------------------------
		IF (ISNULL(@IDX_M_Partner,0)) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please Select Business Partner!')
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

			IF @IDX_M_Company = 0
			BEGIN
				SELECT @IDX_M_Company = IDX_M_Company FROM GN_M_Branch WHERE IDX_M_Branch = @IDX_M_Branch
			END

			INSERT INTO [dbo].[GL_T_JournalHeader]
				([IDX_M_Company]
				,[IDX_M_Branch]				
				,[IDX_M_JournalType]
				,[IDX_M_Partner]				
				,[ApplicationID]
				,[IDX_ReferenceNo]
				,[ReferenceNo]
				,[VoucherNo]
				,[JournalDate]				
				,[RemarkHeader]
				,[PartnerDesc]
				,[PostingStatus]
				--,[PostingDate]
				--,[PostedBy]
				,[DebetAmount]
				,[CreditAmount]
				,[JournalSource]
				,[UCreate]
				,[DCreate]			  
				,[RecordStatus])
			 VALUES
			   (@IDX_M_Company
			   ,@IDX_M_Branch			   
			   ,@IDX_M_JournalType
			   ,@IDX_M_Partner
			   ,@ApplicationID
			   ,@IDX_ReferenceNo
			   ,@ReferenceNo
			   ,@VoucherNo
			   ,@JournalDate
			   ,@RemarkHeader
			   ,@PartnerDesc
			   ,@PostingStatus			   
			   --,@PostingDate
			   --,@PostedBy
			   ,@DebetAmount
			   ,@CreditAmount
			   ,@JournalSource
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @_IDX_T_JournalHeader AS BIGINT
			SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())	
			
			/** Update Draft InvoiceNo **/
			UPDATE [dbo].[GL_T_JournalHeader]
			SET VoucherNo = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@_IDX_T_JournalHeader))
			WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader			

			INSERT INTO @TableLog VALUES ('success', @_IDX_T_JournalHeader, 'Data Sudah Disimpan')
				
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



