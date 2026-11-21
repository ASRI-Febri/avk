-- =============================================================================================================================================
-- Author			: Samuel Febrianto
-- Create date		: 20 November 2016
-- Description		: Create Table Financial Payment Header
-- Mod				: 2020-08-24 by Anton --> added textbox DestinationAccountName, DestinationBank, & DestinationAccountNo
--					  2020-09-14 by Anton --> retrieve param @COAHeader
--					  2024-03-19 by Anton --> added validation idx branch under selected FA must exact with param @idx_branch
-- =============================================================================================================================================

/*	
	
	EXEC [dbo].[USP_CM_FinancialPaymentHeader_Update] 
					1,1,1,
					1,,1,
					'G12345',NULL,'2017-01-12',
					'2017-01-12','TEST',1,						
					1000000,10000,0,
					0,'D',
					'admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPaymentHeader_Update] 	
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@IDX_M_Company						BIGINT,
	@IDX_M_Branch						BIGINT,
	@IDX_M_FinancialAccount				BIGINT,
	@IDX_M_DocumentType					BIGINT,
	@IDX_M_Partner						BIGINT,			
	@IDX_M_Currency						BIGINT,	
	@IDX_M_PaymentType					BIGINT,
	@COAHeader							BIGINT,
	@PaymentID							VARCHAR(50),
	@VoucherNoManual					VARCHAR(50),
	@PaymentDate						DATETIME,	
	@RemarkHeader						VARCHAR(500),
	@PaymentStatus						CHAR(1),	
	@PaymentAmount						DECIMAL(22,2),
	@DestinationAccountName				VARCHAR(100),
	@DestinationBank					VARCHAR(100),
	@DestinationAccountNo				VARCHAR(50),
	@PDCNo								VARCHAR(50),
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
		DECLARE @_StatusFP VARCHAR(1)

		SELECT @_IDX_M_Partner = IDX_M_Partner FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
		SELECT @_CountDetail = COUNT(IDX_T_FinancialPaymentDetail) FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
		select @_StatusFP = PaymentStatus FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader --mod anton 2019-06-20

		--IF @_CountDetail > 0 AND (@_IDX_M_Partner <> @IDX_M_Partner) --mod anton 2019-06-20
		IF @_StatusFP <> 'D'
		BEGIN
			--INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Can not change business partner !') --mod anton 2019-06-20
			INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Transaction status already not DRAFT, cannot change header information !')
		END

		

		
		

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		

			SELECT @COAHeader = IDX_M_COA FROM CM_M_FinancialAccount WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Payment Header 
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[CM_T_FinancialPaymentHeader] SET
				    [IDX_M_Company] = @IDX_M_Company
				   ,[IDX_M_Branch] = @IDX_M_Branch
				   ,[IDX_M_FinancialAccount] = @IDX_M_FinancialAccount
				   ,[IDX_M_Partner] = @IDX_M_Partner
				   ,[IDX_M_Currency] = @IDX_M_Currency
				   ,[IDX_M_PaymentType] = @IDX_M_PaymentType
				   ,[IDX_M_DocumentType] = @IDX_M_DocumentType
				   ,[COAHeader] = @COAHeader
				   --,[PaymentID] = @PaymentID
				   ,[VoucherNoManual] = @VoucherNoManual
				   ,[PaymentDate] = @PaymentDate
				   ,[RemarkHeader] = @RemarkHeader
				   ,[PaymentStatus] = @PaymentStatus				  
				   ,[PaymentAmount] = @PaymentAmount
				   ,[DestinationAccountName] = @DestinationAccountName
				   ,[DestinationBank] = @DestinationBank
				   ,[DestinationAccountNo] = @DestinationAccountNo
				   ,[PDCNo] = @PDCNo
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()				  
				   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')

			
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
