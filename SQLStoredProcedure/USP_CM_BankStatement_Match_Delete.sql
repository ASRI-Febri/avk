SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Membatalkan pasangan transaksi yang ditandai cocok manual
--				(RecordStatus 'D'); transaksinya kembali dicocokkan otomatis.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_Match_Delete') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_Match_Delete]
GO
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
GO
