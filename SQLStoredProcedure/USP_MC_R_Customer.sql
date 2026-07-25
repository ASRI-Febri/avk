SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Laporan data customer berdasarkan periode tanggal pendaftaran (GN_M_Partner.DCreate)
-- =============================================

-- EXEC USP_MC_R_Customer '2026-01-01','2026-07-25'

CREATE PROCEDURE [dbo].[USP_MC_R_Customer]
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		BP.IDX_M_Partner,
		RTRIM(ISNULL(BP.PartnerID,''))				AS PartnerID,
		RTRIM(ISNULL(BP.PartnerName,''))			AS PartnerName,
		RTRIM(ISNULL(BP.PlaceOfBirth,''))			AS PlaceOfBirth,
		BP.DateOfBirth,
		RTRIM(ISNULL(BPA.Street,''))				AS Street,
		RTRIM(ISNULL(BP.SingleIdentityNumber,''))	AS SingleIdentityNumber,
		RTRIM(ISNULL(BP.TaxIdentityNumber,''))		AS TaxIdentityNumber,
		BP.DCreate
	FROM GN_M_Partner BP
		OUTER APPLY (
			SELECT TOP 1 A.Street
			FROM GN_M_PartnerAddress A
			WHERE A.IDX_M_Partner = BP.IDX_M_Partner
				AND RTRIM(ISNULL(A.RecordStatus,'')) = 'A'
			ORDER BY CASE WHEN RTRIM(ISNULL(A.IsDefault,'')) = 'Y' THEN 0 ELSE 1 END, A.IDX_M_PartnerAddress
		) BPA
	WHERE RTRIM(ISNULL(BP.RecordStatus,'')) = 'A'
		AND (RTRIM(ISNULL(BP.IsCustomer,'')) = 'Y' OR RTRIM(ISNULL(BP.IsMember,'')) = 'Y')
		AND CAST(BP.DCreate AS DATE) BETWEEN @StartDate AND @EndDate
	ORDER BY BP.DCreate, BP.PartnerID
END
GO
