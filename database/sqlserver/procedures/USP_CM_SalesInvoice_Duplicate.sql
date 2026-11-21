-- ==========================================================================================
-- Author		: Anton
-- Create date	: 2024-05-10
-- Description	: Duplicate Sales Invoice Transaction (header,detail,tax)
-- Modified		: 2024-08-16 by Anton --> Adjust logic duplicate
-- ==========================================================================================

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Duplicate]
	@IDX_T_SalesInvoiceHeader		BIGINT,	
	@UserID							VARCHAR(50)	
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
			DECLARE @UploadID VARCHAR(50) = (SELECT ReferenceNo FROM CM_T_SalesInvoiceHeader WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)

			IF EXISTS (	SELECT 1 FROM X_MemberSummary_Quality WITH(NOLOCK) WHERE UploadID = @UploadID)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Duplicate Member Transaction From Uploaded Source Data!')
			END

			IF EXISTS (	SELECT 1 FROM X_SalesSummary_Quality WITH(NOLOCK) WHERE UploadID = @UploadID)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Not Allow Duplicate Sales Transaction From Uploaded Source Data!')
			END

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
				INSERT INTO [dbo].[CM_T_SalesInvoiceHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Currency]
				   ,[IDX_M_LocationInventory]
				   ,[IDX_M_Partner]
				   ,[IDX_M_DocumentType]
				   ,[IDX_ReferenceNo]
				   ,[IDX_M_SalesPerson]
				   ,[ReferenceNo]
				   ,[TaxInvoiceNo]
				   ,[ERPNo]
				   ,[InvoiceNo]
				   ,[InvoiceDate]
				   ,[InvoiceDueDate]
				   ,[DeliveryNo]
				   ,[RemarkHeader]
				   ,[InvoiceStatus]
				   ,[ApprovedDate]
				   ,[ApproveBy]
				   ,[ApproveRemark]
				   ,[VoidDate]
				   ,[VoidBy]
				   ,[VoidReason]
				   ,[IsProforma]
				   ,[IsCreateJournal]
				   ,[COAHeader]
				   ,[AccrueType]
				   ,[StampDuty]
				   ,[TotalSalesAmount]
				   ,[TotalDiscountAmount]
				   ,[TotalUntaxedAmount]
				   ,[TotalTaxedAmount]
				   ,[UCreate]
				   ,[DCreate]
				   ,[UModified]
				   ,[DModified]
				   ,[RecordStatus])
				SELECT 
					[IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Currency]
				   ,[IDX_M_LocationInventory]
				   ,[IDX_M_Partner]
				   ,[IDX_M_DocumentType]
				   ,[IDX_ReferenceNo]
				   ,[IDX_M_SalesPerson]
				   ,[ReferenceNo]
				   ,[TaxInvoiceNo]
				   ,[ERPNo]
				   ,NULL
				   ,GETDATE()
				   ,GETDATE()
				   ,[DeliveryNo]
				   ,[RemarkHeader]
				   ,'D'
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,[IsProforma]
				   ,[IsCreateJournal]
				   ,[COAHeader]
				   ,[AccrueType]
				   ,[StampDuty]
				   ,[TotalSalesAmount]
				   ,[TotalDiscountAmount]
				   ,[TotalUntaxedAmount]
				   ,[TotalTaxedAmount]
				   ,@UserID
				   ,SYSDATETIME()
				   ,NULL
				   ,NULL
				   ,[RecordStatus]
				FROM CM_T_SalesInvoiceHeader WITH(NOLOCK)
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader
			
				DECLARE @_IDX_T_SalesInvoiceHeader AS BIGINT
				SET @_IDX_T_SalesInvoiceHeader = (SELECT SCOPE_IDENTITY())	
			
				-- UPDATE DRAFT VOUCHER NO
				UPDATE [dbo].CM_T_SalesInvoiceHeader
				SET InvoiceNo = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@_IDX_T_SalesInvoiceHeader))
				WHERE IDX_T_SalesInvoiceHeader = @_IDX_T_SalesInvoiceHeader

				DECLARE @_VoucherNo VARCHAR(10) = (SELECT InvoiceNo FROM CM_T_SalesInvoiceHeader WHERE IDX_T_SalesInvoiceHeader = @_IDX_T_SalesInvoiceHeader)

				-- =======================================================================================
				-- INSERT TABLE DETAIL
				-- =======================================================================================
				CREATE TABLE #TAMPUNG (IDXDetailNew BIGINT, IDXDetailPrev BIGINT, ExistsTax BIT)

				INSERT INTO [dbo].[CM_T_SalesInvoiceDetail]
				   ([IDX_T_SalesInvoiceHeader]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_Item]
				   ,[IDX_M_UoM]
				   ,[IDX_M_COA]
				   ,[IDX_M_Tax]
				   ,[IncludeTax]
				   ,[ItemDesc]
				   ,[Quantity]
				   ,[UnitPrice]
				   ,[UntaxedAmount]
				   ,[DiscountAmount]
				   ,[TaxAmount]
				   ,[RemarkDetail]
				   ,[IDX_Prev_T_SalesInvoiceDetail]
				   ,[UCreate]
				   ,[DCreate]
				   ,[UModified]
				   ,[DModified]
				   ,[RecordStatus])
				OUTPUT INSERTED.IDX_T_SalesInvoiceDetail,INSERTED.IDX_Prev_T_SalesInvoiceDetail,0  INTO #TAMPUNG(IDXDetailNew, IDXDetailPrev, ExistsTax)
				SELECT 
					@_IDX_T_SalesInvoiceHeader
				   ,[IDX_M_Branch]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_Item]
				   ,[IDX_M_UoM]
				   ,[IDX_M_COA]
				   ,[IDX_M_Tax]
				   ,[IncludeTax]
				   ,[ItemDesc]
				   ,[Quantity]
				   ,[UnitPrice]
				   ,[UntaxedAmount]
				   ,[DiscountAmount]
				   ,[TaxAmount]
				   ,[RemarkDetail]
				   ,[IDX_T_SalesInvoiceDetail]
				   ,@UserID
				   ,SYSDATETIME()
				   ,NULL
				   ,NULL
				   ,[RecordStatus]
				FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				-- =======================================================================================
				-- INSERT TABLE TAX
				-- =======================================================================================
				IF EXISTS (SELECT 1 FROM CM_T_SalesInvoiceTax WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)
				BEGIN
					UPDATE B SET ExistsTax = 1
					FROM CM_T_SalesInvoiceTax A WITH(NOLOCK)
						INNER JOIN #TAMPUNG B WITH(NOLOCK) ON A.IDX_T_SalesInvoiceDetail = B.IDXDetailPrev
					WHERE A.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

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
					   ,[UModified]
					   ,[DModified]
					   ,[RecordStatus])
					SELECT 
						 @_IDX_T_SalesInvoiceHeader
						,B.IDXDetailNew
						--,B.IDX_T_SalesInvoiceDetail
						,A.IDX_M_Tax
						,A.TaxID
						,A.TaxDesc
						,A.TaxRate
						,A.TaxAmount
						,A.TaxCOA
						,A.AllowEdit
						,@UserID
						,SYSDATETIME()
						,NULL
						,NULL
						,A.RecordStatus
					FROM CM_T_SalesInvoiceTax A WITH(NOLOCK)
						INNER JOIN #TAMPUNG B WITH(NOLOCK) ON A.IDX_T_SalesInvoiceDetail = B.IDXDetailPrev
						--INNER JOIN CM_T_SalesInvoiceDetail B WITH(NOLOCK) ON A.IDX_T_SalesInvoiceDetail = B.IDX_Prev_T_SalesInvoiceDetail
					WHERE A.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND B.ExistsTax = 1
				END

				-- =======================================================================================
				-- OUTPUT
				-- =======================================================================================

				INSERT INTO @TableLog VALUES ('success', @_IDX_T_SalesInvoiceHeader, 'Data Berhasil Duplikat ke ' + @_VoucherNo)
					
			END			

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog		

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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




