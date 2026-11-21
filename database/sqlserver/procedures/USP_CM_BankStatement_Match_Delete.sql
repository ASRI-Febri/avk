
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_Match_Delete]
	@IDX_T_BankStatementMatch	BIGINT,
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE CM_T_BankStatementMatch
	SET RecordStatus = 'D', UModified = @UserID, DModified = GETDATE()
	WHERE IDX_T_BankStatementMatch = @IDX_T_BankStatementMatch AND RecordStatus = 'A'

	IF @@ROWCOUNT = 0
		SELECT 'error' AS Result, @IDX_T_BankStatementMatch AS ID, 'Pasangan tidak ditemukan atau sudah dibatalkan.' AS LogDesc
	ELSE
		SELECT 'success' AS Result, @IDX_T_BankStatementMatch AS ID, 'Tanda cocok dibatalkan.' AS LogDesc
END
