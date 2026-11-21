-- ==========================================================================================
-- Author		: Anton
-- Create date	: 2024-05-15
-- Description	: Duplicate Financial Receive Transaction (header & detail)
-- ==========================================================================================

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_Duplicate]
	@IDX_T_FinancialReceiveHeader		BIGINT,	
	@UserID								VARCHAR(50)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail AS INT
			DECLARE @_CountLog AS INT
			DECLARE @_Discount AS DECIMAL(22,2)
			DECLARE @_Commission AS DECIMAL(22,2)

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID		VARCHAR(20)
			--DECLARE @_RoleID		CHAR(1)
			--DECLARE @Output			INT

			--SET @_FormID = 'GL-JOUR-006' -- Journal Posting
			--SET @_RoleID = 'R'
			
			--EXEC USP_SM_CheckUserForm @UserID, @_FormID, @_RoleID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

				

			-- ===========================================================================================================
			-- Check Journal Type
			-- ===========================================================================================================
			--DECLARE @UploadID VARCHAR(50) = (SELECT ReferenceNo FROM CM_T_SalesInvoiceHeader WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)

			--IF EXISTS (	SELECT 1 FROM X_MemberSummary_Quality WITH(NOLOCK) WHERE UploadID = @UploadID)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Duplicate Member Transaction From Uploaded Source Data!')
			--END

			--IF EXISTS (	SELECT 1 FROM X_SalesSummary_Quality WITH(NOLOCK) WHERE UploadID = @UploadID)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Duplicate Sales Transaction From Uploaded Source Data!')
			--END

			-- ===========================================================================================================
			--Check Error Log
			-- ===========================================================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			-- ===========================================================================================================
			-- If no error, then post journal
			-- ===========================================================================================================
			IF @_CountLog = 0
			BEGIN 
				
				-- =======================================================================================
				-- INSERT TABLE HEADER
				-- =======================================================================================
				INSERT INTO [dbo].[CM_T_FinancialReceiveHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_DocumentType]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]
				   ,[IDX_M_PaymentType]
				   ,[COAHeader]
				   ,[ReceiveID]
				   ,[ReceiveDate]
				   ,[RemarkHeader]
				   ,[ReceiveStatus]
				   ,[TenderedAmount]
				   ,[ReceiveAmount]
				   ,[ApprovedBy]
				   ,[ApprovalDate]
				   ,[ApprovalRemark]
				   ,[ValidateBy]
				   ,[ValidationDate]
				   ,[VoidBy]
				   ,[VoidDate]
				   ,[VoidReason]
				   ,[CardNumber]
				   ,[CardHolderName]
				   ,[VoucherNoManual]
				   ,[PDCNo]
				   ,[UCreate]
				   ,[DCreate]
				   ,[UModified]
				   ,[DModified]
				   ,[RecordStatus])
				SELECT 
					[IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_DocumentType]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]
				   ,[IDX_M_PaymentType]
				   ,[COAHeader]
				   ,NULL
				   ,GETDATE()
				   ,[RemarkHeader]
				   ,'D'
				   ,NULL
				   ,[ReceiveAmount]
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@UserID
				   ,SYSDATETIME()
				   ,NULL
				   ,NULL
				   ,[RecordStatus]
				FROM CM_T_FinancialReceiveHeader WITH(NOLOCK)
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
			
				DECLARE @_IDX_T_FinancialReceiveHeader AS BIGINT
				SET @_IDX_T_FinancialReceiveHeader = (SELECT SCOPE_IDENTITY())	
			
				-- UPDATE DRAFT VOUCHER NO
				UPDATE [dbo].CM_T_FinancialReceiveHeader
				SET ReceiveID = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@_IDX_T_FinancialReceiveHeader))
				WHERE IDX_T_FinancialReceiveHeader = @_IDX_T_FinancialReceiveHeader

				DECLARE @_VoucherNo VARCHAR(10) = (SELECT ReceiveID FROM CM_T_FinancialReceiveHeader WHERE IDX_T_FinancialReceiveHeader = @_IDX_T_FinancialReceiveHeader)

				-- =======================================================================================
				-- INSERT TABLE DETAIL
				-- =======================================================================================
				INSERT INTO [dbo].[CM_T_FinancialReceiveDetail]
				   ([IDX_T_FinancialReceiveHeader]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_DocumentType]
				   ,[IDX_DocumentNo]
				   ,[DocumentNo]
				   ,[COADetail]
				   ,[ReceiveAmount]
				   ,[RemarkDetail]
				   ,[UCreate]
				   ,[DCreate]
				   ,[UModified]
				   ,[DModified]
				   ,[RecordStatus])
				SELECT 
					@_IDX_T_FinancialReceiveHeader
				   ,[IDX_M_Branch]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_DocumentType]
				   ,0
				   ,NULL
				   ,[COADetail]
				   ,[ReceiveAmount]
				   ,[RemarkDetail]
				   ,@UserID
				   ,SYSDATETIME()
				   ,NULL
				   ,NULL
				   ,[RecordStatus]
				FROM CM_T_FinancialReceiveDetail WITH(NOLOCK)
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				-- =======================================================================================
				-- OUTPUT
				-- =======================================================================================

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_FinancialReceiveHeader, 'Data Berhasil Duplikat ke ' + @_VoucherNo)
					
			END			

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog		

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog

		--SELECT 	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
			
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




