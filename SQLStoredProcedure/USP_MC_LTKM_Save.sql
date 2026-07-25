SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Simpan satu transaksi yang ditetapkan sebagai TKM ke MC_T_LTKM.
--				Snapshot data nasabah & nominal diambil ulang dari sumber.
--				ReportDueDate = 3 hari sejak tanggal penetapan TKM (@TKMDate).
-- =============================================

-- EXEC USP_MC_LTKM_Save '202607',123,'2026-07-25','Transaksi dipecah untuk menghindari threshold','admin'

CREATE PROCEDURE [dbo].[USP_MC_LTKM_Save]
	@LTKMPeriod			VARCHAR(6),
	@IDX_T_SalesOrder	BIGINT,
	@TKMDate			DATE,
	@TKMIndicator		VARCHAR(1000),
	@UserID				VARCHAR(36)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- HINDARI DUPLIKASI TRANSAKSI YANG SAMA
	DELETE FROM MC_T_LTKM WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

	INSERT INTO MC_T_LTKM (
		LTKMPeriod, IDX_T_SalesOrder, SONumber, TransactionDate,
		IDX_M_Partner, PartnerID, PartnerName, SingleIdentityNumber, PlaceOfBirth, DateOfBirth, Street, IsDTTOT,
		TotalSalesAmount, PaymentCashAmount,
		TKMDate, TKMIndicator, ReportDueDate,
		ReportStatus, UCreate, DCreate, RecordStatus
	)
	SELECT
		@LTKMPeriod, S.IDX_T_SalesOrder, S.SONumber, CONVERT(DATE, S.SODate),
		ISNULL(S.IDX_M_Partner,0), RTRIM(ISNULL(P.PartnerID,'')), UPPER(RTRIM(ISNULL(P.PartnerName,''))),
		RTRIM(ISNULL(P.SingleIdentityNumber,'')), RTRIM(ISNULL(P.PlaceOfBirth,'')), P.DateOfBirth,
		RTRIM(ISNULL(PA.Street,'')),
		CASE WHEN RTRIM(ISNULL(P.IsDTTOT,'N')) = 'Y' THEN 'Y' ELSE 'N' END,
		ISNULL(SOD.BaseCurrencyAmount,0), ISNULL(PMT.ReceiveAmount,0),
		@TKMDate, @TKMIndicator, DATEADD(DAY, 3, @TKMDate),
		'O', @UserID, SYSDATETIME(), 'A'
	FROM MC_T_SalesOrder S
	LEFT JOIN (
		SELECT SOD.IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS BaseCurrencyAmount
		FROM MC_T_SalesOrderDetail SOD
		WHERE SOD.RecordStatus = 'A'
		GROUP BY SOD.IDX_T_SalesOrder
	) SOD ON SOD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
	LEFT JOIN (
		SELECT FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.ReceiveAmount) AS ReceiveAmount
		FROM CM_T_FinancialReceiveDetail FPD
		INNER JOIN CM_T_FinancialReceiveHeader FPH
			ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
		WHERE FPH.ReceiveStatus = 'A'
			AND FPH.IDX_M_FinancialAccount = 3 -- CASH
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT ON PMT.IDX_DocumentNo = S.IDX_T_SalesOrder AND PMT.DocumentNo = S.SONumber
	LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner
	OUTER APPLY (
		SELECT TOP 1 A.Street
		FROM GN_M_PartnerAddress A
		WHERE A.IDX_M_Partner = P.IDX_M_Partner
			AND RTRIM(ISNULL(A.RecordStatus,'')) = 'A'
		ORDER BY CASE WHEN RTRIM(ISNULL(A.IsDefault,'')) = 'Y' THEN 0 ELSE 1 END, A.IDX_M_PartnerAddress
	) PA
	WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder

	SELECT 'success' AS Result
END
GO
