SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Oct 2026
-- Description:	Baris akhir bulan rekening koran Mandiri yang belum dijurnal,
--				dikelompokkan per kategori jurnal:
--				  ADMIN    : debit "MONTHLY CARD CHARGE ..." dan "Biaya Adm ..."
--				  INTEREST : kredit "Bunga ..."
--				  TAX      : debit "Pajak ..." (pajak atas bunga)
--				Baris yang ditandai biaya admin (IsAdminFee) tidak ikut, karena
--				masuk ke Jurnal Biaya Admin.
--				Satu-satunya tempat aturan kategori ini; dipakai untuk modal dan
--				oleh USP_CM_BankStatement_CreateMonthEndJournal.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_MonthEndRows') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_MonthEndRows]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_MonthEndRows]
	@IDX_T_BankStatementHeader BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM (
		SELECT
			SD.IDX_T_BankStatementDetail,
			SD.SeqNo,
			CONVERT(VARCHAR(19), SD.PostingDate, 120)	AS PostingDate,
			RTRIM(SD.Remark)							AS Remark,
			SD.DebitAmount,
			SD.CreditAmount,
			CASE
				WHEN SD.DebitAmount > 0 AND SD.IsAdminFee = 0
					 AND (SD.Remark LIKE 'MONTHLY CARD CHARGE%' OR SD.Remark LIKE 'Biaya Adm%') THEN 'ADMIN'
				WHEN SD.CreditAmount > 0 AND SD.Remark LIKE 'Bunga%' THEN 'INTEREST'
				WHEN SD.DebitAmount > 0 AND SD.Remark LIKE 'Pajak%' THEN 'TAX'
			END											AS Category
		FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
			LEFT JOIN GL_T_JournalHeader J WITH(NOLOCK)
				ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
		WHERE SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A'
			AND J.IDX_T_JournalHeader IS NULL
	) R
	WHERE R.Category IS NOT NULL
	ORDER BY R.PostingDate, R.SeqNo
END
GO
