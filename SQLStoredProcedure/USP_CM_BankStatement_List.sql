SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Daftar rekening koran untuk DataTables (server-side).
--				Parameter posisional dari MyController::get_datatables +
--				BankStatementController::inquiry_data.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_List') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_List]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_List]
	@Page				INT,
	@Row				INT,
	@SortBy				VARCHAR(50),
	@SortDir			VARCHAR(5),
	@ReturnType			CHAR(1),
	@StatementNo		VARCHAR(50)  = '',
	@FinancialAccount	VARCHAR(100) = '',
	@AccountNo			VARCHAR(50)  = '',
	@Period				VARCHAR(20)  = '',
	@UserID				VARCHAR(50)  = ''
AS
BEGIN
	SET NOCOUNT ON;

	;WITH Statement AS
	(
		SELECT
			H.IDX_T_BankStatementHeader,
			RTRIM(H.StatementNo)							AS StatementNo,
			RTRIM(FA.FinancialAccountID) + ' - ' + RTRIM(FA.FinancialAccountDesc) AS FinancialAccount,
			RTRIM(H.AccountNo)								AS AccountNo,
			CONVERT(VARCHAR(10), H.PeriodStart, 120)		AS PeriodStart,
			CONVERT(VARCHAR(10), H.PeriodEnd, 120)			AS PeriodEnd,
			H.OpeningBalance,
			H.ClosingBalance,
			ISNULL(D.LineCount, 0)							AS LineCount,
			ISNULL(D.JournalCount, 0)						AS JournalCount
		FROM CM_T_BankStatementHeader H WITH(NOLOCK)
			INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON H.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
			LEFT JOIN (
				SELECT SD.IDX_T_BankStatementHeader,
					   COUNT(*) AS LineCount,
					   SUM(CASE WHEN J.IDX_T_JournalHeader IS NULL THEN 0 ELSE 1 END) AS JournalCount
				FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
					LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
						ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
				WHERE SD.RecordStatus = 'A'
				GROUP BY SD.IDX_T_BankStatementHeader
			) D ON H.IDX_T_BankStatementHeader = D.IDX_T_BankStatementHeader
		WHERE H.RecordStatus = 'A'
			AND (@StatementNo = '' OR H.StatementNo LIKE '%' + @StatementNo + '%')
			AND (@FinancialAccount = '' OR FA.FinancialAccountID + ' ' + FA.FinancialAccountDesc LIKE '%' + @FinancialAccount + '%')
			AND (@AccountNo = '' OR H.AccountNo LIKE '%' + @AccountNo + '%')
			AND (@Period = '' OR CONVERT(VARCHAR(10), H.PeriodStart, 120) LIKE '%' + @Period + '%')
			AND H.IDX_M_Branch IN (
				SELECT UB.IDX_M_Branch
				FROM SM_M_UserBranch UB WITH(NOLOCK)
					INNER JOIN SM_M_User SU WITH(NOLOCK) ON UB.IDX_M_User = SU.IDX_M_User
				WHERE SU.LoginID = @UserID AND UB.RecordStatus = 'A'
			)
	)
	SELECT
		ROW_NUMBER() OVER (ORDER BY
			CASE WHEN @SortDir = 'asc'  AND @SortBy = 'StatementNo' THEN StatementNo END ASC,
			CASE WHEN @SortDir = 'desc' AND @SortBy = 'StatementNo' THEN StatementNo END DESC,
			PeriodStart DESC, IDX_T_BankStatementHeader DESC) AS RowNumber,
		*
	INTO #Result
	FROM Statement;

	IF @ReturnType = 'C'
	BEGIN
		SELECT COUNT(*) AS TotalRows FROM #Result;
		RETURN;
	END

	SELECT *
	FROM #Result
	WHERE RowNumber BETWEEN ((@Page - 1) * @Row) + 1 AND (@Page * @Row)
	ORDER BY RowNumber;
END
GO
