
-- =============================================
-- Author		:	ANGGI
-- Create date	:	9 JANUARI 2019
-- Description	:	Insert Table Master COAGroup1
-- =============================================

/*	
	EXEC [dbo].[USP_GL_M_COAGroup1_Create] 2,'bbbb','Alam Sutera','ASR','Jalur Sutera Barat','2018-09-04 20:46:31.340','A'

*/



CREATE PROCEDURE [dbo].[USP_GL_COAGroup1_Create] 	
	@IDX_M_COAType		INT,
    @COAGroup1ID		VARCHAR(50),  
    @COAGroup1Name1		VARCHAR(150),
    @COAGroup1Name2		VARCHAR(150),
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
		
		IF exists (select * from GL_M_COAGroup1 where LTRIM(RTRIM(COAGroup1ID)) = LTRIM(RTRIM(@COAGroup1ID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'COAGroup 1 ID Already Exist!')
		END
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert Master COA GROUP 1
			--------------------------------------------------------------------------------**/

			INSERT INTO [dbo].GL_M_COAGroup1
				(
					[IDX_M_COAType]
				   ,[COAGroup1ID]
				   ,[COAGroup1Name1]
				   ,[COAGroup1Name2]
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus]				
				)
			VALUES 
				(
					@IDX_M_COAType,
					@COAGroup1ID,			
					@COAGroup1Name1,			
					@COAGroup1Name2,						
					@UserID,			
					GETDATE(),					
					@RecordStatus
				)

			DECLARE @IDX_M_COAGroup1 AS BIGINT
			SET @IDX_M_COAGroup1 = (SELECT SCOPE_IDENTITY())			 					

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_COAGroup1, 'Data Sudah Disimpan')
				
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



