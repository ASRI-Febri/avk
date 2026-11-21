
-- =============================================
-- Author		:	Anton
-- Create date	:	11 JANUARI 2019
-- Description	:	Update Table Master COA Group 3
-- =============================================

/*	
	EXEC [dbo].[USP_GL_M_COAGroup3_Update] 'ASR', 'Alam Sutera', 'ASR1', 'Jalur Sutera Barat'

*/


CREATE PROCEDURE [dbo].[USP_GL_COAGroup3_Update] 
	@IDX_M_COAGroup3	INT,
	@IDX_M_COAGroup2	INT,
    @COAGroup3ID		VARCHAR(50),  
    @COAGroup3Name1		VARCHAR(150),
    @COAGroup3Name2		VARCHAR(150),
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
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Update Master Branch
			--------------------------------------------------------------------------------**/

			UPDATE [dbo].GL_M_COAGroup3 SET
					[IDX_M_COAGroup2] = @IDX_M_COAGroup2,
					[COAGroup3ID] = @COAGroup3ID, 
					[COAGroup3Name1] = @COAGroup3Name1,
					[COAGroup3Name2] = @COAGroup3Name2,	
					[DModified] = GETDATE(),					
					[UModified] = @UserID,														
					[RecordStatus] = @RecordStatus
			WHERE IDX_M_COAGroup3 = @IDX_M_COAGroup3
					
			
			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_COAGroup3, 'Data Sudah Disimpan')
				
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



