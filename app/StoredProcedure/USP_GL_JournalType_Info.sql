SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Get single journal type by IDX
-- =============================================

-- EXEC [dbo].[USP_GL_JournalType_Info] 1

CREATE PROCEDURE [dbo].[USP_GL_JournalType_Info]
	@IDX_M_JournalType	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		JT.IDX_M_JournalType,
		JT.JournalTypeID,
		JT.JournalTypeDesc,
		JT.AllowJournalEntry,
		JT.JournalLabel,
		JT.RecordStatus,
		JT.UCreate,
		JT.DCreate,
		JT.UModified,
		JT.DModified
	FROM GL_M_JournalType JT WITH(NOLOCK)
	WHERE JT.IDX_M_JournalType = @IDX_M_JournalType

END
GO
