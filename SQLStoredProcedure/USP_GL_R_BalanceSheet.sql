SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 16 Jan 2026
-- Description:	Report balance sheet based on trial balance
-- =============================================

-- EXEC [dbo].[USP_GL_R_BalanceSheet] 1, 1, '2025-12-01', '2025-12-31'

-- EXEC [dbo].[USP_GL_R_BalanceSheet] 1, 1, '2026-01-01', '2026-03-31'
-- EXEC [dbo].[USP_GL_R_BalanceSheet] 1, 1, '2026-02-01', '2026-02-28'
-- EXEC [dbo].[USP_GL_R_BalanceSheet] 1, 1, '2026-03-01', '2026-03-31'

ALTER PROCEDURE [dbo].[USP_GL_R_BalanceSheet]
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT,
	@StartDate			DATE,
	@EndDate			DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- ============================================================================================
	-- Table Trial Balance
	-- ============================================================================================
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

	DECLARE @_RetainedEarningAccount		INT
	DECLARE @_CurrentEarningAccount			INT
	DECLARE @_CurrentEarningAmount			DECIMAL(22,2)
	DECLARE @_RetainedEarningAmount			DECIMAL(22,2)

	SELECT @_RetainedEarningAccount = RetainedEarningAccount, @_CurrentEarningAccount = CurrentEarningAccount
	FROM GN_M_Company 
	WHERE IDX_M_Company = @IDX_M_Company

	-- INSERT TRIAL BALANCE
	INSERT INTO #TB
	EXEC [dbo].[USP_GL_R_TrialBalance] @IDX_M_Company, @IDX_M_Branch, @StartDate, @EndDate

	UPDATE #TB SET BEBalanceAmount = (BEBalanceAmount * -1)
	WHERE AccountType IN ('LI','EQ') AND BEBalanceAmount < 0 

	UPDATE #TB SET BEBalanceAmount = (BEBalanceAmount * -1)
	WHERE IDX_M_COA = @_RetainedEarningAccount AND BEBalanceAmount > 0
		

	-- =====================================================================================================
	-- PROFIT & LOSS CALCULATION FOR CURRENT PERIOD / CURRENT EARNING
	-- =====================================================================================================
	
	DECLARE @_TotalRevenue					DECIMAL(22,2)
	DECLARE @_TotalExpense					DECIMAL(22,2)

	SELECT @_TotalRevenue = ABS(SUM(BEBalanceAmount)) FROM #TB WHERE AccountType = 'IC'
	SELECT @_TotalExpense = ABS(SUM(BEBalanceAmount)) FROM #TB WHERE AccountType = 'EX'

	PRINT CONVERT(VARCHAR, @_TotalRevenue)
	PRINT CONVERT(VARCHAR, @_TotalExpense)

	-- SET @_CurrentEarningAmount = (@_TotalRevenue - @_TotalExpense)

	-- UPDATE #TB SET BEBalanceAmount = @_CurrentEarningAmount
	-- WHERE IDX_M_COA = @_CurrentEarningAccount
	-- ====================================================================================================	

	-- ====================================================================================================
	-- OUTPUT REPORT
	-- ====================================================================================================
	SELECT #TB.AccountType, C1.COAGroup1ID, C1.COAGroup1Name1, 
		SUM(#TB.BBBalanceAmount) AS BBBalanceAmount,
		SUM(#TB.BDebetAmount) AS BDebetAmount,			
		SUM(#TB.BCreditAmount) AS BCreditAmount,
		SUM(#TB.BEBalanceAmount) AS Amount 
	FROM #TB
	LEFT JOIN GL_M_COA C ON C.IDX_M_COA = #TB.IDX_M_COA
	LEFT JOIN GL_M_COAGroup1 C1 ON C1.IDX_M_COAGroup1 = C.COAGroup1
	WHERE #TB.AccountType NOT IN ('IC','EX')
	GROUP BY #TB.AccountType, C1.COAGroup1ID, C1.COAGroup1Name1

	-- DROP TEMP TABLE
	DROP TABLE #TB
END
GO
