
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	7 April 2026
-- Description	:	Check journal balance
-- =============================================

-- EXEC [USP_GL_CheckJournalBalance] 1

CREATE PROCEDURE [dbo].[USP_GL_CheckJournalBalance] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SubQuery.IDX_T_JournalHeader, SubQuery.VoucherNo, SubQuery.TotalDebet, SubQuery.TotalCredit 
	FROM 
		(SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, SUM(JD.BDebetAmount) AS TotalDebet, SUM(JD.BCreditAmount) AS TotalCredit
			FROM GL_T_JournalHeader JH
			LEFT JOIN GL_T_JournalDetail JD ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			WHERE JH.PostingStatus = 'P'
			GROUP BY JH.IDX_T_JournalHeader, JH.VoucherNo
		) AS SubQuery
	WHERE TotalDebet <> TotalCredit


END



