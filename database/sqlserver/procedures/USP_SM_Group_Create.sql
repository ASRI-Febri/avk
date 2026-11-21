-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Create Table Master Group
-- =============================================

/*		
	EXEC USP_CM_User_Create 1,'guest','Guest User','guest','','efbfcb31d5bace6bb5793a529254424e','215f2340b6067545fc324cda36398229','',1406069,'A'
*/

CREATE PROCEDURE [dbo].[USP_SM_Group_Create] 
	@GroupID					VARCHAR(50),
	@GroupName					VARCHAR(150),
	@Notes						VARCHAR(150),	
	@FormCheck					VARCHAR(5000),
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

		IF EXISTS(SELECT GroupID FROM SM_M_Group WHERE RTRIM(UPPER(GroupID)) = RTRIM(UPPER(@GroupID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Group ID Already Exists!')
		END		
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert User ID 
			--------------------------------------------------------------------------------**/		

			INSERT INTO [dbo].[SM_M_Group]
				([GroupID]
				,[GroupName]				
				,[Notes]				
				,[DCreate]
				,[UCreate]				
				,[Recordstatus])
			 VALUES
				(@GroupID
				,@GroupName				
				,@Notes									   
				,GETDATE()
				,@UserID								  
				,@RecordStatus)			
			
			DECLARE @IDX_M_Group AS BIGINT
			SET @IDX_M_Group = (SELECT SCOPE_IDENTITY())			

			DECLARE @pos INT
			DECLARE @len INT
			DECLARE @value varchar(8000)

			-- ===============================================================================
			-- Insert Form
			-- ===============================================================================
			SET @pos = 0
			SET @len = 0

			DELETE SM_M_GroupForm WHERE IDX_M_Group = @IDX_M_Group

			WHILE CHARINDEX(',', @FormCheck, @pos + 1) > 0
			BEGIN
				SET @len = CHARINDEX(',', @FormCheck, @pos+1) - @pos
				SET @value = SUBSTRING(@FormCheck, @pos, @len)
				--SELECT @pos, @len, @value /*this is here for debugging*/
        
				--PRINT 'Company Value ' + @value
				INSERT INTO SM_M_GroupForm (IDX_M_Group, IDX_M_Form, UCreate, DCreate, RecordStatus)
				SELECT @IDX_M_Group,IDX_M_Form, @UserID, GETDATE(), @RecordStatus FROM SM_M_Form WHERE IDX_M_Form = CONVERT(INT,@value)
				
				SET @pos = CHARINDEX(',', @FormCheck, @pos+@len) +1
			END

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Group, 'Data Sudah Disimpan')
				
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


