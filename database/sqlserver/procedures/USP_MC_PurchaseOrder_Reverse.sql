
/* 
	BEGIN TRAN
	EXEC [dbo].[USP_MC_PurchaseOrder_Reverse] 2,'2025-06-16','stok awal','it_febry'
	ROLLBACK TRAN
*/


CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrder_Reverse] 
	@IDX_T_PurchaseOrder				BIGINT,
	@ApprovalDate						DATE,
	@ApprovalRemark						VARCHAR(500),
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
			--DECLARE @_FormID AS VARCHAR(20)
			--SET @_FormID = 'CM-PINV-005' -- Approval Receiving Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			PRINT 'Before Validation'

			SELECT @_CountDetail = COUNT(IDX_T_PurchaseOrderDetail) 
			FROM MC_T_PurchaseOrderDetail
			WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrder,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current order status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseOrder 
						FROM MC_T_PurchaseOrder 
						WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder AND POStatus = 'D')
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrder,'This order already draft!')
			END		

			-- =======================================
			-- Validate approval date and order date
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseOrder 
						FROM MC_T_PurchaseOrder 
						WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder AND PODate > @ApprovalDate)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrder,'Approval Date must be greater than Order Date!')
			END

			-- =======================================
			-- Check pembayaran
			-- Nota tidak bisa direverse jika sudah ada pembayaran
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseOrder 
						FROM MC_T_PurchaseOrder POH
						LEFT JOIN CM_T_FinancialPaymentDetail 
							ON CM_T_FinancialPaymentDetail.IDX_DocumentNo = POH.IDX_T_PurchaseOrder						
							AND CM_T_FinancialPaymentDetail.IDX_M_DocumentType = POH.IDX_M_DocumentType
						INNER JOIN CM_T_FinancialPaymentHeader 
							ON CM_T_FinancialPaymentHeader.IDX_T_FinancialPaymentHeader = CM_T_FinancialPaymentDetail.IDX_T_FinancialPaymentHeader
						WHERE POH.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder AND CM_T_FinancialPaymentHeader.PaymentStatus = 'A')
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrder,'TIdak bisa direverse, karena sudah ada pembayaran!')
			END	

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_PONumber 		VARCHAR(30)

				SELECT @_PONumber = PONumber FROM MC_T_PurchaseOrder WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder	

				-- ====================================================================================
				-- UPDATE PO		
				-- ====================================================================================	
				UPDATE MC_T_PurchaseOrder SET POStatus = 'D', 
					POApprovalDate = NULL, 
					POApprovalBy = '', 
					POApprovalNotes = '', 
					DModified = GETDATE(), 
					UModified = @UserID 
				WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder				

				-- ====================================================================================
				-- DELETE STOCK CARD		
				-- ====================================================================================	
				DELETE FROM [dbo].[MC_T_StockCardValas]
				WHERE IDX_Transaction = @IDX_T_PurchaseOrder AND RTRIM(TransactionNo) = RTRIM(@_PONumber) AND IDX_M_TransactionType = 3
				  
				

				-- ========================================================
				-- DELETE JOURNAL
				-- ========================================================
				DECLARE @_IDX_T_JournalHeader 			AS BIGINT

				SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader 
				FROM GL_T_JournalHeader
				WHERE IDX_M_JournalType = 2 AND IDX_ReferenceNo = @IDX_T_PurchaseOrder AND ReferenceNo = RTRIM(@_PONumber)

				DELETE FROM [dbo].[GL_T_JournalDetail] 
				WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader

				DELETE FROM [dbo].[GL_T_JournalHeader] 
				WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader				

				-- ====================================================================================
				-- OUTPUT		
				-- ====================================================================================		
				INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseOrder, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

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




