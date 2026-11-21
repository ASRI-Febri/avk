-- ==============================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Payment
-- Modified		: 2020-01-31 by Anton --> Reset column PaymentID into DRAFT-"@IDX_T_FinancialPaymentHeader"
--				  2023-09-07 by Anton --> Added logic to rollback when transaction already validate (before only for status approve / handover)
--				  2024-01-08 by Anton --> Reverse retain current document number
-- ==============================================================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_ReverseApproval] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_ReverseApproval] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@ApproveRemark						VARCHAR(500),
	@UserID								VARCHAR(36)
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
			
			--IF EXISTS(
			--	SELECT	1 
			--	FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
			--	WHERE	FPH.RecordStatus='A'
			--	AND		FPH.PaymentStatus='F'
			--	AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
			--)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'This payment is already validate!')
			--END

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

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Receive Header
				-- ==========================================

				SELECT @_PaymentDate = PaymentDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner 
				FROM CM_T_FinancialPaymentHeader WITH (NOLOCK)
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				
				IF EXISTS (	SELECT	1
							FROM CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
								INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
							WHERE FPH.RecordStatus='A' AND FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader )
				BEGIN
					DECLARE @_IDX_T_JournalHeader	AS BIGINT

					SELECT @_IDX_T_JournalHeader = JH.IDX_T_JournalHeader
					FROM CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
						INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
					WHERE FPH.RecordStatus='A' AND FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

					DELETE GL_T_JournalDetail WHERE	IDX_T_JournalHeader = @_IDX_T_JournalHeader
					DELETE GL_T_JournalHeader WHERE	IDX_T_JournalHeader = @_IDX_T_JournalHeader

					IF EXISTS ( SELECT 1
							FROM CM_T_FinancialPaymentDetail FRD WITH(NOLOCK)
								INNER JOIN CM_T_PaymentAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
							WHERE FRD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND RA.AllocationStatus = 'A' )
					BEGIN
						DECLARE @PaymentAllocation TABLE ( IDX_Allocation BIGINT )
						DECLARE @JournalAllocation TABLE ( IDX_JournalAllocation BIGINT )

						INSERT INTO @PaymentAllocation
							SELECT RA.IDX_T_ReceiveAllocation 
							FROM CM_T_FinancialReceiveDetail FRD WITH(NOLOCK)
								INNER JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
							WHERE FRD.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialPaymentHeader AND RA.AllocationStatus = 'A'

						UPDATE CM_T_PaymentAllocation SET AllocationStatus = 'D', DModified = SYSDATETIME(), UModified = @UserID
						WHERE IDX_T_PaymentAllocation IN (SELECT IDX_Allocation FROM @PaymentAllocation)

						IF EXISTS ( SELECT 1
									FROM GL_T_JournalHeader JH WITH(NOLOCK)
									WHERE JH.IDX_M_JournalType = 9 AND IDX_ReferenceNo IN (SELECT IDX_Allocation FROM @PaymentAllocation) )
						BEGIN
							INSERT INTO @JournalAllocation
								SELECT JH.IDX_T_JournalHeader
								FROM GL_T_JournalHeader JH WITH(NOLOCK)
								WHERE JH.IDX_M_JournalType = 9 AND IDX_ReferenceNo IN (SELECT IDX_Allocation FROM @PaymentAllocation)

							DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader IN (SELECT IDX_JournalAllocation FROM @JournalAllocation)
							DELETE GL_T_JournalDetail WHERE IDX_T_JournalHeader IN (SELECT IDX_JournalAllocation FROM @JournalAllocation)
						END
					END
				END

				-- Update status
				UPDATE	FPH
					SET --FPH.PaymentID = 'DRAFT-' + CONVERT(VARCHAR,@IDX_T_FinancialPaymentHeader),
						FPH.PaymentStatus = 'D', 
						--FPH.ApprovalDate = NULL, 
						FPH.ApprovedBy = NULL, 
						FPH.ApprovalRemark = NULL,
						FPH.ValidateBy = NULL,
						--FPH.ValidationDate = NULL,
						FPH.ValidationRemark = NULL,
						FPH.DModified = @GlobalDateTime, 
						FPH.UModified = @UserID 
				FROM	CM_T_FinancialPaymentHeader  FPH
				WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				-- =======================================================================
				-- Approval Financial Receive Allocation
				-- =======================================================================
				--UPDATE CM_T_PaymentAllocation SET AllocationStatus = 'D', UModified = @UserID, DModified = GETDATE()
				--FROM (
				--	SELECT IDX_T_FinancialPaymentDetail FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				--) FRD
				--INNER JOIN CM_T_PaymentAllocation ON CM_T_PaymentAllocation.IDX_T_FinancialPaymentDetail = FRD.IDX_T_FinancialPaymentDetail 	


				UPDATE	PA
					SET	PA.AllocationStatus = 'D',
						PA.DModified = @GlobalDateTime,
						PA.UModified = @UserID
				FROM	CM_T_PaymentAllocation PA 
				INNER JOIN CM_T_FinancialPaymentDetail FPD WITH (NOLOCK) ON PA.IDX_T_FinancialPaymentDetail=FPD.IDX_T_FinancialPaymentDetail
				WHERE	FPD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader


				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[CM_T_FinancialPaymentLog]
					([IDX_T_FinancialPaymentHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_FinancialPaymentHeader, 'ReverseApproval', GETDATE(), @ApproveRemark, @UserID, GETDATE(), 'A'


				
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

