USE [AVKDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_CM_FinancialReceive_CreateJournal]    Script Date: 28/01/2026 16:05:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: <Create Date,,>
-- Description:	Generate journal from financial receive
-- =============================================

-- USP_CM_FinancialReceive_CreateJournal 670843, 'yanti'

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_CreateJournal]
	@IDX_T_FinancialReceive		BIGINT,
	@UCreate					VARCHAR(50),
	@Result						SMALLINT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	BEGIN TRY		
		
		BEGIN TRANSACTION;

			DECLARE @_IDX_M_JournalType			INT = 6
			DECLARE @_IDX_T_JournalHeader		BIGINT
			DECLARE @_IDX_M_Partner				BIGINT
			DECLARE @_ReceiveAmount				DECIMAL(18,2)
			DECLARE @_DCreate					DATETIME

			UPDATE CM_T_FinancialReceiveDetail SET COADetail = 5 
			WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive AND COADetail = 0

			IF NOT EXISTS(
				SELECT RH.IDX_T_FinancialReceiveHeader, RH.IDX_M_Partner, ReceiveID, RH.UCreate, RH.DCreate
				FROM CM_T_FinancialReceiveHeader RH		
					INNER JOIN GL_T_JournalHeader JH ON JH.IDX_ReferenceNo = RH.IDX_T_FinancialReceiveHeader 
					AND RTRIM(JH.ReferenceNo) = RTRIM(RH.ReceiveID)
				WHERE RH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive AND ReceiveStatus = 'A' 
					AND RH.RecordStatus = 'A')
			BEGIN

				-- ======================================================================================================
				-- INSERT JOURNAL HEADER FROM FINANCIAL RECEIVE
				-- ======================================================================================================
				INSERT INTO [dbo].[GL_T_JournalHeader]
					([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]				
					,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
					,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
					,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
					,[JournalSource],[UCreate],[DCreate],[RecordStatus])
				SELECT	RH.IDX_M_Company, RH.IDX_M_Branch, @_IDX_M_JournalType, RH.IDX_M_Partner, 
						0, IDX_T_FinancialReceiveHeader, ReceiveID, ReceiveID, 
						ReceiveDate, RH.RemarkHeader, MP.PartnerName, 'P', 
						ReceiveDate, @UCreate, 0, 0, 
						'S', @UCreate, @_DCreate, 'A'
				FROM CM_T_FinancialReceiveHeader RH 		
				LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = RH.IDX_M_FinancialAccount
				LEFT JOIN GL_M_COA CH ON CH.IDX_M_COA = FA.IDX_M_COA
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner
				WHERE ReceiveStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive

				-- GET IDX JOURNAL HEADER FOR INSERT TO JOURNAL DETAIL
				SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ======================================================================================================
				-- INSERT JOURNAL DETAIL FROM FINANCIAL RECEIVE
				-- FINANCIAL ACCOUNT (DEBET)		
				-- PIUTANG (KREDIT)
				-- ======================================================================================================
		

				SELECT @_IDX_M_Partner = @_IDX_M_Partner, @_DCreate = DCreate
				FROM CM_T_FinancialReceiveDetail 
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive

				SELECT @_ReceiveAmount = SUM(ReceiveAmount)		
				FROM CM_T_FinancialReceiveDetail 
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive
				GROUP BY IDX_T_FinancialReceiveHeader		

				-- FINANCIAL ACCOUNT (DEBET)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, ISNULL(FA.IDX_M_COA,9999), 
						@_IDX_M_Partner, 
						0, CH.COADesc, 'Penerimaan Piutang ' + RD.DocumentNo, 
						1, @_ReceiveAmount, 0, 1, 
						1, @_ReceiveAmount, 0, @UCreate, @_DCreate, 'A'
				FROM CM_T_FinancialReceiveHeader RH 		
				LEFT JOIN CM_T_FinancialReceiveDetail RD ON RD.IDX_T_FinancialReceiveHeader = RH.IDX_T_FinancialReceiveHeader
				LEFT JOIN CM_M_FinancialAccount FA ON FA.IDX_M_FinancialAccount = RH.IDX_M_FinancialAccount
				LEFT JOIN GL_M_COA CH ON CH.IDX_M_COA = FA.IDX_M_COA
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner
				WHERE ReceiveStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive	
				GROUP BY FA.IDX_M_COA, RD.IDX_M_DocumentType, RD.IDX_DocumentNo, RD.DocumentNo, CH.COADesc	
		
				-- DETAIL RECEIVE BASED ON DETAIL TRANSACTION (DEBET)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, RD.COADetail, 
						@_IDX_M_Partner,
						0, CD.COADesc, 'Penerimaan Piutang ' + RD.DocumentNo, 
						1, ABS(RD.ReceiveAmount), 0, 1, 
						1, ABS(RD.ReceiveAmount), 0, @UCreate, RH.DCreate, 'A'
				FROM CM_T_FinancialReceiveHeader RH 	
				LEFT JOIN CM_T_FinancialReceiveDetail RD ON RD.IDX_T_FinancialReceiveHeader = RH.IDX_T_FinancialReceiveHeader			
				LEFT JOIN GL_M_COA CD ON CD.IDX_M_COA = RD.COADetail
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner	
				WHERE ReceiveStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive
					AND RD.ReceiveAmount < 0
				--GROUP BY RD.COADetail, CD.COADesc, RD.IDX_M_DocumentType, RD.IDX_DocumentNo, RD.DocumentNo
		
				-- DETAIL RECEIVE BASED ON DETAIL TRANSACTION (CREDIT)
				INSERT INTO [dbo].[GL_T_JournalDetail]
					([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
					,[IDX_M_Partner]
					,[JournalSeqNo],[COADescription],[RemarkDetail]
					,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
					,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate],[DCreate],[RecordStatus])
				SELECT	@_IDX_T_JournalHeader, 99, 99, RD.COADetail, 
						@_IDX_M_Partner, 
						0, CD.COADesc, 'Penerimaan Piutang ' + RD.DocumentNo, 
						1, 0, RD.ReceiveAmount, 1, 
						1, 0, RD.ReceiveAmount, @UCreate, RH.DCreate, 'A'
				FROM CM_T_FinancialReceiveHeader RH 	
				LEFT JOIN CM_T_FinancialReceiveDetail RD ON RD.IDX_T_FinancialReceiveHeader = RH.IDX_T_FinancialReceiveHeader			
				LEFT JOIN GL_M_COA CD ON CD.IDX_M_COA = RD.COADetail
				LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = RH.IDX_M_Partner	
				WHERE ReceiveStatus = 'A' AND RH.RecordStatus = 'A'
					AND RH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceive
					AND RD.ReceiveAmount > 0

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

