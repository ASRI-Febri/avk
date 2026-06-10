SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Tren Profitabilitas 12 bulan (Money Changer).
--               Sumber data : GL (jurnal terposting), konsisten dengan laporan PL.
--               Output 1 baris per bulan : Revenue, COGS, OpEx (laba bersih dihitung di view).
--
--   Klasifikasi akun (LEFT(COAID,4)) :
--     Revenue : 4100, 4200, 7110   (pendapatan, natural credit)
--     COGS    : 5110, 5113         (pembelian / HPP valas)
--     OpEx    : 6110,6111,6112,6113,8110,8111
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Profitability_Trend] '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Profitability_Trend]
	@AsOfDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_StartMonth DATE = DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1)
	DECLARE @_From       DATE = DATEADD(MONTH, -11, @_StartMonth)
	DECLARE @_To         DATE = DATEADD(MONTH, 1, @_StartMonth)   -- exclusive

	;WITH Months AS (
		SELECT @_From AS M
		UNION ALL
		SELECT DATEADD(MONTH, 1, M) FROM Months WHERE M < @_StartMonth
	),
	J AS (
		SELECT YEAR(JH.JournalDate) AS Y, MONTH(JH.JournalDate) AS Mo, LEFT(A.COAID,4) AS P,
			SUM(JD.BCreditAmount - JD.BDebetAmount) AS CreditMinusDebit,
			SUM(JD.BDebetAmount  - JD.BCreditAmount) AS DebitMinusCredit
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
		WHERE JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND JH.JournalDate >= @_From AND JH.JournalDate < @_To
		GROUP BY YEAR(JH.JournalDate), MONTH(JH.JournalDate), LEFT(A.COAID,4)
	)
	SELECT
		CONVERT(VARCHAR(6), Months.M, 112) AS Period,
		FORMAT(Months.M, 'MMM yy') AS PeriodLabel,
		ISNULL(SUM(CASE WHEN J.P IN ('4100','4200','7110') THEN J.CreditMinusDebit END), 0) AS Revenue,
		ISNULL(SUM(CASE WHEN J.P IN ('5110','5113') THEN J.DebitMinusCredit END), 0) AS COGS,
		ISNULL(SUM(CASE WHEN J.P IN ('6110','6111','6112','6113','8110','8111') THEN J.DebitMinusCredit END), 0) AS OpEx
	FROM Months
	LEFT JOIN J ON J.Y = YEAR(Months.M) AND J.Mo = MONTH(Months.M)
	GROUP BY Months.M
	ORDER BY Months.M
	OPTION (MAXRECURSION 100);
END
GO
