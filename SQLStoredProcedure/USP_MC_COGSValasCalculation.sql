SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
	EXEC [dbo].[USP_MC_COGSValasCalculation] 1,'202603','it_febry'
	EXEC [dbo].[USP_MC_COGSValasCalculation] 1,'202604','it_febry'
*/


ALTER PROCEDURE [dbo].[USP_MC_COGSValasCalculation] 
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

			
			-- ===================================================================
			-- Check Error Log
			-- ===================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_PrevPeriod			VARCHAR(6)
				DECLARE @_StartDate				DATE = LEFT(@COGSPeriod, 4) + '-' + RIGHT(@COGSPeriod,2) + '-01'

				SET @_PrevPeriod = LEFT(CONVERT(VARCHAR,DATEADD(M,-1, @_StartDate),112),6) 

				--PRINT @_PrevPeriod

				IF EXISTS(SELECT 1 FROM MC_T_COGSValasCalculation WHERE COGSPeriod = @COGSPeriod)
				BEGIN
					DELETE MC_T_COGSValasCalculation
					WHERE COGSPeriod = @COGSPeriod
				END

				-- ========================================================================================================================
				-- INSERT CURRENCY FOR CURRENT PERIOD
				-- ========================================================================================================================
				INSERT INTO [dbo].[MC_T_COGSValasCalculation]
				    ([IDX_M_Currency]
					,[IDX_M_Valas]
					,[COGSPeriod]
					,[ValasChangeNumber]
					,[BB_ForeignAmount]
					,[BB_Qty]
					,[BB_BaseAmount]
					,[IN_ForeignAmount]
					,[IN_Qty]
					,[IN_BaseAmount]
					,[AverageAmount]
					,[Sold_Qty]
					,[Sold_BaseAmount]
					,[Sold_ForeignAmount]
					,[COGSAmount]
					,[GrossProfitAmount]
					,[EB_ForeignAmount]
					,[EB_Qty]
					,[EB_BaseAmount]					
					,[UCreate]
					,[DCreate]				   
					,[RecordStatus])
				SELECT MV.IDX_M_Currency, MV.IDX_M_Valas, @COGSPeriod, MVC.ValasChangeNumber, 
					0, 0, 0, 
					0, 0, 0, 
					0, 
					0, 0, 0, 
					0, 0, 
					0, 0, 0, 
					@UserID, GETDATE(), 'A'
				FROM MC_M_Valas MV 
				LEFT JOIN MC_M_Currency MC ON MC.IDX_M_Currency = MV.IDX_M_Currency
				LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
				
				-- UPDATE SALDO AWAL DARI PURCHASE ORDER
				--UPDATE MC_T_COGSValasCalculation SET 
				--	BB_ForeignAmount = ISNULL(BB.ForeignAmount, 0), 
				--	BB_BaseAmount = ISNULL(BB.BaseCurrencyAmount, 0) 
				--FROM (
				--	SELECT 
				--		C.IDX_M_Currency, V.IDX_M_Valas,
				--		SUM(SD.ForeignAmount) AS ForeignAmount, 
				--		SUM(SD.BaseCurrencyAmount) AS BaseCurrencyAmount,					
				--		SUM(SD.BaseCurrencyAmount) / (SUM(SD.ForeignAmount)) AS AverageAmount
				--	FROM MC_T_PurchaseOrder S
				--	LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
				--	LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
				--	LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
				--	LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
				--	WHERE YEAR(PODate) = LEFT(@_PrevPeriod, 4) AND MONTH(PODate) = RIGHT(@_PrevPeriod,2) AND S.POStatus = 'A'
				--		AND SD.ForeignAmount > 0
				--		AND SD.BaseCurrencyAmount > 0
				--	GROUP BY C.IDX_M_Currency, C.CurrencyID, C.CurrencyName, V.IDX_M_Valas
				--) BB 
				--INNER JOIN MC_T_COGSValasCalculation ON MC_T_COGSValasCalculation.IDX_M_Currency = BB.IDX_M_Currency
				--WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod	
				
				-- ========================================================================================================================
				-- UPDATE SALDO AWAL COGS CALCULATION PERIODE SEBELUMNYA
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET 
					BB_ForeignAmount = ISNULL(BB.EB_ForeignAmount, 0), 
					BB_BaseAmount = ISNULL(BB.EB_BaseAmount, 0),
					BB_Qty = ISNULL(BB.[EB_Qty], 0)
				FROM (
					SELECT 
						 [IDX_M_Currency]
						,[IDX_M_Valas]
						,[COGSPeriod]
						,[ValasChangeNumber]
						,[BB_ForeignAmount]
						,[BB_Qty]
						,[BB_BaseAmount]
						,[IN_ForeignAmount]
						,[IN_Qty]
						,[IN_BaseAmount]
						,[EB_ForeignAmount]
						,[EB_Qty]
						,[EB_BaseAmount]
						,[AverageAmount]
					FROM MC_T_COGSValasCalculation
					WHERE COGSPeriod = @_PrevPeriod
				) BB 
				INNER JOIN MC_T_COGSValasCalculation ON MC_T_COGSValasCalculation.IDX_M_Currency = BB.IDX_M_Currency
					AND MC_T_COGSValasCalculation.IDX_M_Valas = BB.IDX_M_Valas
				WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod							

				-- ========================================================================================================================
				-- UPDATE PURCHASE IN CURRENT PERIOD
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET 
					IN_ForeignAmount = ISNULL(I.ForeignAmount, 0), 
					IN_BaseAmount = ISNULL(I.BaseCurrencyAmount, 0),
					IN_Qty = ISNULL(I.Qty, 0)
				FROM (
					SELECT 
						C.IDX_M_Currency, V.IDX_M_Valas,
						SUM(SD.ForeignAmount) AS ForeignAmount, 
						SUM(SD.BaseCurrencyAmount) AS BaseCurrencyAmount,					
						SUM(SD.BaseCurrencyAmount) / (SUM(SD.ForeignAmount)) AS AverageAmount,
						SUM(SD.Quantity) AS Qty
					FROM MC_T_PurchaseOrder S
					LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
					LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
					WHERE YEAR(PODate) = LEFT(@COGSPeriod, 4) AND MONTH(PODate) = RIGHT(@COGSPeriod,2) AND S.POStatus = 'A'
						AND SD.ForeignAmount > 0
						AND SD.BaseCurrencyAmount > 0
					GROUP BY C.IDX_M_Currency, C.CurrencyID, C.CurrencyName, V.IDX_M_Valas
				) I 
				INNER JOIN MC_T_COGSValasCalculation ON MC_T_COGSValasCalculation.IDX_M_Currency = I.IDX_M_Currency
					AND MC_T_COGSValasCalculation.IDX_M_Valas = I.IDX_M_Valas
				WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod

				
				-- ========================================================================================================================
				-- UPDATE AVERAGE AMOUNT FOR EACH VALAS WITH FORMULA
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET 
					AverageAmount = (BB_BaseAmount + IN_BaseAmount) / (BB_ForeignAmount + IN_ForeignAmount)
				WHERE COGSPeriod = @COGSPeriod AND (BB_ForeignAmount + IN_ForeignAmount <> 0)

				-- ========================================================================================================================
				-- UPDATE SALES IN CURRENT PERIOD
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET 
					Sold_ForeignAmount = ISNULL(I.ForeignAmount, 0), 
					Sold_BaseAmount = ISNULL(I.BaseCurrencyAmount, 0),
					Sold_Qty = ISNULL(I.Qty, 0)
				FROM (
					SELECT 
						C.IDX_M_Currency, V.IDX_M_Valas,
						SUM(SD.ForeignAmount) AS ForeignAmount, 
						SUM(SD.BaseCurrencyAmount) AS BaseCurrencyAmount,											
						SUM(SD.Quantity) AS Qty
					FROM MC_T_SalesOrder S
					LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
					LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
					WHERE YEAR(SODate) = LEFT(@COGSPeriod, 4) AND MONTH(SODate) = RIGHT(@COGSPeriod,2) AND S.SOStatus = 'A'
						AND SD.ForeignAmount > 0
						AND SD.BaseCurrencyAmount > 0
					GROUP BY C.IDX_M_Currency, C.CurrencyID, C.CurrencyName, V.IDX_M_Valas
				) I 
				INNER JOIN MC_T_COGSValasCalculation ON MC_T_COGSValasCalculation.IDX_M_Currency = I.IDX_M_Currency
					AND MC_T_COGSValasCalculation.IDX_M_Valas = I.IDX_M_Valas
				WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod
				
				-- ========================================================================================================================
				-- UPDATE COGS AMOUNT AND GROSS PROFIT AMOUNT
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET
					COGSAmount = (Sold_Qty * AverageAmount * ValasChangeNumber)					
				WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod

				UPDATE MC_T_COGSValasCalculation SET					
					GrossProfitAmount = Sold_BaseAmount - COGSAmount
				WHERE MC_T_COGSValasCalculation.COGSPeriod = @COGSPeriod

				-- ========================================================================================================================
				-- UPDATE ENDING BALANCE FOR CURRENT PERIOD
				-- ========================================================================================================================
				UPDATE MC_T_COGSValasCalculation SET 	
					 EB_Qty = BB_Qty + IN_Qty - Sold_Qty											
				WHERE COGSPeriod = @COGSPeriod

				UPDATE MC_T_COGSValasCalculation SET 	
					 EB_ForeignAmount = (EB_Qty * ValasChangeNumber)
					,EB_BaseAmount = (EB_Qty * AverageAmount * ValasChangeNumber)
				WHERE COGSPeriod = @COGSPeriod

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





