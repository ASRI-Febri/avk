-- ==========================================================================================
-- Author			: Anton
-- Create date		: 8 July 2019
-- Description		: Rollback Validated Purchase Invoice Transaction
-- Mod				: 2020-10-02 by Anton --> Added Journal Closing Period Validation
--					  2024-01-08 by Anton --> Reverse retain current document number
-- ==========================================================================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_PurchaseInvoice_ReverseValidate] 23,'Testing reverse transaksi','XA.ADMIN'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_ReverseValidate] 
	@IDX_T_PurchaseInvoiceHeader		BIGINT,
	@ReverseRemark						VARCHAR(500),
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @GlobalDateTime		DATETIME = SYSDATETIME()
			DECLARE @_CountLog			INT

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)
			
			DECLARE @_ValidationDate DATE
			SELECT	@_ValidationDate = ApprovedDate FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@_ValidationDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Cannot Reverse Because Journal Period Already Closed!')
			END	

			IF EXISTS(
				SELECT	1 
				FROM CM_T_PaymentAllocation PA WITH(NOLOCK)
					INNER JOIN CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) ON PA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader AND PA.DocumentNo = PIH.InvoiceNo
				WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'This invoice already exist at Financial Payment Allocation. Please un-allocate first!')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @PurchaseInvoiceNo		VARCHAR(100)
				DECLARE @_IDX_T_JournalHeader	BIGINT

				-- ==========================================
				-- Get Data
				-- ==========================================

				SELECT @PurchaseInvoiceNo = InvoiceNo
				FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK)
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader
				FROM GL_T_JournalHeader WITH(NOLOCK)
				WHERE IDX_ReferenceNo = @IDX_T_PurchaseInvoiceHeader AND ReferenceNo = @PurchaseInvoiceNo

				UPDATE	PIH 
					SET --PIH.InvoiceNo		= 'DRAFT-' + CONVERT(VARCHAR,@IDX_T_PurchaseInvoiceHeader),
						PIH.InvoiceStatus	= 'D',
						PIH.IsTaxChecked	= 0,
						--PIH.ApprovedDate	= NULL, 
						PIH.ApproveBy		= NULL, 
						PIH.ApproveRemark	= NULL, 
						PIH.DModified		= @GlobalDateTime, 
						PIH.UModified		= @UserID 
				FROM	CM_T_PurchaseInvoiceHeader PIH WITH (NOLOCK)
				WHERE	PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				DELETE	JD
				FROM	GL_T_JournalDetail JD WITH (NOLOCK)
				WHERE	JD.IDX_T_JournalHeader = @_IDX_T_JournalHeader

				UPDATE	JH
					SET JH.RecordStatus		= 'I',
						JH.PostingStatus	= 'U',
						JH.DModified		= @GlobalDateTime,
						JH.UModified		= @UserID
				FROM	GL_T_JournalHeader JH WITH (NOLOCK)
				WHERE	JH.IDX_T_JournalHeader = @_IDX_T_JournalHeader

				--SELECT * FROM CM_T_PurchaseInvoiceHeader WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
				--SELECT * FROM GL_T_JournalHeader WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader

				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[GL_T_JournalHeaderLog]
					([IDX_T_JournalHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @_IDX_T_JournalHeader, 'Unposting', GETDATE(), @ReverseRemark, @UserID, GETDATE(), 'A'

				INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseInvoiceHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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

