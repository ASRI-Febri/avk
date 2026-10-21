SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Membuat satu jurnal dua baris (Dr @DebitCOA / Cr @CreditCOA)
--				dari rekening koran. Dipakai bersama oleh
--				USP_CM_BankStatement_CreateJournal (per baris mutasi) dan
--				USP_CM_BankStatement_CreateAdminFeeJournal (gabungan biaya admin);
--				pemanggil yang mengatur transaksi.
--
--				Jurnal bertipe JM (Journal Memorial / penyesuaian), berstatus
--				Unposted dengan nomor DRAFT-<id> seperti jurnal manual, sehingga
--				akunting masih bisa memeriksa lalu mem-posting lewat menu Journal.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_InsertJournal') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_InsertJournal]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_InsertJournal]
	@IDX_T_BankStatementHeader	BIGINT,
	@JournalDate				DATETIME,
	@Remark						VARCHAR(5000),
	@DebitCOA					BIGINT,
	@CreditCOA					BIGINT,
	@Amount						DECIMAL(22,4),
	@UserID						VARCHAR(50),
	@IDX_T_JournalHeader		BIGINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @JournalType INT, @Currency INT, @IDX_M_Company BIGINT, @IDX_M_Branch BIGINT, @StatementNo VARCHAR(50)

	SELECT @JournalType = IDX_M_JournalType FROM GL_M_JournalType WITH(NOLOCK) WHERE JournalTypeID = 'JM'

	SELECT TOP 1 @Currency = IDX_M_Currency FROM GN_M_Currency WITH(NOLOCK)
	WHERE RecordStatus = 'A' AND CurrencyID = 'IDR'

	SELECT @IDX_M_Company = IDX_M_Company, @IDX_M_Branch = IDX_M_Branch, @StatementNo = RTRIM(StatementNo)
	FROM CM_T_BankStatementHeader WITH(NOLOCK)
	WHERE IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader

	INSERT INTO GL_T_JournalHeader
		(IDX_M_Company, IDX_M_Branch, IDX_M_JournalType, IDX_ReferenceNo, ReferenceNo, VoucherNo,
		 JournalDate, RemarkHeader, PostingStatus, DebetAmount, CreditAmount, JournalSource,
		 UCreate, DCreate, RecordStatus)
	VALUES
		(@IDX_M_Company, @IDX_M_Branch, @JournalType, @IDX_T_BankStatementHeader, LEFT(@StatementNo, 32), 'DRAFT',
		 CONVERT(DATE, @JournalDate), @Remark, 'U', @Amount, @Amount, 'S',
		 @UserID, GETDATE(), 'A')

	SET @IDX_T_JournalHeader = SCOPE_IDENTITY()

	UPDATE GL_T_JournalHeader SET VoucherNo = 'DRAFT-' + CONVERT(VARCHAR, @IDX_T_JournalHeader)
	WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

	INSERT INTO GL_T_JournalDetail
		(IDX_T_JournalHeader, IDX_M_COA, JournalSeqNo, COADescription, RemarkDetail,
		 OriginalCurrencyID, ODebetAmount, OCreditAmount, ExchangeRate, BaseCurrencyID, BDebetAmount, BCreditAmount,
		 UCreate, DCreate, RecordStatus)
	SELECT @IDX_T_JournalHeader, L.IDX_M_COA, L.SeqNo,
		   LTRIM(RTRIM(ISNULL(COA.COAID, '') + ' - ' + ISNULL(COA.COADesc, ''))),
		   LEFT(@Remark, 8000),
		   @Currency, L.Debit, L.Credit, 1, @Currency, L.Debit, L.Credit,
		   @UserID, GETDATE(), 'A'
	FROM (VALUES (1, @DebitCOA, @Amount, 0), (2, @CreditCOA, 0, @Amount)) L(SeqNo, IDX_M_COA, Debit, Credit)
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON L.IDX_M_COA = COA.IDX_M_COA
END
GO
