-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Delete Branch for specific user
-- =============================================
/*		
	EXEC [dbo].[USP_SM_User_DeleteBranch] 1	
*/

CREATE PROCEDURE [dbo].[USP_SM_User_DeleteProject] 	
	@IDX_M_UserProject					BIGINT,		
	------------------------------------------------
	@UserID								VARCHAR(50),
	@RecordStatus						CHAR(1)	
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

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			DECLARE @_IDX_M_User		BIGINT			

			SELECT @_IDX_M_User = IDX_M_User FROM SM_M_UserProject WHERE IDX_M_UserProject = @IDX_M_UserProject

			UPDATE SM_M_UserProject SET RecordStatus = 'I' WHERE IDX_M_UserProject = @IDX_M_UserProject

			INSERT INTO @TableLog VALUES ('success', @_IDX_M_User, 'Data Sudah Disimpan')			
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

