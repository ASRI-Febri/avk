
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
