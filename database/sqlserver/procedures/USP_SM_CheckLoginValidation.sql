
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 19 Juni 2017
-- Description:	Check user login
-- =============================================

-- EXEC [dbo].[USP_SM_CheckLoginValidation] 'admin',''

CREATE PROCEDURE [dbo].[USP_SM_CheckLoginValidation]
	@UserID			VARCHAR(50),
	@UserPassword	VARCHAR(50)
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

		DECLARE @_CountLog		INT
		DECLARE @_UserName		VARCHAR(100)
		DECLARE @_UserIndex		INT
		/*****************************/		

		IF RTRIM(@UserID) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'User ID required !')
		END

		IF RTRIM(@UserPassword) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'User Password required !')
		END 

		/** Check user login **/
		IF NOT EXISTS(	SELECT LoginID FROM SM_M_User 
						WHERE RTRIM(LoginID) = RTRIM(@UserID) AND RTRIM(Password2) = CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@UserPassword)), 2))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Invalid User ID or Password !')
		END			

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 		
			SELECT @_UserName = RTRIM(Name), @_UserIndex =  IDX_M_User 
			FROM SM_M_User 
			WHERE LoginID = @UserID

			INSERT INTO @TableLog VALUES ('success', @_UserIndex, @_UserName)
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

