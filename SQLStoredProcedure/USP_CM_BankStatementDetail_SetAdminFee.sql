SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 21 Oct 2026
-- Description:	Menandai / melepas tanda biaya admin pada satu baris rekening
--				koran. Deteksi otomatis saat upload bisa meleset, jadi user
--				boleh mengoreksi selama baris tersebut belum dijurnal.
-- =============================================
IF OBJECT_ID('dbo.USP_CM_BankStatementDetail_SetAdminFee') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_BankStatementDetail_SetAdminFee]
GO
CREATE PROCEDURE [dbo].[USP_CM_BankStatementDetail_SetAdminFee]
	@IDX_T_BankStatementDetail	BIGINT,
	@IsAdminFee					BIT,
	@UserID						VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM CM_T_BankStatementDetail SD WITH(NOLOCK)
				   INNER JOIN GL_T_JournalHeader J WITH(NOLOCK)
					   ON SD.IDX_T_JournalHeader = J.IDX_T_JournalHeader AND J.RecordStatus = 'A'
			   WHERE SD.IDX_T_BankStatementDetail = @IDX_T_BankStatementDetail)
	BEGIN
		SELECT 'error' AS Result, @IDX_T_BankStatementDetail AS ID, 'Baris ini sudah dijurnal.' AS LogDesc
		RETURN
	END

	IF @IsAdminFee = 1 AND EXISTS (SELECT 1 FROM CM_T_BankStatementDetail WITH(NOLOCK)
								   WHERE IDX_T_BankStatementDetail = @IDX_T_BankStatementDetail AND DebitAmount <= 0)
	BEGIN
		SELECT 'error' AS Result, @IDX_T_BankStatementDetail AS ID, 'Hanya baris debit yang bisa ditandai biaya admin.' AS LogDesc
		RETURN
	END

	UPDATE CM_T_BankStatementDetail
	SET IsAdminFee = @IsAdminFee, UModified = @UserID, DModified = GETDATE()
	WHERE IDX_T_BankStatementDetail = @IDX_T_BankStatementDetail

	SELECT 'success' AS Result, @IDX_T_BankStatementDetail AS ID, 'Tanda biaya admin diperbarui.' AS LogDesc
END
GO
