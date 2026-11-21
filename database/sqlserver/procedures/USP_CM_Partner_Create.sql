
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Master  Partner
-- =============================================

/*		
	EXEC USP_CM_Partner_Create '','','Ibu','Emilia Indriati Wijaya','EIW',1,234324,'','2019-01-09','','','23432','','','234324','N','N','N','N','','',0,0,'',0,0,'guest','A'
*/

CREATE PROCEDURE [dbo].[USP_CM_Partner_Create] 	
	@PartnerID					VARCHAR(50),
	@BarcodeMember				VARCHAR(50),
	@Prefix						VARCHAR(50),
	@PartnerName				VARCHAR(150),	
	@PartnerAlias				VARCHAR(32),
	@Gender						CHAR(1),
	@SingleIdentityNumber		VARCHAR(64),
	@TaxIdentityNumber			VARCHAR(64),
	@DateOfBirth				VARCHAR(10) NULL,
	@PlaceOfBirth				VARCHAR(64),
	@Email						VARCHAR(50),	
	@Phone1						VARCHAR(50),
	@Phone2						VARCHAR(50),
	@FaxNo						VARCHAR(50),
	@MobilePhone				VARCHAR(50),
	@Remarks					VARCHAR(256),
	@IsSupplier					CHAR(1),
	@IsCustomer					CHAR(1),
	@IsCompany					CHAR(1),
	@IsMember					CHAR(1),
	@StartDate					VARCHAR(10) NULL,
	@EndDate					VARCHAR(10) NULL,
	@ARAccount					BIGINT,
	@APAccount					BIGINT,
	@ActiveStatus				CHAR(1),
	@CreditLimit				DECIMAL(22,2),	
	@DiscountMember				DECIMAL(5,2),
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
		--SET @_FormID = 'MS-BPAR-001'

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		/***************************************************************************************/
		
		/** Cek Partner Name **/
		IF RTRIM(@PartnerName) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Partner name is required!')
		END
		
		--INSERT INTO @TableLog VALUES ('error',0,'Test Error!')

		/** Generate Partner ID **/
		--DECLARE @LastID AS INT
		--SELECT @LastID = COUNT(IDX_GN_M_Partner) FROM GN_M_Partner

		--SET @PartnerID = 'BP' + CONVERT(VARCHAR,@LastID + 1)

		SET @PartnerID = LEFT(UPPER(RTRIM(@PartnerID)),3)

		/** Check existing user id **/
		IF EXISTS(SELECT PartnerID	FROM GN_M_Partner WHERE RTRIM(@PartnerID) <> '' AND RTRIM(UPPER(PartnerID)) = RTRIM(UPPER(@PartnerID)))
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'PartnerID Already Exists!')
		END	

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 
			
			-- GENERATE PARTNER ID
			DECLARE @_LastNumber			AS INTEGER			
			DECLARE @_Year					AS VARCHAR(2)
			DECLARE @_PartnerID				AS VARCHAR(20)

			SET @_LastNumber = 0

			IF EXISTS(	SELECT TOP 1 PartnerID
						FROM GN_M_Partner  
						WHERE SUBSTRING(PartnerID,4,2) = RIGHT(YEAR(GETDATE()),2)
						ORDER BY PartnerID DESC)
			BEGIN

				SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(PartnerID),4))
				FROM GN_M_Partner 
				WHERE SUBSTRING(PartnerID,4,2) = RIGHT(YEAR(GETDATE()),2)
				ORDER BY PartnerID DESC

			END					

			SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(GETDATE())),2)

			/** Set Sales Order No **/
			SET @_PartnerID = 'BP-' + @_Year + RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),5)

			INSERT INTO [dbo].[GN_M_Partner]
			   ([Prefix]
			   ,[PartnerID]
			   ,[BarcodeMember]
			   ,[PartnerName]
			   ,[PartnerAlias]
			   ,[Gender]
			   ,[SingleIdentityNumber]
			   ,[TaxIdentityNumber]
			   ,[DateOfBirth]
			   ,[PlaceOfBirth]
			   ,[Email]
			   ,[Phone1]
			   ,[Phone2]
			   ,[FaxNo]
			   ,[MobilePhone]
			   ,[Remarks]
			   ,[IsSupplier]
			   ,[IsCustomer]
			   ,[IsCompany]
			   ,[IsMember]
			   ,[StartDate]
			   ,[EndDate]
			   ,[ARAccount]
			   ,[APAccount]
			   ,[ActiveStatus]
			   ,[CreditLimit]	
			   ,[DiscountMember]		   
			   ,[UCreate]
			   ,[DCreate]			  
			   ,[RecordStatus])
		 VALUES
			   (@Prefix
			   ,@_PartnerID
			   ,@BarcodeMember
			   ,@PartnerName
			   ,@PartnerAlias
			   ,@Gender
			   ,@SingleIdentityNumber
			   ,@TaxIdentityNumber
			   ,@DateOfBirth
			   ,@PlaceOfBirth
			   ,@Email
			   ,@Phone1
			   ,@Phone2
			   ,@FaxNo
			   ,@MobilePhone
			   ,@Remarks
			   ,@IsSupplier
			   ,@IsCustomer
			   ,@IsCompany		
			   ,@IsMember	  
			   ,@StartDate
			   ,@EndDate
			   ,@ARAccount
			   ,@APAccount
			   ,@ActiveStatus
			   ,@CreditLimit
			   ,@DiscountMember
			   ,@UserID
			   ,GETDATE()			  
			   ,@RecordStatus)

			DECLARE @IDX_M_Partner AS BIGINT
			SET @IDX_M_Partner = (SELECT SCOPE_IDENTITY())		
		
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

