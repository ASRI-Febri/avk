-- =========================================================================================================================
-- Author			: Anton
-- Create date		: 9 July 2019
-- Description		: Rollback validated FR Transaction
-- Mod				: 2020-10-02 by Anton --> Added Journal Closing Period Validation
--					  2021-03-17 by Anton --> Added delete journal allocation & rollback status receive allocation
--					  2024-01-08 by Anton --> Reverse retain current document number
-- =========================================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialReceive_ReverseValidate] 1,'Reverse Transaction','XA.ADMIN'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_ReverseApproval] 
	@IDX_T_FinancialReceiveHeader		BIGINT,
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
			
			--DECLARE @_ValidationDate DATE
			--SELECT	@_ValidationDate = ApprovalDate FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
			--IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@_ValidationDate,112),6)) = 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Cannot Reverse Because Journal Period Already Closed!')
			--END	

			--IF NOT EXISTS(
			--	SELECT	1 
			--	FROM	CM_T_FinancialReceiveHeader FRH WITH (NOLOCK)
			--	INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = JH.IDX_ReferenceNo AND FRH.ReceiveID = JH.ReferenceNo
			--	WHERE	FRH.RecordStatus = 'A'
			--	AND		FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
			--)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'This transaction is still not validated!')
			--END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_IDX_M_Partner			BIGINT
				-- ==========================
				-- Generate Receive No
				-- ==========================
				DECLARE @_ReceiveDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(3)
				DECLARE @_IDX_T_JournalHeader	AS BIGINT

				-- ==========================================
				-- Get Data From Financial Receive Header
				-- ==========================================

				SELECT @_ReceiveDate = ReceiveDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner
				FROM CM_T_FinancialReceiveHeader WITH (NOLOCK)
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				
				SELECT	@_IDX_T_JournalHeader = JH.IDX_T_JournalHeader
				FROM	CM_T_FinancialReceiveHeader FRH WITH (NOLOCK)
					INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = JH.IDX_ReferenceNo AND FRH.ReceiveID = JH.ReferenceNo
				WHERE	FRH.RecordStatus='A' AND FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				UPDATE	FRH 
					SET --FRH.ReceiveID			= 'DRAFT-' + CONVERT(VARCHAR,@IDX_T_FinancialReceiveHeader),
						FRH.ReceiveStatus		= 'D',
						FRH.ApprovedBy			= NULL,
						--FRH.ApprovalDate		= NULL,
						FRH.ApprovalRemark		= NULL,
						FRH.ValidationDate		= NULL, 
						FRH.ValidateBy			= @UserID, 
						FRH.DModified			= @GlobalDateTime, 
						FRH.UModified			= @UserID 
				FROM	CM_T_FinancialReceiveHeader FRH
				WHERE	IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				DELETE	JD
				FROM	GL_T_JournalDetail JD WITH (NOLOCK)
				WHERE	JD.IDX_T_JournalHeader = @_IDX_T_JournalHeader

				DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader

				--UPDATE	JH
				--	SET JH.RecordStatus		= 'I',
				--		JH.PostingStatus	= 'U',
				--		JH.DModified		= @GlobalDateTime,
				--		JH.UModified		= @UserID
				--FROM	GL_T_JournalHeader JH WITH (NOLOCK)
				--WHERE	JH.IDX_T_JournalHeader = @_IDX_T_JournalHeader

				DECLARE @ReceiveAllocation TABLE ( IDX_Allocation BIGINT )
				DECLARE @JournalAllocation TABLE ( IDX_JournalAllocation BIGINT )

				IF EXISTS ( SELECT 1
							FROM CM_T_FinancialReceiveDetail FRD WITH(NOLOCK)
								INNER JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
							WHERE FRD.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND RA.AllocationStatus = 'A' )
				BEGIN
					INSERT INTO @ReceiveAllocation
						SELECT RA.IDX_T_ReceiveAllocation 
						FROM CM_T_FinancialReceiveDetail FRD WITH(NOLOCK)
							INNER JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
						WHERE FRD.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND RA.AllocationStatus = 'A'

					UPDATE CM_T_ReceiveAllocation SET AllocationStatus = 'D', DModified = SYSDATETIME(), UModified = @UserID
					WHERE IDX_T_ReceiveAllocation IN (SELECT IDX_Allocation FROM @ReceiveAllocation)

					IF EXISTS ( SELECT 1
								FROM GL_T_JournalHeader JH WITH(NOLOCK)
								WHERE JH.IDX_M_JournalType = 8 AND IDX_ReferenceNo IN (SELECT IDX_Allocation FROM @ReceiveAllocation) )
					BEGIN
						INSERT INTO @JournalAllocation
							SELECT JH.IDX_T_JournalHeader
							FROM GL_T_JournalHeader JH WITH(NOLOCK)
							WHERE JH.IDX_M_JournalType = 8 AND IDX_ReferenceNo IN (SELECT IDX_Allocation FROM @ReceiveAllocation)

						DELETE GL_T_JournalHeader WHERE IDX_T_JournalHeader IN (SELECT IDX_JournalAllocation FROM @JournalAllocation)
						DELETE GL_T_JournalDetail WHERE IDX_T_JournalHeader IN (SELECT IDX_JournalAllocation FROM @JournalAllocation)
					END
				END

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


				
				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialReceiveHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

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

