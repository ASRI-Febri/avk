SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Tautan jurnal penyesuaian rekonsiliasi pada satu rekening koran,
--				hanya yang jurnalnya masih aktif. SourceType 'B' = baris rekening
--				koran, 'L' = baris ledger COA bank.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_AdjustmentLinks') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_AdjustmentLinks]
GO
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
GO
