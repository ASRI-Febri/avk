CREATE PROCEDURE [dbo].[USP_CM_BankStatement_LedgerBalance]
	@IDX_T_BankStatementHeader BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @COA BIGINT, @Company BIGINT, @Start DATE, @End DATE

	SELECT @COA = FA.IDX_M_COA, @Company = H.IDX_M_Company, @Start = H.PeriodStart, @End = H.PeriodEnd
	FROM CM_T_BankStatementHeader H WITH(NOLOCK)
		INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
	WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader

	SELECT
		ISNULL(SUM(CASE WHEN J.PostingStatus = 'P' AND J.JournalDate < @Start
						THEN D.BDebetAmount - D.BCreditAmount END), 0)	AS OpeningBalance,
		ISNULL(SUM(CASE WHEN J.PostingStatus = 'P'
						THEN D.BDebetAmount - D.BCreditAmount END), 0)	AS ClosingBalance,
		ISNULL(SUM(CASE WHEN J.PostingStatus <> 'P' AND J.JournalDate >= @Start
						THEN D.BDebetAmount - D.BCreditAmount END), 0)	AS UnpostedNet
	FROM GL_T_JournalDetail D WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader J WITH(NOLOCK) ON D.IDX_T_JournalHeader = J.IDX_T_JournalHeader
	WHERE D.IDX_M_COA = @COA AND J.IDX_M_Company = @Company
		AND J.RecordStatus = 'A' AND D.RecordStatus = 'A'
		AND J.JournalDate < DATEADD(DAY, 1, @End)
END
