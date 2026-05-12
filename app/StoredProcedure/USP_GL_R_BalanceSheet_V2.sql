SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 2026
-- Description:	Balance Sheet (versi standar accounting) — COA level output.
--
-- Perbedaan dengan USP_GL_R_BalanceSheet:
--   1. Output per IDX_M_COA (bukan agregat per COAGroup1).
--   2. Sign LI/EQ diflip secara konsisten (× -1) supaya display positif.
--   3. Laba Tahun Berjalan dihitung DENGAN MEMANGGIL USP_GL_R_ProfitLoss
--      langsung (bukan menebak dari IC/EX di trial balance), supaya
--      angka konsisten dengan laporan P&L dan neraca selalu balanced.
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
	-- SIGN NORMALIZATION (LI/EQ → positif untuk display)
	-- ============================================================
	UPDATE #TB SET BEBalanceAmount = BEBalanceAmount * -1
	WHERE AccountType IN ('LI','EQ')

	-- ============================================================
	-- CURRENT EARNING (Laba Tahun Berjalan)
	--   Dihitung dengan memanggil USP_GL_R_ProfitLoss agar konsisten
	--   dengan logika P&L (BB carry-forward, reset Januari, dst).
	--   Net Income = SUM(IC × -1) - SUM(EX) dari output P&L.
	-- ============================================================
	DECLARE @_Period		VARCHAR(6) = CONVERT(VARCHAR(6), @EndDate, 112)
	DECLARE @_PL_Project	BIGINT     = 0   -- ALL project

	-- Schema mengikuti #PL di USP_GL_R_ProfitLoss
	CREATE TABLE #PL (
		Period							CHAR(6),
		IDX_M_Company					BIGINT,
		IDX_M_Branch					BIGINT,
		IDX_M_Project					BIGINT,
		IDX_M_COA						BIGINT,
		CompanyID						VARCHAR(50),
		CompanyDesc						VARCHAR(100),
		BranchID						VARCHAR(50),
		BranchDesc						VARCHAR(100),
		ProjectID						VARCHAR(50),
		ProjectName						VARCHAR(100),
		COA								VARCHAR(250),
		COADesc							VARCHAR(250),
		AccountType						CHAR(2),
		AccountTypeDesc					VARCHAR(100),
		COAGroupID						VARCHAR(50),
		COAGroupDesc					VARCHAR(100),
		BBBalanceAmount					DECIMAL(22,2),
		BDebetAmount					DECIMAL(22,2),
		BCreditAmount					DECIMAL(22,2),
		BMovementAmount					DECIMAL(22,2),
		BEBalanceAmount					DECIMAL(22,2),
		SEQ								INT
	)

	INSERT INTO #PL
	EXEC [dbo].[USP_GL_R_ProfitLoss] @_Period, @IDX_M_Company, @IDX_M_Branch, @_PL_Project

	DECLARE @_TotalRevenue		DECIMAL(22,2) = 0
	DECLARE @_TotalExpense		DECIMAL(22,2) = 0
	DECLARE @_CurrentEarning	DECIMAL(22,2) = 0

	SELECT @_TotalRevenue = ISNULL(SUM(BEBalanceAmount * -1), 0) FROM #PL WHERE AccountType = 'IC'
	SELECT @_TotalExpense = ISNULL(SUM(BEBalanceAmount),      0) FROM #PL WHERE AccountType = 'EX'
	SET    @_CurrentEarning = @_TotalRevenue - @_TotalExpense

	-- ============================================================
	-- INJECT CURRENT EARNING KE AKUN LABA TAHUN BERJALAN
	--   SET (overwrite), bukan ADD — supaya nilainya tidak double-count
	--   dengan apapun yang sudah ada di akun tersebut dari trial balance.
	-- ============================================================
	DECLARE @_CurrentEarningAccount		INT
	SELECT @_CurrentEarningAccount = CurrentEarningAccount
	FROM GN_M_Company WHERE IDX_M_Company = @IDX_M_Company

	IF @_CurrentEarningAccount IS NOT NULL
	BEGIN
		IF EXISTS (SELECT 1 FROM #TB WHERE IDX_M_COA = @_CurrentEarningAccount)
		BEGIN
			UPDATE #TB
			SET BEBalanceAmount = @_CurrentEarning
			WHERE IDX_M_COA = @_CurrentEarningAccount
		END
		ELSE
		BEGIN
			INSERT INTO #TB (
				IDX_M_Company, IDX_M_Branch, IDX_M_COA,
				CompanyID, CompanyDesc, BranchID, BranchDesc,
				COA, COADesc, AccountType,
				BBBalanceAmount, BDebetAmount, BCreditAmount, BMovementAmount, BEBalanceAmount
			)
			SELECT
				@IDX_M_Company, @IDX_M_Branch, MC.IDX_M_COA,
				'', '', '', '',
				MC.COAID, MC.COADesc, 'EQ',
				0, 0, 0, 0, @_CurrentEarning
			FROM GL_M_COA MC
			WHERE MC.IDX_M_COA = @_CurrentEarningAccount
		END
	END

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
	  AND #TB.BEBalanceAmount <> 0
	ORDER BY
		CASE #TB.AccountType WHEN 'AS' THEN 1 WHEN 'LI' THEN 2 WHEN 'EQ' THEN 3 ELSE 9 END,
		C1.COAGroup1ID,
		#TB.COA

	DROP TABLE #TB
	DROP TABLE #PL
END
GO
