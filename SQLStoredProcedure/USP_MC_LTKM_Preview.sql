SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Preview kandidat LTKM (Laporan Transaksi Keuangan Mencurigakan).
--				Menampilkan SEMUA penjualan approved dalam periode (tidak ada batasan
--				nominal) sebagai bahan pertimbangan admin untuk menetapkan TKM.
--				Kolom pembantu: IsDTTOT (nasabah terdaftar DTTOT), DailyCashAmount
--				(total tunai nasabah per hari), InLTKM + data TKM yang sudah tersimpan.
-- =============================================

-- EXEC USP_MC_LTKM_Preview '202607'

CREATE PROCEDURE [dbo].[USP_MC_LTKM_Preview]
	@LTKMPeriod			VARCHAR(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate DATE = DATEFROMPARTS(CAST(LEFT(@LTKMPeriod,4) AS INT), CAST(RIGHT(@LTKMPeriod,2) AS INT), 1)
	DECLARE @EndDate   DATE = EOMONTH(@StartDate)

	-- ============================================================
	-- PENJUALAN APPROVED DALAM PERIODE + PEMBAYARAN TUNAI
	-- ============================================================
	CREATE TABLE #Sales (
		IDX_T_SalesOrder		BIGINT,
		SONumber				VARCHAR(50),
		TransactionDate			DATE,
		IDX_M_Partner			BIGINT,
		PartnerID				VARCHAR(32),
		PartnerName				VARCHAR(256),
		SingleIdentityNumber	VARCHAR(64),
		IsDTTOT					CHAR(1),
		TotalSalesAmount		DECIMAL(18,4),
		PaymentCashAmount		DECIMAL(18,4)
	)

	INSERT INTO #Sales
	SELECT S.IDX_T_SalesOrder, S.SONumber, CONVERT(DATE, S.SODate), ISNULL(S.IDX_M_Partner,0),
		RTRIM(ISNULL(P.PartnerID,'')), UPPER(RTRIM(ISNULL(P.PartnerName,''))),
		RTRIM(ISNULL(P.SingleIdentityNumber,'')),
		CASE WHEN RTRIM(ISNULL(P.IsDTTOT,'N')) = 'Y' THEN 'Y' ELSE 'N' END,
		ISNULL(SOD.BaseCurrencyAmount,0), 0
	FROM MC_T_SalesOrder S
	LEFT JOIN (
		SELECT SOD.IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS BaseCurrencyAmount
		FROM MC_T_SalesOrderDetail SOD
		WHERE SOD.RecordStatus = 'A'
		GROUP BY SOD.IDX_T_SalesOrder
	) SOD ON SOD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
	LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner
	WHERE S.SOStatus = 'A' AND CONVERT(DATE, S.SODate) BETWEEN @StartDate AND @EndDate

	-- UPDATE PEMBAYARAN TUNAI (CASH)
	UPDATE #Sales SET PaymentCashAmount = PMT.ReceiveAmount
	FROM (
		SELECT FPD.IDX_DocumentNo, FPD.DocumentNo, SUM(FPD.ReceiveAmount) AS ReceiveAmount
		FROM CM_T_FinancialReceiveDetail FPD
		INNER JOIN CM_T_FinancialReceiveHeader FPH
			ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
		INNER JOIN MC_T_SalesOrder MH
			ON MH.IDX_M_DocumentType = FPD.IDX_M_DocumentType AND MH.SONumber = FPD.DocumentNo
			AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
		WHERE FPH.ReceiveStatus = 'A'
			AND FPH.IDX_M_FinancialAccount = 3 -- CASH
		GROUP BY FPD.IDX_DocumentNo, FPD.DocumentNo
	) PMT
	INNER JOIN #Sales ON #Sales.IDX_T_SalesOrder = PMT.IDX_DocumentNo AND #Sales.SONumber = PMT.DocumentNo

	-- ============================================================
	-- OUTPUT + STATUS TKM YANG SUDAH TERSIMPAN
	-- ============================================================
	SELECT S.*,
		SUM(S.PaymentCashAmount) OVER (PARTITION BY S.IDX_M_Partner, S.TransactionDate) AS DailyCashAmount,
		CASE WHEN M.IDX_T_LTKM IS NULL THEN 0 ELSE 1 END AS InLTKM,
		M.TKMDate, RTRIM(ISNULL(M.TKMIndicator,'')) AS TKMIndicator
	FROM #Sales S
	LEFT JOIN MC_T_LTKM M
		ON M.IDX_T_SalesOrder = S.IDX_T_SalesOrder
		AND RTRIM(ISNULL(M.RecordStatus,'')) = 'A'
	ORDER BY S.TransactionDate, S.PartnerName, S.SONumber
END
GO
