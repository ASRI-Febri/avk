
/* 
	EXEC [dbo].[USP_MC_COGSCalculation] 1,'202603','it_febry'
*/


CREATE PROCEDURE [dbo].[USP_MC_COGSCalculation] 
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

				IF EXISTS(SELECT 1 FROM MC_T_COGSCalculation WHERE COGSPeriod = @COGSPeriod)
				BEGIN
					DELETE MC_T_COGSCalculation
					WHERE COGSPeriod = @COGSPeriod
				END

				-- INSERT CURRENCY FOR CURRENT PERIOD
				INSERT INTO [dbo].[MC_T_COGSCalculation]
				   ([IDX_M_Currency]
				   ,[COGSPeriod]
				   ,[BB_ForeignAmount]
				   ,[BB_BaseAmount]
				   ,[IN_ForeignAmount]
				   ,[IN_BaseAmount]
				   ,[EB_ForeignAmount]
				   ,[EB_BaseAmount]
				   ,[AverageAmount]
				   ,[UCreate]
				   ,[DCreate]				   
				   ,[RecordStatus])
				SELECT IDX_M_Currency, @COGSPeriod, 0, 0, 0, 0, 0, 0, 0, @UserID, GETDATE(), 'A'
				FROM MC_M_Currency				
				
				-- UPDATE SALDO AWAL
				UPDATE MC_T_COGSCalculation SET 
					BB_ForeignAmount = ISNULL(BB.ForeignAmount, 0), 
					BB_BaseAmount = ISNULL(BB.BaseCurrencyAmount, 0) 
				FROM (
					SELECT 
						C.IDX_M_Currency, 
						SUM(SD.ForeignAmount) AS ForeignAmount, 
						SUM(SD.BaseCurrencyAmount) AS BaseCurrencyAmount,					
						SUM(SD.BaseCurrencyAmount) / (SUM(SD.ForeignAmount)) AS AverageAmount
					FROM MC_T_PurchaseOrder S
					LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
					LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
					WHERE YEAR(PODate) = LEFT(@_PrevPeriod, 4) AND MONTH(PODate) = RIGHT(@_PrevPeriod,2) AND S.POStatus = 'A'
						AND SD.ForeignAmount > 0
						AND SD.BaseCurrencyAmount > 0
					GROUP BY C.IDX_M_Currency, C.CurrencyID, C.CurrencyName
				) BB 
				INNER JOIN MC_T_COGSCalculation ON MC_T_COGSCalculation.IDX_M_Currency = BB.IDX_M_Currency
				WHERE MC_T_COGSCalculation.COGSPeriod = @COGSPeriod								

				-- UPDATE MOVEMENT IN CURRENT PERIOD
				UPDATE MC_T_COGSCalculation SET IN_ForeignAmount = ISNULL(I.ForeignAmount, 0), 
					IN_BaseAmount = ISNULL(I.BaseCurrencyAmount, 0)
				FROM (
					SELECT 
						C.IDX_M_Currency, 
						SUM(SD.ForeignAmount) AS ForeignAmount, 
						SUM(SD.BaseCurrencyAmount) AS BaseCurrencyAmount,					
						SUM(SD.BaseCurrencyAmount) / (SUM(SD.ForeignAmount)) AS AverageAmount
					FROM MC_T_PurchaseOrder S
					LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
					LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
					WHERE YEAR(PODate) = LEFT(@COGSPeriod, 4) AND MONTH(PODate) = RIGHT(@COGSPeriod,2) AND S.POStatus = 'A'
						AND SD.ForeignAmount > 0
						AND SD.BaseCurrencyAmount > 0
					GROUP BY C.IDX_M_Currency, C.CurrencyID, C.CurrencyName
				) I 
				INNER JOIN MC_T_COGSCalculation ON MC_T_COGSCalculation.IDX_M_Currency = I.IDX_M_Currency
				WHERE MC_T_COGSCalculation.COGSPeriod = @COGSPeriod


				-- UPDATE ENDING BALANCE FOR CURRENT PERIOD
				UPDATE MC_T_COGSCalculation SET 
					EB_ForeignAmount = BB_ForeignAmount + IN_ForeignAmount, 
					EB_BaseAmount = BB_BaseAmount + IN_BaseAmount
				WHERE COGSPeriod = @COGSPeriod

				UPDATE MC_T_COGSCalculation SET AverageAmount = EB_BaseAmount / EB_ForeignAmount
				WHERE COGSPeriod = @COGSPeriod AND EB_ForeignAmount > 0

				

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




