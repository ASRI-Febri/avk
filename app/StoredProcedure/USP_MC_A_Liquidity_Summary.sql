SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description : [ANALYTIC] Ringkasan likuiditas & modal kerja per tanggal (GL based).
--               Output 1 baris. Saldo = SUM(Debet - Kredit) s/d @AsOfDate.
--               Untuk akun liabilitas dibalik (Kredit - Debet) agar bernilai positif.
--
--   Aset lancar  : Kas (1110), Bank (1111), Persediaan Valas (1117),
--                  Persediaan/Perlengkapan (1119), Piutang (1115), Dibayar dimuka (1120,1121)
--   Liab lancar  : Hutang Usaha (2110), Hutang Pajak (2115), Uang Muka Penjualan (2119),
--                  Titipan (2120)
-- ==========================================================================================
-- EXEC [dbo].[USP_MC_A_Liquidity_Summary] '2026-06-30'
-- ==========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_MC_A_Liquidity_Summary]
	@AsOfDate	DATE
AS
BEGIN
	SET NOCOUNT ON;

	;WITH Bal AS (
		SELECT LEFT(A.COAID,4) AS P, SUM(JD.BDebetAmount - JD.BCreditAmount) AS Amt
		FROM GL_T_JournalDetail JD WITH(NOLOCK)
			INNER JOIN GL_T_JournalHeader JH WITH(NOLOCK) ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
			INNER JOIN GL_M_COA A WITH(NOLOCK) ON A.IDX_M_COA = JD.IDX_M_COA
		WHERE JH.PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'
			AND CONVERT(DATE, JH.JournalDate) <= @AsOfDate
		GROUP BY LEFT(A.COAID,4)
	)
	SELECT
		@AsOfDate AS AsOfDate,
		ISNULL(SUM(CASE WHEN P = '1110' THEN Amt END), 0) AS Cash,
		ISNULL(SUM(CASE WHEN P = '1111' THEN Amt END), 0) AS Bank,
		ISNULL(SUM(CASE WHEN P = '1117' THEN Amt END), 0) AS InventoryValas,
		ISNULL(SUM(CASE WHEN P = '1119' THEN Amt END), 0) AS InventoryOther,
		ISNULL(SUM(CASE WHEN P = '1115' THEN Amt END), 0) AS Receivable,
		ISNULL(SUM(CASE WHEN P IN ('1120','1121') THEN Amt END), 0) AS Prepaid,
		ISNULL(SUM(CASE WHEN P = '2110' THEN -Amt END), 0) AS Payable,
		ISNULL(SUM(CASE WHEN P = '2115' THEN -Amt END), 0) AS TaxPayable,
		ISNULL(SUM(CASE WHEN P = '2119' THEN -Amt END), 0) AS CustomerAdvance,
		ISNULL(SUM(CASE WHEN P = '2120' THEN -Amt END), 0) AS Deposit
	FROM Bal;
END
GO
