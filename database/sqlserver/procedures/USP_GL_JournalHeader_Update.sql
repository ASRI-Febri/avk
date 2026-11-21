-- =======================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 05 Feb 2018
-- Description	: Update Table Journal Header
-- Modified		: 2024-06-04 by Anton --> Added validation cannot change company / branch when already have voucherno
-- =======================================================================================================================================

/* 	
	EXEC USP_GL_JournalHeader_Update 1	
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalHeader_Update]
	@IDX_T_JournalHeader		BIGINT,
	@IDX_M_Company				BIGINT,
	@IDX_M_Branch				BIGINT,	
	@IDX_M_JournalType			BIGINT,
	@IDX_M_Partner				BIGINT,
	@ApplicationID				BIGINT,
	@IDX_ReferenceNo			BIGINT,
	@ReferenceNo				VARCHAR(50),
	@VoucherNo					VARCHAR(50),
	@JournalDate				DATETIME,
	@RemarkHeader				VARCHAR(5000),
	@PartnerDesc				VARCHAR(50),
	@PostingStatus				CHAR(1),
	--@PostingDate				DATETIME NULL,	
	--@PostedBy					VARCHAR(50),
	@DebetAmount				DECIMAL(24,4),
	@CreditAmount				DECIMAL(24,4),
	@JournalSource				CHAR(1),
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
		
		BEGIN TRANSACTION;

		DECLARE @_LocationID AS VARCHAR(50)
		DECLARE @_ItemSKU AS VARCHAR(10)
		DECLARE @_LastNumber AS INTEGER

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		DECLARE @_CountDetail AS INT

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'GL-JOUR-002' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		--------------------------------------------------------------------------------------
		IF (SELECT PostingStatus FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) = 'P'
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Transaction Already Posted!')
		END

		IF (ISNULL(@IDX_M_Partner,0)) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Please Select Business Partner!')
		END

		IF (SELECT LEFT(VoucherNo,5) FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) <> 'DRAFT'
		BEGIN
			DECLARE @Current_Company BIGINT
			DECLARE @Current_Branch BIGINT
			
			SET @Current_Company = (SELECT IDX_M_Company FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader)
			SET @Current_Branch = (SELECT IDX_M_Branch FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader)

			IF (@Current_Company <> @IDX_M_Company)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'VoucherNo Already Exist, Cannot Change Company Information. Please Void & Create New Transaction!')
			END

			IF (@Current_Branch <> @IDX_M_Branch)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'VoucherNo Already Exist, Cannot Change Branch Information. Please Void & Create New Transaction!')
			END
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN			

			UPDATE [dbo].[GL_T_JournalHeader] SET
				 [IDX_M_Company] = @IDX_M_Company
				,[IDX_M_Branch] = @IDX_M_Branch				
				,[IDX_M_JournalType] = @IDX_M_JournalType
				,[IDX_M_Partner] = @IDX_M_Partner			
				,[ApplicationID] = @ApplicationID
				,[IDX_ReferenceNo] = @IDX_ReferenceNo
				,[ReferenceNo] = @ReferenceNo
				,[VoucherNo] = @VoucherNo
				,[JournalDate] = @JournalDate			
				,[RemarkHeader] = @RemarkHeader
				,[PartnerDesc] = @PartnerDesc
				,[PostingStatus] = @PostingStatus
				--,[PostingDate] = @PostingDate
				--,[PostedBy] = @PostedBy
				,[DebetAmount] = @DebetAmount
				,[CreditAmount] = @CreditAmount
				,[JournalSource] = @JournalSource
				,[UModified] = @UserID
				,[DModified] = GETDATE()		  
				,[RecordStatus] = @RecordStatus
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader			

			INSERT INTO @TableLog VALUES ('success', @IDX_T_JournalHeader, 'Data Sudah Disimpan')
				
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



