SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Proses LTKT: simpan kandidat transaksi tunai >= threshold ke MC_T_LTKT.
--				Kriteria harus sama dengan USP_MC_LTKT_Preview.
--				Proses ulang periode yang sama akan menghapus hasil sebelumnya (replace).
--				ReportDueDate = 14 hari kerja (Senin-Jumat) sejak tanggal transaksi.
-- =============================================

-- EXEC USP_MC_LTKT_Process '202607','admin'

CREATE PROCEDURE [dbo].[USP_MC_LTKT_Process]
	@LTKTPeriod			VARCHAR(6),
	@UserID				VARCHAR(36),
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
	SELECT X.*, CAST(NULL AS DATE) AS ReportDueDate
	INTO #Candidate
	FROM (
		SELECT S.*,
			SUM(S.PaymentCashAmount) OVER (PARTITION BY S.IDX_M_Partner, S.TransactionDate) AS DailyCashAmount
		FROM #Sales S
	) X
	WHERE X.DailyCashAmount >= @CashThreshold

	-- ============================================================
	-- BATAS LAPOR: 14 HARI KERJA (SENIN-JUMAT) SEJAK TANGGAL TRANSAKSI
	-- Hari 0 (1900-01-01) adalah Senin, sehingga modulo 7 < 5 = weekday
	-- ============================================================
	;WITH N AS (
		SELECT TOP (40) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
		FROM sys.all_objects
	)
	UPDATE C SET ReportDueDate = D.DueDate
	FROM #Candidate C
	CROSS APPLY (
		SELECT x.D AS DueDate
		FROM (
			SELECT DATEADD(DAY, N.n, C.TransactionDate) AS D,
				ROW_NUMBER() OVER (ORDER BY N.n) AS rn
			FROM N
			WHERE (DATEDIFF(DAY, 0, DATEADD(DAY, N.n, C.TransactionDate)) % 7) < 5
		) x
		WHERE x.rn = 14
	) D

	-- ============================================================
	-- REPLACE DATA PERIODE
	-- ============================================================
	DELETE FROM MC_T_LTKT WHERE LTKTPeriod = @LTKTPeriod

	INSERT INTO MC_T_LTKT (
		LTKTPeriod, IDX_T_SalesOrder, SONumber, TransactionDate,
		IDX_M_Partner, PartnerID, PartnerName, SingleIdentityNumber, PlaceOfBirth, DateOfBirth, Street,
		TotalSalesAmount, PaymentCashAmount, DailyCashAmount, ReportDueDate,
		ReportStatus, UCreate, DCreate, RecordStatus
	)
	SELECT
		@LTKTPeriod, C.IDX_T_SalesOrder, C.SONumber, C.TransactionDate,
		C.IDX_M_Partner, C.PartnerID, C.PartnerName, C.SingleIdentityNumber, C.PlaceOfBirth, C.DateOfBirth, C.Street,
		C.TotalSalesAmount, C.PaymentCashAmount, C.DailyCashAmount, C.ReportDueDate,
		'O', @UserID, SYSDATETIME(), 'A'
	FROM #Candidate C

	SELECT 'success' AS Result, COUNT(*) AS TotalRows FROM #Candidate
END
GO
