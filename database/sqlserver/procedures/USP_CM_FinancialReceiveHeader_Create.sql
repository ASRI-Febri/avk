-- =======================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Create Table Financial Receive Header
-- Modified		: 2024-03-19 by Anton --> added validation idx branch under selected FA must exact with param @idx_branch
-- =======================================================================================================================================

/*	
	EXEC [dbo].[USP_CM_FinancialReceiveHeader_Create] 
					 1
					,1
					,1
					,4
					,1
					,1
					,2
					,0
					,'PMT'
					,'2018-06-06'
					,'Kencana Zone 1'
					,'D'
					,15200000
					,'1406069'
					,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceiveHeader_Create] 	
	@IDX_M_Company				BIGINT,
	@IDX_M_Branch				BIGINT,
	@IDX_M_FinancialAccount		BIGINT,
	@IDX_M_DocumentType			BIGINT,
	@IDX_M_Partner				BIGINT,			
	@IDX_M_Currency				BIGINT,	
	@IDX_M_PaymentType			BIGINT,	
	@COAHeader					BIGINT,
	@ReceiveID					VARCHAR(50),
	@VoucherNoManual			VARCHAR(50),
	@ReceiveDate				DATETIME,	
	@RemarkHeader				VARCHAR(500),
	@ReceiveStatus				CHAR(1),
	@ReceiveAmount				DECIMAL(22,2),	
	--------------------------------------------------------------	
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

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/			
		
		/** Check User Access Right **/
		/*
		DECLARE @_FormID AS VARCHAR(20)
		SET @_FormID = ''

		DECLARE @Output INT
		EXEC USP_CheckUserForm @UserID,@_FormID, @Output OUT

		IF @Output <> 1
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		END
		*/
		/****************************************************************************/

		--DECLARE @_ReceiveID AS VARCHAR(20)
		--DECLARE @_LastNumber AS INTEGER
		--DECLARE @_Month AS VARCHAR(4)
		--DECLARE @_Year AS VARCHAR(2)
		--DECLARE @_DocumentTypeID AS CHAR(3)
		
		--SET @_LastNumber = 0

		--SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @IDX_M_DocumentType

		--IF EXISTS(	SELECT TOP 1 ReceiveID
		--			FROM CM_T_FinancialReceiveHeader 
		--			WHERE MONTH(ReceiveDate) = MONTH(GETDATE())
		--				AND YEAR(ReceiveDate) = YEAR(GETDATE())
		--				AND LEFT(ReceiveID,3) = @_DocumentTypeID
		--			ORDER BY ReceiveID DESC)
		--BEGIN
		--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
		--	FROM CM_T_FinancialReceiveHeader 
		--	WHERE MONTH(ReceiveDate) = MONTH(GETDATE())
		--		AND YEAR(ReceiveDate) = YEAR(GETDATE())
		--		AND LEFT(ReceiveID,3) = @_DocumentTypeID
		--	ORDER BY ReceiveID DESC
		--END			

		--SET @_Month = RIGHT('00' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2)
		--SET @_Month = RIGHT(RTRIM(@_Month),2)

		--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(GETDATE())),2)

		--/** SetNo by System **/
		--SET @_ReceiveID = @_DocumentTypeID + '-' 
		--	+ @_Month
		--	+ @_Year + '-' 
		--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

		DECLARE @IDXGC_Branch BIGINT
		DECLARE @IDXBranch_FA BIGINT

		SET @IDXGC_Branch = (SELECT IDX_M_Company FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch)
		SET @IDXBranch_FA = (SELECT IDX_M_Branch FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount)

		IF @IDX_M_Company <> @IDXGC_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Selected Branch Not Under The Same Group Company!')
		END

		IF @IDX_M_Branch <> @IDXBranch_FA
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Selected Financial Account Not Under The Same Branch!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			SELECT @IDX_M_Company = IDX_M_Company FROM GN_M_Branch WHERE IDX_M_Branch = @IDX_M_Branch
			SELECT @COAHeader = IDX_M_COA FROM CM_M_FinancialAccount WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Receive Header 
			--------------------------------------------------------------------------------**/
			INSERT INTO [dbo].[CM_T_FinancialReceiveHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_DocumentType]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]	
				   ,[IDX_M_PaymentType]
				   ,[COAHeader]			  
				   ,[ReceiveID]
				   ,[VoucherNoManual]
				   ,[ReceiveDate]
				   ,[RemarkHeader]
				   ,[ReceiveStatus]
				   ,[ReceiveAmount]				  
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
			 VALUES
				   (@IDX_M_Company
				   ,@IDX_M_Branch
				   ,@IDX_M_FinancialAccount
				   ,@IDX_M_DocumentType
				   ,@IDX_M_Partner
				   ,@IDX_M_Currency		
				   ,@IDX_M_PaymentType
				   ,@COAHeader		  
				   ,''
				   ,@VoucherNoManual
				   ,@ReceiveDate
				   ,@RemarkHeader
				   ,@ReceiveStatus	
				   ,@ReceiveAmount			   
				   ,@UserID
				   ,GETDATE()				  
				   ,@RecordStatus)			
			
			DECLARE @IDX_T_FinancialReceiveHeader AS BIGINT
			SET @IDX_T_FinancialReceiveHeader = (SELECT SCOPE_IDENTITY())

			/** Update Draft Receive ID **/
			UPDATE [dbo].[CM_T_FinancialReceiveHeader]
			SET ReceiveID = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_FinancialReceiveHeader))
			WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialReceiveHeader, 'Data Sudah Disimpan')
			
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



-- USE [TunasDB]
