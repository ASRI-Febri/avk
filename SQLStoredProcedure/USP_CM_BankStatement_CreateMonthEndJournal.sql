SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Oct 2026
-- Description:	Jurnal akhir bulan rekening koran: semua baris dari
--				USP_CM_BankStatement_MonthEndRows dijadikan satu journal memorial,
--				dua baris jurnal per mutasi dengan keterangan remark bank:
--				  ADMIN    : Dr @COAAdmin    / Cr COA Bank
--				  INTEREST : Dr COA Bank     / Cr @COAInterest
--				  TAX      : Dr @COATax      / Cr COA Bank
--				Pola ini mengikuti jurnal manual yang selama ini dibuat tiap bulan
--				(mis. JM-100-2608-5258). COA hanya wajib untuk kategori yang ada.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_CreateMonthEndJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_CreateMonthEndJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_CreateMonthEndJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@COAAdmin					BIGINT,
	@COAInterest				BIGINT,
	@COATax						BIGINT,
	@JournalDate				DATETIME,
	@ReferenceNo				VARCHAR(32),
	@Remark						VARCHAR(5000),
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @BankCOA BIGINT, @CurrencyID VARCHAR(3), @Journal BIGINT, @Count INT

		SELECT @BankCOA = FA.IDX_M_COA, @CurrencyID = RTRIM(H.CurrencyID)
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND H.RecordStatus = 'A'

		DECLARE @Rows TABLE (IDX_T_BankStatementDetail BIGINT, SeqNo INT, PostingDate VARCHAR(19), Remark VARCHAR(1000),
							 DebitAmount DECIMAL(22,4), CreditAmount DECIMAL(22,4), Category VARCHAR(10))

		INSERT INTO @Rows EXEC [dbo].[USP_CM_BankStatement_MonthEndRows] @IDX_T_BankStatementHeader

		SELECT @Count = COUNT(*) FROM @Rows

		DECLARE @Error VARCHAR(500) =
			CASE WHEN ISNULL(@BankCOA, 0) = 0 THEN 'Financial Account rekening koran belum memiliki mapping COA.'
				 WHEN ISNULL(@CurrencyID, 'IDR') <> 'IDR' THEN 'Jurnal otomatis hanya untuk rekening IDR.'
				 WHEN @Count = 0 THEN 'Tidak ada baris biaya, bunga, atau pajak akhir bulan yang belum dijurnal.'
				 WHEN EXISTS (SELECT 1 FROM (SELECT DISTINCT Category FROM @Rows) R
								  CROSS APPLY (SELECT CASE R.Category WHEN 'ADMIN' THEN @COAAdmin
															  WHEN 'INTEREST' THEN @COAInterest
															  ELSE @COATax END AS IDX_M_COA) C
								  LEFT JOIN GL_M_COA COA WITH(NOLOCK)
									  ON C.IDX_M_COA = COA.IDX_M_COA AND COA.AllowJournalEntry = 'Y' AND COA.RecordStatus = 'A'
							  WHERE COA.IDX_M_COA IS NULL)
					THEN 'Pilih Chart of Account yang aktif dan boleh dijurnal untuk setiap kategori.'
				 WHEN @BankCOA IN (@COAAdmin, @COAInterest, @COATax)
					THEN 'Chart of Account kategori tidak boleh sama dengan COA bank.'
			END

		IF @Error IS NOT NULL
		BEGIN
			SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, @Error AS LogDesc
			RETURN
		END

		CREATE TABLE #BankStatementJournalLine (SeqNo INT, IDX_M_COA BIGINT,
			Debit DECIMAL(22,4), Credit DECIMAL(22,4), Remark VARCHAR(5000))

		;WITH Ordered AS (
			SELECT ROW_NUMBER() OVER (ORDER BY PostingDate, SeqNo) AS N, *,
				   DebitAmount + CreditAmount AS Amount,
				   CASE Category WHEN 'ADMIN' THEN @COAAdmin WHEN 'INTEREST' THEN @COAInterest ELSE @COATax END AS CategoryCOA
			FROM @Rows
		)
		INSERT INTO #BankStatementJournalLine (SeqNo, IDX_M_COA, Debit, Credit, Remark)
		SELECT N * 2 - 1,
			   CASE WHEN Category = 'INTEREST' THEN @BankCOA ELSE CategoryCOA END, Amount, 0, Remark
		FROM Ordered
		UNION ALL
		SELECT N * 2,
			   CASE WHEN Category = 'INTEREST' THEN CategoryCOA ELSE @BankCOA END, 0, Amount, Remark
		FROM Ordered

		BEGIN TRANSACTION

		EXEC [dbo].[USP_CM_BankStatement_InsertJournal] @IDX_T_BankStatementHeader, @JournalDate, @ReferenceNo, @Remark,
			@UserID, @Journal OUTPUT

		UPDATE SD
		SET IDX_T_JournalHeader = @Journal, UModified = @UserID, DModified = GETDATE()
		FROM CM_T_BankStatementDetail SD
			INNER JOIN @Rows R ON SD.IDX_T_BankStatementDetail = R.IDX_T_BankStatementDetail

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @IDX_T_BankStatementHeader AS ID,
			   'Jurnal akhir bulan dari ' + CONVERT(VARCHAR, @Count) + ' baris berhasil dibuat (status Unposted).' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
