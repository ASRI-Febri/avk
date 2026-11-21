
-- =============================================
-- Author		: Anton
-- Create date	: 2019-04-24
-- Description	: Update Partner Address
-- =============================================

/*		
	EXEC [dbo].[USP_CM_PartnerAddress_Update] 1,2,2,2,'Trial street update','36135','Trial street update','XA.ADMIN','A'	
*/

CREATE PROCEDURE [dbo].[USP_CM_PartnerAddress_Update] 
	@IDX_M_PartnerAddress	BIGINT,	
	@IDX_M_Partner			BIGINT,
	@IDX_M_AddressType		BIGINT,
	@IDX_M_PostalCode		BIGINT,
	@Street					VARCHAR(1024),	
	@Zip					VARCHAR(32),
	@Notes					VARCHAR(8000),
	@IsDefault				CHAR(1),
	------------------------------------------------
	@UserID					VARCHAR(50),
	@RecordStatus			CHAR(1)		
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
		IF RTRIM(@Street) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Street information is required!')
		END

		IF RTRIM(@IDX_M_PostalCode) = '' OR RTRIM(@IDX_M_PostalCode) = '0'
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Invalid postal code!')
		END

		IF RTRIM(@IDX_M_AddressType) = '' OR RTRIM(@IDX_M_AddressType) = '0'
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Address type is invalid !')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			UPDATE [dbo].[GN_M_PartnerAddress] SET
				 [IDX_M_Partner]		= @IDX_M_Partner		
				,[IDX_M_AddressType]	= @IDX_M_AddressType
			    ,[IDX_M_PostalCode]		= @IDX_M_PostalCode
			    ,[Street]				= @Street				
			    ,[Zip]					= @Zip				
			    ,[Notes]				= @Notes	
				,[IsDefault]		    = @IsDefault
				,[UModified]			= @UserID
				,[DModified]			= GETDATE()
				,[RecordStatus]			= @RecordStatus
			WHERE IDX_M_PartnerAddress  = @IDX_M_PartnerAddress

			IF @IsDefault = 'Y'
			BEGIN
				UPDATE GN_M_PartnerAddress SET IsDefault = 'N'
				WHERE IDX_M_Partner = @IDX_M_Partner AND IDX_M_PartnerAddress <> @IDX_M_PartnerAddress
			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Partner, 'Data Sudah Disimpan')
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

