-- =============================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Create Table Financial Receive Header
-- Mod			: 2020-09-14 by Anton --> Retrieve param @COAHeader
--				  2024-03-19 by Anton --> added validation idx branch under selected FA must exact with param @idx_branch
-- =============================================================================================================================

/*	
	
EXEC [dbo].[USP_CM_FinancialReceiveHeader_Update] 792,4,91,9,3,2,1,4,10,'DRAFT-792','-','2024-03-19 10:42:08.137','VA 16/01/24','D',75000,'1305276','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceiveHeader_Update] 	
	@IDX_T_FinancialReceiveHeader		BIGINT,
	@IDX_M_Company						BIGINT,
	@IDX_M_Branch						BIGINT,
	@IDX_M_FinancialAccount				BIGINT,
	@IDX_M_DocumentType					BIGINT,
	@IDX_M_Partner						BIGINT,			
	@IDX_M_Currency						BIGINT,	
	@IDX_M_PaymentType					BIGINT,
	@COAHeader							BIGINT,
	@ReceiveID							VARCHAR(50),
	@VoucherNoManual					VARCHAR(50),
	@ReceiveDate						DATETIME,	
	@RemarkHeader						VARCHAR(500),
	@ReceiveStatus						CHAR(1),	
	@ReceiveAmount						DECIMAL(22,2),
	--------------------------------------------------------------	
	@UserID								VARCHAR(50),
	@RecordStatus						CHAR(1)	
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

		DECLARE @_IDX_M_Partner BIGINT
		DECLARE @_CountDetail	INT
		DECLARE @_StatusFR VARCHAR(1)

		SELECT @_IDX_M_Partner = IDX_M_Partner FROM CM_T_FinancialReceiveHeader WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
		SELECT @_CountDetail = COUNT(IDX_T_FinancialReceiveDetail) FROM CM_T_FinancialReceiveDetail WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
		select @_StatusFR = ReceiveStatus FROM CM_T_FinancialReceiveHeader WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader --mod anton 2019-08-16

		--IF @_CountDetail > 0 AND (@_IDX_M_Partner <> @IDX_M_Partner) --mod anton 2019-08-16 
		IF @_StatusFR <> 'D'
		BEGIN
			--INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Can not change business partner !') --mod anton 2019-08-16
			INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Transaction status already not DRAFT, cannot change header information !')
		END

		DECLARE @IDXGC_Branch BIGINT
		DECLARE @IDXBranch_FA BIGINT

		SET @IDXGC_Branch = (SELECT IDX_M_Company FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @IDX_M_Branch)
		SET @IDXBranch_FA = (SELECT IDX_M_Branch FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount)

		IF @IDX_M_Company <> @IDXGC_Branch
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'Selected Branch Not Under The Same Group Company!')
		END

		IF @IDX_M_Branch <> @IDXBranch_FA
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'Selected Financial Account Not Under The Same Branch!')
		END

		DECLARE @CurrentTransNo VARCHAR(50)
		SET @CurrentTransNo = (SELECT ReceiveID FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader)

		--IF LEFT(@CurrentTransNo,5) <> 'DRAFT'
		--BEGIN
		--	DECLARE @CurrBankCode VARCHAR(10) = (SELECT LEFT(ReceiveID,5) 
		--										 FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) 
		--										 WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader)

		--	IF (SELECT FinancialAccountID FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount) <> @CurrBankCode
		--	BEGIN
		--		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'VoucherNo Already Generated, Cannot Change Financial Account. Please Void Transaction!')
		--	END
		--END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			SELECT @COAHeader = IDX_M_COA FROM CM_M_FinancialAccount WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Receive Header 
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[CM_T_FinancialReceiveHeader] SET
				    [IDX_M_Company] = @IDX_M_Company
				   ,[IDX_M_Branch] = @IDX_M_Branch
				   ,[IDX_M_FinancialAccount] = @IDX_M_FinancialAccount
				   ,[IDX_M_Partner] = @IDX_M_Partner
				   ,[IDX_M_Currency] = @IDX_M_Currency
				   ,[IDX_M_PaymentType] = @IDX_M_PaymentType
				   ,[IDX_M_DocumentType] = @IDX_M_DocumentType
				   ,[COAHeader] = @COAHeader
				   --,[ReceiveID] = @ReceiveID
				   ,[VoucherNoManual] = @VoucherNoManual
				   ,[ReceiveDate] = @ReceiveDate
				   ,[RemarkHeader] = @RemarkHeader
				   ,[ReceiveStatus] = @ReceiveStatus				  
				   ,[ReceiveAmount] = @ReceiveAmount
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()				  
				   ,[RecordStatus] = @RecordStatus
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
