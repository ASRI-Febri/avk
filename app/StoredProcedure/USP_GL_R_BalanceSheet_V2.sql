-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026
-- Description:	Balance Sheet (versi standar accounting) — COA level output.
--
-- Perbedaan dengan USP_GL_R_BalanceSheet:
--   1. Output per IDX_M_COA (bukan agregat per COAGroup1) sehingga view bisa
--      menampilkan struktur grouping berlapis dan/atau drill-down.
--   2. Sign LI/EQ diflip secara konsisten supaya nilai display selalu positif.
--
-- Catatan penting:
--   Saldo akun Current Earning (Laba Tahun Berjalan) DI-AMBIL APA ADANYA dari
--   trial balance — USP_GL_R_TrialBalance di sistem ini sudah mengisi akun
--   tersebut dengan nilai laba periode. Jangan menghitung ulang dari SUM(IC)
--   dan SUM(EX) di sini karena bisa berbeda dengan logika TB dan menyebabkan
--   neraca tidak balanced.
-- =============================================
-- EXEC [dbo].[USP_GL_R_BalanceSheet_V2] 1, 1, '2026-04-01', '2026-04-30'

ALTER PROCEDURE [dbo].[USP_GL_R_BalanceSheet_V2]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN
	SET NOCOUNT ON;

	-- ============================================================
	-- TRIAL BALANCE LOAD
	-- ============================================================
	CREATE TABLE #TB
	(
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_COA						BIGINT,
		---------------------------------------------------------------------
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(50),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(50),
		COA								VARCHAR(250),
		COADesc							VARCHAR(250),
		AccountType						CHAR(2),
		---------------------------------------------------------------------
		BBBalanceAmount					DECIMAL(22,2),
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2),
		BMovementAmount					DECIMAL(22,2),
		BEBalanceAmount					DECIMAL(22,2)
	)

	INSERT INTO #TB
	EXEC [dbo].[USP_GL_R_TrialBalance] @IDX_M_Company, @IDX_M_Branch, @StartDate, @EndDate

	-- ============================================================
	-- INJEKSI LABA PERIODE BERJALAN KE AKUN LABA TAHUN BERJALAN
	--
	-- FIX 19 Jul 2026 (Samuel Febrianto):
	-- USP_GL_R_TrialBalance versi perbaikan 19 Jul 2026 tidak lagi menaruh
	-- mutasi sintetis (pendapatan/beban periode) pada akun Laba Tahun Berjalan
	-- — di Trial Balance mutasi tsb sudah terwakili baris akun IC/EX sendiri.
	-- Karena Balance Sheet hanya menampilkan akun AS/LI/EQ, laba periode
	-- berjalan harus ditambahkan di sini agar neraca tetap balanced.
	-- CATATAN: SP ini mensyaratkan USP_GL_R_TrialBalance versi >= 19 Jul 2026;
	-- dengan TB versi lama laba periode akan terhitung dua kali.
	-- ============================================================
	DECLARE @_CurrentEarningAccount	INT
	DECLARE @_PeriodPL				DECIMAL(22,2)

	SELECT @_CurrentEarningAccount = CurrentEarningAccount
	FROM GN_M_Company
	WHERE IDX_M_Company = @IDX_M_Company

	-- Laba periode berjalan = net kredit akun pendapatan & beban pada mutasi periode
	SELECT @_PeriodPL = ISNULL(SUM(BCreditAmount - BDebetAmount), 0)
	FROM #TB
	WHERE AccountType IN ('IC','EX')

	UPDATE #TB SET
		 BCreditAmount = BCreditAmount + @_PeriodPL
		,BEBalanceAmount = BBBalanceAmount + BDebetAmount - (BCreditAmount + @_PeriodPL)
	WHERE IDX_M_COA = @_CurrentEarningAccount

	-- ============================================================
	-- SIGN NORMALIZATION (LI/EQ → positif untuk display)
	--
	-- Sign-flip dilakukan KONSISTEN untuk semua baris LI/EQ (termasuk akun
	-- Current Earning), berbeda dari SP lama yang hanya flip kalau saldo < 0.
	-- Catatan: USP_GL_R_TrialBalance sudah memposisikan saldo Current Earning
	-- dengan benar, jadi kita tidak menghitung ulang Revenue - Expense di sini.
	-- ============================================================
	UPDATE #TB SET BEBalanceAmount = BEBalanceAmount * -1
	WHERE AccountType IN ('LI','EQ')

	-- ============================================================
	-- OUTPUT: COA-level rows untuk AS/LI/EQ, lengkap dengan grouping
	-- ============================================================
	SELECT
		#TB.IDX_M_COA,
		#TB.COA,
		#TB.COADesc,
		#TB.AccountType,
		C1.COAGroup1ID,
		C1.COAGroup1Name1,
		#TB.BBBalanceAmount,
		#TB.BDebetAmount,
		#TB.BCreditAmount,
		#TB.BEBalanceAmount AS Amount
	FROM #TB
	LEFT JOIN GL_M_COA       C  ON C.IDX_M_COA       = #TB.IDX_M_COA
	LEFT JOIN GL_M_COAGroup1 C1 ON C1.IDX_M_COAGroup1 = C.COAGroup1
	WHERE #TB.AccountType IN ('AS','LI','EQ')
	  -- FIX 19 Jul 2026 (Samuel Febrianto): baris juga ditampilkan bila saldo
	  -- akhir M-1 (BBBalanceAmount) atau mutasi bulan berjalan tidak nol,
	  -- supaya kolom saldo M-1 di laporan tetap lengkap dan balanced walaupun
	  -- saldo akhir periode akun tersebut sudah menjadi 0.
	  AND (#TB.BEBalanceAmount <> 0 OR #TB.BBBalanceAmount <> 0
		OR #TB.BDebetAmount <> 0 OR #TB.BCreditAmount <> 0)
	ORDER BY
		CASE #TB.AccountType WHEN 'AS' THEN 1 WHEN 'LI' THEN 2 WHEN 'EQ' THEN 3 ELSE 9 END,
		C1.COAGroup1ID,
		#TB.COA

	DROP TABLE #TB
END
