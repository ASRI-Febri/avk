SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Daftar lampiran aktif satu transaksi (lihat GN_T_Attachment).
-- =============================================
IF OBJECT_ID('dbo.USP_GN_Attachment_List') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_Attachment_List]
GO
CREATE PROCEDURE [dbo].[USP_GN_Attachment_List]
	@SourceType	VARCHAR(10),
	@SourceID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.IDX_T_Attachment, A.SourceType, A.SourceID, RTRIM(A.Category) AS Category,
		   RTRIM(A.FileName) AS FileName, RTRIM(A.StoredName) AS StoredName, A.FileSize,
		   RTRIM(ISNULL(A.Description, '')) AS Description,
		   RTRIM(A.UCreate) AS UCreate, RTRIM(ISNULL(U.Name, A.UCreate)) AS CreateByName, A.DCreate
	FROM GN_T_Attachment A WITH(NOLOCK)
		LEFT JOIN SM_M_User U WITH(NOLOCK) ON RTRIM(U.LoginID) = RTRIM(A.UCreate)
	WHERE A.SourceType = @SourceType AND A.SourceID = @SourceID AND A.RecordStatus = 'A'
	ORDER BY A.IDX_T_Attachment
END
GO
