
-- =============================================
-- Author:		Jonathan
-- Create date: 10 January 2024
-- Description:	Save reset password
-- =============================================

/*		
	EXEC [USP_SM_User_SaveResetPassword] 'jonathan.setyono@alam-sutera.com','1234567','1234567'           
*/

CREATE PROCEDURE [dbo].[USP_SM_User_SaveResetPassword] 		
	@EmailAddress				VARCHAR(150),
	@AccountPassword			VARCHAR(150),
	@AccountPasswordConfirm		VARCHAR(150)
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
		DECLARE @_IDX_M_User AS BIGINT	

		IF RTRIM(@AccountPassword) <> RTRIM(@AccountPasswordConfirm)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Password and Password confirmation not match!')
		END
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			DECLARE @PasswordMD5 varchar(256) = CONVERT(VARCHAR(32), HashBytes('MD5', @AccountPassword), 2)
						
			UPDATE SM_M_User SET
				Password2 = @PasswordMD5
			WHERE Email = @EmailAddress

			-- =========================================================================
			-- UPDATE RESET PASSWORD
			-- =========================================================================	
			UPDATE [dbo].[SM_T_CustomerResetPassword] SET 
				 IsExpired = 1
				,IsReset = 1
				,ResetDate = GETDATE()
				,UModified = @EmailAddress
				,DModified = GETDATE()
			WHERE EmailAddress = @EmailAddress
						   
			-- =========================================================================
			-- INSERT LOG
			-- =========================================================================		
			--SELECT @_IDX_M_RegisterCustomer = IDX_M_RegisterCustomer FROM SL_M_RegisterCustomer where EmailAddress = @EmailAddress

			--INSERT INTO [dbo].[T_RegisterCustomerLog]
			--   ([IDX_M_RegisterCustomer]
			--   ,[EmailAddress]
			--   ,[LogDate]
			--   ,[LogType]
			--   ,[LogDesc]
			--   ,[DCreate]
			--   ,[UCreate]			   
			--   ,[RecordStatus])
			--VALUES
			--   (@_IDX_M_RegisterCustomer
			--   ,@EmailAddress
			--   ,GETDATE()
			--   ,'ChangePassword'
			--   ,'Change password success'
			--   ,GETDATE()	
			--   ,SUSER_SNAME()	   
			--   ,'A')

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', 0, 'Data Sudah Disimpan')
				
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


