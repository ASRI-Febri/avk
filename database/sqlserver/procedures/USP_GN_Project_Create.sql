
-- =============================================
-- Author		:	Anton
-- Create date	:	2021-10-05
-- Description	:	Insert Table Master Project
-- =============================================

CREATE PROCEDURE [dbo].[USP_GN_Project_Create] 	
    @ProjectID					VARCHAR(50),
    @ProjectName				VARCHAR(150),
    @ProjectDesc				VARCHAR(500),
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
		--SET @_FormID = 'CM-MFIA-002' -- Create Financial Account

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END		
		/****************************************************************************/
		
		IF exists (select * from GN_M_Project where LTRIM(RTRIM(ProjectID)) = LTRIM(RTRIM(@ProjectID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Project ID Already Exist!')
		END

		IF exists (select * from GN_M_Project where LTRIM(RTRIM(ProjectName)) = LTRIM(RTRIM(@ProjectName)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Project Name Already Exist!')
		END
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert Master Project
			--------------------------------------------------------------------------------**/

			INSERT INTO [dbo].[GN_M_Project]
				(
					[ProjectID]
				   ,[ProjectName]
				   ,[StartDate]
				   ,[EndDate]
				   ,[ProjectDesc]
				   ,[DCreate]
				   ,[UCreate]
				   ,[RecordStatus]		
				)
			VALUES 
				(
					@ProjectID,	
					@ProjectName,		
					NULL,				
					NULL,		
					@ProjectDesc,																						
					GETDATE(),	
					@UserID,				
					@RecordStatus
				)

			DECLARE @IDX_M_Project AS BIGINT
			SET @IDX_M_Project = (SELECT SCOPE_IDENTITY())			 					

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Project, 'Data Sudah Disimpan')
				
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



