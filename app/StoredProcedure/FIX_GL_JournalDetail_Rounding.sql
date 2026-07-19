/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: PERBAIKAN DATA SATU KALI - pembulatan nilai jurnal ke 2 desimal.

	Latar belakang:
	Jurnal HPP valas (voucher HP-SMC-*) tersimpan dengan 4 desimal di
	GL_T_JournalDetail (mis. 672,014.2857) karena generator jurnal memakai
	SUM(Quantity * AverageAmount * ValasChangeNumber) tanpa ROUND.
	Laporan TB/BS/PL membulatkan per akun ke 2 desimal, sehingga muncul
	selisih beberapa sen (0.01 - 0.03) antara Aset vs Liabilitas + Ekuitas.

	Yang dilakukan script ini:
	1. Bulatkan semua kolom nilai (ODebet/OCredit/BDebet/BCredit) ke 2 desimal
	   pada baris jurnal yang masih menyimpan pecahan > 2 desimal.
	2. Setelah pembulatan per baris, jurnal bisa selisih 1-2 sen antara total
	   debet dan kredit. Selisih tsb di-plug ke baris detail dengan nilai
	   terbesar di jurnal itu (praktik umum: distorsi relatif terkecil).
	3. Verifikasi akhir: tidak boleh ada baris > 2 desimal tersisa dan tidak
	   boleh ada jurnal yang tidak balance.

	PRASYARAT:
	- Jalankan JUGA ALTER USP_MC_COGSValasJournal_Create (ROUND saat insert)
	  agar data 4 desimal tidak muncul lagi di periode berikutnya.
	- Backup GL_T_JournalDetail dianjurkan sebelum eksekusi.

	EKSEKUSI: jalankan seluruh script ini sekali di database AVKDB.
-- ============================================= */

SET NOCOUNT ON;

BEGIN TRY

	BEGIN TRANSACTION;

		-- ==================================================
		-- 0. KONDISI AWAL
		-- ==================================================
		SELECT 'SEBELUM: baris dengan > 2 desimal' AS Info, COUNT(*) AS Jml
		FROM GL_T_JournalDetail
		WHERE (ODebetAmount <> ROUND(ODebetAmount,2)
			OR OCreditAmount <> ROUND(OCreditAmount,2)
			OR BDebetAmount <> ROUND(BDebetAmount,2)
			OR BCreditAmount <> ROUND(BCreditAmount,2))

		-- ==================================================
		-- 1. CATAT JURNAL TERDAMPAK
		-- ==================================================
		SELECT DISTINCT JD.IDX_T_JournalHeader
		INTO #Affected
		FROM GL_T_JournalDetail JD
		WHERE (JD.ODebetAmount <> ROUND(JD.ODebetAmount,2)
			OR JD.OCreditAmount <> ROUND(JD.OCreditAmount,2)
			OR JD.BDebetAmount <> ROUND(JD.BDebetAmount,2)
			OR JD.BCreditAmount <> ROUND(JD.BCreditAmount,2))

		-- ==================================================
		-- 2. BULATKAN SEMUA KOLOM NILAI KE 2 DESIMAL
		-- ==================================================
		UPDATE GL_T_JournalDetail SET
			 ODebetAmount	= ROUND(ODebetAmount,2)
			,OCreditAmount	= ROUND(OCreditAmount,2)
			,BDebetAmount	= ROUND(BDebetAmount,2)
			,BCreditAmount	= ROUND(BCreditAmount,2)
			,UModified		= 'fix_rounding'
			,DModified		= GETDATE()
		WHERE IDX_T_JournalHeader IN (SELECT IDX_T_JournalHeader FROM #Affected)
			AND (ODebetAmount <> ROUND(ODebetAmount,2)
				OR OCreditAmount <> ROUND(OCreditAmount,2)
				OR BDebetAmount <> ROUND(BDebetAmount,2)
				OR BCreditAmount <> ROUND(BCreditAmount,2))

		-- ==================================================
		-- 3. PLUG SELISIH PEMBULATAN PER JURNAL
		--    ke baris detail aktif dengan nilai terbesar
		-- ==================================================
		DECLARE @_IDX_T_JournalHeader	BIGINT
		DECLARE @_Residu				DECIMAL(22,2)
		DECLARE @_IDX_T_JournalDetail	BIGINT
		DECLARE @_IsDebet				BIT

		DECLARE crs CURSOR LOCAL FOR
		SELECT JD.IDX_T_JournalHeader, SUM(JD.BDebetAmount - JD.BCreditAmount) AS Residu
		FROM GL_T_JournalDetail JD
		WHERE JD.IDX_T_JournalHeader IN (SELECT IDX_T_JournalHeader FROM #Affected)
			AND JD.RecordStatus = 'A'
		GROUP BY JD.IDX_T_JournalHeader
		HAVING SUM(JD.BDebetAmount - JD.BCreditAmount) <> 0

		OPEN crs
		FETCH NEXT FROM crs INTO @_IDX_T_JournalHeader, @_Residu

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- baris dengan nilai terbesar pada jurnal ini
			SELECT TOP 1
				@_IDX_T_JournalDetail = IDX_T_JournalDetail,
				@_IsDebet = CASE WHEN BDebetAmount >= BCreditAmount THEN 1 ELSE 0 END
			FROM GL_T_JournalDetail
			WHERE IDX_T_JournalHeader = @_IDX_T_JournalHeader AND RecordStatus = 'A'
			ORDER BY CASE WHEN BDebetAmount >= BCreditAmount THEN BDebetAmount ELSE BCreditAmount END DESC

			IF @_IsDebet = 1
			BEGIN
				-- kurangi sisi debet sebesar residu (residu > 0 berarti debet kelebihan)
				UPDATE GL_T_JournalDetail SET
					 BDebetAmount	= BDebetAmount - @_Residu
					,ODebetAmount	= ODebetAmount - @_Residu
					,UModified		= 'fix_rounding'
					,DModified		= GETDATE()
				WHERE IDX_T_JournalDetail = @_IDX_T_JournalDetail
			END
			ELSE
			BEGIN
				-- tambah sisi kredit sebesar residu
				UPDATE GL_T_JournalDetail SET
					 BCreditAmount	= BCreditAmount + @_Residu
					,OCreditAmount	= OCreditAmount + @_Residu
					,UModified		= 'fix_rounding'
					,DModified		= GETDATE()
				WHERE IDX_T_JournalDetail = @_IDX_T_JournalDetail
			END

			FETCH NEXT FROM crs INTO @_IDX_T_JournalHeader, @_Residu
		END

		CLOSE crs
		DEALLOCATE crs

		-- ==================================================
		-- 4. VERIFIKASI AKHIR
		-- ==================================================
		SELECT 'SESUDAH: baris dengan > 2 desimal (harus 0)' AS Info, COUNT(*) AS Jml
		FROM GL_T_JournalDetail
		WHERE (ODebetAmount <> ROUND(ODebetAmount,2)
			OR OCreditAmount <> ROUND(OCreditAmount,2)
			OR BDebetAmount <> ROUND(BDebetAmount,2)
			OR BCreditAmount <> ROUND(BCreditAmount,2))

		SELECT 'SESUDAH: jurnal terdampak yang tidak balance (harus 0)' AS Info, COUNT(*) AS Jml
		FROM (
			SELECT JD.IDX_T_JournalHeader
			FROM GL_T_JournalDetail JD
			WHERE JD.IDX_T_JournalHeader IN (SELECT IDX_T_JournalHeader FROM #Affected)
				AND JD.RecordStatus = 'A'
			GROUP BY JD.IDX_T_JournalHeader
			HAVING SUM(JD.BDebetAmount - JD.BCreditAmount) <> 0
		) X

		SELECT 'Jurnal yang diperbaiki' AS Info, COUNT(*) AS Jml FROM #Affected

		DROP TABLE #Affected

	COMMIT TRANSACTION;

	PRINT 'Perbaikan pembulatan selesai.'

END TRY

BEGIN CATCH

	IF (XACT_STATE()) <> 0
		ROLLBACK TRANSACTION;

	PRINT 'GAGAL: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE()

END CATCH;
