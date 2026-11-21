
/* 
	BEGIN TRAN
	EXEC [dbo].[USP_MC_OpenCloseDaily_Approve 2,'2025-06-16','stok awal','it_febry'
	ROLLBACK TRAN
*/


CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDaily_Approve] 
	@IDX_T_OpenCloseDaily				BIGINT,
	@ApprovalDate						VARCHAR(10),
	@ApprovalRemark						VARCHAR(500),
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

			SELECT @_CountDetail = COUNT(IDX_T_OpenCloseDailyDetail) 
			FROM MC_T_OpenCloseDailyDetail
			WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current order status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_OpenCloseDaily 
						FROM MC_T_OpenCloseDaily 
						WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily AND TransactionStatus IN ('A','F','C'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'Transaksi sudah ditutup!')
			END		

			-- ==================================================================
			-- Check pending purchase order and pending sales order
			-- ==================================================================
			IF EXISTS(	SELECT IDX_T_OpenCloseDaily 
						FROM MC_T_OpenCloseDaily 
						WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily AND TransactionStatus IN ('A','F','C'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'Transaksi sudah ditutup!')
			END	

			-- =======================================
			-- Validate approval date and order date
			-- =======================================
			IF EXISTS(	SELECT IDX_T_OpenCloseDaily 
						FROM MC_T_OpenCloseDaily 
						WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily AND TransactionDate > @ApprovalDate)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'Approval Date must be greater than Order Date!')
			END

			-- =======================================
			-- Validate pending penjualan dan pembelian
			-- =======================================
			DECLARE @_SONumber					VARCHAR(50)
			DECLARE @_PONumber					VARCHAR(50)
			DECLARE @_TransactionDate			DATE

			IF EXISTS(	SELECT H.IDX_T_SalesOrder 
						FROM MC_T_SalesOrder H
						WHERE SOStatus = 'D'
			)
			BEGIN
				SELECT TOP 1 @_SONumber = SONumber 
				FROM MC_T_SalesOrder H
				WHERE SOStatus = 'D'

				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'Masih ada transaksi penjualan yang tertunda! ' + @_SONumber)
			END

			IF EXISTS(	SELECT H.IDX_T_PurchaseOrder 
						FROM MC_T_PurchaseOrder H
						WHERE POStatus = 'D'
			)
			BEGIN
				SELECT TOP 1 @_PONumber = PONumber 
				FROM MC_T_PurchaseOrder H
				WHERE POStatus = 'D'

				INSERT INTO @TableLog VALUES ('error',@IDX_T_OpenCloseDaily,'Masih ada transaksi pembelian yang tertunda! ' + @_PONumber)
			END

			-- ===================================================================
			-- Check Error Log
			-- ===================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				SELECT @_TransactionDate = TransactionDate 
				FROM MC_T_OpenCloseDaily 
				WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

				UPDATE MC_T_OpenCloseDaily SET	
					TransactionStatus = 'C',
					DModified = GETDATE()
				WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

				-- SELECT H.IDX_T_SalesOrder, H.SODate, H.SOStatus, 
				-- 	MT.TransactionTypeID, MT.TransactionTypeName,
				-- 	D.IDX_T_SalesOrderDetail, D.IDX_M_Valas, MV.ValasSKU, MV.ValasName, 
				-- 	D.Quantity, D.ExchangeRate, D.ForeignCurrency, D.ForeignAmount, 
				-- 	D.BaseCurrency, D.BaseCurrencyAmount,
				-- 	CF.CurrencyID AS ForeignCurrencyID, 
				-- 	CB.CurrencyID AS BaseCurrencyID
				-- FROM MC_T_SalesOrder H
				-- LEFT JOIN MC_T_SalesOrderDetail D ON D.IDX_T_SalesOrder = H.IDX_T_SalesOrder
				-- LEFT JOIN MC_M_TransactionType MT ON MT.IDX_M_TransactionType = D.IDX_M_TransactionType
				-- LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = D.IDX_M_Valas
				-- LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = MV.IDX_M_Currency
				-- LEFT JOIN GN_M_Currency CB ON CB.IDX_M_Currency = D.BaseCurrency
				-- WHERE CONVERT(DATE, H.SODate) = @_TransactionDate AND H.SOStatus = 'A'

				UPDATE MC_T_OpenCloseDailyDetail SET
					OutQty = S.Quantity
				FROM (
					SELECT D.IDX_M_Valas, ValasSKU, SUM(Quantity) AS Quantity
					FROM MC_T_SalesOrder H
					LEFT JOIN MC_T_SalesOrderDetail D ON D.IDX_T_SalesOrder = H.IDX_T_SalesOrder
					LEFT JOIN MC_M_TransactionType MT ON MT.IDX_M_TransactionType = D.IDX_M_TransactionType
					LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = D.IDX_M_Valas
					LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = MV.IDX_M_Currency
					LEFT JOIN GN_M_Currency CB ON CB.IDX_M_Currency = D.BaseCurrency
					WHERE CONVERT(DATE, H.SODate) = @_TransactionDate AND H.SOStatus = 'A' AND D.IDX_M_TransactionType = 2
					GROUP BY D.IDX_M_Valas, ValasSKU
				) S 
				INNER JOIN MC_T_OpenCloseDailyDetail ON MC_T_OpenCloseDailyDetail.IDX_M_Valas = S.IDX_M_Valas
				WHERE MC_T_OpenCloseDailyDetail.IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

				UPDATE MC_T_OpenCloseDailyDetail SET
					InQty = S.Quantity
				FROM (
					SELECT D.IDX_M_Valas, ValasSKU, SUM(Quantity) AS Quantity
					FROM MC_T_SalesOrder H
					LEFT JOIN MC_T_SalesOrderDetail D ON D.IDX_T_SalesOrder = H.IDX_T_SalesOrder
					LEFT JOIN MC_M_TransactionType MT ON MT.IDX_M_TransactionType = D.IDX_M_TransactionType
					LEFT JOIN MC_M_Valas MV ON MV.IDX_M_Valas = D.IDX_M_Valas
					LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = MV.IDX_M_Currency
					LEFT JOIN GN_M_Currency CB ON CB.IDX_M_Currency = D.BaseCurrency
					WHERE CONVERT(DATE, H.SODate) = @_TransactionDate AND H.SOStatus = 'A' AND D.IDX_M_TransactionType = 1
					GROUP BY D.IDX_M_Valas, ValasSKU
				) S 
				INNER JOIN MC_T_OpenCloseDailyDetail ON MC_T_OpenCloseDailyDetail.IDX_M_Valas = S.IDX_M_Valas
				WHERE MC_T_OpenCloseDailyDetail.IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

				

				-- ====================================================================================
				-- OUTPUT		
				-- ====================================================================================		
				INSERT INTO @TableLog VALUES ('success', @IDX_T_OpenCloseDaily, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_OpenCloseDaily, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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




