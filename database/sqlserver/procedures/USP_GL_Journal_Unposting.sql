-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 06 Feb 2018
-- Description	: Journal Unposting
-- Mod			: 2020-10-02 by Anton --> Added Journal Closing Period Validation
-- ==========================================================================================

/*
	BEGIN TRAN
	EXEC [dbo].[USP_GL_Journal_Unposting] 
			1
		,'2018-09-27'
		,'TEst'
		,'1406069'
		,'A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_GL_Journal_Unposting]
	@IDX_T_JournalHeader		BIGINT,
	@UnpostingDate				DATE,
	@PostingNotes				VARCHAR(500),
	@UserID						VARCHAR(50)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_JournalPeriod			AS VARCHAR(6)
			DECLARE @_IDX_M_JournalType		AS INT
			DECLARE @_GLStatus				AS BIT
			DECLARE @_CountLog				AS INT
			

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID		VARCHAR(20)
			--DECLARE @_RoleID		CHAR(1)
			--DECLARE @Output			INT

			--SET @_FormID = 'GL-JOUR-006' -- Journal Posting
			--SET @_RoleID = 'R'
			
			--EXEC USP_SM_CheckUserForm @UserID, @_FormID, @_RoleID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			-- ===========================================================================================================
			-- Check GLStatus in fiscal period
			-- ===========================================================================================================
			DECLARE @_ValidationDate DATE
			
			SELECT	@_ValidationDate = PostingDate, @_IDX_M_JournalType = IDX_M_JournalType
			FROM GL_T_JournalHeader WITH(NOLOCK) 
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@_ValidationDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Cannot Reverse Because Journal Period Already Closed!')
			END	
			
			--IF @_IDX_M_JournalType <> 5
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Unposting Journal Only For Journal Memorial Type!')
			--END					

			-- ===========================================================================================================
			--Check Error Log
			-- ===========================================================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			-- ===========================================================================================================
			-- If no error, then post journal
			-- ===========================================================================================================
			IF @_CountLog = 0
			BEGIN 				

				UPDATE GL_T_JournalHeader SET 
					 PostingStatus = 'U'
					,PostedBy = NULL
					,PostingNotes = NULL
					,PostingDate = NULL
					,UModified = @UserID
					,DModified = GETDATE() 
				WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader				

				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[GL_T_JournalHeaderLog]
					([IDX_T_JournalHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_JournalHeader, 'Unposting', GETDATE(), @PostingNotes, @UserID, GETDATE(), 'A'

				INSERT INTO @TableLog VALUES ('success', @IDX_T_JournalHeader, 'Data Sudah Disimpan')
					
			END			

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog		

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_JournalHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog

		--SELECT 	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
			
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



