-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Delete Table Journal Detail
-- =============================================

/*		
	EXEC [dbo].[USP_GL_JournalDetail_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalDetail_Delete] 	
	@IDX_T_JournalDetail		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY		
		
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
		--SET @_FormID = 'GL-JOUR-004' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END

		IF EXISTS(	SELECT JD.IDX_T_JournalHeader
					FROM GL_T_JournalDetail JD
					INNER JOIN GL_T_JournalHeader JH ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
					WHERE JD.IDX_T_JournalDetail = @IDX_T_JournalDetail AND JH.PostingStatus = 'P')
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Can not delete journal that already posted !')
		END
		

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			DECLARE @_IDX_T_JournalHeader		BIGINT

			SELECT @_IDX_T_JournalHeader = IDX_T_JournalHeader 
			FROM GL_T_JournalDetail 
			WHERE IDX_T_JournalDetail = @IDX_T_JournalDetail

			DELETE GL_T_JournalDetail 
			WHERE IDX_T_JournalDetail = @IDX_T_JournalDetail				

			INSERT INTO @TableLog VALUES ('success', @_IDX_T_JournalHeader, 'Data Sudah Dihapus')
		END

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



