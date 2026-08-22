SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create and update Busienss Partner
-- Mod			:	Samuel Febrianto, 22 Aug 2026
-- Mod Desc		:	Tambah @IDX_M_IDType (jenis identitas: KTP/SIM/Paspor/KITAS).
--					Ditaruh sebagai parameter terakhir dengan default NULL supaya
--					pemanggil lama yang mengirim parameter posisional tetap jalan.
-- =============================================

/*		
	EXEC [dbo].[USP_GN_Partner_Save] 'Admin','Administrator','',0,'','','admin','A'	
*/
IF OBJECT_ID('[dbo].[USP_GN_Partner_Save]','P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_Partner_Save]
GO

CREATE PROCEDURE [dbo].[USP_GN_Partner_Save] 
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
	@IsDTTOT					CHAR(1),
	@StartDate					VARCHAR(10) NULL,
	@EndDate					VARCHAR(10) NULL,
	@ARAccount					BIGINT,
	@APAccount					BIGINT,
	@ActiveStatus				CHAR(1),
	@CreditLimit				DECIMAL(22,2),
	@DiscountMember				DECIMAL(5,2),
	------------------------------------------------
	@UserID						VARCHAR(50),
	@RecordStatus				CHAR(1),
	------------------------------------------------
	-- Jenis identitas (KTP/SIM/Paspor/KITAS). Ditaruh paling akhir dengan
	-- default NULL supaya pemanggil lama yang mengirim parameter secara
	-- posisional tidak perlu diubah.
	@IDX_M_IDType				BIGINT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Pemanggil mengirim parameter secara posisional dan tidak bisa mengirim
	-- NULL, jadi 0 diperlakukan sebagai "jenis identitas belum ditentukan".
	IF ISNULL(@IDX_M_IDType,0) = 0 SET @IDX_M_IDType = NULL

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

		/** Cek Duplicate NIK
			Satu orang hanya boleh punya satu data konsumen; NIK kembar membuat
			riwayat transaksinya terpecah dan menyulitkan pelaporan PPATK.

			Yang diperiksa hanya nomor yang berbentuk identitas sungguhan, yaitu
			seluruhnya angka dan minimal 8 digit. Data lama memakai isian
			penampung seperti '-' dan '0' untuk badan usaha, dan itu sengaja
			dibiarkan lolos supaya penyimpanan data lama tidak ikut terhalang. **/
		DECLARE @_NIK AS VARCHAR(64) = RTRIM(LTRIM(ISNULL(@SingleIdentityNumber,'')))

		IF LEN(@_NIK) >= 8 AND @_NIK NOT LIKE '%[^0-9]%'
		BEGIN
			DECLARE @_NamaPemilikNIK AS VARCHAR(150)

			SELECT TOP 1 @_NamaPemilikNIK = RTRIM(PartnerName)
			FROM GN_M_Partner WITH(NOLOCK)
			WHERE RTRIM(LTRIM(ISNULL(SingleIdentityNumber,''))) = @_NIK
				AND IDX_M_Partner <> @IDX_M_Partner
				AND RTRIM(ISNULL(RecordStatus,'A')) = 'A'
			ORDER BY IDX_M_Partner

			IF @_NamaPemilikNIK IS NOT NULL
			BEGIN
				INSERT INTO @TableLog
				VALUES ('error',0,'NIK ' + @_NIK + ' sudah terdaftar atas nama ' + @_NamaPemilikNIK + '!')
			END
		END

		IF RTRIM(@ActiveStatus) = '' OR @ActiveStatus = '0'
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Partner status is required!')
		END

		--INSERT INTO @TableLog VALUES ('error',0,'Test Error!')

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 
			
			IF @IDX_M_Partner = 0
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
				   ,[IsDTTOT]
				   ,[StartDate]
				   ,[EndDate]
				   ,[ARAccount]
				   ,[APAccount]
				   ,[ActiveStatus]
				   ,[CreditLimit]	
				   ,[DiscountMember]		   
				   ,[UCreate]
				   ,[DCreate]			  
				   ,[RecordStatus]
				   ,[IDX_M_IDType])
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
				   ,@IsDTTOT	  
				   ,@StartDate
				   ,@EndDate
				   ,@ARAccount
				   ,@APAccount
				   ,@ActiveStatus
				   ,@CreditLimit
				   ,@DiscountMember
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus
				   ,@IDX_M_IDType)
				   				
				SET @IDX_M_Partner = (SELECT SCOPE_IDENTITY())

			END
			ELSE
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
					,[IsDTTOT] = @IsDTTOT
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
					,[IDX_M_IDType] = @IDX_M_IDType
				WHERE IDX_M_Partner = @IDX_M_Partner

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
GO
