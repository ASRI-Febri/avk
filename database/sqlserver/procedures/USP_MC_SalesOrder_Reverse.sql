
/* 
	BEGIN TRAN
	EXEC [dbo].[USP_MC_SalesOrder_Reverse] 2,'2025-06-16','stok awal','it_febry'
	ROLLBACK TRAN
*/


CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_Reverse] 
	@IDX_T_SalesOrder					BIGINT,
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

			SELECT @_CountDetail = COUNT(IDX_T_SalesOrderDetail) 
			FROM MC_T_SalesOrderDetail
			WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current order status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_SalesOrder 
						FROM MC_T_SalesOrder 
						WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND SOStatus = 'D')
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'This order already draft!')
			END		

			-- =======================================
			-- Validate approval date and order date
			-- =======================================
			--IF EXISTS(	SELECT IDX_T_SalesOrder 
			--			FROM MC_T_SalesOrder 
			--			WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND SODate > @ApprovalDate)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'Approval Date must be greater than Order Date!')
			--END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_SONumber 		VARCHAR(30)

				SELECT @_SONumber = SONumber FROM MC_T_SalesOrder WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder	

				-- ====================================================================================
				-- UPDATE PO		
				-- ====================================================================================	
				UPDATE MC_T_SalesOrder SET SOStatus = 'D', 
					SOApprovalDate = NULL, 
					SOApprovalBy = '', 
					SOApprovalNotes = '', 
					DModified = GETDATE(), 
					UModified = @UserID 
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder				

				-- ====================================================================================
				-- DELETE STOCK CARD		
				-- ====================================================================================	
				DELETE FROM [dbo].[MC_T_StockCardValas]
				WHERE IDX_Transaction = @IDX_T_SalesOrder AND RTRIM(TransactionNo) = RTRIM(@_SONumber) AND IDX_M_TransactionType = 2
				  
				

				-- ========================================================
				-- DELETE JOURNAL
				-- ========================================================
				DECLARE @_IDX_T_JournalHeader 			AS BIGINT

				SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader 
				FROM GL_T_JournalHeader
				WHERE IDX_M_JournalType = 5 AND IDX_ReferenceNo = @IDX_T_SalesOrder AND ReferenceNo = RTRIM(@_SONumber)

				DELETE FROM [dbo].[GL_T_JournalDetail] 
				WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader

				DELETE FROM [dbo].[GL_T_JournalHeader] 
				WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader				

				-- ====================================================================================
				-- OUTPUT		
				-- ====================================================================================		
				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesOrder, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrder, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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




