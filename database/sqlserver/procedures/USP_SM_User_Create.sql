-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 29 Jan 2018
-- Description	: Create Table Master User
-- Mod			: Anton 2020-04-01 --> Formatting MD5 for param @Password2
-- =============================================

/*		
	EXEC USP_CM_User_Create 1,'guest','Guest User','guest','','efbfcb31d5bace6bb5793a529254424e','215f2340b6067545fc324cda36398229','',1406069,'A'
*/

CREATE PROCEDURE [dbo].[USP_SM_User_Create] 	
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
		
		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/			
		
		/** Check User Access Right **/		
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'CM-MFIA-001' -- Create Financial Account

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END		
		/****************************************************************************/

		IF EXISTS(SELECT LoginID	FROM SM_M_User WHERE RTRIM(UPPER(LoginID)) = RTRIM(UPPER(@LoginID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'User ID Already Exists!')
		END

		IF RTRIM(@Password2) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Password is required!')
		END

		/** Cek password **/
		IF RTRIM(@Password2) <> RTRIM(@Password2Confirm)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Different Password & Password Confirmation !')
		END
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert User ID 
			--------------------------------------------------------------------------------**/		

			INSERT INTO [dbo].[SM_M_User]
				([IDX_M_Gender]
				,[LoginID]
				,[Name]
				,[Alias]				
				,[Password2]				
				,[Email]
				,[Notes]				
				,[DCreate]
				,[UCreate]				
				,[Recordstatus])
			 VALUES
				(@IDX_M_Gender
				,@LoginID
				,@Name
				,@Alias
				,CONVERT(VARCHAR(32), HashBytes('MD5', RTRIM(@Password2)), 2)
				--,@Password2
				,@Email
				,@Notes									   
				,GETDATE()
				,@UserID								  
				,@RecordStatus)			
			
			DECLARE @IDX_M_User AS BIGINT
			SET @IDX_M_User = (SELECT SCOPE_IDENTITY())

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



