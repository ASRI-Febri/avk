
/****** Object:  StoredProcedure [dbo].[USP_MC_GenerateJournalCOGSValas]    Script Date: 6/4/2026 12:55:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202603','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202604','it_febry'
	EXEC [dbo].[USP_MC_GenerateJournalCOGSValas] 1,'202605','it_febry'
*/


ALTER PROCEDURE [dbo].[USP_MC_GenerateJournalCOGSValas] 
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

				DECLARE crs CURSOR FOR
				SELECT IDX_T_SalesOrder 
				FROM MC_T_SalesOrder
				WHERE SOStatus = 'A' AND YEAR(SODate) = LEFT(@COGSPeriod, 4) AND MONTH(SODate) = RIGHT(@COGSPeriod, 2)	
					

				OPEN crs
				FETCH NEXT FROM crs INTO @_IDX_T_SalesOrder

				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT CONVERT(VARCHAR, @_IDX_T_SalesOrder)

					-- ========================================================
					-- GENERATE JOURNAL
					-- ========================================================
					DECLARE @_JournalResult		SMALLINT

					EXEC [USP_MC_COGSValasJournal_Create] @_IDX_T_SalesOrder, @COGSPeriod, @UserID, @_JournalResult OUTPUT

					IF @_JournalResult <> 1
					BEGIN
						INSERT INTO @TableLog VALUES ('error', 1, 'Create journal failed!')
					END

					FETCH NEXT FROM crs INTO @_IDX_T_SalesOrder
				END

				CLOSE crs
				DEALLOCATE crs


				-- ====================================================================================
				-- OUTPUT		
				-- ====================================================================================		
				INSERT INTO @TableLog VALUES ('success', 1, 'Data Sudah Disimpan')

			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

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

		-- Test whether the transaction is active and valid.
		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. ' + 'Committing transaction.'
			COMMIT TRANSACTION;   
		END;

	END CATCH;
END





