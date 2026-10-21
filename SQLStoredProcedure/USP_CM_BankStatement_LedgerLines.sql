SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Oct 2026
-- Description:	Baris ledger COA bank (COA milik Financial Account rekening koran)
--				untuk rekonsiliasi dengan rekening koran. Selain periode rekening
--				koran, ikut diambil @Days hari sebelum dan sesudahnya (InPeriod = 0)
--				sebagai kandidat pencocokan transaksi yang beda tanggal; yang tidak
--				cocok tidak ditampilkan.
--				Jurnal Unposted ikut diambil (PostingStatus) supaya jurnal yang baru
--				dibuat dari rekening koran tetap terlihat cocok sebelum diposting.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_LedgerLines') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_LedgerLines]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_LedgerLines]
	@IDX_T_BankStatementHeader	BIGINT,
	@Days						INT = 3
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @COA BIGINT, @Company BIGINT, @Start DATE, @End DATE

	SELECT @COA = FA.IDX_M_COA, @Company = H.IDX_M_Company, @Start = H.PeriodStart, @End = H.PeriodEnd
	FROM CM_T_BankStatementHeader H WITH(NOLOCK)
		INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
	WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader

	SELECT
		D.IDX_T_JournalDetail,
		J.IDX_T_JournalHeader,
		RTRIM(J.VoucherNo)									AS VoucherNo,
		CONVERT(VARCHAR(10), J.JournalDate, 120)			AS JournalDate,
		RTRIM(ISNULL(NULLIF(D.RemarkDetail, ''), J.RemarkHeader)) AS Remark,
		RTRIM(ISNULL(J.PartnerDesc, ''))					AS PartnerDesc,
		D.BDebetAmount,
		D.BCreditAmount,
		J.PostingStatus,
		CASE WHEN J.JournalDate >= @Start AND J.JournalDate < DATEADD(DAY, 1, @End) THEN 1 ELSE 0 END AS InPeriod
	FROM GL_T_JournalDetail D WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader J WITH(NOLOCK) ON D.IDX_T_JournalHeader = J.IDX_T_JournalHeader
	WHERE D.IDX_M_COA = @COA AND J.IDX_M_Company = @Company
		AND J.RecordStatus = 'A' AND D.RecordStatus = 'A'
		AND J.JournalDate >= DATEADD(DAY, -@Days, @Start)
		AND J.JournalDate < DATEADD(DAY, @Days + 1, @End)
	ORDER BY J.JournalDate, J.IDX_T_JournalHeader, D.IDX_T_JournalDetail
END
GO
