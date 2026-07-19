-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026-01-23
-- Description:	Create COGS valas journal after COGS calculation
-- =============================================

/*
DECLARE @_JournalResult		SMALLINT
EXEC USP_MC_COGSValasJournal_Create 2, @_JournalResult OUTPUT
PRINT CONVERT(VARCHAR, @_JournalResult)
*/

-- =============================================
-- FIX 19 Jul 2026 (Samuel Febrianto):
-- Nilai jurnal HPP dibulatkan ROUND(...,2) saat insert.
-- Sebelumnya SUM(Quantity * AverageAmount * ValasChangeNumber) tersimpan
-- dengan 4 desimal di GL_T_JournalDetail, menyebabkan selisih pembulatan
-- beberapa sen di Trial Balance / Balance Sheet / Profit Loss yang
-- membulatkan per akun ke 2 desimal. Debet (HPP) dan kredit (Persediaan)
-- memakai ekspresi identik sehingga jurnal tetap balance setelah ROUND.
-- Jalankan bersama FIX_GL_JournalDetail_Rounding.sql untuk membereskan
-- data historis yang terlanjur tersimpan 4 desimal.
-- =============================================
ALTER PROCEDURE [dbo].[USP_MC_COGSValasJournal_Create]
	@IDX_T_SalesOrder			BIGINT,
	@COGSPeriod					VARCHAR(6),
	@UserID						VARCHAR(50),
	@Result						SMALLINT OUTPUT -- 1 = TRUE, 0 = FALSE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY		
		
		BEGIN TRANSACTION;		
		
		-- =============================================================
		-- JOURNAL PARAMETER
		-- =============================================================
		DECLARE @_IDX_T_JournalHeader			BIGINT
		DECLARE @_IDX_M_Company					BIGINT
		DECLARE @_IDX_M_Branch					BIGINT
		DECLARE @_IDX_M_Partner					BIGINT
		DECLARE @_SONumber						VARCHAR(30)
		DECLARE @_TransactionDate				DATE
		DECLARE @_UCreate						VARCHAR(50)
		DECLARE @_DCreate						DATE

		DECLARE @_PurchaseAmount				DECIMAL(22,2)
		DECLARE @_SalesAmount					DECIMAL(22,2)
		DECLARE @_ReceiveAmount					DECIMAL(22,2)
		
		-- ACCOUNTING
		DECLARE @_IDX_M_JournalType				INT = 8 -- JOURNAL PERHITUNGAN COGS	
		DECLARE @_COA_AR						INT = 5 -- 1115-001 PIUTANG USAHA
		DECLARE @_COA_AP						INT = 12 -- 2110-001 HUTANG USAHA
		DECLARE @_COA_Inventory					INT = 80 -- 1117-000 - PERSEDIAAN VALAS

		DECLARE @_COA_AdminFeeIncome			INT = 22 -- 4110-004
		DECLARE @_COA_OtherIncome				INT = 67 -- 4110-002
		DECLARE @_COA_CashBank					INT	= 1 -- 1110-001		

		SELECT @_SONumber = RTRIM(S.SONumber), @_TransactionDate = SODate, 
			@_IDX_M_Company = 1, @_IDX_M_Branch = B.IDX_M_Branch, @_IDX_M_Partner = S.IDX_M_Partner, 
			@_UCreate = S.UCreate, @_DCreate = S.DCreate			
		FROM MC_T_SalesOrder S
		LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner 
		WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder

		SELECT @_PurchaseAmount = SUM(SD.BaseCurrencyAmount)
		FROM MC_T_SalesOrder S
		INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
		WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 1

		SELECT @_SalesAmount = SUM(SD.BaseCurrencyAmount)
		FROM MC_T_SalesOrder S
		INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
		WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 2

		

		-- ======================================================================================================
		-- DELETE EXISTING JOURNAL
		-- ======================================================================================================
		DELETE GL_T_JournalDetail 
		WHERE IDX_T_JournalHeader IN (
			SELECT IDX_T_JournalHeader 
			FROM GL_T_JournalHeader 
			WHERE IDX_M_JournalType = @_IDX_M_JournalType AND RTRIM(ReferenceNo) = RTRIM(@_SONumber) AND IDX_ReferenceNo = @IDX_T_SalesOrder)

		DELETE GL_T_JournalHeader 
		WHERE IDX_M_JournalType = @_IDX_M_JournalType AND RTRIM(ReferenceNo) = RTRIM(@_SONumber) AND IDX_ReferenceNo = @IDX_T_SalesOrder

		-- ======================================================================================================
		-- INSERT JOURNAL HEADER FROM SALES ORDER
		-- ======================================================================================================
		INSERT INTO [dbo].[GL_T_JournalHeader]
			([IDX_M_Company],[IDX_M_Branch],[IDX_M_JournalType],[IDX_M_Partner]				
			,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo]
			,[JournalDate],[RemarkHeader],[PartnerDesc],[PostingStatus]
			,[PostingDate],[PostedBy],[DebetAmount],[CreditAmount]
			,[JournalSource],[UCreate],[DCreate],[RecordStatus])
		SELECT	1, S.IDX_M_Branch, @_IDX_M_JournalType, P.IDX_M_Partner, 
				0, IDX_T_SalesOrder, S.SONumber, 'HP-' + S.SONumber, 
				S.SODate, 'Perhitungan HPP', P.PartnerName, 'P', 
				S.SODate, @_UCreate, 0, 0, 
				'S', @_UCreate, @_DCreate, 'A'
		FROM MC_T_SalesOrder S
		LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner 
		WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder

		-- GET IDX JOURNAL HEADER FOR INSERT TO JOURNAL DETAIL
		SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

		-- ======================================================================================================
		-- INSERT DETAIL
		-- ======================================================================================================
		-- HPP (DEBET)
		-- PERSEDIAAN VALAS (CREDIT)		

		IF @_SalesAmount > 0
		BEGIN
			-- HPP (DEBET)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, CU.COGSAccount, 
					S.IDX_M_Partner, 0, 'HPP Valas', 'HPP Valas', 
					1, ROUND(SUM(SD.Quantity * COGS.AverageAmount * VC.ValasChangeNumber), 2), 0, 1, 
					1, ROUND(SUM(SD.Quantity * COGS.AverageAmount * VC.ValasChangeNumber), 2), 0, @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = MV.IDX_M_ValasChange
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			LEFT JOIN GL_M_COA CHP ON CHP.IDX_M_COA = CU.COGSAccount
			INNER JOIN (SELECT IDX_T_COGSValasCalculation, IDX_M_Currency, IDX_M_Valas, AverageAmount 
						FROM MC_T_COGSValasCalculation 
						WHERE COGSPeriod = @COGSPeriod) COGS
				ON COGS.IDX_M_Currency = CU.IDX_M_Currency AND COGS.IDX_M_Valas = MV.IDX_M_Valas
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder 
			GROUP BY SD.IDX_T_SalesOrder, CU.COGSAccount, S.IDX_M_Partner, MV.IDX_M_Currency, CU.CurrencyID, MV.IDX_M_Valas

			-- PERSEDIAAN (CREDIT)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, CU.PurchaseAccount, 
					S.IDX_M_Partner, 0, 'HPP Persediaan valas', 'HPP Persediaan valas', 
					1, 0, ROUND(SUM(SD.Quantity * COGS.AverageAmount * VC.ValasChangeNumber), 2), 1, 
					1, 0, ROUND(SUM(SD.Quantity * COGS.AverageAmount * VC.ValasChangeNumber), 2), @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = MV.IDX_M_ValasChange
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			LEFT JOIN GL_M_COA CHP ON CHP.IDX_M_COA = CU.PurchaseAccount
			INNER JOIN (SELECT IDX_T_COGSValasCalculation, IDX_M_Currency, IDX_M_Valas, AverageAmount 
						FROM MC_T_COGSValasCalculation 
						WHERE COGSPeriod = @COGSPeriod) COGS
				ON COGS.IDX_M_Currency = CU.IDX_M_Currency AND COGS.IDX_M_Valas = MV.IDX_M_Valas
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder 
			GROUP BY SD.IDX_T_SalesOrder, CU.PurchaseAccount, S.IDX_M_Partner, MV.IDX_M_Currency, CU.CurrencyID, MV.IDX_M_Valas
		END
				

		


		-- ========================================================================================================
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

