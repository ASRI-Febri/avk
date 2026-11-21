
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table COA
-- =============================================

/*	
	
	EXEC [dbo].[USP_COA_Create] 
					
	
*/

CREATE PROCEDURE [dbo].[USP_GL_COA_Create] 	
	@IDX_M_COACategory			INT,
	@IDX_M_COAType				INT,
	@COAFlag					CHAR(1),
	@COAID						VARCHAR(50),
	@COADesc					VARCHAR(150),
	@COADesc2					VARCHAR(150),	
	@ParentID					BIGINT,
	@IDX_M_CashflowIn			BIGINT,
	@IDX_M_CashflowOut			BIGINT,
	@AllowJournalEntry			CHAR(1),
	@IsReconcile				CHAR(1),
	@DefaultBalance				CHAR(1),
	@COAStatus					CHAR(1),
	@COAGroup1					INT,
	@COAGroup2					INT,
	@COAGroup3					INT,
	------------------------------------------------
	@UserID						VARCHAR(50),
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

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'GL-COAC-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END

		IF EXISTS (SELECT 1 FROM GL_M_COA WHERE COAID = @COAID)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'COA ID already exists!')
		END	

		--IF (LEN(@COAID) <> 10)
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'COA ID must contain exactly 10 amount of characters!')
		--END	

		--IF (SELECT CategoryType FROM CM_M_CashflowID WHERE IDX_M_CashflowID = @IDX_M_CashflowIn) = 'H'
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'Selected CashflowID-In type level cannot be Parent!')
		--END	

		--IF (SELECT CategoryType FROM CM_M_CashflowID WHERE IDX_M_CashflowID = @IDX_M_CashflowOut) = 'H'
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'Selected CashflowID-Out type level cannot be Parent!')
		--END	

		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			INSERT INTO [dbo].GL_M_COA (
				[IDX_M_COACategory],[IDX_M_COAType],[COAFlag],[COAID],
				[COADesc],[COADesc2],[ParentID],[IDX_M_CashflowIn],[IDX_M_CashflowOut],[AllowJournalEntry],[IsReconcile],[DefaultBalance],                     
				[COAStatus],[COAGroup1],[COAGroup2],[COAGroup3],[TranslationRate],[UCreate],[DCreate],[RecordStatus])
			 VALUES (
				@IDX_M_COACategory,@IDX_M_COAType,@COAFlag,@COAID,
				@COADesc,@COADesc2,@ParentID,@IDX_M_CashflowIn,@IDX_M_CashflowOut,@AllowJournalEntry,@IsReconcile,@DefaultBalance,						
				'A',@COAGroup1,@COAGroup2,@COAGroup3,'E',@UserID,GETDATE(),@RecordStatus)		
			
			DECLARE @IDX_GL_M_COA AS BIGINT
			SET @IDX_GL_M_COA= (SELECT SCOPE_IDENTITY())	
		
			INSERT INTO @TableLog VALUES ('success', @IDX_GL_M_COA, 'Data Sudah Disimpan')

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


