
-- =============================================
-- Author:		Jonathan
-- Create date: 10 January 2023
-- Description:	Kirim Email link Reset Password Customer
-- =============================================

/*		
	EXEC [USP_SM_User_SendResetPassword]  'jonathan.setyono@alam-sutera.com', '123456789'                
*/

CREATE PROCEDURE [dbo].[USP_SM_User_SendResetPassword] 		
	@EmailAddress				VARCHAR(150),
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
			ID			BIGINT,			
			LogDesc		VARCHAR(500),
			MemberName	VARCHAR(150)
		)

		DECLARE @_CountLog		AS INT	
		DECLARE @_UserName	AS VARCHAR(150)			
		DECLARE @_IDX_M_User AS BIGINT

		IF NOT EXISTS(SELECT Email FROM SM_M_User WITH(NOLOCK) WHERE RTRIM(Email) = RTRIM(@EmailAddress))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Alamat Email tidak terdaftar!','')
		END

		IF EXISTS(	SELECT EmailAddress FROM SM_T_CustomerResetPassword WITH(NOLOCK)
					WHERE IsExpired = 1 AND RTRIM(EmailAddress) = RTRIM(@EmailAddress) 
						AND RTRIM(ResetPasswordKey) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@ResetPasswordKey)), 2))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Link already expired!','')
		END
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
			
			SELECT @_UserName = Name FROM SM_M_User WITH(NOLOCK) WHERE RTRIM(Email) = RTRIM(@EmailAddress)	
					
			-- =========================================================================
			-- INSERT RESET PASSWORD
			-- =========================================================================	
			INSERT INTO [dbo].[SM_T_CustomerResetPassword]
			   ([EmailAddress]
			   ,[ResetPasswordKey]
			   ,[IsExpired]
			   ,[IsReset]
			   ,[ResetDate]
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			 VALUES
				(@EmailAddress
				,CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@ResetPasswordKey)), 2)
				,0
				,0
				,NULL
				,@EmailAddress
				,GETDATE()				
				,'A')
		
			-- =========================================================================
			-- INSERT LOG
			-- =========================================================================	
			--SELECT @_IDX_M_User = IDX_M_User FROM SM_M_User where Email = @EmailAddress

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
			--   ,'ResetPassword'
			--   ,'Reset password Email'
			--   ,GETDATE()	
			--   ,SUSER_SNAME()	   
			--   ,'A')

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', 0, 'Data Sudah Disimpan',@_UserName)
				
		END

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH       

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()),'')
				
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


