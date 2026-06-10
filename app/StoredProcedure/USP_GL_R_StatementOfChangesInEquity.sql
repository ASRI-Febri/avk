SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================================
-- Description  : Laporan Perubahan Ekuitas / Statement of Changes in Equity.
--
--   METODE
--   ------
--   Laporan disusun dengan "movement approach" dari Trial Balance, sehingga selalu
--   konsisten dengan Neraca (USP_GL_R_BalanceSheet_V2) yang juga berbasis Trial Balance.
--
--   Untuk periode (YYYYMM) yang dipilih:
--       StartDate = tanggal 1 bulan tsb,  EndDate = akhir bulan tsb.
--
--   Per akun ekuitas (AccountType = 'EQ'):
--       Saldo Awal   = BBBalanceAmount * -1   (flip sign agar positif untuk display)
--       Penambahan   = BCreditAmount          (kredit menambah ekuitas)
--       Pengurangan  = BDebetAmount           (debet mengurangi ekuitas)
--       Saldo Akhir  = BEBalanceAmount * -1   (= Saldo Awal + Penambahan - Pengurangan)
--
--   Laba/(Rugi) Bersih Periode Berjalan dihitung dari pergerakan akun laba-rugi
--   (AccountType IC & EX) pada Trial Balance yang sama:
--       Net Income = -SUM(BMovementAmount) untuk seluruh akun IC + EX
--                  = (Pendapatan - Beban) periode berjalan
--
--   REKONSILIASI (selalu balance):
--       Total Saldo Akhir Ekuitas = Total Saldo Awal Ekuitas
--                                 + (Penambahan - Pengurangan seluruh akun ekuitas)
--                                 + Laba/(Rugi) Bersih Periode Berjalan
--
--   CATATAN
--   -------
--   - Baris "Laba/(Rugi) Bersih Periode Berjalan" mengasumsikan laba berjalan BELUM
--     dijurnal-tutup ke akun ekuitas pada periode tsb (model derived earning, sama
--     seperti USP_GL_R_BalanceSheet_V2). Bila perusahaan melakukan jurnal penutup ke
--     akun ekuitas, pergerakan itu sudah tampil pada akun ekuitas terkait dan baris
--     Laba Bersih berpotensi double-count — sesuaikan bila proses closing berubah.
--   - Level company/branch (mengikuti USP_GL_R_TrialBalance yang tidak memfilter project).
-- ==========================================================================================
-- EXEC [dbo].[USP_GL_R_StatementOfChangesInEquity] '202604', 1, 1
-- EXEC [dbo].[USP_GL_R_StatementOfChangesInEquity] '202605', 1, 1
-- ==========================================================================================

-- Catatan: gunakan CREATE OR ALTER karena procedure ini baru (belum ada di database).
CREATE OR ALTER PROCEDURE [dbo].[USP_GL_R_StatementOfChangesInEquity]
	@Period				VARCHAR(6),
	@IDX_M_Company		INT,
	@IDX_M_Branch		INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_Year		CHAR(4) = LEFT(@Period,4)
	DECLARE @_Month		CHAR(2) = RIGHT(@Period,2)
	DECLARE @_StartDate	DATE    = @_Year + '-' + @_Month + '-01'
	DECLARE @_EndDate	DATE    = EOMONTH(@_StartDate)

	-- ======================================================================================
	-- 1. Trial Balance load (schema mengikuti #TB di USP_GL_R_BalanceSheet_V2)
	-- ======================================================================================
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
	EXEC [dbo].[USP_GL_R_TrialBalance] @IDX_M_Company, @IDX_M_Branch, @_StartDate, @_EndDate

	-- ======================================================================================
	-- 2. Laba/(Rugi) Bersih Periode Berjalan (movement akun laba-rugi)
	-- ======================================================================================
	DECLARE @_NetIncome	DECIMAL(22,2) = 0

	SELECT @_NetIncome = ISNULL(SUM(BMovementAmount * -1), 0)
	FROM #TB
	WHERE AccountType IN ('IC','EX')

	-- ======================================================================================
	-- 3. Output : baris akun ekuitas + baris Laba Bersih Periode Berjalan
	-- ======================================================================================
	;WITH Result AS (
		SELECT
			GroupSEQ		= 1,
			RowType			= 'EQUITY',
			COA				= COA,
			COADesc			= COADesc,
			BeginBalance	= BBBalanceAmount * -1,
			Additions		= BCreditAmount,
			Reductions		= BDebetAmount,
			EndBalance		= BEBalanceAmount * -1
		FROM #TB
		WHERE AccountType = 'EQ'
			AND (BBBalanceAmount <> 0 OR BDebetAmount <> 0 OR BCreditAmount <> 0 OR BEBalanceAmount <> 0)

		UNION ALL

		SELECT
			GroupSEQ		= 2,
			RowType			= 'NETINCOME',
			COA				= '',
			COADesc			= 'Laba/(Rugi) Bersih Periode Berjalan',
			BeginBalance	= 0,
			Additions		= @_NetIncome,
			Reductions		= 0,
			EndBalance		= @_NetIncome
	)
	SELECT * FROM Result
	ORDER BY GroupSEQ, COA

	DROP TABLE #TB
END
GO
