-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 01 October 2018
-- Description:	Delete draft internal transfer
-- =============================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_InternalTransfer_Delete] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Delete] 
	@IDX_T_InternalTransferHeader		BIGINT,
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

			IF EXISTS(	SELECT IDX_T_InternalTransferHeader
						FROM CM_T_InternalTransferHeader
						WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'Internal transfer transaction already approved!')
			END
			
			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
											
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
				SELECT @IDX_T_InternalTransferHeader, 'Delete', GETDATE(), @DeleteRemark, @UserID, GETDATE(), 'A'
													
				-- =======================================================================
				-- Delete Internal Transfer Detail
				-- =======================================================================
				DELETE CM_T_InternalTransferDetail 				
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader		
				
				-- =======================================================================
				-- Delete Internal Transfer Header
				-- =======================================================================
				DELETE CM_T_InternalTransferHeader 				
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader		

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


