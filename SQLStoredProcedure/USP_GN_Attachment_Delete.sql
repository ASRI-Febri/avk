SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Menghapus lampiran (RecordStatus 'D'); file fisik tetap disimpan
--				untuk keperluan audit.
-- =============================================
IF OBJECT_ID('dbo.USP_GN_Attachment_Delete') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_Attachment_Delete]
GO
CREATE PROCEDURE [dbo].[USP_GN_Attachment_Delete]
	@IDX_T_Attachment	BIGINT,
	@UserID				VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE GN_T_Attachment
	SET RecordStatus = 'D', UModified = @UserID, DModified = GETDATE()
	WHERE IDX_T_Attachment = @IDX_T_Attachment AND RecordStatus = 'A'

	IF @@ROWCOUNT = 0
		SELECT 'error' AS Result, @IDX_T_Attachment AS ID, 'Lampiran tidak ditemukan atau sudah dihapus.' AS LogDesc
	ELSE
		SELECT 'success' AS Result, @IDX_T_Attachment AS ID, 'Lampiran dihapus.' AS LogDesc
END
GO
