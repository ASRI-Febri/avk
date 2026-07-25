SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Update flag IsDTTOT pada data konsumen dari hasil Screening DTTOT.
-- =============================================

-- EXEC USP_GN_Partner_SetDTTOT 123,'Y','admin'

CREATE PROCEDURE [dbo].[USP_GN_Partner_SetDTTOT]
	@IDX_M_Partner		BIGINT,
	@IsDTTOT			CHAR(1),
	@UserID				VARCHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE GN_M_Partner SET
		IsDTTOT = CASE WHEN @IsDTTOT = 'Y' THEN 'Y' ELSE 'N' END,
		UModified = @UserID,
		DModified = SYSDATETIME()
	WHERE IDX_M_Partner = @IDX_M_Partner

	SELECT 'success' AS Result
END
GO
