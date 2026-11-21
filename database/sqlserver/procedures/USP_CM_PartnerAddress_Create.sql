
-- =============================================
-- Author		: Anton
-- Create date	: 2019-04-24
-- Description	: Create Partner Address
-- =============================================

/*		
	EXEC USP_CM_PartnerAddress_Create 1,1,1,'Trial street testing','36134','Trial street testing','XA.ADMIN','A'
*/

CREATE PROCEDURE [dbo].[USP_CM_PartnerAddress_Create] 	
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
		--SET @_FormID = 'MS-BPAR-001'

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		/***************************************************************************************/
		
		/** Cek Address **/
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

			INSERT INTO [dbo].[GN_M_PartnerAddress]
			   ([IDX_M_Partner]
			   ,[IDX_M_AddressType]
			   ,[IDX_M_PostalCode]
			   ,[Street]
			   ,[Zip]
			   ,[IsDefault]
			   ,[Notes]	   
			   ,[UCreate]
			   ,[DCreate]			  
			   ,[RecordStatus])
		 VALUES
			   (@IDX_M_Partner		
			   ,@IDX_M_AddressType	
			   ,@IDX_M_PostalCode	
			   ,@Street				
			   ,@Zip			
			   ,@IsDefault	
			   ,@Notes
			   ,@UserID
			   ,GETDATE()			  
			   ,@RecordStatus)

			DECLARE @IDX_M_PartnerAddress AS BIGINT
			SET @IDX_M_PartnerAddress = (SELECT SCOPE_IDENTITY())		

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

