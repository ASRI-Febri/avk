
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 03 June 2023
-- Description:	Save table GN_M_Company
-- =============================================

--EXEC [dbo].USP_GN_Company_Save @IDX_M_BrandItem,'@BrandID','@BrandDesc','@BrandInitial','@UserID','@RecordStatus'

CREATE PROCEDURE [dbo].[USP_GN_Company_Save] 
	@IDX_M_Company				INT,
	@IDX_M_Parent				INT,
	@IDX_M_Currency				INT,
	@CompanyID					CHAR(1),
	@CompanyName				VARCHAR(50),
	@CompanyAlias				VARCHAR(150),	
	@SIUP						VARCHAR(150),
	@NPWP						VARCHAR(50),
	@PKPIdentityNumber			VARCHAR(50),
	@PKPDate					DATE,
	@Phone						VARCHAR(50),
	@Fax						VARCHAR(50),
	@Email						VARCHAR(50),
	@LegalAddress				VARCHAR(250),
	@Country					VARCHAR(50),
	@Province					VARCHAR(50),
	@City						VARCHAR(50),
	@Subdistrict				VARCHAR(50),
	@District					VARCHAR(50),
	@Zip						VARCHAR(50),
	@Logo						VARCHAR(50),
	@Website					VARCHAR(50),
	@Remarks					VARCHAR(150),
	------------------------------------------------
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

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'CM-PINV-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END

		IF EXISTS (SELECT 1 FROM GN_M_Company WHERE CompanyID = @CompanyID AND IDX_M_Company <> @IDX_M_Company)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Company ID already exists!')
		END			
		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			IF @IDX_M_Company = 0
			BEGIN				

				INSERT INTO [dbo].[GN_M_Company]
				   ([IDX_M_Parent]
				   ,[IDX_M_Currency]
				   ,[CompanyID]
				   ,[CompanyName]
				   ,[CompanyAlias]
				   ,[SIUP]
				   ,[NPWP]
				   ,[PKPIdentityNumber]
				   ,[PKPDate]
				   ,[Phone]
				   ,[Fax]
				   ,[Email]
				   ,[LegalAddress]
				   ,[Country]
				   ,[Province]
				   ,[City]
				   ,[Subdistrict]
				   ,[District]
				   ,[Zip]
				   ,[Logo]
				   ,[Website]
				   ,[Remarks]
				   ,[DCreate]
				   ,[UCreate]				   
				   ,[RecordStatus])
				VALUES
				   (@IDX_M_Parent
				   ,@IDX_M_Currency
				   ,@CompanyID
				   ,@CompanyName
				   ,@CompanyAlias
				   ,@SIUP
				   ,@NPWP
				   ,@PKPIdentityNumber
				   ,@PKPDate
				   ,@Phone
				   ,@Fax
				   ,@Email
				   ,@LegalAddress
				   ,@Country
				   ,@Province
				   ,@City
				   ,@Subdistrict
				   ,@District
				   ,@Zip
				   ,@Logo
				   ,@Website
				   ,@Remarks
				   ,GETDATE()
				   ,@UserID
				   ,@RecordStatus)

			END
			ELSE
			BEGIN
				UPDATE [dbo].[GN_M_Company]
				SET 
					 [IDX_M_Parent] = @IDX_M_Parent
					,[IDX_M_Currency] = @IDX_M_Currency
					,[CompanyID] = @CompanyID 
					,[CompanyName] = @CompanyName
					,[CompanyAlias] = @CompanyAlias
					,[SIUP] = @SIUP
					,[NPWP] = @NPWP
					,[PKPIdentityNumber] = @PKPIdentityNumber
					,[PKPDate] = @PKPDate
					,[Phone] = @Phone
					,[Fax] = @Fax
					,[Email] = @Email
					,[LegalAddress] = @LegalAddress
					,[Country] = @Country
					,[Province] = @Province
					,[City] = @City
					,[Subdistrict] = @Subdistrict
					,[District] = @District
					,[Zip] = @Zip
					,[Logo] = @Logo
					,[Website] = @Website
					,[Remarks] = @Remarks
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_M_Company = @IDX_M_Company	
			END
			
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Company, 'Data Sudah Disimpan')
			
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


