-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 29 Jan 2018
-- Description	: Create Table Journal Detail
-- Modified		: 2024-06-05 by Anton --> Added validation on Project Information
-- =============================================

/*	
	EXEC [dbo].[USP_GL_JournalDetail_Create] 15258,'','',142,0,0,'105.10.299 - Piutang Lain-lain','Test',1,50000,80000,1,50000,80000,'1406069','A'
*/

CREATE PROCEDURE [dbo].[USP_GL_JournalDetail_Create] 	
	@IDX_T_JournalHeader		BIGINT,
	@IDX_M_Project				BIGINT,	
	@IDX_M_Department			BIGINT,
	@IDX_M_COA					BIGINT,
	@IDX_M_Partner				BIGINT,
	@JournalSeqNo				INT,
	@COADescription				VARCHAR(500),
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
		--SET @_FormID = 'GL-JOUR-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		--------------------------------------------------------------------------------------
		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_JournalHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END

		IF @ODebetAmount = 0 AND @OCreditAmount = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Debet and Credit are zero!')
		END

		IF @ODebetAmount > 0 AND @OCreditAmount > 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please choose only one, Debet or Credit !')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN			

			DECLARE @_IDX_M_Company		INT
			DECLARE @_BaseCurrency		INT
			 
			SELECT @_IDX_M_Company = IDX_M_Company, @IDX_M_Partner = IDX_M_Partner 
			FROM GL_T_JournalHeader 
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

			SELECT @_BaseCurrency = IDX_M_Currency FROM GN_M_Company WHERE IDX_M_Company = @_IDX_M_Company
			SELECT @COADescription = COADesc FROM GL_M_COA WITH(NOLOCK) WHERE IDX_M_COA = @IDX_M_COA

			INSERT INTO [dbo].[GL_T_JournalDetail]
			   ([IDX_T_JournalHeader]
			   ,[IDX_M_Project]
			   ,[IDX_M_Department]
			   ,[IDX_M_COA]
			   ,[IDX_M_Partner]
			   ,[JournalSeqNo]
			   ,[COADescription]
			   ,[RemarkDetail]
			   ,[OriginalCurrencyID]
			   ,[ODebetAmount]
			   ,[OCreditAmount]
			   ,[ExchangeRate]
			   ,[BaseCurrencyID]
			   ,[BDebetAmount]
			   ,[BCreditAmount]
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			 VALUES
			   (@IDX_T_JournalHeader
			   ,@IDX_M_Project			  
			   ,@IDX_M_Department
			   ,@IDX_M_COA
			   ,@IDX_M_Partner
			   ,@JournalSeqNo
			   ,@COADescription
			   ,@RemarkDetail
			   ,@OriginalCurrencyID
			   ,@ODebetAmount
			   ,@OCreditAmount
			   ,@ExchangeRate
			   ,@_BaseCurrency			   
			   ,(@ODebetAmount * @ExchangeRate)
			   ,(@OCreditAmount * @ExchangeRate)			   
			   ,@UserID
			   ,GETDATE()
			   ,@RecordStatus)		
			
			DECLARE @_IDX_GL_T_JournalDetail AS BIGINT
			SET @_IDX_GL_T_JournalDetail = (SELECT SCOPE_IDENTITY())				

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



