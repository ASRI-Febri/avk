SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Get single template journal recurring by IDX
-- =============================================

-- EXEC [dbo].[USP_GL_RecurringJournal_Info] 1

CREATE PROCEDURE [dbo].[USP_GL_RecurringJournal_Info]
	@IDX_M_RecurringJournal	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		RJ.IDX_M_RecurringJournal,
		RJ.IDX_M_Company,
		RJ.IDX_M_Branch,
		RJ.RecurringCode,
		RJ.RecurringName,
		RJ.RecurringDesc,
		RJ.IDX_M_COA_Debet,
		RJ.IDX_M_COA_Credit,
		RJ.RecurringAmount,
		TotalAmount = ISNULL(RJ.TotalAmount, 0),
		AdjustLastPeriod = ISNULL(RJ.AdjustLastPeriod, 'N'),
		RJ.StartPeriod,
		RJ.EndPeriod,
		RJ.RecurringStatus,
		RJ.RecordStatus,
		RJ.UCreate,
		RJ.DCreate,
		RJ.UModified,
		RJ.DModified
	FROM GL_M_RecurringJournal RJ WITH(NOLOCK)
	WHERE RJ.IDX_M_RecurringJournal = @IDX_M_RecurringJournal

END
GO
