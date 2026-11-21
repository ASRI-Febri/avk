/* 
	BEGIN TRAN
	EXEC [dbo].[USP_MC_SalesOrder_Approve 2,'2025-06-16','stok awal','it_febry'
	ROLLBACK TRAN
*/


CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_Approve] 
	@IDX_T_SalesOrder					BIGINT,
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

			SELECT @_CountDetail = COUNT(IDX_T_SalesOrderDetail) 
			FROM MC_T_SalesOrderDetail
			WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current order status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_SalesOrder 
						FROM MC_T_SalesOrder 
						WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND SOStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'This order already approved!')
			END		

			-- =======================================
			-- Validate approval date and order date
			-- =======================================
			IF EXISTS(	SELECT IDX_T_SalesOrder 
						FROM MC_T_SalesOrder 
						WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND SODate > @ApprovalDate)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesOrder,'Approval Date must be greater than Order Date!')
			END

			-- =======================================
			-- Validate stok valas per pecahan untuk baris jual: stok harus cukup
			-- pada tanggal nota dan saldo transaksi sesudahnya tidak boleh jadi
			-- minus (nota mundur tanggal). Sama dengan dashboard money changer:
			-- kartu stok aktif, per cabang nota.
			-- =======================================
			DECLARE @_StockDate		DATE
			DECLARE @_StockBranch	BIGINT

			SELECT @_StockDate = CONVERT(DATE, SODate), @_StockBranch = IDX_M_Branch
			FROM MC_T_SalesOrder WITH(NOLOCK)
			WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

			;WITH Req AS (
				SELECT IDX_M_Valas, SUM(Quantity) AS Qty
				FROM MC_T_SalesOrderDetail WITH(NOLOCK)
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder AND IDX_M_TransactionType = 2
				GROUP BY IDX_M_Valas
			),
			Daily AS (
				SELECT S.IDX_M_Valas, CONVERT(DATE, S.TransactionDate) AS TD,
					SUM(ISNULL(S.StockInQty, 0) - ISNULL(S.StockOutQty, 0)) AS Net
				FROM MC_T_StockCardValas S WITH(NOLOCK)
				INNER JOIN Req R ON R.IDX_M_Valas = S.IDX_M_Valas
				WHERE S.RecordStatus = 'A' AND S.IDX_M_Branch = @_StockBranch
				GROUP BY S.IDX_M_Valas, CONVERT(DATE, S.TransactionDate)
			),
			Running AS (
				SELECT IDX_M_Valas, TD,
					SUM(Net) OVER (PARTITION BY IDX_M_Valas ORDER BY TD ROWS UNBOUNDED PRECEDING) AS Bal
				FROM Daily
			),
			Avail AS (
				SELECT R.IDX_M_Valas, R.Qty,
					(SELECT MIN(M.Bal) FROM (
						SELECT ISNULL(SUM(D.Net), 0) AS Bal FROM Daily D
						WHERE D.IDX_M_Valas = R.IDX_M_Valas AND D.TD <= @_StockDate
						UNION ALL
						SELECT X.Bal FROM Running X
						WHERE X.IDX_M_Valas = R.IDX_M_Valas AND X.TD > @_StockDate
					) M) AS Available
				FROM Req R
			)
			INSERT INTO @TableLog
			SELECT 'error', @IDX_T_SalesOrder,
				'Stok ' + RTRIM(V.ValasSKU) + ' tidak cukup: diminta ' + FORMAT(A.Qty, '0.##')
				+ ' lembar, tersedia ' + FORMAT(CASE WHEN A.Available < 0 THEN 0 ELSE A.Available END, '0.##') + ' lembar'
			FROM Avail A
			INNER JOIN MC_M_Valas V WITH(NOLOCK) ON V.IDX_M_Valas = A.IDX_M_Valas
			WHERE A.Qty > A.Available

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				PRINT 'After validation'

				DECLARE @_IDX_M_Partner		BIGINT
				-- ==========================
				-- Generate Order No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_SONumber				AS VARCHAR(20)
				DECLARE @_SODate				AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_BranchID				AS VARCHAR(3)
				DECLARE @_IDX_M_Branch			AS INT

				SET @_LastNumber = 0


				-- ==========================================
				-- Get Data From Purchase Order Header
				-- ==========================================

				SELECT @_SODate = SODate, @_IDX_M_Partner = IDX_M_Partner, 
					@_IDX_M_DocumentType = IDX_M_DocumentType,  
					@_BranchID = IDX_M_Branch, @_IDX_M_Branch = IDX_M_Branch
				FROM MC_T_SalesOrder 
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) 
				FROM GN_M_DocumentType 
				WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				SELECT @_BranchID = RTRIM(BranchID) 
				FROM GN_M_Branch 
				WHERE IDX_M_Branch = @_BranchID

				
				SELECT @_LastNumber= ISNULL(MAX( CONVERT(INT,RIGHT(RTRIM(SONumber),4))),0)
				FROM MC_T_SalesOrder 
				WHERE IDX_M_Branch = @_IDX_M_Branch --AND MONTH(POApproveDate) = MONTH(@ApprovalDate)
				AND YEAR(SODate) = YEAR(@ApprovalDate) AND SONumber NOT LIKE 'DRAFT-%' --AND POStatus IN ('D','A','F','C')
				--END

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ApprovalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)
				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ApprovalDate)),2)

				/** Set Purchase Order No **/
				SET @_SONumber = RTRIM(@_DocumentTypeID) + '-' 
					+ @_BranchID + '-' 
					+ @_Year
					+ @_Month + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				IF (SELECT SONumber FROM MC_T_SalesOrder WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder) LIKE 'DRAFT%'
				BEGIN
					UPDATE MC_T_SalesOrder 
					SET SONumber = @_SONumber,
						SOStatus = 'A', 
						SOApprovalDate = @ApprovalDate, 
						SOApprovalBy = @UserID, 
						SOApprovalNotes = @ApprovalRemark, 
						DModified = GETDATE(), 
						UModified = @UserID 
					WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder
				END
				ELSE
				BEGIN
					UPDATE MC_T_SalesOrder 
					SET SOStatus = 'A', 
						SOApprovalDate = @ApprovalDate, 
						SOApprovalBy = @UserID, 
						SOApprovalNotes = @ApprovalRemark, 
						DModified = GETDATE(), 
						UModified = @UserID 
					WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder
				END

				-- ====================================================================================
				-- INSERT STOCK CARD		
				-- ====================================================================================	

				-- TRANSAKSI JUAL
				INSERT INTO [dbo].[MC_T_StockCardValas]
				   ([IDX_M_Branch]
				   ,[IDX_M_Valas]
				   ,[IDX_M_TransactionType]
				   ,[IDX_Transaction]
				   ,[TransactionNo]
				   ,[TransactionDate]
				   -----------------------------------------------------------------------
				   ,[StockInQty]
				   ,[ExchangeRateIn]
				   ,[StockInForeignAmount]
				   ,[StockInBaseAmount]
				   -----------------------------------------------------------------------
				   ,[StockOutQty]
				   ,[ExchangeRateOut]
				   ,[StockOutForeignAmount]
				   ,[StockOutBaseAmount]
				   -----------------------------------------------------------------------
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus])
				SELECT SOH.IDX_M_Branch, SOD.IDX_M_Valas, SOD.IDX_M_TransactionType, SOH.IDX_T_SalesOrder, SOH.SONumber, SOH.SODate,
					-----------------------------------------------------------------------
					0, 0, 0, 0,
					-----------------------------------------------------------------------
					SOD.Quantity, SOD.ExchangeRate, (SOD.Quantity * MVC.ValasChangeNumber), 
					(SOD.Quantity * MVC.ValasChangeNumber * SOD.ExchangeRate),
					-----------------------------------------------------------------------
					@UserID, GETDATE(), 'A' 
				FROM MC_T_SalesOrderDetail SOD
				INNER JOIN MC_T_SalesOrder SOH ON SOH.IDX_T_SalesOrder = SOD.IDX_T_SalesOrder
				INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SOD.IDX_M_Valas
				INNER JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange 
				WHERE SOH.IDX_T_SalesOrder = @IDX_T_SalesOrder 
					AND SOD.IDX_M_TransactionType = 2 -- SELL (TRANSAKSI JUAL)

				-- TRANSAKSI BELI
				INSERT INTO [dbo].[MC_T_StockCardValas]
				   ([IDX_M_Branch]
				   ,[IDX_M_Valas]
				   ,[IDX_M_TransactionType]
				   ,[IDX_Transaction]
				   ,[TransactionNo]
				   ,[TransactionDate]
				   -----------------------------------------------------------------------
				   ,[StockInQty]
				   ,[ExchangeRateIn]
				   ,[StockInForeignAmount]
				   ,[StockInBaseAmount]
				   -----------------------------------------------------------------------
				   ,[StockOutQty]
				   ,[ExchangeRateOut]
				   ,[StockOutForeignAmount]
				   ,[StockOutBaseAmount]
				   -----------------------------------------------------------------------
				   ,[UCreate]
				   ,[DCreate]
				   ,[RecordStatus])
				SELECT SOH.IDX_M_Branch, SOD.IDX_M_Valas, SOD.IDX_M_TransactionType, SOH.IDX_T_SalesOrder, SOH.SONumber, SOH.SODate,
					SOD.Quantity, SOD.ExchangeRate, (SOD.Quantity * MVC.ValasChangeNumber), 
					-----------------------------------------------------------------------
					(SOD.Quantity * MVC.ValasChangeNumber * SOD.ExchangeRate),
					-----------------------------------------------------------------------
					 0, 0, 0, 0,
					@UserID, GETDATE(), 'A' 
				FROM MC_T_SalesOrderDetail SOD
				INNER JOIN MC_T_SalesOrder SOH ON SOH.IDX_T_SalesOrder = SOD.IDX_T_SalesOrder
				INNER JOIN MC_M_Valas MV ON MV.IDX_M_Valas = SOD.IDX_M_Valas
				INNER JOIN MC_M_ValasChange MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange 
				WHERE SOH.IDX_T_SalesOrder = @IDX_T_SalesOrder 
					AND SOD.IDX_M_TransactionType = 1 -- BUY (TRANSAKSI BELI)

				-- ========================================================
				-- GENERATE JOURNAL
				-- ========================================================
				DECLARE @_JournalResult		SMALLINT

				EXEC USP_MC_SalesJournal_Create @IDX_T_SalesOrder, @UserID, @_JournalResult OUTPUT

				IF @_JournalResult <> 1
				BEGIN
					INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrder, 'Create journal failed!')
				END

				-- ====================================================================================
				-- OUTPUT		
				-- ====================================================================================		
				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesOrder, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrder, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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