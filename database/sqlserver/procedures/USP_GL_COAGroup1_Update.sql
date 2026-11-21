
-- =============================================
-- Author		:	ANGGI
-- Create date	:	9 JANUARI 2019
-- Description	:	Update Table Master COA Group 1
-- =============================================

/*	
	EXEC [dbo].[USP_GL_M_COAGroup1_Update] 'ASR', 'Alam Sutera', 'ASR1', 'Jalur Sutera Barat'

*/


CREATE PROCEDURE [dbo].[USP_GL_COAGroup1_Update] 
	@IDX_M_COAGroup1	INT,
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
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Update Master Branch
			--------------------------------------------------------------------------------**/

			UPDATE [dbo].GL_M_COAGroup1 SET
					[IDX_M_COAType] = @IDX_M_COAType,
					[COAGroup1ID] = @COAGroup1ID, 
					[COAGroup1Name1] = @COAGroup1Name1,
					[COAGroup1Name2] = @COAGroup1Name2,	
					[DModified] = GETDATE(),					
					[UModified] = @UserID,														
					[RecordStatus] = @RecordStatus
			WHERE IDX_M_COAGroup1 = @IDX_M_COAGroup1
					
			
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



