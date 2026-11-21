
/* 
	BEGIN TRAN
	EXEC [dbo].[USP_MC_PurchaseOrder_Approve 2,'2025-06-16','stok awal','it_febry'
	ROLLBACK TRAN
*/


CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrder_Approve] 
	@IDX_T_PurchaseOrder				BIGINT,
	@ApprovalDate						VARCHAR(10),
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
						WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder AND POStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseOrder,'This order already approved!')
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

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				PRINT 'After validation'

				DECLARE @_IDX_M_Partner		BIGINT
				-- ==========================
				-- Generate Order No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_PONumber				AS VARCHAR(20)
				DECLARE @_PODate				AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_BranchID				AS VARCHAR(3)
				DECLARE @_IDX_M_Branch			AS INT

				SET @_LastNumber = 0


				-- ==========================================
				-- Get Data From Purchase Order Header
				-- ==========================================

				SELECT @_PODate = PODate, @_IDX_M_Partner = IDX_M_Partner, 
					@_IDX_M_DocumentType = IDX_M_DocumentType,  
					@_BranchID = IDX_M_Branch, @_IDX_M_Branch = IDX_M_Branch
				FROM MC_T_PurchaseOrder 
				WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) 
				FROM GN_M_DocumentType 
				WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				SELECT @_BranchID = RTRIM(BranchID) 
				FROM GN_M_Branch 
				WHERE IDX_M_Branch = @_BranchID

				
				SELECT @_LastNumber= ISNULL(MAX( CONVERT(INT,RIGHT(RTRIM(PONumber),4))),0)
				FROM MC_T_PurchaseOrder 
				WHERE IDX_M_Branch = @_IDX_M_Branch --AND MONTH(POApproveDate) = MONTH(@ApprovalDate)
				AND YEAR(PODate) = YEAR(@ApprovalDate) AND PONumber NOT LIKE 'DRAFT-%' --AND POStatus IN ('D','A','F','C')
				--END

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ApprovalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)
				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ApprovalDate)),2)

				/** Set Purchase Order No **/
				SET @_PONumber = RTRIM(@_DocumentTypeID) + '-' 
					+ @_BranchID + '-' 
					+ @_Year
					+ @_Month + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				IF (SELECT PONumber FROM MC_T_PurchaseOrder WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder) LIKE 'DRAFT%'
				BEGIN
					UPDATE MC_T_PurchaseOrder 
					SET PONumber = @_PONumber,
						POStatus = 'A', 
						POApprovalDate = @ApprovalDate, 
						POApprovalBy = @UserID, 
						POApprovalNotes = @ApprovalRemark, 
						DModified = GETDATE(), 
						UModified = @UserID 
					WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder
				END
				ELSE
				BEGIN
					UPDATE MC_T_PurchaseOrder 
					SET POStatus = 'A', 
						POApprovalDate = @ApprovalDate, 
						POApprovalBy = @UserID, 
						POApprovalNotes = @ApprovalRemark, 
						DModified = GETDATE(), 
						UModified = @UserID 
					WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder
				END

				-- ====================================================================================
				-- INSERT STOCK CARD		
				-- ====================================================================================	
				INSERT INTO [dbo].[MC_T_StockCardValas]
				   ([IDX_M_Branch]
				   ,[IDX_M_Valas]
				   ,[IDX_M_TransactionType]
				   ,[IDX_Transaction]
				   ,[TransactionNo]
				   ,[TransactionDate]
				   -----------------------------------------------------------------------
				   ,[StockInQty]
				   ,[ExchangeRateIn]
				   ,[StockInForeignAmount]
				   ,[StockInBaseAmount]
				   -----------------------------------------------------------------------
				   ,[StockOutQty]
				   ,[ExchangeRateOut]
				   ,[StockOutForeignAmount]
				   ,[StockOutBaseAmount]
				   -----------------------------------------------------------------------
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus])
				SELECT POH.IDX_M_Branch, POD.IDX_M_Valas, 3, POH.IDX_T_PurchaseOrder, POH.PONumber, POH.PODate,
					POD.Quantity, POD.ExchangeRate, (POD.Quantity * MVC.ValasChangeNumber), 
					(POD.Quantity * MVC.ValasChangeNumber * POD.ExchangeRate), 
					-----------------------------------------------------------------------
					0, 0, 0, 0, 
					-----------------------------------------------------------------------
					@UserID, GETDATE(), 'A' 
				FROM MC_T_PurchaseOrderDetail POD
				INNER JOIN MC_T_PurchaseOrder POH ON POH.IDX_T_PurchaseOrder = POD.IDX_T_PurchaseOrder
				INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = POD.IDX_M_Valas
				INNER JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange 
				WHERE POH.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

				-- ========================================================
				-- GENERATE JOURNAL
				-- ========================================================
				DECLARE @_JournalResult		SMALLINT

				EXEC USP_MC_PurchaseJournal_Create @IDX_T_PurchaseOrder, @UserID, @_JournalResult OUTPUT

				IF @_JournalResult <> 1
				BEGIN
					INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseOrder, 'Create journal failed!')
				END

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




