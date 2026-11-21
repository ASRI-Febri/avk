-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 27 Mar 2023
-- Description:	Create Table SM_M_UserGroup (Table mapping between User and Group Roles)
-- =============================================
/*		
	EXEC [dbo].[USP_SM_User_AddGroup] 51,'1,2','1406069','A'	
*/

CREATE PROCEDURE [dbo].[USP_SM_User_AddGroup] 	
	@IDX_M_User						BIGINT,	
	@GroupList						VARCHAR(5000),			
	------------------------------------------------
	@UserID							VARCHAR(20),
	@RecordStatus					CHAR(1)	
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
			ID			VARCHAR(20),			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		DECLARE @_Sql AS VARCHAR(5000)
		DECLARE @_RowCount AS INT
		/*****************************/

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'LG-BORO-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		--------------------------------------------------------------------------------------		
		

		IF RTRIM(@GroupList) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'No data selected !')
		END
		
		IF RTRIM(@GroupList) <> ''
		BEGIN
			SET @_Sql = 'SELECT ''error'', CONVERT(VARCHAR, UG.IDX_M_Group), ''Group '' + CONVERT(VARCHAR, UG.IDX_M_Group) + '' - '' + CONVERT(VARCHAR, G.GroupName) + '' already exists!'' 
				FROM SM_M_User U
					LEFT JOIN SM_M_UserGroup UG ON UG.IDX_M_User = U.IDX_M_User 
					LEFT JOIN SM_M_Group G ON G.IDX_M_Group = UG.IDX_M_Group
				WHERE UG.IDX_M_User = ' + CONVERT(VARCHAR,@IDX_M_User) + ' AND UG.IDX_M_Group IN (' + RTRIM(@GroupList) + ')'
		
			SET @_Sql = RTRIM(@_Sql)

			--PRINT @_Sql

			INSERT INTO @TableLog EXEC (@_Sql)

			--PRINT 'After Insert SQL Error'
		END		

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			SET @_Sql = ''
					
			SET @_Sql = 'INSERT INTO [dbo].[SM_M_UserGroup]
			   ([IDX_M_User]
			   ,[IDX_M_Group]			             
			   ,[UCreate]
			   ,[DCreate]
			   ,[RecordStatus])
			SELECT ' + CONVERT(VARCHAR,@IDX_M_User) + ', IDX_M_Group, ''' + @UserID + ''', GETDATE(), ''' + @RecordStatus + '''
			FROM SM_M_Group 
			WHERE RecordStatus = ''A'' AND IDX_M_Group IN (' + RTRIM(@GroupList) + ')'
			
			--PRINT @_Sql

			SET @_Sql = RTRIM(@_Sql)

			--PRINT 'Before'

			EXEC (@_Sql)
			
			-- OUTPUT
			INSERT INTO @TableLog VALUES ('success', @IDX_M_User, 'Data Sudah Disimpan')	
			
			--PRINT 'Last'
					
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

