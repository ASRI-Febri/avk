
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_AdjustmentLinks]
	@IDX_T_BankStatementHeader	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.IDX_T_JournalHeader, A.SourceType, A.SourceID
	FROM CM_T_BankStatementAdjustment A WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
			ON A.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
	WHERE A.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND A.RecordStatus = 'A'
	ORDER BY A.IDX_T_JournalHeader, A.SourceType, A.SourceID
END
