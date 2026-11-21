-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Create Table Master Form
-- =============================================

/*		
	EXEC USP_SM_Form_Create 1,'guest','Guest User','guest','','efbfcb31d5bace6bb5793a529254424e','215f2340b6067545fc324cda36398229','',1406069,'A'
*/

CREATE PROCEDURE [dbo].[USP_SM_Form_Create] 
	@ApplicationID				VARCHAR(50),
	@FormID						VARCHAR(50),
	@FormName					VARCHAR(150),
	@FormURL					VARCHAR(150),	
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

		IF EXISTS(SELECT FormID FROM SM_M_Form WHERE RTRIM(UPPER(FormID)) = RTRIM(UPPER(@FormID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Form ID Already Exists!')
		END		
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert User ID 
			--------------------------------------------------------------------------------**/		

			INSERT INTO [dbo].[SM_M_Form]
				([ApplicationID]
				,[FormID]
				,[FormName]				
				,[FormURL]				
				,[DCreate]
				,[UCreate]				
				,[Recordstatus])
			 VALUES
				(@ApplicationID
				,@FormID
				,@FormName				
				,@FormURL									   
				,GETDATE()
				,@UserID								  
				,@RecordStatus)			
			
			DECLARE @IDX_M_Form AS BIGINT
			SET @IDX_M_Form = (SELECT SCOPE_IDENTITY())			

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Form, 'Data Sudah Disimpan')
				
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


