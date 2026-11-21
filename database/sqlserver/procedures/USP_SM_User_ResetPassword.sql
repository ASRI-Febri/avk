
-- =============================================
-- Author:		Jonathan
-- Create date: 10 January 2024
-- Description:	Save reset password
-- =============================================

/*		
	EXEC [USP_SM_User_SaveResetPassword] '84','2301013'           
*/

CREATE PROCEDURE [dbo].[USP_SM_User_ResetPassword] 		
	@IDX_M_User					VARCHAR(150),
	@UserID						VARCHAR(150),
	@RecordStatus				VARCHAR(1)
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
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT			
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			DECLARE @PasswordMD5 varchar(256) = CONVERT(VARCHAR(32), HashBytes('MD5', @UserID), 2)
						
			UPDATE SM_M_User SET
				Password2 = @PasswordMD5
			WHERE IDX_M_User = @IDX_M_User

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_User, 'Data Sudah Disimpan')
				
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


