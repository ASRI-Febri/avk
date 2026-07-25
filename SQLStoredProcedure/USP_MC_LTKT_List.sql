SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Sumber data Laporan LTKT dari tabel MC_T_LTKT (hasil Proses LTKT).
--				@LTKTPeriod = '' untuk menampilkan semua periode.
-- =============================================

-- EXEC USP_MC_LTKT_List '202607'
-- EXEC USP_MC_LTKT_List ''

CREATE PROCEDURE [dbo].[USP_MC_LTKT_List]
	@LTKTPeriod			VARCHAR(6) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		L.IDX_T_LTKT, L.LTKTPeriod, L.IDX_T_SalesOrder, L.SONumber, L.TransactionDate,
		L.IDX_M_Partner, L.PartnerID, L.PartnerName, L.SingleIdentityNumber,
		L.PlaceOfBirth, L.DateOfBirth, L.Street,
		L.TotalSalesAmount, L.PaymentCashAmount, L.DailyCashAmount,
		L.ReportDueDate, L.ReportStatus, L.DCreate
	FROM MC_T_LTKT L
	WHERE RTRIM(ISNULL(L.RecordStatus,'')) = 'A'
		AND (RTRIM(@LTKTPeriod) = '' OR L.LTKTPeriod = @LTKTPeriod)
	ORDER BY L.TransactionDate, L.PartnerName, L.SONumber
END
GO
