SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Tren saldo Kas & Bank dan nilai Persediaan Valas 12 bulan.
--               Saldo akhir tiap bulan = saldo awal (sebelum window) + akumulasi mutasi.
--
--   Kas & Bank      : akun 1110, 1111  (Debet - Kredit)
--   Persediaan Valas: akun 1117
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Cash_Trend] '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Cash_Trend]
	@AsOfDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_StartMonth DATE = DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1)
	DECLARE @_From       DATE = DATEADD(MONTH, -11, @_StartMonth)
	DECLARE @_To         DATE = DATEADD(MONTH, 1, @_StartMonth)

	-- Saldo awal sebelum window (akumulasi s/d sebelum @_From)
	DECLARE @_BeginCash DECIMAL(22,2) = 0
	DECLARE @_BeginInv  DECIMAL(22,2) = 0

	SELECT
		@_BeginCash = ISNULL(SUM(CASE WHEN LEFT(A.COAID,4) IN ('1110','1111') THEN JD.BDebetAmount - JD.BCreditAmount END), 0),
		@_BeginInv  = ISNULL(SUM(CASE WHEN LEFT(A.COAID,4) = '1117' THEN JD.BDebetAmount - JD.BCreditAmount END), 0)
	FROM GL_T_JournalDetail JD WITH(NOLOCK)
		INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
		INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
	WHERE JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
		AND CONVERT(DATE, JH.JournalDate) < @_From

	;WITH Months AS (
		SELECT @_From AS M
		UNION ALL
		SELECT DATEADD(MONTH, 1, M) FROM Months WHERE M < @_StartMonth
	),
	Mov AS (
		SELECT YEAR(JH.JournalDate) AS Y, MONTH(JH.JournalDate) AS Mo,
			SUM(CASE WHEN LEFT(A.COAID,4) IN ('1110','1111') THEN JD.BDebetAmount - JD.BCreditAmount ELSE 0 END) AS CashMov,
			SUM(CASE WHEN LEFT(A.COAID,4) = '1117' THEN JD.BDebetAmount - JD.BCreditAmount ELSE 0 END) AS InvMov
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
		WHERE JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND JH.JournalDate >= @_From AND JH.JournalDate < @_To
		GROUP BY YEAR(JH.JournalDate), MONTH(JH.JournalDate)
	),
	Monthly AS (
		SELECT Months.M,
			ISNULL(Mov.CashMov, 0) AS CashMov,
			ISNULL(Mov.InvMov, 0)  AS InvMov
		FROM Months
		LEFT JOIN Mov ON Mov.Y = YEAR(Months.M) AND Mov.Mo = MONTH(Months.M)
	)
	SELECT
		CONVERT(VARCHAR(6), M, 112) AS Period,
		FORMAT(M, 'MMM yy') AS PeriodLabel,
		@_BeginCash + SUM(CashMov) OVER (ORDER BY M ROWS UNBOUNDED PRECEDING) AS CashBank,
		@_BeginInv  + SUM(InvMov)  OVER (ORDER BY M ROWS UNBOUNDED PRECEDING) AS InventoryValas
	FROM Monthly
	ORDER BY M
	OPTION (MAXRECURSION 100);
END
GO
