SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Satu lampiran aktif, untuk view / download / hapus.
-- =============================================
IF OBJECT_ID('dbo.USP_GN_Attachment_Info') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_Attachment_Info]
GO
CREATE PROCEDURE [dbo].[USP_GN_Attachment_Info]
	@IDX_T_Attachment	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IDX_T_Attachment, RTRIM(SourceType) AS SourceType, SourceID, RTRIM(Category) AS Category,
		   RTRIM(FileName) AS FileName, RTRIM(StoredName) AS StoredName, FileSize
	FROM GN_T_Attachment WITH(NOLOCK)
	WHERE IDX_T_Attachment = @IDX_T_Attachment AND RecordStatus = 'A'
END
GO
