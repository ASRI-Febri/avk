
CREATE PROCEDURE [dbo].[USP_GN_Attachment_Save]
	@SourceType		VARCHAR(10),
	@SourceID		BIGINT,
	@Category		VARCHAR(50),
	@FileName		VARCHAR(255),
	@StoredName		VARCHAR(100),
	@FileSize		BIGINT,
	@Description	VARCHAR(500),
	@UserID			VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT (   (@SourceType = 'FP' AND EXISTS (SELECT 1 FROM CM_T_FinancialPaymentHeader WITH(NOLOCK)
											  WHERE IDX_T_FinancialPaymentHeader = @SourceID AND RecordStatus = 'A'))
			OR (@SourceType = 'JE' AND EXISTS (SELECT 1 FROM GL_T_JournalHeader WITH(NOLOCK)
											  WHERE IDX_T_JournalHeader = @SourceID AND RecordStatus = 'A')))
	BEGIN
		SELECT 'error' AS Result, @SourceID AS ID, 'Transaksi tidak ditemukan.' AS LogDesc
		RETURN
	END

	INSERT INTO GN_T_Attachment
		(SourceType, SourceID, Category, FileName, StoredName, FileSize, Description, UCreate, DCreate, RecordStatus)
	VALUES
		(@SourceType, @SourceID, NULLIF(@Category, ''), @FileName, @StoredName, @FileSize, NULLIF(@Description, ''),
		 @UserID, GETDATE(), 'A')

	SELECT 'success' AS Result, SCOPE_IDENTITY() AS ID, 'Lampiran ' + @FileName + ' berhasil diupload.' AS LogDesc
END
