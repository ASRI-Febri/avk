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
