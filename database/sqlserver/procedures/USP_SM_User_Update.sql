-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update Master User
-- =============================================

/*		
	EXEC USP_SM_User_Update 2,1,18020101,'Michael','Michael','aaa@aaa.com','','','','1,','1,',1406069,'A'
	EXEC USP_SM_User_Update 2,1,18020101,'Michael','Michael','aaa@aaa.com','','','','1,','1,',1406069,'A'
*/

CREATE PROCEDURE [dbo].[USP_SM_User_Update] 
	@IDX_M_User					BIGINT,	
	@IDX_M_Gender				SMALLINT,	
	@LoginID					VARCHAR(50),
	@Name						VARCHAR(50),
	@Alias						VARCHAR(32),
	@Email						VARCHAR(50),
	@Password2					VARCHAR(150),
	@Password2Confirm			VARCHAR(150),
	@Notes						VARCHAR(150),
	@CompanyCheck				VARCHAR(200),
	@BranchCheck				VARCHAR(500),
	@GroupCheck					VARCHAR(500),
	--------------------------------------------------------------	
	@UserID						VARCHAR(10),
	@RecordStatus				CHAR(1)		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY			

		BEGIN TRANSACTION
		
		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)
				
		DECLARE @_CountLog AS INT
		/*****************************/
		
		/** Check User Access Right **/
		DECLARE @_FormID AS VARCHAR(20)
		SET @_FormID = 'SM-USID-002'

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END

		/** Check existing user id **/
		IF EXISTS(SELECT LoginID	FROM SM_M_User WHERE RTRIM(UPPER(LoginID)) = RTRIM(UPPER(@LoginID)) AND IDX_M_User <> @IDX_M_User )
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'User ID Already Exists!')
		END
				
		--INSERT INTO @TableLog VALUES ('error',0,'Test Error!')

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		/** Generate Company Check **/
		--SET @CompanyCheck = LEFT(@CompanyCheck,LEN(RTRIM(@CompanyCheck)) - 1)
		--SET @BranchCheck = LEFT(@BranchCheck,LEN(RTRIM(@BranchCheck)) - 1)

		--PRINT @CompanyCheck
		--PRINT @BranchCheck
		

		IF @_CountLog = 0
		BEGIN 

			UPDATE [dbo].SM_M_User SET
				[LoginID] = @LoginID,
				[IDX_M_Gender] = @IDX_M_Gender,
				[Name] = @Name,				
				[Email] = @Email,
				[Alias] = @Alias,
				[Notes] = @Notes,
				[UModified] = @UserID,
				[DModified] = GETDATE(),
				[RecordStatus] = @RecordStatus
			WHERE IDX_M_User = @IDX_M_User				

			DECLARE @pos INT
			DECLARE @len INT
			DECLARE @value varchar(8000)

			

			-- ===============================================================================
			-- Insert Company
			-- ===============================================================================
			--SET @pos = 0
			--SET @len = 0

			--DELETE SM_M_UserCompany WHERE IDX_M_User = @IDX_M_User

			--WHILE CHARINDEX(',', @CompanyCheck, @pos + 1) > 0
			--BEGIN
			--	SET @len = CHARINDEX(',', @CompanyCheck, @pos+1) - @pos
			--	SET @value = SUBSTRING(@CompanyCheck, @pos, @len)
			--	--SELECT @pos, @len, @value /*this is here for debugging*/
        
			--	--PRINT 'Company Value ' + @value
			--	INSERT INTO SM_M_UserCompany (IDX_M_User, IDX_M_Company, UCreate, DCreate, RecordStatus)
			--	SELECT @IDX_M_User,IDX_M_Company, @UserID, GETDATE(), @RecordStatus FROM GN_M_Company WHERE IDX_M_Company = CONVERT(INT,@value)
				
			--	SET @pos = CHARINDEX(',', @CompanyCheck, @pos+@len) +1
			--END

			-- ===============================================================================
			-- Insert Branch
			-- ===============================================================================
			--SET @pos = 0
			--SET @len = 0

			--DELETE SM_M_UserBranch WHERE IDX_M_User = @IDX_M_User

			--WHILE CHARINDEX(',', @BranchCheck, @pos + 1) > 0
			--BEGIN
			--	SET @len = CHARINDEX(',', @BranchCheck, @pos+1) - @pos
			--	SET @value = SUBSTRING(@BranchCheck, @pos, @len)
			--	--SELECT @pos, @len, @value /*this is here for debugging*/
        
			--	--PRINT 'Branch ' + @value
			--	INSERT INTO SM_M_UserBranch (IDX_M_User, IDX_M_Branch, UCreate, DCreate, RecordStatus) 
			--	SELECT @IDX_M_User,IDX_M_Branch, @UserID, GETDATE(), @RecordStatus FROM GN_M_Branch WHERE IDX_M_Branch = CONVERT(INT,@value)
				
			--	SET @pos = CHARINDEX(',', @BranchCheck, @pos+@len) +1
			--END	

			-- ===============================================================================
			-- Insert User Group
			-- ===============================================================================
			--SET @pos = 0
			--SET @len = 0

			--DELETE SM_M_UserGroup WHERE IDX_M_User = @IDX_M_User

			--WHILE CHARINDEX(',', @GroupCheck, @pos + 1) > 0
			--BEGIN
			--	SET @len = CHARINDEX(',', @GroupCheck, @pos+1) - @pos
			--	SET @value = SUBSTRING(@GroupCheck, @pos, @len)
			--	--SELECT @pos, @len, @value /*this is here for debugging*/
        
			--	--PRINT 'Group ' + @value
			--	INSERT INTO SM_M_UserGroup (IDX_M_User, IDX_M_Group, UCreate, DCreate, RecordStatus) 
			--	SELECT @IDX_M_User,IDX_M_Group, @UserID, GETDATE(), @RecordStatus FROM SM_M_Group WHERE IDX_M_Group = CONVERT(INT,@value)
				
			--	SET @pos = CHARINDEX(',', @GroupCheck, @pos+@len) +1
			--END	

			INSERT INTO @TableLog VALUES ('success', @IDX_M_User, 'Data Sudah Disimpan')
			
		END 

		COMMIT TRANSACTION

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


