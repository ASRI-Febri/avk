SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Preview kandidat LTKT (Laporan Transaksi Keuangan Tunai).
--				Kriteria: penjualan approved dengan total pembayaran TUNAI
--				per nasabah per hari >= @CashThreshold (default Rp 500.000.000).
--				Kolom ProcessedRows = jumlah baris yang sudah tersimpan di
--				MC_T_LTKT untuk periode ini (0 = belum pernah diproses).
-- =============================================

-- EXEC USP_MC_LTKT_Preview '202607'

CREATE PROCEDURE [dbo].[USP_MC_LTKT_Preview]
	@LTKTPeriod			VARCHAR(6),
	@CashThreshold		DECIMAL(18,2) = 500000000
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate DATE = DATEFROMPARTS(CAST(LEFT(@LTKTPeriod,4) AS INT), CAST(RIGHT(@LTKTPeriod,2) AS INT), 1)
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
		PlaceOfBirth			VARCHAR(64),
		DateOfBirth				DATE,
		Street					VARCHAR(1024),
		TotalSalesAmount		DECIMAL(18,4),
		PaymentCashAmount		DECIMAL(18,4)
	)

	INSERT INTO #Sales
	SELECT S.IDX_T_SalesOrder, S.SONumber, CONVERT(DATE, S.SODate), ISNULL(S.IDX_M_Partner,0),
		RTRIM(ISNULL(P.PartnerID,'')), UPPER(RTRIM(ISNULL(P.PartnerName,''))),
		RTRIM(ISNULL(P.SingleIdentityNumber,'')), RTRIM(ISNULL(P.PlaceOfBirth,'')), P.DateOfBirth,
		RTRIM(ISNULL(PA.Street,'')),
		ISNULL(SOD.BaseCurrencyAmount,0), 0
	FROM MC_T_SalesOrder S
	LEFT JOIN (
		SELECT SOD.IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS BaseCurrencyAmount
		FROM MC_T_SalesOrderDetail SOD
		WHERE SOD.RecordStatus = 'A'
		GROUP BY SOD.IDX_T_SalesOrder
	) SOD ON SOD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
	LEFT JOIN GN_M_Partner P ON P.IDX_M_Partner = S.IDX_M_Partner
	OUTER APPLY (
		SELECT TOP 1 A.Street
		FROM GN_M_PartnerAddress A
		WHERE A.IDX_M_Partner = P.IDX_M_Partner
			AND RTRIM(ISNULL(A.RecordStatus,'')) = 'A'
		ORDER BY CASE WHEN RTRIM(ISNULL(A.IsDefault,'')) = 'Y' THEN 0 ELSE 1 END, A.IDX_M_PartnerAddress
	) PA
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
	-- KANDIDAT: TOTAL TUNAI PER NASABAH PER HARI >= THRESHOLD
	-- ============================================================
	SELECT * FROM (
		SELECT S.*,
			SUM(S.PaymentCashAmount) OVER (PARTITION BY S.IDX_M_Partner, S.TransactionDate) AS DailyCashAmount,
			(SELECT COUNT(*) FROM MC_T_LTKT L
				WHERE L.LTKTPeriod = @LTKTPeriod AND RTRIM(ISNULL(L.RecordStatus,'')) = 'A') AS ProcessedRows
		FROM #Sales S
	) X
	WHERE X.DailyCashAmount >= @CashThreshold
	ORDER BY X.TransactionDate, X.PartnerName, X.SONumber
END
GO
