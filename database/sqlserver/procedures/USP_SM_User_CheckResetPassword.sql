
-- =============================================
-- Author:		Jonathan
-- Create date: 10 January 2024
-- Description:	Check reset password key
-- =============================================

/*		
	EXEC [USP_SM_User_CheckResetPassword] '123456789'           
*/

CREATE PROCEDURE [dbo].[USP_SM_User_CheckResetPassword] 
	@ResetPasswordKey			VARCHAR(150)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		
		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			VARCHAR(150),			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_EmailAddress	AS VARCHAR(150)
		DECLARE @_CountLog		AS INT				

		IF NOT EXISTS(SELECT EmailAddress FROM SM_T_CustomerResetPassword WITH(NOLOCK) WHERE RTRIM(ResetPasswordKey) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@ResetPasswordKey)), 2))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Invalid request!')
		END

		IF EXISTS(SELECT EmailAddress FROM SM_T_CustomerResetPassword WITH(NOLOCK) WHERE IsExpired = 1 AND RTRIM(ResetPasswordKey) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@ResetPasswordKey)), 2))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Link already expired!')
		END
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
			
			SELECT @_EmailAddress = EmailAddress FROM SM_T_CustomerResetPassword WITH(NOLOCK) WHERE RTRIM(ResetPasswordKey) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@ResetPasswordKey)), 2)
			
			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @_EmailAddress, 'Data Sudah Disimpan')
				
		END

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH       

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog
			
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


