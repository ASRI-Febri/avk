
/****** Object:  StoredProcedure [dbo].[USP_CM_FinancialPayment_Delete]    Script Date: 6/6/2026 12:23:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Delete Financial Payment
-- =============================================


/*
	SELECT * FROM CM_T_FinancialPaymentHeader
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_Delete] 6,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

ALTER PROCEDURE [dbo].[USP_CM_FinancialPayment_Delete]
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@DeleteRemark						VARCHAR(500),
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;

			DECLARE @_CountDetail			AS INT
			DECLARE @_TotalAmount			AS DECIMAL(22,2)
			DECLARE @_DetailAmount			AS DECIMAL(22,2)
			DECLARE @_AllocationAmount		AS DECIMAL(22,2)
			DECLARE @_CountLog				AS INT

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),
				ID			BIGINT,
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID AS VARCHAR(20)
			--SET @_FormID = 'CM-FIPY-005' -- Approval Payment Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			IF EXISTS(	SELECT IDX_T_FinancialPaymentHeader
						FROM CM_T_FinancialPaymentHeader
						WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND PaymentStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Financial transaction already approved!')
			END

			IF EXISTS(	SELECT FPH.IDX_T_FinancialPaymentHeader
						FROM CM_T_PaymentAllocation PA
							LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
							LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
						WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND AllocationStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'There are financial allocation that already approved!')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

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
				SELECT @IDX_T_FinancialPaymentHeader, 'Delete', GETDATE(), @DeleteRemark, @UserID, GETDATE(), 'A'

				-- =======================================================================
				-- Get Journal reference BEFORE deleting header (header is needed to
				-- resolve PaymentID / IDX_T_JournalHeader)
				-- =======================================================================
				DECLARE @_IDX_T_JournalHeader			BIGINT
				DECLARE @_PaymentID						VARCHAR(500)

				SELECT @_PaymentID = PaymentID
				FROM CM_T_FinancialPaymentHeader
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader
				FROM GL_T_JournalHeader
				WHERE IDX_ReferenceNo = @IDX_T_FinancialPaymentHeader AND RTRIM(ReferenceNo) = RTRIM(@_PaymentID)
					AND IDX_M_JournalType = 4 -- Financial Payment

				-- =======================================================================
				-- Delete Financial Payment Detail
				-- =======================================================================
				DELETE CM_T_FinancialPaymentDetail
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				-- =======================================================================
				-- Delete Financial Payment Allocation
				-- =======================================================================
				DELETE CM_T_PaymentAllocation FROM (
					SELECT FPH.IDX_T_FinancialPaymentHeader, PA.IDX_T_FinancialPaymentDetail
					FROM CM_T_PaymentAllocation PA
						LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
						LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
					WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				) Temp
				INNER JOIN CM_T_PaymentAllocation ON CM_T_PaymentAllocation.IDX_T_FinancialPaymentDetail = Temp.IDX_T_FinancialPaymentDetail

				-- =======================================================================
				-- Delete Financial Payment Header
				-- =======================================================================
				DELETE CM_T_FinancialPaymentHeader
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				-- =======================================================================
				-- DELETE JOURNAL
				-- =======================================================================
				IF @_IDX_T_JournalHeader IS NOT NULL
				BEGIN
					DELETE GL_T_JournalDetail WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
					DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader
				END

				-- =======================================================================
				-- OUTPUT
				-- =======================================================================
				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')

			END

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())

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
