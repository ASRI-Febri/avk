SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Simpan rekening koran hasil upload PDF (header + seluruh baris).
--				Baris dikirim sekaligus sebagai XML karena SQL Server 2014 belum
--				punya OPENJSON dan memanggil SP per baris (300+ baris) terlalu lambat:
--				<rows><r s="SeqNo" d="PostingDate" m="Remark" f="ReferenceNo"
--				         db="Debit" cr="Credit" b="Balance" a="IsAdminFee"/></rows>
--				Periode yang beririsan untuk rekening yang sama ditolak supaya
--				mutasi tidak tercatat dua kali.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_Save') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_Save]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_Save]
	@IDX_M_FinancialAccount	BIGINT,
	@BankName				VARCHAR(50),
	@AccountNo				VARCHAR(50),
	@AccountName			VARCHAR(100),
	@CurrencyID				VARCHAR(3),
	@PeriodStart			DATE,
	@PeriodEnd				DATE,
	@OpeningBalance			DECIMAL(22,4),
	@ClosingBalance			DECIMAL(22,4),
	@TotalDebit				DECIMAL(22,4),
	@TotalCredit			DECIMAL(22,4),
	@FileName				VARCHAR(255),
	@Notes					VARCHAR(500),
	@DetailXml				VARCHAR(MAX),
	@UserID					VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @IDX_M_Company BIGINT, @IDX_M_Branch BIGINT, @FinancialAccountID VARCHAR(50), @ID BIGINT

		SELECT @IDX_M_Branch       = FA.IDX_M_Branch,
			   @IDX_M_Company      = COALESCE(NULLIF(FA.IDX_M_Company, 0), B.IDX_M_Company),
			   @FinancialAccountID = RTRIM(FA.FinancialAccountID)
		FROM CM_M_FinancialAccount FA WITH(NOLOCK)
			LEFT JOIN GN_M_Branch B WITH(NOLOCK) ON FA.IDX_M_Branch = B.IDX_M_Branch
		WHERE FA.IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND FA.RecordStatus = 'A'

		IF @FinancialAccountID IS NULL
		BEGIN
			SELECT 'error' AS Result, 0 AS ID, 'Financial Account tidak ditemukan.' AS LogDesc
			RETURN
		END

		IF EXISTS (SELECT 1 FROM CM_T_BankStatementHeader WITH(NOLOCK)
				   WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND RecordStatus = 'A'
					 AND PeriodStart <= @PeriodEnd AND PeriodEnd >= @PeriodStart)
		BEGIN
			SELECT 'error' AS Result, 0 AS ID,
				   'Rekening koran ' + @FinancialAccountID + ' untuk periode ini sudah pernah disimpan ('
				   + (SELECT TOP 1 StatementNo FROM CM_T_BankStatementHeader WITH(NOLOCK)
					  WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount AND RecordStatus = 'A'
						AND PeriodStart <= @PeriodEnd AND PeriodEnd >= @PeriodStart) + ').' AS LogDesc
			RETURN
		END

		DECLARE @Xml XML = CAST(@DetailXml AS XML)

		BEGIN TRANSACTION

		INSERT INTO CM_T_BankStatementHeader
			(IDX_M_Company, IDX_M_Branch, IDX_M_FinancialAccount, StatementNo, BankName, AccountNo, AccountName,
			 CurrencyID, PeriodStart, PeriodEnd, OpeningBalance, ClosingBalance, TotalDebit, TotalCredit,
			 FileName, Notes, UCreate, DCreate, RecordStatus)
		VALUES
			(@IDX_M_Company, @IDX_M_Branch, @IDX_M_FinancialAccount,
			 'RK-' + @FinancialAccountID + '-' + CONVERT(VARCHAR(8), @PeriodStart, 112) + '-' + CONVERT(VARCHAR(8), @PeriodEnd, 112),
			 @BankName, @AccountNo, @AccountName,
			 @CurrencyID, @PeriodStart, @PeriodEnd, @OpeningBalance, @ClosingBalance, @TotalDebit, @TotalCredit,
			 @FileName, @Notes, @UserID, GETDATE(), 'A')

		SET @ID = SCOPE_IDENTITY()

		INSERT INTO CM_T_BankStatementDetail
			(IDX_T_BankStatementHeader, SeqNo, PostingDate, Remark, ReferenceNo,
			 DebitAmount, CreditAmount, Balance, IsAdminFee, UCreate, DCreate, RecordStatus)
		SELECT @ID,
			   R.value('@s', 'INT'),
			   R.value('@d', 'DATETIME'),
			   R.value('@m', 'VARCHAR(1000)'),
			   NULLIF(R.value('@f', 'VARCHAR(100)'), ''),
			   R.value('@db', 'DECIMAL(22,4)'),
			   R.value('@cr', 'DECIMAL(22,4)'),
			   R.value('@b', 'DECIMAL(22,4)'),
			   R.value('@a', 'BIT'),
			   @UserID, GETDATE(), 'A'
		FROM @Xml.nodes('/rows/r') X(R)

		IF @@ROWCOUNT = 0
		BEGIN
			ROLLBACK TRANSACTION
			SELECT 'error' AS Result, 0 AS ID, 'Tidak ada baris transaksi untuk disimpan.' AS LogDesc
			RETURN
		END

		COMMIT TRANSACTION

		SELECT 'success' AS Result, @ID AS ID, 'Rekening koran berhasil disimpan.' AS LogDesc
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT 'error' AS Result, 0 AS ID, ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
