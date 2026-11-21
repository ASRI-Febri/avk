-- =============================================
-- Author:		Samuel Febrianto
-- Create date: <Create Date,,>
-- Description:	Generate journal from financial Payment
-- =============================================

-- USP_CM_FinancialPayment_CreateJournal 670843, 'yanti'

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_CreateJournal]
	@IDX_T_FinancialPayment		BIGINT,
	@UCreate					VARCHAR(50),
	@Result						SMALLINT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	BEGIN TRY		
		
		BEGIN TRANSACTION;

			DECLARE @_IDX_M_JournalType			INT = 4 -- FINANCIAL PAYMENT JOURNAL
			DECLARE @_IDX_T_JournalHeader		BIGINT
			DECLARE @_IDX_M_Partner				BIGINT
			DECLARE @_PaymentAmount				DECIMAL(18,2)
			DECLARE @_DCreate					DATETIME

			UPDATE CM_T_FinancialPaymentDetail SET COADetail = 5 
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment AND COADetail = 0

			IF NOT EXISTS(
				SELECT RH.IDX_T_FinancialPaymentHeader, RH.IDX_M_Partner, PaymentID, RH.UCreate, RH.DCreate
				FROM CM_T_FinancialPaymentHeader RH		
					INNER JOIN GL_T_JournalHeader JH ON JH.IDX_ReferenceNo = RH.IDX_T_FinancialPaymentHeader 
					AND RTRIM(JH.ReferenceNo) = RTRIM(RH.PaymentID)
				WHERE RH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment AND PaymentStatus = 'A' 
					AND RH.RecordStatus = 'A')
			BEGIN

				-- ======================================================================================================
				-- INSERT JOURNAL HEADER FROM FINANCIAL Payment
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalHeader]
					([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]				
					,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
					,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
					,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
					,[JournalSource],[UCreate],[DCreate],[RecordStatus])
				SELECT	RH.IDX_M_Company, RH.IDX_M_Branch, @_IDX_M_JournalType, RH.IDX_M_Partner, 
						0, IDX_T_FinancialPaymentHeader, PaymentID, PaymentID, 
						PaymentDate, RH.RemarkHeader, MP.PartnerName, 'P', 
						PaymentDate, @UCreate, 0, 0, 
						'S', @UCreate, @_DCreate, 'A'
				FROM CM_T_FinancialPaymentHeader RH 		
				LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = RH.IDX_M_FinancialAccount
				LEFT JOIN GL_M_COA CH ON CH.IDX_M_COA = FA.IDX_M_COA
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner
				WHERE PaymentStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment

				-- GET IDX JOURNAL HEADER FOR INSERT TO JOURNAL DETAIL
				SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ======================================================================================================
				-- INSERT JOURNAL DETAIL FROM FINANCIAL Payment
				-- REKENING ANTARA (DEBET)		
				-- FINANCIAL ACCOUNT (KREDIT)
				-- ======================================================================================================
		

				SELECT @_IDX_M_Partner = @_IDX_M_Partner, @_DCreate = DCreate
				FROM CM_T_FinancialPaymentDetail 
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment

				SELECT @_PaymentAmount = SUM(PaymentAmount)		
				FROM CM_T_FinancialPaymentDetail 
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment
				GROUP BY IDX_T_FinancialPaymentHeader		

				
		
				-- DETAIL Payment BASED ON DETAIL TRANSACTION (DEBET)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, RD.COADetail, 
						@_IDX_M_Partner,
						0, CD.COADesc, 'Pembayaran Pembelian ' + RD.DocumentNo, 
						1, ABS(RD.PaymentAmount), 0, 1, 
						1, ABS(RD.PaymentAmount), 0, @UCreate, RH.DCreate, 'A'
				FROM CM_T_FinancialPaymentHeader RH 	
				LEFT JOIN CM_T_FinancialPaymentDetail RD ON RD.IDX_T_FinancialPaymentHeader = RH.IDX_T_FinancialPaymentHeader			
				LEFT JOIN GL_M_COA CD ON CD.IDX_M_COA = RD.COADetail
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner	
				WHERE PaymentStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment
					AND RD.PaymentAmount > 0
				--GROUP BY RD.COADetail, CD.COADesc, RD.IDX_M_DocumentType, RD.IDX_DocumentNo, RD.DocumentNo
		
				-- DETAIL Payment BASED ON DETAIL TRANSACTION (CREDIT)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, RD.COADetail, 
						@_IDX_M_Partner, 
						0, CD.COADesc, 'Pembayaran Pembelian ' + RD.DocumentNo, 
						1, 0, RD.PaymentAmount, 1, 
						1, 0, RD.PaymentAmount, @UCreate, RH.DCreate, 'A'
				FROM CM_T_FinancialPaymentHeader RH 	
				LEFT JOIN CM_T_FinancialPaymentDetail RD ON RD.IDX_T_FinancialPaymentHeader = RH.IDX_T_FinancialPaymentHeader			
				LEFT JOIN GL_M_COA CD ON CD.IDX_M_COA = RD.COADetail
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner	
				WHERE PaymentStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment
					AND RD.PaymentAmount < 0

				-- FINANCIAL ACCOUNT (CREDIT)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, ISNULL(FA.IDX_M_COA,9999), 
						@_IDX_M_Partner, 
						0, CH.COADesc, 'Pembayaran Pembelian ' + RD.DocumentNo, 
						1, 0, @_PaymentAmount, 1, 
						1, 0, @_PaymentAmount, @UCreate, @_DCreate, 'A'
				FROM CM_T_FinancialPaymentHeader RH 		
				LEFT JOIN CM_T_FinancialPaymentDetail RD ON RD.IDX_T_FinancialPaymentHeader = RH.IDX_T_FinancialPaymentHeader
				LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = RH.IDX_M_FinancialAccount
				LEFT JOIN GL_M_COA CH ON CH.IDX_M_COA = FA.IDX_M_COA
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner
				WHERE PaymentStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPayment	
				GROUP BY FA.IDX_M_COA, RD.IDX_M_DocumentType, RD.IDX_DocumentNo, RD.DocumentNo, CH.COADesc	

			END

		COMMIT TRANSACTION;

		SELECT @Result = 1		

	END TRY

	BEGIN CATCH       

		--INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT @Result = 0
			
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

