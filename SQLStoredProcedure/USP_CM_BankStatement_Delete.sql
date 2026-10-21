SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Menghapus (soft delete) rekening koran, mis. karena salah upload.
--				Ditolak bila masih ada baris yang terhubung ke jurnal aktif;
--				hapus/void jurnalnya terlebih dahulu.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatement_Delete') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatement_Delete]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatement_Delete]
	@IDX_T_BankStatementHeader	BIGINT,
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
				   INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
					   ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
			   WHERE SD.IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader AND SD.RecordStatus = 'A')
	BEGIN
		SELECT 'error' AS Result, @IDX_T_BankStatementHeader AS ID,
			   'Rekening koran tidak bisa dihapus karena sudah ada baris yang dijurnal.' AS LogDesc
		RETURN
	END

	UPDATE CM_T_BankStatementHeader
	SET RecordStatus = 'D', UModified = @UserID, DModified = GETDATE()
	WHERE IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader

	UPDATE CM_T_BankStatementDetail
	SET RecordStatus = 'D', UModified = @UserID, DModified = GETDATE()
	WHERE IDX_T_BankStatementHeader = @IDX_T_BankStatementHeader

	SELECT 'success' AS Result, 0 AS ID, 'Rekening koran berhasil dihapus.' AS LogDesc
END
GO
