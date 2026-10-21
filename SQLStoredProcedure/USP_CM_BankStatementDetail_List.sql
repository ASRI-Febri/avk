SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Baris rekening koran beserta jurnal yang sudah dibuat.
--				Jurnal yang sudah dihapus/void (RecordStatus <> 'A') dianggap
--				belum ada, sehingga barisnya bisa dijurnal ulang.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatementDetail_List') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatementDetail_List]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatementDetail_List]
	@IDX_T_BankStatementHeader BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		SD.IDX_T_BankStatementDetail,
		SD.SeqNo,
		CONVERT(VARCHAR(19), SD.PostingDate, 120)	AS PostingDate,
		RTRIM(SD.Remark)							AS Remark,
		RTRIM(ISNULL(SD.ReferenceNo, ''))			AS ReferenceNo,
		SD.DebitAmount,
		SD.CreditAmount,
		SD.Balance,
		SD.IsAdminFee,
		J.IDX_T_JournalHeader,
		RTRIM(J.VoucherNo)							AS VoucherNo,
		J.PostingStatus
	FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
		LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
			ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
	WHERE SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
	ORDER BY SD.SeqNo
END
GO
