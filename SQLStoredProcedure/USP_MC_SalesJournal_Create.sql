USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Revisi 13 Agustus 2026: hapus jurnal lama berdasarkan index transaksi, bukan nomor nota.

IF OBJECT_ID('[dbo].[USP_MC_SalesJournal_Create]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_SalesJournal_Create]
GO

-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026-01-23
-- Description:	Create transaction journal (buy or sell valas)
-- =============================================

/*
DECLARE @_JournalResult		SMALLINT
EXEC USP_MC_SalesJournal_Create 2, @_JournalResult OUTPUT
PRINT CONVERT(VARCHAR, @_JournalResult)
*/

CREATE PROCEDURE [dbo].[USP_MC_SalesJournal_Create]
	@IDX_T_SalesOrder			BIGINT,
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
		DECLARE @_IDX_M_JournalType				INT = 5 -- JOURNAL PENJUALAN VALAS	
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

		-- GET DETAIL PEMBELIAN
		--SELECT SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, SD.IDX_M_Valas,
		--	MV.IDX_M_Currency,
		--	CU.CurrencyID, SUM(SD.Quantity) AS Quantity, SUM(SD.BaseCurrencyAmount) AS BuyAmount
		--FROM MC_T_SalesOrder S
		--INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		--INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
		--INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
		--WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 1
		--GROUP BY SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, SD.IDX_M_Valas,
		--	MV.IDX_M_Currency, CU.CurrencyID

		-- CHECK PAYMENT
		SELECT @_ReceiveAmount = SUM(FRD.ReceiveAmount) 
		FROM CM_T_FinancialReceiveDetail FRD
		LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
		WHERE FRD.IDX_DocumentNo = @IDX_T_SalesOrder AND RTRIM(FRD.DocumentNo) = RTRIM(@_SONumber)
			AND FRH.ReceiveStatus = 'A' AND FRH.RecordStatus = 'A'

		-- ======================================================================================================
		-- DELETE EXISTING JOURNAL
		-- ======================================================================================================
		-- Kunci penghapusan hanya jenis jurnal + index transaksi, TANPA nomor nota.
		-- Nomor nota bisa berubah kalau nota di-approve ulang (mis. sempat kembali
		-- ke DRAFT), dan dulu jurnal lama jadi tidak ketemu sehingga tertinggal
		-- sebagai jurnal ganda di GL.
		DELETE GL_T_JournalDetail
		WHERE IDX_T_JournalHeader IN (
			SELECT IDX_T_JournalHeader
			FROM GL_T_JournalHeader
			WHERE IDX_M_JournalType = @_IDX_M_JournalType AND IDX_ReferenceNo = @IDX_T_SalesOrder)

		DELETE GL_T_JournalHeader
		WHERE IDX_M_JournalType = @_IDX_M_JournalType AND IDX_ReferenceNo = @IDX_T_SalesOrder

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
				0, IDX_T_SalesOrder, S.SONumber, S.SONumber, 
				S.SODate, 'Transaksi jual beli', P.PartnerName, 'P', 
				S.SODate, @_UCreate, 0, 0, 
				'S', @_UCreate, @_DCreate, 'A'
		FROM MC_T_SalesOrder S
		LEFT JOIN GN_M_Branch B ON B.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner 
		WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder

		-- GET IDX JOURNAL HEADER FOR INSERT TO JOURNAL DETAIL
		SET @_IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

		-- ======================================================================================================
		-- INSERT DETAIL PEMBELIAN
		-- ======================================================================================================
		-- PERSEDIAAN (DEBET)
		-- HUTANG (CREDIT)

		-- ======================================================================================================
		-- INSERT DETAIL PENJUALAN
		-- ======================================================================================================
		-- PIUTANG USAHA (DEBET)
		-- PENJUALAN (CREDIT)

		-- ======================================================================================================
		-- (JIKA TRANSAKSI LANGSUNG DIBAYAR LUNAS)
		-- ======================================================================================================
		-- HUTANG (DEBET)		
		-- KAS/BANK (KREDIT)
		-- ======================================================================================================		

		IF @_PurchaseAmount > 0
		BEGIN
			-- PERSEDIAAN (DEBET)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, CU.PurchaseAccount, 
					S.IDX_M_Partner, 0, 'Persediaan Valas', 'Persediaan Valas', 
					1, SUM(SD.BaseCurrencyAmount), 0, 1, 
					1, SUM(SD.BaseCurrencyAmount), 0, @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 1
			GROUP BY SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, CU.PurchaseAccount, S.IDX_M_Partner, SD.IDX_M_Valas,
				MV.IDX_M_Currency, CU.CurrencyID

			-- HUTANG (CREDIT)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, @_COA_AP, 
					S.IDX_M_Partner, 0, 'Hutang pembelian', 'Hutang pembelian Valas', 
					1, 0, SUM(SD.BaseCurrencyAmount), 1, 
					1, 0, SUM(SD.BaseCurrencyAmount), @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 1
			GROUP BY SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, S.IDX_M_Partner
				--SD.IDX_M_Valas, MV.IDX_M_Currency, CU.CurrencyID
		END

		IF @_SalesAmount > 0
		BEGIN
			-- PIUTANG (DEBET)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, @_COA_AR, 
					S.IDX_M_Partner, 0, 'Piutang Valas', 'Piutang penjualan valas', 
					1, SUM(SD.BaseCurrencyAmount), 0, 1, 
					1, SUM(SD.BaseCurrencyAmount), 0, @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 2
			GROUP BY SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, S.IDX_M_Partner, SD.IDX_M_Valas,
				MV.IDX_M_Currency, CU.CurrencyID

			-- PENJUALAN (CREDIT)
			INSERT INTO [dbo].[GL_T_JournalDetail]
				([IDX_T_JournalHeader],[IDX_M_Project],[IDX_M_Department],[IDX_M_COA]
				,[IDX_M_Partner],[JournalSeqNo],[COADescription],[RemarkDetail]
				,[OriginalCurrencyID],[ODebetAmount],[OCreditAmount],[ExchangeRate]
				,[BaseCurrencyID],[BDebetAmount],[BCreditAmount],[UCreate]
				,[DCreate],[RecordStatus])
			SELECT	@_IDX_T_JournalHeader, 0, 0, CU.SalesAccount, 
					S.IDX_M_Partner, 0, 'Penjualan Valas', 'Penjualan valas', 
					1, 0, SUM(SD.BaseCurrencyAmount), 1, 
					1, 0, SUM(SD.BaseCurrencyAmount), @_UCreate, 
					@_DCreate, 'A'
			FROM MC_T_SalesOrder S
			INNER JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
			INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SD.IDX_M_Valas
			INNER JOIN MC_M_Currency CU ON CU.IDX_M_Currency = MV.IDX_M_Currency 
			WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder AND SD.IDX_M_TransactionType = 2
			GROUP BY SD.IDX_T_SalesOrder, SD.IDX_M_TransactionType, CU.SalesAccount, S.IDX_M_Partner, SD.IDX_M_Valas,
				MV.IDX_M_Currency, CU.CurrencyID
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
GO
