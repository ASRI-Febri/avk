
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Create and update valas change / pecahan valas
-- =============================================

/*		
	EXEC [dbo].[USP_MC_ValasChange_Save] 'Admin','Administrator','',0,'','','admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_MC_ValasChange_Save] 
	@IDX_M_ValasChange				BIGINT,	
	@ValasChangeID		        VARCHAR(50),
	@ValasChangeName	        VARCHAR(50),
	@ValasChangeNumber		    VARCHAR(50),	
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
		--SET @_FormID = 'MS-BPAR-002'

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		/***************************************************************************************/
		
		/** Cek Partner Name **/
		IF RTRIM(@ValasChangeName) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nama pecahan belum diisi!')
		END
		
		/** Cek Duplicate Partner ID **/
		IF EXISTS(	SELECT ValasChangeID	
					FROM MC_M_ValasChange 
					WHERE RTRIM(@ValasChangeID) <> '' AND RTRIM(UPPER(ValasChangeID)) = RTRIM(UPPER(@ValasChangeID)) 
                    AND IDX_M_ValasChange <> @IDX_M_ValasChange)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Kode pecahan sudah ada!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 
			
			IF @IDX_M_ValasChange = 0
			BEGIN				

				INSERT INTO [dbo].[MC_M_ValasChange]
				   ([ValasChangeID]
                   ,[ValasChangeName]
                   ,[ValasChangeNumber]		   
				   ,[UCreate]
				   ,[DCreate]			  
				   ,[RecordStatus])
			 VALUES
				   (@ValasChangeID
                   ,@ValasChangeName
                   ,@ValasChangeNumber
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus)
				   				
				SET @IDX_M_ValasChange = (SELECT SCOPE_IDENTITY())

			END
			ELSE
			BEGIN

				UPDATE [dbo].[MC_M_ValasChange] SET
					 [ValasChangeID] = @ValasChangeID
					,[ValasChangeName] = @ValasChangeName
					,[ValasChangeNumber] = @ValasChangeNumber				
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_M_ValasChange = @IDX_M_ValasChange

			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_M_ValasChange, 'Data Sudah Disimpan')
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

