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
