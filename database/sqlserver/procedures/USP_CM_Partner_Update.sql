
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update  Partner
-- =============================================

/*		
	EXEC [dbo].[USP_CM_Partner_Update] 'Admin','Administrator','',0,'','','admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_CM_Partner_Update] 
	@IDX_M_Partner				BIGINT,	
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
		--SET @_FormID = 'MS-BPAR-002'

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
		
		/** Cek Duplicate Partner ID **/
		IF EXISTS(	SELECT PartnerID	
					FROM GN_M_Partner 
					WHERE RTRIM(@PartnerID) <> '' AND RTRIM(UPPER(PartnerID)) = RTRIM(UPPER(@PartnerID)) AND IDX_M_Partner <> @IDX_M_Partner)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Partner ID Already Exists!')
		END

		--INSERT INTO @TableLog VALUES ('error',0,'Test Error!')

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			UPDATE [dbo].[GN_M_Partner] SET
				 [PartnerID] = @PartnerID
				,[BarcodeMember] = @BarcodeMember
				,[Prefix] = @Prefix
				,[PartnerName] = @PartnerName
				,[PartnerAlias] = @PartnerAlias
				,[Gender] = @Gender
				,[SingleIdentityNumber] = @SingleIdentityNumber
				,[TaxIdentityNumber] = @TaxIdentityNumber
				,[DateOfBirth] = @DateOfBirth
				,[PlaceOfBirth] = @PlaceOfBirth
				,[Email] = @Email
				,[Phone1] = @Phone1
				,[Phone2] = @Phone2
				,[FaxNo] = @FaxNo
				,[MobilePhone] = @MobilePhone
				,[Remarks] = @Remarks	
				,[IsSupplier] = @IsSupplier
				,[IsCustomer] = @IsCustomer
				,[IsCompany] = @IsCompany
				,[IsMember] = @IsMember 
				,[StartDate] = @StartDate
				,[EndDate] = @EndDate
				,[ARAccount] = @ARAccount
				,[APAccount] = @APAccount
				,[ActiveStatus] = @ActiveStatus
				,[CreditLimit] = @CreditLimit	
				,[DiscountMember] = @DiscountMember					
				,[UModified] = @UserID
				,[DModified] = GETDATE()
				,[RecordStatus] = @RecordStatus
			WHERE IDX_M_Partner = @IDX_M_Partner				
		
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

