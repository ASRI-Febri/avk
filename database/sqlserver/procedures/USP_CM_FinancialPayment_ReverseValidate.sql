-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Payment
-- Mod			: 2020-10-02 by Anton --> Added Journal Closing Period Validation
-- ==========================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_ReverseApproval] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_ReverseValidate] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@ApproveRemark						VARCHAR(500),
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
			SELECT	@_ValidationDate = ValidationDate FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@_ValidationDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Cannot Reverse Because Journal Period Already Closed!')
			END	
			
			IF NOT EXISTS(
				SELECT	1 
				FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
				WHERE	FPH.RecordStatus='A'
				AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'This payment is still not validated!')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_IDX_M_Partner			BIGINT
				-- ==========================
				-- Generate Receive No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_PaymentID				AS VARCHAR(20)
				DECLARE @_PaymentDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(3)
				DECLARE @_VoucherNoManual		AS VARCHAR(64)
				DECLARE @_PDCNo					AS VARCHAR(64)
				DECLARE @_IDX_T_JournalHeader	AS BIGINT

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Receive Header
				-- ==========================================

				SELECT @_PaymentDate = PaymentDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner , @_PDCNo = PDCNo, @_VoucherNoManual = VoucherNoManual
				FROM CM_T_FinancialPaymentHeader 
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				
				SELECT	@_IDX_T_JournalHeader=JH.IDX_T_JournalHeader
				FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
				INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
				WHERE	FPH.RecordStatus='A'
				AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				UPDATE	FPH 
					SET FPH.PaymentStatus = 'A',
						FPH.ValidationDate = NULL, 
						FPH.ValidateBy = @UserID, 
						FPH.VoucherNoManual = @_VoucherNoManual, 
						FPH.PDCNo = @_PDCNo, 
						FPH.ValidationRemark = NULL, 
						FPH.DModified = @GlobalDateTime, 
						FPH.UModified = @UserID 
				FROM	CM_T_FinancialPaymentHeader FPH
				WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				DELETE	JD
				FROM	GL_T_JournalDetail JD WITH (NOLOCK)
				WHERE	JD.IDX_T_JournalHeader=@_IDX_T_JournalHeader

				UPDATE	JD
					SET JD.RecordStatus='I',
						JD.DModified=@GlobalDateTime,
						JD.UModified=@UserID
				FROM	GL_T_JournalHeader JD WITH (NOLOCK)
				WHERE	JD.IDX_T_JournalHeader=@_IDX_T_JournalHeader


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
				SELECT @_IDX_T_JournalHeader, 'Unposting', GETDATE(), @ApproveRemark, @UserID, GETDATE(), 'A'


				
				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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

