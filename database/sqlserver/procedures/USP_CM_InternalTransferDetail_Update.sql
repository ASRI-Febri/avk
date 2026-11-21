-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update Table Internal Transfer Detail
-- =============================================

/*	
	EXEC [dbo].[USP_CM_InternalTransferDetail_Update] 
					 2
					,1					
					,2
					,1
					,'PINV-0518-0001'
					,18
					,5000
					,'Bayar kedua kali'					
					,'1406069'
					,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_InternalTransferDetail_Update] 	
	@IDX_T_InternalTransferDetail			BIGINT,
	@IDX_T_InternalTransferHeader			BIGINT,	
	@COADetail								BIGINT,			
	@TransferAmount							DECIMAL(22,2),	
	@RemarkDetail							VARCHAR(500),		
	--------------------------------------------------------------	
	@UserID									VARCHAR(10),
	@RecordStatus							CHAR(1)	
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
		/*
		DECLARE @_FormID AS VARCHAR(20)
		SET @_FormID = ''

		DECLARE @Output INT
		EXEC USP_CheckUserForm @UserID,@_FormID, @Output OUT

		IF @Output <> 1
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		END
		*/
		/****************************************************************************/		

		IF NOT EXISTS(SELECT IDX_M_COA FROM GL_M_COA WHERE IDX_M_COA = @COADetail)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Invalid chart of account!')
		END		

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN					

			/**----------------------------------------------------------------------------- 
											Insert Internal Transfer Header 
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[CM_T_InternalTransferDetail] SET
				    [IDX_T_InternalTransferHeader] = IDX_T_InternalTransferHeader				  
				   ,[COADetail] = @COADetail
				   ,[TransferAmount] = @TransferAmount
				   ,[RemarkDetail] = @RemarkDetail				  			  				  
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()				  
				   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_InternalTransferDetail = @IDX_T_InternalTransferDetail

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferDetail, 'Data Sudah Disimpan')
			
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



