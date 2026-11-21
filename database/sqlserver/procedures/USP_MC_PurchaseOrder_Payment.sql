
CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrder_Payment] 
	@IDX_T_PurchaseOrder				BIGINT,	
	@IDX_M_FinancialAccount				BIGINT,	
	@PaymentAmount						DECIMAL(22,2),
	@RemarkHeader						VARCHAR(500),
	@PaymentDate						DATE,
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail AS INT
			DECLARE @_CountLog AS INT

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/			
			-- DECLARE @_FormID AS VARCHAR(20)
			-- SET @_FormID = 'SL-SAOD-008' -- Approval Contract

			-- DECLARE @Output INT
			-- EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			-- IF @Output <> 1
			-- BEGIN
			-- 	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			-- END
			
			/****************************/

			-- ================================================================================
			-- Pembayaran hanya boleh untuk Nota pembelian yang sudah Approved.
			-- Kalau masih Draft, nomornya masih DRAFT-xxxx dan akan berubah saat approval,
			-- sehingga DocumentNo yang tersimpan di detail pembayaran jadi basi dan
			-- pembayaran itu tidak terhubung lagi ke notanya (mis. di laporan AR/AP).
			-- ================================================================================
			DECLARE @_StatusTransaksi AS CHAR(1)
			DECLARE @_NomorTransaksi AS VARCHAR(50)

			SELECT @_StatusTransaksi = POStatus, @_NomorTransaksi = RTRIM(PONumber)
			FROM MC_T_PurchaseOrder WITH(NOLOCK)
			WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

			IF @_StatusTransaksi IS NULL
			BEGIN
				INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrder, 'Nota pembelian tidak ditemukan!')
			END
			ELSE IF @_StatusTransaksi <> 'A'
			BEGIN
				INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrder,
					'Nota pembelian ' + ISNULL(@_NomorTransaksi,'') + ' belum di-approve. Pembayaran hanya bisa diinput untuk nota yang sudah Approved.')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 

				/** Insert Financial Payment Header **/

				DECLARE @_IDX_M_Company 				BIGINT
				DECLARE @_IDX_M_Branch 					BIGINT	
				DECLARE @_BranchID 						VARCHAR(20)
				DECLARE @_PurchaseOrderNo 				VARCHAR(50)			
				DECLARE @_IDX_M_Partner 				BIGINT
				DECLARE @_IDX_M_Currency 				BIGINT				
				DECLARE @_IDX_M_DocumentType 			BIGINT = 4 -- FINANCIAL PAYMENT
				DECLARE @_PaymentID 					VARCHAR(50)
				DECLARE @_NotaManual 					VARCHAR(50)

				--DECLARE @PaymentDate DATETIME				
				DECLARE @_PaymentStatus 				CHAR(1)				
				DECLARE @_RecordStatus 					CHAR(1)
				DECLARE @_PurchaseOrderStatus 			CHAR(1)
				DECLARE @_PurchaseOrderDate				DATE
				DECLARE @_SalesDocumentType 			INT

				DECLARE @_IDX_T_FinancialPaymentHeader 	BIGINT
				DECLARE @_IDX_DocumentNo 				BIGINT
				DECLARE @_COADetail 					BIGINT = 102 -- REKENING ANTARA				
				DECLARE @_RemarkDetail 					VARCHAR(500)
				DECLARE @_IsUnidentified 				CHAR(1)

				-- TODO: Set parameter values here.
				-- Document Type 305 : Payment Sales Order Payment

				SELECT @_IDX_M_Company = IDX_M_Company, @_IDX_M_Branch = IDX_M_Branch, 
					@_PurchaseOrderNo = PONumber, @_IDX_M_Partner = IDX_M_Partner,
					@_IDX_M_Currency = 1, @_PurchaseOrderDate = PODate, 
					@_SalesDocumentType = IDX_M_DocumentType, @_PurchaseOrderStatus = POStatus,
					@_NotaManual = ReferenceNo
				FROM MC_T_PurchaseOrder 
				WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

				--SET @PaymentDate = GETDATE()
				SET @_RecordStatus = 'A'				
				SET @_PaymentStatus = 'A'

				-- Nota Draft sudah ditolak di awal SP, jadi pembayaran selalu dibuat
				-- untuk nota yang sudah Approved.
				IF @_PurchaseOrderStatus <> 'A'
					SET @_PaymentStatus = 'D'

				/**********************************************************************************************************/
				
				DECLARE @_LastNumber AS INTEGER
				DECLARE @_Month AS VARCHAR(4)
				DECLARE @_Year AS VARCHAR(2)
				DECLARE @_DocumentTypeID AS CHAR(3)				
		
				SET @_LastNumber = 0

				SELECT @_DocumentTypeID = DocumentTypeID 
				FROM GN_M_DocumentType 
				WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				SELECT @_BranchID = RTRIM(CONVERT(VARCHAR,@_IDX_M_Branch)) 
				FROM GN_M_Branch 
				WHERE IDX_M_Branch = @_IDX_M_Branch

				IF RTRIM(@RemarkHeader) = ''
					SET @RemarkHeader = 'Pembayaran pembelian valas'

				--IF EXISTS(	SELECT TOP 1 ReceiveID
				--			FROM CM_T_FinancialPaymentH 
				--			WHERE MONTH(ReceiveDate) = MONTH(@PurchaseOrderDate)
				--				AND YEAR(ReceiveDate) = YEAR(@PurchaseOrderDate)
				--				AND LEFT(ReceiveID,3) = LEFT(RTRIM(@_DocumentTypeID),3)
				--			ORDER BY ReceiveID DESC)
				--BEGIN
				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
				--	FROM CM_T_FinancialPaymentH 
				--	WHERE MONTH(ReceiveDate) = MONTH(@PurchaseOrderDate)
				--		AND YEAR(ReceiveDate) = YEAR(@PurchaseOrderDate)
				--		AND LEFT(ReceiveID,3) = LEFT(RTRIM(@_DocumentTypeID),3)
				--	ORDER BY ReceiveID DESC
				--END			

				

				--SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@PurchaseOrderDate))
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@PurchaseOrderDate)),2)

				--/** Set Contract No by System **/
				--SET @_ReceiveID = RTRIM(@_DocumentTypeID) 
				--	+ @_BranchID + '-' 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)				

				INSERT INTO [dbo].[CM_T_FinancialPaymentHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]
				   ,[IDX_M_PaymentType]
				   ,[IDX_M_DocumentType]
				   ,[PaymentID]
				   ,[PaymentDate]
				   ,[RemarkHeader]
				   ,[PaymentStatus]
				   ,[PaymentAmount]	
				   ,[ApprovalDate]
				   ,[ApprovedBy]			  
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
			 VALUES
				   (@_IDX_M_Company
				   ,@_IDX_M_Branch
				   ,@IDX_M_FinancialAccount
				   ,@_IDX_M_Partner
				   ,@_IDX_M_Currency
				   ,0
				   ,@_IDX_M_DocumentType
				   ,@_PaymentID
				   ,@PaymentDate
				   ,@RemarkHeader
				   ,@_PaymentStatus	
				   ,@PaymentAmount	
				   ,@PaymentDate
				   ,@UserID		   
				   ,@UserID
				   ,GETDATE()				  
				   ,@_RecordStatus)

				SET @_IDX_T_FinancialPaymentHeader = (SELECT SCOPE_IDENTITY())

				-- =====================================================================
				-- UPDATE Payment ID
				-- =====================================================================
				SET @_PaymentID = RTRIM(@_DocumentTypeID) + @_BranchID + '-' + CONVERT(VARCHAR, @_IDX_T_FinancialPaymentHeader)	
				
				UPDATE CM_T_FinancialPaymentHeader SET PaymentID = @_PaymentID
				WHERE IDX_T_FinancialPaymentHeader = @_IDX_T_FinancialPaymentHeader

				-- ====================================================================
				-- Insert Financial Payment Detail 
				-- ====================================================================		
								
				SET @_RemarkDetail = 'Pembayaran ' + @_PurchaseOrderNo + ' / ' + @_NotaManual			
				SET @_IDX_DocumentNo = @IDX_T_PurchaseOrder				
				SET @_IsUnidentified = 'N'		

				INSERT INTO [dbo].[CM_T_FinancialPaymentDetail]
					   ([IDX_T_FinancialPaymentHeader]
					   ,[IDX_M_DocumentType]
					   ,[IDX_DocumentNo]
					   ,[DocumentNo]
					   ,[COADetail]
					   ,[PaymentAmount]
					   ,[RemarkDetail]
					   ,[UCreate]
					   ,[DCreate]
					   ,[RecordStatus])
				 VALUES
					   (@_IDX_T_FinancialPaymentHeader
					   ,@_SalesDocumentType
					   ,@_IDX_DocumentNo
					   ,@_PurchaseOrderNo
					   ,@_COADetail
					   ,@PaymentAmount
					   ,@_RemarkDetail
					   ,@UserID
					   ,GETDATE()
					   ,@_RecordStatus)


				-- ========================================================
				-- GENERATE JOURNAL
				-- ========================================================
				IF @_PaymentStatus = 'A'
				BEGIN
					DECLARE @_JournalResult		SMALLINT

					EXEC USP_CM_FinancialPayment_CreateJournal @_IDX_T_FinancialPaymentHeader, @UserID, @_JournalResult OUTPUT

					IF @_JournalResult <> 1
					BEGIN
						INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrder, 'Create journal failed!')
					END
				END

				-- ========================================================
				-- OUTPUT
				-- ========================================================
				INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseOrder, 'Data Sudah Disimpan')

				COMMIT TRANSACTION;

			END
			ELSE
			BEGIN
				-- Tidak ada yang disimpan. Transaksi harus ditutup di sini, kalau tidak
				-- transaksi menggantung terbuka karena COMMIT-nya ada di dalam blok atas.
				ROLLBACK TRANSACTION;
			END

			SELECT * FROM @TableLog

			

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrder, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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
