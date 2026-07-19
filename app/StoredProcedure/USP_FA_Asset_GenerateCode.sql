SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Generate kode aset otomatis
--				  Format: FA/{BranchID}/{YYYYMM}/{seq 4 digit}
-- =============================================

-- EXEC [dbo].[USP_FA_Asset_GenerateCode] 1,'2026-07-19'

CREATE PROCEDURE [dbo].[USP_FA_Asset_GenerateCode]
	@IDX_M_Branch		INT,
	@AcquisitionDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_BranchID		VARCHAR(20)
	DECLARE @_Period		VARCHAR(6)
	DECLARE @_Prefix		VARCHAR(40)
	DECLARE @_LastSeq		INT

	SELECT @_BranchID = RTRIM(ISNULL(BranchID,'XX'))
	FROM GN_M_Branch WITH(NOLOCK)
	WHERE IDX_M_Branch = @IDX_M_Branch

	SET @_Period = CONVERT(VARCHAR(6), ISNULL(@AcquisitionDate, GETDATE()), 112)
	SET @_Prefix = 'FA/' + ISNULL(@_BranchID,'XX') + '/' + @_Period + '/'

	SELECT @_LastSeq = ISNULL(MAX(CONVERT(INT, RIGHT(RTRIM(AssetCode), 4))), 0)
	FROM FA_M_Asset WITH(NOLOCK)
	WHERE AssetCode LIKE @_Prefix + '%'
		AND ISNUMERIC(RIGHT(RTRIM(AssetCode), 4)) = 1

	SELECT AssetCode = @_Prefix + RIGHT('0000' + CONVERT(VARCHAR, @_LastSeq + 1), 4)

END
GO
