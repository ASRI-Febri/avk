
/* 
	EXEC [dbo].[USP_MC_InventoryCalculation] 1,'202601','it_febry'
*/


CREATE PROCEDURE [dbo].[USP_MC_InventoryCalculation] 
	@IDX_M_Company						BIGINT,
	@CalculationPeriod					VARCHAR(6),
	@UserID								VARCHAR(20)
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

			/** Check User Access Right **/
			--DECLARE @_FormID AS VARCHAR(20)
			--SET @_FormID = 'CM-PINV-005' -- Approval Receiving Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			PRINT 'Before Validation'

			

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
				
				--SELECT * FROM MC_M_TransactionType
				--1	BUY
				--2	SELL
				--3	PO
				--4	ADJIN
				--5	ADJOUT

				-- ============================================================
				-- TEMP TABLE TRANSACTION
				-- ============================================================
				CREATE TABLE #Transaction (
					IDX_M_Company				BIGINT,
					IDX_M_Currency				INT,
					IDX_M_Valas					BIGINT,
					IDX_M_ValasChange			BIGINT,
					Period						VARCHAR(6),
					----------------------------------------------------------					
					CurrencyID					VARCHAR(5),
					CurrencyName				VARCHAR(50),
					ValasSKU					VARCHAR(50),
					ValasName					VARCHAR(50),
					ValasChangeName				VARCHAR(50),
					ValasChangeNumber			INT,
					-----------------------------------------------------------
					OpeningQuantity				DECIMAL(18,2),
					OpeningValue				DECIMAL(22,4),
					InQuantity					DECIMAL(18,2),
					InValue						DECIMAL(22,4),
					OutQuantity					DECIMAL(18,2),
					OutValue					DECIMAL(22,4),
					------------------------------------------------------------
					ClosingQuantity				DECIMAL(18,2),
					AverageValue				DECIMAL(22,4),
					COGSValue					DECIMAL(22,4),
					InventoryValue				DECIMAL(22,4)
				)
				
				INSERT INTO #Transaction
				SELECT @IDX_M_Company, C.IDX_M_Currency, MV.IDX_M_Valas, MV.IDX_M_ValasChange, @CalculationPeriod, 
					C.CurrencyID, C.CurrencyName, MV.ValasSKU, MV.ValasName, 
					MVC.ValasChangeName, MVC.ValasChangeNumber, 
					0, 0, 0, 0, 0, 0, 
					0, 0, 0, 0
				FROM MC_M_Valas MV
				LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = MV.IDX_M_Currency
				LEFT JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange

				DECLARE @_PrevPeriod	VARCHAR(6) 
				DECLARE @_StartDate		VARCHAR(8) = @CalculationPeriod + '01'
				
				SET @_PrevPeriod = LEFT(CONVERT(VARCHAR,DATEADD(M, -1, CONVERT(DATE,@_StartDate)), 112), 6)

				PRINT 'Prev Period' + @_PrevPeriod
				PRINT 'Start Date' + @_StartDate

				-- UPDATE SALDO AWAL
				UPDATE #Transaction SET OpeningQuantity = P.ClosingQty, OpeningValue = P.InventoryValue
				FROM (
					SELECT CalculationPeriod, IDX_M_Valas, 
						SUM(ClosingQty) AS ClosingQty, SUM(InventoryValue) AS InventoryValue
					FROM MC_T_InventoryCalculation
					WHERE CalculationPeriod = @_PrevPeriod
					GROUP BY CalculationPeriod, IDX_M_Valas
				) P 
				INNER JOIN #Transaction ON #Transaction.IDX_M_Valas = P.IDX_M_Valas

				-- UPDATE PEMBELIAN
				--UPDATE #Transaction SET InQuantity = SD.Quantity, InValue = SD.Value
				--FROM (
				--	SELECT 
				--		SD.IDX_M_Valas, SUM(SD.Quantity) AS Quantity, SUM(SD.BaseCurrencyAmount) AS Value
				--	FROM MC_T_SalesOrder S
				--	LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
				--	WHERE IDX_M_Branch = @IDX_M_Company AND SOStatus = 'A' 
				--		AND SD.IDX_M_TransactionType = 1 
				--		AND YEAR(SODate) = LEFT(@CalculationPeriod, 4) AND MONTH(SODate) = RIGHT(@CalculationPeriod, 2)
				--	GROUP BY SD.IDX_M_Valas
				--) SD
				--INNER JOIN #Transaction ON #Transaction.IDX_M_Valas = SD.IDX_M_Valas

				UPDATE #Transaction SET InQuantity = SD.Quantity, InValue = SD.Value
				FROM (
					SELECT 
						--C.IDX_M_Currency, 
						V.IDX_M_Valas, 
						SUM(SD.Quantity) AS Quantity, SUM(SD.BaseCurrencyAmount) AS Value, 
						SUM(SD.BaseCurrencyAmount) / (SUM(SD.Quantity * VC.ValasChangeNumber)) AS AverageValue
					FROM MC_T_PurchaseOrder S
					LEFT JOIN MC_T_PurchaseOrderDetail SD ON SD.IDX_T_PurchaseOrder = S.IDX_T_PurchaseOrder
					LEFT JOIN MC_M_Valas V ON V.IDX_M_Valas = SD.IDX_M_Valas
					LEFT JOIN MC_M_ValasChange VC ON VC.IDX_M_ValasChange = V.IDX_M_ValasChange
					LEFT JOIN MC_M_Currency C ON C.IDX_M_Currency = V.IDX_M_Currency
					WHERE YEAR(PODate) = LEFT(@CalculationPeriod, 4) AND MONTH(PODate) = RIGHT(@CalculationPeriod, 2)
					GROUP BY V.IDX_M_Valas
				) SD
				INNER JOIN #Transaction ON #Transaction.IDX_M_Valas = SD.IDX_M_Valas

				-- UPDATE PENJUALAN
				UPDATE #Transaction SET OutQuantity = SD.Quantity, OutValue = SD.Value
				FROM (
					SELECT 
						SD.IDX_M_Valas, SUM(SD.Quantity) AS Quantity, SUM(SD.BaseCurrencyAmount) AS Value
					FROM MC_T_SalesOrder S
					LEFT JOIN MC_T_SalesOrderDetail SD ON SD.IDX_T_SalesOrder = S.IDX_T_SalesOrder
					WHERE IDX_M_Branch = @IDX_M_Company AND SOStatus = 'A' 
						AND SD.IDX_M_TransactionType = 2
						AND YEAR(SODate) = LEFT(@CalculationPeriod, 4) AND MONTH(SODate) = RIGHT(@CalculationPeriod, 2)
					GROUP BY SD.IDX_M_Valas
				) SD
				INNER JOIN #Transaction ON #Transaction.IDX_M_Valas = SD.IDX_M_Valas

				UPDATE #Transaction SET ClosingQuantity = OpeningQuantity + InQuantity - OutQuantity

				-- UPDATE AVERAGE QTY
				UPDATE #Transaction SET AverageValue = (OpeningValue + InValue) / (OpeningQuantity + InQuantity)
				WHERE (OpeningQuantity + InQuantity) > 0

				-- UPDATE COGS CALCULATION
				UPDATE #Transaction SET COGSValue = OutQuantity * AverageValue

				-- UPDATE INVENTORY CALCULATION
				UPDATE #Transaction SET InventoryValue = ClosingQuantity * AverageValue

				-- DELETE EXISTING DATA
				IF EXISTS(	SELECT IDX_T_InventoryCalculation 
							FROM MC_T_InventoryCalculation 
							WHERE CalculationPeriod = @CalculationPeriod)
				BEGIN
					DELETE MC_T_InventoryCalculation WHERE CalculationPeriod = @CalculationPeriod
				END

				-- INSERT DATA
				INSERT INTO [dbo].[MC_T_InventoryCalculation]
				   ([IDX_M_Company]
				   ,[IDX_M_Valas]
				   ,[CalculationPeriod]
				   ,[OpeningQty]
				   ,[OpeningValue]
				   ,[InQty]
				   ,[InValue]
				   ,[OutQty]
				   ,[OutValue]
				   ,[ClosingQty]
				   ,[AverageValue]
				   ,[COGSValue]
				   ,[InventoryValue]
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus])
				SELECT IDX_M_Company, IDX_M_Valas, @CalculationPeriod,OpeningQuantity, OpeningValue, 
					InQuantity, InValue, OutQuantity, OutValue, ClosingQuantity, AverageValue, 
					COGSValue, InventoryValue, @UserID, GETDATE(), 'A' 
				FROM #Transaction

				-- GET TRANSACTION DATA
				--SELECT * FROM #Transaction

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




