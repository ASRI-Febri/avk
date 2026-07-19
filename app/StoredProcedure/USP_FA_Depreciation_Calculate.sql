SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Hitung penyusutan aset tetap satu periode (YYYYMM) - PSAK 16
			  - SL (Garis Lurus)   : (Harga Perolehan - Residu) / Umur Manfaat Bulan
			  - DB (Saldo Menurun) : Nilai Buku x (2 / Umur Manfaat Bulan), tarif 2x garis lurus
			  - Penyusutan berhenti saat akumulasi = (Perolehan - Residu);
			    periode terakhir menyusutkan sisa (plug) agar tidak ada selisih pembulatan
			  - Fiskal dihitung paralel (dasar = harga perolehan penuh, tanpa residu,
			    umur sesuai kelompok harta UU PPh) - tidak membuat jurnal
			  Hasil disimpan ke FA_T_Depreciation (status C = Calculated) + Detail

/*
	EXEC [dbo].[USP_FA_Depreciation_Calculate] 1,'202607','it_febry'
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_FA_Depreciation_Calculate]
	@IDX_M_Company		INT,
	@DeprPeriod			VARCHAR(6),
	@UserID				VARCHAR(36)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),
				ID			BIGINT,
				LogDesc		VARCHAR(500)
			)

			DECLARE @_CountLog				INT
			DECLARE @_IDX_T_Depreciation	BIGINT
			DECLARE @_PeriodStart			DATE
			DECLARE @_PeriodEnd				DATE
			DECLARE @_LastPeriod			VARCHAR(6)
			DECLARE @_LastStatus			CHAR(1)
			DECLARE @_CountAsset			INT

			-- ==================================================
			-- VALIDASI
			-- ==================================================
			IF LEN(RTRIM(ISNULL(@DeprPeriod,''))) <> 6 OR ISNUMERIC(@DeprPeriod) = 0
				OR CONVERT(INT, RIGHT(@DeprPeriod,2)) NOT BETWEEN 1 AND 12
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Periode tidak valid! Gunakan format YYYYMM.')
			END
			ELSE
			BEGIN
				SET @_PeriodStart = CONVERT(DATE, @DeprPeriod + '01', 112)
				SET @_PeriodEnd = EOMONTH(@_PeriodStart)
			END

			IF EXISTS (
				SELECT 1 FROM FA_T_Depreciation
				WHERE IDX_M_Company = @IDX_M_Company AND DeprPeriod = @DeprPeriod AND RecordStatus = 'A'
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Penyusutan periode ' + @DeprPeriod + ' sudah pernah dihitung! Batalkan dulu bila ingin hitung ulang.')
			END

			-- Periode harus urut: run terakhir harus lebih kecil dan sudah diposting
			SELECT TOP 1 @_LastPeriod = DeprPeriod, @_LastStatus = DeprStatus
			FROM FA_T_Depreciation
			WHERE IDX_M_Company = @IDX_M_Company AND RecordStatus = 'A'
			ORDER BY DeprPeriod DESC

			IF @_LastPeriod IS NOT NULL
			BEGIN
				IF @_LastPeriod >= @DeprPeriod
				BEGIN
					INSERT INTO @TableLog VALUES ('error', 0, 'Periode ' + @DeprPeriod + ' tidak boleh mundur! Periode terakhir: ' + @_LastPeriod + '.')
				END

				IF @_LastStatus <> 'P'
				BEGIN
					INSERT INTO @TableLog VALUES ('error', 0, 'Periode ' + @_LastPeriod + ' belum digenerate jurnalnya! Generate atau batalkan dulu.')
				END
			END

			-- ==================================================
			-- HITUNG PENYUSUTAN PER ASET
			-- ==================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN

				;WITH PriorDepr AS (
					-- Akumulasi penyusutan periode-periode sebelumnya (komersial & fiskal)
					SELECT DD.IDX_M_Asset,
						PriorCommercial = SUM(ISNULL(DD.DeprAmount,0)),
						PriorFiscal = SUM(ISNULL(DD.FiscalDeprAmount,0))
					FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
						INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
					WHERE D.IDX_M_Company = @IDX_M_Company
						AND D.RecordStatus = 'A'
						AND DD.RecordStatus = 'A'
					GROUP BY DD.IDX_M_Asset
				),
				Base AS (
					SELECT
						A.IDX_M_Asset,
						Cost = ISNULL(A.AcquisitionCost,0),
						Residual = ISNULL(A.ResidualValue,0),
						LifeMonth = A.UsefulLifeMonth,
						A.DeprMethod,
						-- Akumulasi komersial = saldo awal migrasi + penyusutan tercatat
						PriorAccum = ISNULL(A.OpeningAccumDepr,0) + ISNULL(PD.PriorCommercial,0),
						PriorFiscal = ISNULL(PD.PriorFiscal,0),
						-- Umur fiskal sesuai kelompok harta (bulan)
						FiscalLifeMonth = CASE A.FiscalGroup
											WHEN '1' THEN 48
											WHEN '2' THEN 96
											WHEN '3' THEN 192
											WHEN '4' THEN 240
											WHEN 'BP' THEN 240
											WHEN 'BN' THEN 120
											ELSE 0 END,
						FiscalMethod = ISNULL(A.FiscalDeprMethod,'SL'),
						-- Bulan berjalan sejak mulai pakai (periode mulai pakai = bulan ke-1)
						ElapsedMonth = DATEDIFF(MONTH, A.UsageStartDate, @_PeriodStart) + 1
					FROM FA_M_Asset A WITH(NOLOCK)
						LEFT JOIN PriorDepr PD ON A.IDX_M_Asset = PD.IDX_M_Asset
					WHERE A.IDX_M_Company = @IDX_M_Company
						AND A.RecordStatus = 'A'
						AND A.AssetStatus = 'A'
						AND A.UsageStartDate <= @_PeriodEnd
				),
				Calc AS (
					SELECT
						B.IDX_M_Asset,
						B.Cost,
						B.PriorAccum,
						B.PriorFiscal,
						-- ================= KOMERSIAL =================
						DeprAmount = CASE
							-- Sudah habis disusutkan
							WHEN (B.Cost - B.Residual) - B.PriorAccum <= 0 THEN 0
							-- Umur manfaat sudah habis: plug sisa nilai buku
							WHEN B.ElapsedMonth >= B.LifeMonth THEN (B.Cost - B.Residual) - B.PriorAccum
							-- Garis lurus, dibatasi sisa dasar penyusutan
							WHEN B.DeprMethod = 'SL' THEN
								CASE WHEN ROUND((B.Cost - B.Residual) / B.LifeMonth, 2) > (B.Cost - B.Residual) - B.PriorAccum
									THEN (B.Cost - B.Residual) - B.PriorAccum
									ELSE ROUND((B.Cost - B.Residual) / B.LifeMonth, 2) END
							-- Saldo menurun: nilai buku x tarif bulanan (2x garis lurus)
							WHEN B.DeprMethod = 'DB' THEN
								CASE WHEN ROUND((B.Cost - B.PriorAccum) * (2.0 / B.LifeMonth), 2) > (B.Cost - B.Residual) - B.PriorAccum
									THEN (B.Cost - B.Residual) - B.PriorAccum
									ELSE ROUND((B.Cost - B.PriorAccum) * (2.0 / B.LifeMonth), 2) END
							ELSE 0 END,
						-- ================= FISKAL =================
						FiscalDeprAmount = CASE
							WHEN B.FiscalLifeMonth = 0 THEN 0
							WHEN B.Cost - B.PriorFiscal <= 0 THEN 0
							WHEN B.ElapsedMonth >= B.FiscalLifeMonth THEN B.Cost - B.PriorFiscal
							WHEN B.FiscalMethod = 'DB' THEN
								CASE WHEN ROUND((B.Cost - B.PriorFiscal) * (2.0 / B.FiscalLifeMonth), 2) > B.Cost - B.PriorFiscal
									THEN B.Cost - B.PriorFiscal
									ELSE ROUND((B.Cost - B.PriorFiscal) * (2.0 / B.FiscalLifeMonth), 2) END
							ELSE
								CASE WHEN ROUND(B.Cost / B.FiscalLifeMonth, 2) > B.Cost - B.PriorFiscal
									THEN B.Cost - B.PriorFiscal
									ELSE ROUND(B.Cost / B.FiscalLifeMonth, 2) END
							END
					FROM Base B
				)
				SELECT *
				INTO #CalcResult
				FROM Calc
				WHERE DeprAmount > 0 OR FiscalDeprAmount > 0

				SELECT @_CountAsset = COUNT(*) FROM #CalcResult

				IF @_CountAsset = 0
				BEGIN
					INSERT INTO @TableLog VALUES ('error', 0, 'Tidak ada aset aktif yang perlu disusutkan pada periode ' + @DeprPeriod + '!')
				END
				ELSE
				BEGIN

					-- ==================================================
					-- SIMPAN HEADER + DETAIL
					-- ==================================================
					INSERT INTO [dbo].[FA_T_Depreciation]
						([IDX_M_Company],[DeprPeriod],[IDX_T_JournalHeader],[DeprStatus]
						,[RecordStatus],[UCreate],[DCreate])
					VALUES
						(@IDX_M_Company, @DeprPeriod, NULL, 'C', 'A', @UserID, GETDATE())

					SET @_IDX_T_Depreciation = SCOPE_IDENTITY()

					INSERT INTO [dbo].[FA_T_DepreciationDetail]
						([IDX_T_Depreciation],[IDX_M_Asset],[DeprAmount],[FiscalDeprAmount]
						,[AccumDeprAfter],[BookValueAfter],[RecordStatus],[UCreate],[DCreate])
					SELECT
						@_IDX_T_Depreciation,
						CR.IDX_M_Asset,
						CR.DeprAmount,
						CR.FiscalDeprAmount,
						CR.PriorAccum + CR.DeprAmount,
						CR.Cost - (CR.PriorAccum + CR.DeprAmount),
						'A',
						@UserID,
						GETDATE()
					FROM #CalcResult CR

					INSERT INTO @TableLog VALUES ('success', @_IDX_T_Depreciation,
						'Penyusutan periode ' + @DeprPeriod + ' berhasil dihitung untuk '
						+ CONVERT(VARCHAR, @_CountAsset) + ' aset.')
				END

				DROP TABLE #CalcResult

			END

			SELECT * FROM @TableLog

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())

		SELECT * FROM @TableLog

		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. Committing transaction.'
			COMMIT TRANSACTION;
		END;

	END CATCH;

END
GO
