USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Revisi 13 Agustus 2026: laporkan nota yang gagal dan jangan commit hasil separuh jalan.

IF OBJECT_ID('[dbo].[USP_MC_GenerateJournalCOGSValas]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_GenerateJournalCOGSValas]
GO

/* 
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202603','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202604','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202605','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202606','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202607','it_febry'
*/


CREATE PROCEDURE [dbo].[USP_MC_GenerateJournalCOGSValas] 
	@IDX_M_Company				BIGINT,
	@COGSPeriod					VARCHAR(6),
	@UserID						VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail AS INT
			DECLARE @_CountLog AS INT

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			--PRINT 'Before Validation'

			

			-- ==================================================================
			-- Check pending purchase order and pending sales order
			-- ==================================================================
			--IF EXISTS(	SELECT IDX_T_InventoryCalculation 
			--			FROM MC_T_InventoryCalculation 
			--			WHERE CalculationPeriod = @CalculationPeriod
			--)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',1,'Transaksi sudah ada!')
			--END	

			IF NOT EXISTS(SELECT 1 FROM MC_T_COGSValasCalculation WHERE COGSPeriod = @COGSPeriod)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',1,'Belum ada perhitungan COGS!')
			END

			
			-- ===================================================================
			-- Check Error Log
			-- ===================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				--SELECT * 
				--FROM GL_T_JournalHeader
				--WHERE IDX_M_JournalType = 5 AND PostingStatus = 'P' AND 
				--YEAR(JournalDate) = LEFT(@COGSPeriod, 4) AND MONTH(JournalDate) = RIGHT(@COGSPeriod, 2)		

				DECLARE @_IDX_T_SalesOrder			BIGINT
				DECLARE @_SONumber					VARCHAR(50)
				DECLARE @_CountJournal				INT = 0
				DECLARE @_CountSkip					INT = 0
				DECLARE @_IDX_M_JournalType			INT = 8 -- JOURNAL PERHITUNGAN HPP

				DECLARE crs CURSOR FOR
				SELECT IDX_T_SalesOrder, RTRIM(ISNULL(SONumber,''))
				FROM MC_T_SalesOrder
				WHERE SOStatus = 'A' AND YEAR(SODate) = LEFT(@COGSPeriod, 4) AND MONTH(SODate) = RIGHT(@COGSPeriod, 2)	
					

				OPEN crs
				FETCH NEXT FROM crs INTO @_IDX_T_SalesOrder, @_SONumber

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- ========================================================
					-- GENERATE JOURNAL
					-- ========================================================
					DECLARE @_JournalResult		SMALLINT

					EXEC [USP_MC_COGSValasJournal_Create] @_IDX_T_SalesOrder, @COGSPeriod, @UserID, @_JournalResult OUTPUT

					IF @_JournalResult <> 1
					BEGIN
						-- Sebutkan notanya supaya user tahu mana yang harus diperiksa
						INSERT INTO @TableLog VALUES ('error', @_IDX_T_SalesOrder,
							'Gagal membuat jurnal HPP untuk nota ' + @_SONumber
							+ ' (IDX ' + CONVERT(VARCHAR, @_IDX_T_SalesOrder) + '). '
							+ 'Cek apakah valas pada nota ini punya baris perhitungan HPP periode ' + @COGSPeriod + '.')
					END
					ELSE
					BEGIN
						-- Nota tanpa penjualan valas tidak menghasilkan jurnal dan itu wajar,
						-- jadi dihitung terpisah supaya angka di pesan tetap jujur.
						IF EXISTS (SELECT 1 FROM GL_T_JournalHeader
									WHERE IDX_M_JournalType = @_IDX_M_JournalType
										AND IDX_ReferenceNo = @_IDX_T_SalesOrder
										AND RTRIM(ReferenceNo) = @_SONumber)
							SET @_CountJournal = @_CountJournal + 1
						ELSE
							SET @_CountSkip = @_CountSkip + 1
					END

					FETCH NEXT FROM crs INTO @_IDX_T_SalesOrder, @_SONumber
				END

				CLOSE crs
				DEALLOCATE crs


				-- ====================================================================================
				-- OUTPUT
				-- Baris 'success' hanya ditulis kalau tidak ada nota yang gagal, supaya
				-- pemanggil tidak menerima 'success' dan 'error' sekaligus.
				-- ====================================================================================
				IF NOT EXISTS (SELECT 1 FROM @TableLog WHERE Result = 'error')
				BEGIN
					INSERT INTO @TableLog VALUES ('success', 1,
						'Jurnal HPP periode ' + @COGSPeriod + ' selesai dibuat untuk '
						+ CONVERT(VARCHAR, @_CountJournal) + ' nota penjualan.'
						+ CASE WHEN @_CountSkip > 0
							THEN ' ' + CONVERT(VARCHAR, @_CountSkip) + ' nota dilewati karena tidak ada penjualan valas.'
							ELSE '' END)
				END

			END		

		-- ============================================================================
		-- Kalau ada satu saja nota yang gagal, seluruh proses dibatalkan supaya tidak
		-- tertinggal jurnal HPP separuh jalan. Perbaiki penyebabnya lalu jalankan
		-- ulang; @TableLog tetap terbaca karena table variable tidak ikut rollback.
		-- ============================================================================
		IF @@TRANCOUNT > 0
		BEGIN
			IF EXISTS (SELECT 1 FROM @TableLog WHERE Result = 'error')
				ROLLBACK TRANSACTION;
			ELSE
				COMMIT TRANSACTION;
		END

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH				

		-- Cursor bisa tertinggal terbuka kalau error terjadi di tengah loop
		IF CURSOR_STATUS('global','crs') > -3
		BEGIN
			IF CURSOR_STATUS('global','crs') > -1
				CLOSE crs
			DEALLOCATE crs
		END

		INSERT INTO @TableLog VALUES ('error', 1, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog

		--SELECT 	ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
			
		-- Test XACT_STATE for 1 or -1.
		-- XACT_STATE = 0 means there is no transaction and
		-- a commit or rollback operation would generate an error.

		-- Test whether the transaction is uncommittable.
		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. ' +	'Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		-- Error di tengah proses tidak boleh menyisakan jurnal separuh jalan,
		-- jadi transaksi dibatalkan, bukan di-commit seperti sebelumnya.
		IF (XACT_STATE()) = 1
		BEGIN
			ROLLBACK TRANSACTION;
		END;

	END CATCH;
END
GO
