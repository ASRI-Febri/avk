-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 Oktober 2018
-- Description:	Reverse Approval Internal Transfer
-- =============================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_InternalTransfer_ReverseApproval] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_ReverseApproval] 
	@IDX_T_InternalTransferHeader		BIGINT,
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
			
			DECLARE @_TransferStatus		CHAR(1)
			DECLARE @_CountLog			INT

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

			SELECT @_TransferStatus = TransferStatus FROM CM_T_InternalTransferHeader WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

			IF @_TransferStatus = 'F'
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'This Transfer is already validate!')
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
				DECLARE @_TransferID			AS VARCHAR(20)
				DECLARE @_TransferDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(3)

				-- Update status
				UPDATE CM_T_InternalTransferHeader 
				SET TransferID = @_TransferID,
					TransferStatus = 'D', ApprovalDate = NULL, ApprovalBy = '', 
					ApprovalRemark = '', DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader				

				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[CM_T_InternalTransferLog]
					([IDX_T_InternalTransferHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_InternalTransferHeader, 'ReverseApproval', GETDATE(), @ApproveRemark, @UserID, GETDATE(), 'A'


				
				INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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


