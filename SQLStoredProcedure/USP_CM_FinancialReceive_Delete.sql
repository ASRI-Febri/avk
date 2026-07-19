
/****** Object:  StoredProcedure [dbo].[USP_CM_FinancialReceive_Delete]    Script Date: 6/6/2026 12:23:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Approval Financial Receive
-- =============================================


/* 
	SELECT * FROM CM_T_FinancialReceiveHeader
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialReceive_Delete] 6,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

ALTER PROCEDURE [dbo].[USP_CM_FinancialReceive_Delete] 
	@IDX_T_FinancialReceiveHeader		BIGINT,
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
			--SET @_FormID = 'CM-FIRC-005' -- Approval Receiving Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			IF EXISTS(	SELECT IDX_T_FinancialReceiveHeader
						FROM CM_T_FinancialReceiveHeader
						WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND ReceiveStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Financial transaction already approved!')
			END

			IF EXISTS(	SELECT FPH.IDX_T_FinancialReceiveHeader
						FROM CM_T_ReceiveAllocation PA
							LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_T_FinancialReceiveDetail = PA.IDX_T_FinancialReceiveDetail
							LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
						WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND AllocationStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'There are financial allocation that already approved!')
			END
			
			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
									
				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[CM_T_FinancialReceiveLog]
					([IDX_T_FinancialReceiveHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_FinancialReceiveHeader, 'Delete', GETDATE(), @DeleteRemark, @UserID, GETDATE(), 'A'		
				
				-- =======================================================================
				-- Get Journal reference BEFORE deleting header (header is needed to
				-- resolve ReceiveID / IDX_T_JournalHeader)
				-- =======================================================================
				DECLARE @_IDX_T_JournalHeader			BIGINT
				DECLARE @_ReceiveID						VARCHAR(500)

				SELECT @_ReceiveID = ReceiveID
				FROM CM_T_FinancialReceiveHeader
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader
				FROM GL_T_JournalHeader
				WHERE IDX_ReferenceNo = @IDX_T_FinancialReceiveHeader AND RTRIM(ReferenceNo) = RTRIM(@_ReceiveID)
					AND IDX_M_JournalType = 3 -- Financial Receive

				-- =======================================================================
				-- Delete Financial Receive Detail
				-- =======================================================================
				DELETE CM_T_FinancialReceiveDetail
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				-- =======================================================================
				-- Delete Financial Receive Allocation
				-- =======================================================================
				DELETE CM_T_ReceiveAllocation FROM (
					SELECT FPH.IDX_T_FinancialReceiveHeader, PA.IDX_T_FinancialReceiveDetail
					FROM CM_T_ReceiveAllocation PA
						LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_T_FinancialReceiveDetail = PA.IDX_T_FinancialReceiveDetail
						LEFT JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
					WHERE FPH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
				) Temp
				INNER JOIN CM_T_ReceiveAllocation ON CM_T_ReceiveAllocation.IDX_T_FinancialReceiveDetail = Temp.IDX_T_FinancialReceiveDetail

				-- =======================================================================
				-- Delete Financial Receive Header
				-- =======================================================================
				DELETE CM_T_FinancialReceiveHeader
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

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
				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialReceiveHeader, 'Data Sudah Disimpan')

			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())
				
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



