SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Sumber data Laporan LTKM dari tabel MC_T_LTKM (hasil Proses LTKM).
--				@LTKMPeriod = '' untuk menampilkan semua periode.
-- =============================================

-- EXEC USP_MC_LTKM_List '202607'
-- EXEC USP_MC_LTKM_List ''

CREATE PROCEDURE [dbo].[USP_MC_LTKM_List]
	@LTKMPeriod			VARCHAR(6) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		M.IDX_T_LTKM, M.LTKMPeriod, M.IDX_T_SalesOrder, M.SONumber, M.TransactionDate,
		M.IDX_M_Partner, M.PartnerID, M.PartnerName, M.SingleIdentityNumber,
		M.PlaceOfBirth, M.DateOfBirth, M.Street, M.IsDTTOT,
		M.TotalSalesAmount, M.PaymentCashAmount,
		M.TKMDate, RTRIM(ISNULL(M.TKMIndicator,'')) AS TKMIndicator,
		M.ReportDueDate, M.ReportStatus, M.DCreate
	FROM MC_T_LTKM M
	WHERE RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
		AND (RTRIM(@LTKMPeriod) = '' OR M.LTKMPeriod = @LTKMPeriod)
	ORDER BY M.TKMDate, M.TransactionDate, M.PartnerName, M.SONumber
END
GO
