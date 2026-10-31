SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Pasangan transaksi yang ditandai cocok manual (masih aktif) pada
--				satu rekening koran. SourceType 'B' = baris rekening koran,
--				'L' = baris ledger COA bank.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_MatchLinks') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_MatchLinks]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_MatchLinks]
	@IDX_T_BankStatementHeader	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT M.IDX_T_BankStatementMatch, D.SourceType, D.SourceID, RTRIM(M.UCreate) AS UCreate, M.DCreate
	FROM CM_T_BankStatementMatch M WITH(NOLOCK)
		INNER JOIN CM_T_BankStatementMatchDetail D WITH(NOLOCK) ON M.IDX_T_BankStatementMatch = D.IDX_T_BankStatementMatch
	WHERE M.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND M.RecordStatus = 'A'
	ORDER BY M.IDX_T_BankStatementMatch, D.SourceType, D.SourceID
END
GO
