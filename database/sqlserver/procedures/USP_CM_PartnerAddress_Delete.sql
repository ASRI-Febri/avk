-- =============================================
-- Author		: Anton
-- Create date	: 2019-04-25
-- Description	: Delete Partner Address
-- =============================================

/*
	SELECT * FROM GN_M_PartnerAddress where IDX_M_PartnerAddress = 2
	BEGIN TRANSACTION A
	EXEC [dbo].[USP_CM_PartnerAddress_Delete] 2,1,'XA.ADMIN'
	SELECT * FROM GN_M_PartnerAddress where IDX_M_PartnerAddress = 2
	ROLLBACK TRANSACTION A
*/

CREATE PROCEDURE [dbo].[USP_CM_PartnerAddress_Delete] 
	@IDX_M_PartnerAddress				BIGINT,
	@IDX_M_Partner						BIGINT,
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

			--IF EXISTS(
			--		   SELECT '' FROM GL_T_JournalHeader WHERE IDX_M_Partner = @IDX_M_Partner
			--			)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_M_Partner,'This partner already used on transaction!')
			--END
			
			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			

				-- GET IDX_M_Partner for return parameter
				SELECT @IDX_M_Partner = IDX_M_Partner FROM GN_M_PartnerAddress WHERE IDX_M_PartnerAddress = @IDX_M_PartnerAddress

				-- =======================================================================
				-- Delete Partner Address
				-- =======================================================================
				-- DELETE GN_M_PartnerAddress WHERE IDX_M_PartnerAddress = @IDX_M_PartnerAddress

				UPDATE GN_M_PartnerAddress SET RecordStatus = 'I' WHERE IDX_M_PartnerAddress = @IDX_M_PartnerAddress

				INSERT INTO @TableLog VALUES ('success', @IDX_M_Partner, 'Data Sudah Dihapus')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_M_Partner, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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


