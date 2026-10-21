SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Header rekening koran beserta ringkasan baris biaya admin yang
--				belum dijurnal (untuk tombol Jurnal Biaya Admin).
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_Info') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_Info]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_Info]
	@IDX_T_BankStatementHeader BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		H.IDX_T_BankStatementHeader,
		H.IDX_M_Company,
		H.IDX_M_Branch,
		H.IDX_M_FinancialAccount,
		RTRIM(H.StatementNo)								AS StatementNo,
		RTRIM(FA.FinancialAccountID) + ' - ' + RTRIM(FA.FinancialAccountDesc) AS FinancialAccount,
		RTRIM(ISNULL(COA.COAID, '')) + ' - ' + RTRIM(ISNULL(COA.COADesc, ''))  AS BankCOA,
		RTRIM(H.BankName)									AS BankName,
		RTRIM(H.AccountNo)									AS AccountNo,
		RTRIM(H.AccountName)								AS AccountName,
		RTRIM(H.CurrencyID)									AS CurrencyID,
		CONVERT(VARCHAR(10), H.PeriodStart, 120)			AS PeriodStart,
		CONVERT(VARCHAR(10), H.PeriodEnd, 120)				AS PeriodEnd,
		H.OpeningBalance,
		H.ClosingBalance,
		H.TotalDebit,
		H.TotalCredit,
		RTRIM(H.FileName)									AS FileName,
		RTRIM(H.Notes)										AS Notes,
		ISNULL(F.AdminFeeCount, 0)							AS AdminFeeCount,
		ISNULL(F.AdminFeeAmount, 0)							AS AdminFeeAmount,
		H.UCreate, H.DCreate, H.UModified, H.DModified, H.RecordStatus
	FROM CM_T_BankStatementHeader H WITH(NOLOCK)
		INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON FA.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN (
			SELECT SD.IDX_T_BankStatementHeader, COUNT(*) AS AdminFeeCount, SUM(SD.DebitAmount) AS AdminFeeAmount
			FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
				LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
					ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
			WHERE SD.RecordStatus = 'A' AND SD.IsAdminFee = 1 AND SD.DebitAmount > 0 AND J.IDX_T_JournalHeader IS NULL
			GROUP BY SD.IDX_T_BankStatementHeader
		) F ON H.IDX_T_BankStatementHeader = F.IDX_T_BankStatementHeader
	WHERE H.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader
END
GO
