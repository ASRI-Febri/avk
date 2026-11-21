-- =============================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 29 Jan 2018
-- Description	: Update Table Journal Detail
-- Mod			: 2020-09-21 by Anton --> Grab @COADescription information
--									  --> Added validation for enabling detail notes adjustment when journal status transaction already POSTED
--				  2024-06-05 by Anton --> Added validation on Project Information
-- =============================================================================================================================================

/*	
	BEGIN TRAN
		EXEC USP_GL_JournalDetail_Update 
			1462, --@IDX_T_JournalDetail
			600, --@IDX_T_JournalHeader
			0, --@IDX_M_Project
			0, --@IDX_M_Department
			66, --@IDX_M_COA
			0, --@IDX_M_Partner
			0, --@JournalSeqNo
			'', --@COADescription
			'TERIMA CN OTO CREDI NUANSA TIMUR LESTARI - ANTON', --@RemarkDetail
			1, --@OriginalCurrencyID
			0, --@ODebetAmount
			7210000, --@OCreditAmount
			1, --@ExchangeRate
			0, --@BaseCurrencyID
			0, --@BDebetAmount
			0, --@BCreditAmount
			1305276, --@UserID
			'A' --@RecordStatus
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalDetail_Update] 	
	@IDX_T_JournalDetail		BIGINT,
	@IDX_T_JournalHeader		BIGINT,
	@IDX_M_Project				BIGINT,	
	@IDX_M_Department			BIGINT,
	@IDX_M_COA					BIGINT,
	@IDX_M_Partner				BIGINT,
	@JournalSeqNo				INT,
	@COADescription				VARCHAR(50),
	@RemarkDetail				VARCHAR(5000),
	@OriginalCurrencyID			INT,
	@ODebetAmount				DECIMAL(24,4),
	@OCreditAmount				DECIMAL(24,4),
	@ExchangeRate				DECIMAL(5,2),
	@BaseCurrencyID				INT,
	@BDebetAmount				DECIMAL(24,4),
	@BCreditAmount				DECIMAL(24,4),
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

		DECLARE @_IDX_M_COA				BIGINT
		DECLARE @_IDX_M_Partner			BIGINT
		DECLARE @_RemarkDetail			VARCHAR(50)
		DECLARE @_OriginalCurrencyID	INT
		DECLARE @_ODebetAmount			DECIMAL(24,4)
		DECLARE @_OCreditAmount			DECIMAL(24,4)
		DECLARE @_ExchangeRate			DECIMAL(5,2)
		DECLARE @_PostingStatus			CHAR(1)

		SELECT	@_IDX_M_COA				= JD.IDX_M_COA,
				@_IDX_M_Partner			= JD.IDX_M_Partner,
				@_RemarkDetail			= JD.RemarkDetail,
				@_OriginalCurrencyID	= JD.OriginalCurrencyID,
				@_ODebetAmount			= JD.ODebetAmount,
				@_OCreditAmount			= JD.OCreditAmount,
				@_ExchangeRate			= JD.ExchangeRate,
				@_PostingStatus			= JH.PostingStatus
		FROM GL_T_JournalDetail JD WITH(NOLOCK) 
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		WHERE JD.IDX_T_JournalDetail = @IDX_T_JournalDetail
		
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

		IF @_PostingStatus = 'P'
		BEGIN
			IF 	(	@_IDX_M_COA			 <> @IDX_M_COA			OR
					@_IDX_M_Partner		 <> @IDX_M_Partner		OR
					@_OriginalCurrencyID <> @OriginalCurrencyID OR
					@_ODebetAmount		 <> @ODebetAmount		OR
					@_OCreditAmount		 <> @OCreditAmount		OR
					@_ExchangeRate		 <> @ExchangeRate			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Journal already Posted! You can only change Detail Notes!')
			END

			IF @_RemarkDetail = @RemarkDetail
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Change Detail Notes or Cancel your Detail Update Action!')
			END
		END

		IF @ODebetAmount = 0 AND @OCreditAmount = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Debet and Credit are zero!')
		END

		IF @ODebetAmount > 0 AND @OCreditAmount > 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please choose only one, Debet or Credit !')
		END

		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_JournalHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN			

			DECLARE @_IDX_M_Company		INT
			DECLARE @_BaseCurrency		INT
			 
			SELECT @_IDX_M_Company = IDX_M_Company, @IDX_M_Partner = IDX_M_Partner  
			FROM GL_T_JournalHeader WITH(NOLOCK) 
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

			SELECT @_BaseCurrency = IDX_M_Currency FROM GN_M_Company WITH(NOLOCK) WHERE IDX_M_Company = @_IDX_M_Company
			SELECT @COADescription = COADesc FROM GL_M_COA WITH(NOLOCK) WHERE IDX_M_COA = @IDX_M_COA

			UPDATE [dbo].[GL_T_JournalDetail] SET
			    [IDX_T_JournalHeader] = @IDX_T_JournalHeader
			   ,[IDX_M_Project] = @IDX_M_Project
			   ,[IDX_M_Department] = @IDX_M_Department
			   ,[IDX_M_COA] = @IDX_M_COA
			   ,[IDX_M_Partner] = @IDX_M_Partner
			   ,[JournalSeqNo] = @JournalSeqNo
			   ,[COADescription] = @COADescription
			   ,[RemarkDetail] = @RemarkDetail
			   ,[OriginalCurrencyID] = @OriginalCurrencyID
			   ,[ODebetAmount] = @ODebetAmount
			   ,[OCreditAmount] = @OCreditAmount
			   ,[ExchangeRate] = @ExchangeRate
			   ,[BaseCurrencyID] = @_BaseCurrency
			   ,[BDebetAmount] = (@ODebetAmount * @ExchangeRate)
			   ,[BCreditAmount] = (@OCreditAmount * @ExchangeRate)
			   ,[UModified] = @UserID
			   ,[DModified]	 = GETDATE()		   
			   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_JournalDetail = @IDX_T_JournalDetail
			
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



