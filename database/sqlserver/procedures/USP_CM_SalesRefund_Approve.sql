-- =======================================================================================================================================
-- Author		: Anton
-- Create date	: 2019-12-12
-- Description	: Approval Sales Refund
-- Mod			: 2020-02-03 by Anton --> Correction logic validate journal date --> SET @_JournalDate = @ApprovalDate
--				  2020-08-21 by Anton --> Added PartnerDesc Information on JH
-- =======================================================================================================================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_SalesRefund_Approve] 1, '2019-12-12', 'Ok, Test Journal','1305276'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesRefund_Approve] 
	@IDX_T_SalesRefundHeader			BIGINT,
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

		-- =======================================
		-- Validation Process - START
		-- =======================================

			SELECT @_CountDetail = COUNT(IDX_T_SalesRefundDetail) 
			FROM CM_T_SalesRefundDetail
			WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'No Data in Detail Transaction')
			END				

			IF EXISTS(	SELECT IDX_T_SalesRefundHeader 
						FROM CM_T_SalesRefundHeader 
						WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND RefundStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'This refund invoice already approved!')
			END		

			IF EXISTS (	SELECT IDX_M_FiscalPeriod 
						FROM GL_M_FiscalPeriod 
						WHERE @ApprovalDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'GL period is already closed!')
			END

			IF (SELECT SUM(RefundQuantity) FROM CM_T_SalesRefundDetail WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'No item is refunded!')
			END

		-- =======================================
		-- Validation Process - END
		-- =======================================

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_IDX_M_Partner		BIGINT
				-- ==========================
				-- Generate Invoice No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_RefundNo				AS VARCHAR(20)
				DECLARE @_RefundDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				--DECLARE @_DocumentTypeID		AS CHAR(5) --mod anton 20190219
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_BranchID				AS VARCHAR(3)
				DECLARE @_IDX_M_Branch			AS INT

				SET @_LastNumber = 0

				--SELECT @_InvoiceDate = InvoiceDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType --mod anton 20190219 
				SELECT @_RefundDate = RefundDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType,  @_BranchID = IDX_M_Branch, @_IDX_M_Branch = IDX_M_Branch
				FROM CM_T_SalesRefundHeader 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WHERE IDX_M_Branch = @_BranchID --Added anton 20190219 

				IF EXISTS(	SELECT TOP 1 RefundNo
							FROM CM_T_SalesRefundHeader 
							WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
								AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND RefundStatus IN ('A','F')
							ORDER BY RIGHT(RefundNo,9) DESC) --MOD Anton 2019-03-19
							--ORDER BY InvoiceNo DESC)
				BEGIN
					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(RefundNo),4))
					FROM CM_T_SalesRefundHeader 
					WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
							AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND RefundStatus IN ('A','F')
					ORDER BY RIGHT(RefundNo,9) DESC --MOD Anton 2019-03-19
					--ORDER BY InvoiceNo DESC
				END	
				--Added area anton 20190219 		
				ELSE
				BEGIN
					SET @_LastNumber = '00000'
				END
				--End added area anton 20190219

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ApprovalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ApprovalDate)),2)

				/** Set Sales Order No **/
				SET @_RefundNo = RTRIM(@_DocumentTypeID) + '-' 
					+ @_BranchID + '-' --Added anton 20190219 
					+ @_Month
					+ @_Year + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				UPDATE CM_T_SalesRefundHeader 
				SET RefundNo = @_RefundNo,
					RefundStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
					ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				-- Insert stock card detail
				--INSERT INTO IN_M_ItemStockDetail 
				--	([IDX_IN_M_Item]
				--   ,[IDX_IN_M_LocationInventory]
				--   ,[IDX_IN_M_UOM]
				--   ,[TransactionType]
				--   ,[TransactionDate]
				--   ,[IDX_Transaction]
				--   ,[Remarks]
				--   ,[IN_Quantity]
				--   ,[IN_Cost]
				--   ,[IN_Value]
				--   ,[BL_Quantity]
				--   ,[BL_Cost]
				--   ,[BL_Value])
				--SELECT RID.IDX_IN_M_Item, RIH.IDX_IN_M_LocationInventory, MI.IDX_IN_M_UOM, 
				--	'SalesInvoice',RIH.InvoiceDate, 
				--	RIH.IDX_T_SalesInvoiceHeader, RIH.RemarkHeader,							
				--	RID.Quantity, RID.UntaxedAmount, (RID.Quantity * RID.UntaxedAmount),	
				--	RID.Quantity, RID.UntaxedAmount, (RID.Quantity * RID.UntaxedAmount)					
				--FROM CM_T_SalesInvoiceD RID
				--	LEFT JOIN CM_T_SalesInvoiceH RIH ON RID.IDX_T_SalesInvoiceHeader = RIH.IDX_T_SalesInvoiceHeader
				--	LEFT JOIN IN_M_Item MI ON RID.IDX_IN_M_Item = MI.IDX_IN_M_Item
				--	LEFT JOIN IN_M_UOM MU ON MI.IDX_IN_M_UOM = MU.IDX_IN_M_UOM 
				--WHERE RIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				-- Update Base Price (Last Sales Price) in table IN_M_Item
				--UPDATE IN_M_Item SET BasePrice = A.UntaxedAmount
				--FROM (SELECT * FROM CM_T_SalesInvoiceD WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) A
				--	INNER JOIN IN_M_Item ON A.IDX_IN_M_Item = IN_M_Item.IDX_IN_M_Item				 
											
			
				-- ====================================================
				-- Create Journal Header - Sales Invoice
				--
				-- Standard Journal :
				-- Piutang Usaha / COA Header from Sales Invoice --> Debet
				-- Pendapatan --> Credit
				-- ====================================================			

				
				DECLARE @_UntaxedAmount					AS DECIMAL(22,2)
				DECLARE @_AccountPayable				AS DECIMAL(22,2)
				DECLARE @_TaxAmount						AS DECIMAL(22,2)
				DECLARE @_TaxAccount					AS BIGINT
				DECLARE @_WithholdingTax				AS DECIMAL(22,2)
				DECLARE @_WithholdingTaxAccount			AS BIGINT

				-- Untaxed Amount
				SELECT @_UntaxedAmount = SUM(RefundPrice * RefundQuantity)
				FROM CM_T_SalesRefundDetail 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader	
				
				-- PPN
				IF EXISTS(	SELECT IDX_T_SalesRefundDetail 
							FROM CM_T_SalesRefundTax PIT
								LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
							WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND MT.IsWithHoldingTax = 0)
				BEGIN
					SELECT @_TaxAccount = PIT.TaxCOA, @_TaxAmount = SUM(PIT.TaxAmount * PID.RefundQuantity)
					FROM CM_T_SalesRefundTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_SalesRefundDetail PID ON PIT.IDX_T_SalesRefundDetail = PID.IDX_T_SalesRefundDetail 
					WHERE PIT.IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND MT.IsWithHoldingTax = 0
					GROUP BY PIT.IDX_M_Tax, TaxCOA
				END
				ELSE
				BEGIN
					SET @_TaxAccount = 0
					SET @_TaxAmount = 0
				END					

				-- PPh
				IF EXISTS(SELECT IDX_T_SalesRefundDetail 
							FROM CM_T_SalesRefundTax PIT
							LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND MT.IsWithHoldingTax = 1)
				BEGIN
					SELECT @_WithholdingTaxAccount = PIT.TaxCOA, @_WithholdingTax = SUM(PIT.TaxAmount * PID.RefundQuantity)
					FROM CM_T_SalesRefundTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_SalesRefundDetail PID ON PIT.IDX_T_SalesRefundDetail = PID.IDX_T_SalesRefundDetail 
					WHERE PIT.IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND MT.IsWithHoldingTax = 1
					GROUP BY PIT.IDX_M_Tax, TaxCOA	
				END
				ELSE
				BEGIN
					SET @_WithholdingTaxAccount = 0
					SET @_WithholdingTax = 0
				END								

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_VoucherNo AS VARCHAR(20)				
				DECLARE @_JournalDate AS DATE

				SET @_LastNumber = 0

				SET @_JournalDate = @ApprovalDate			

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
								AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = 3
								AND IDX_M_Branch = @_IDX_M_Branch
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
						AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = 3
						AND IDX_M_Branch = @_IDX_M_Branch
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

				/** Set Voucher No **/
				SET @_VoucherNo = 'SR' + '-' + @_BranchID + '-' 
					+ @_Month
					+ @_Year + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- =================================================
				-- Insert Journal Header
				-- =================================================

				INSERT INTO [dbo].[GL_T_JournalHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]				   
				   ,[IDX_M_JournalType]
				   ,[IDX_M_Partner]
				   ,[ApplicationID]
				   ,[IDX_ReferenceNo]
				   ,[ReferenceNo]
				   ,[VoucherNo]
				   ,[JournalDate]				   
				   ,[RemarkHeader]
				   ,[PartnerDesc]
				   ,[PostingStatus]
				   ,[PostingDate]
				   ,[PostedBy]
				   ,[DebetAmount]
				   ,[CreditAmount]
				   ,[JournalSource]
				   ,[UCreate]
				   ,[DCreate]			  
				   ,[RecordStatus])
				SELECT 
					 IDX_M_Company
					,IDX_M_Branch					
					,3 -- 3 = SR / Sales Refund Journal
					,SRH.IDX_M_Partner
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_SalesRefundHeader
					,@_RefundNo
					,@_VoucherNo
					,@_JournalDate				
					,'Sales Refund Journal'
					,MP.PartnerName
					,'P'
					,@_JournalDate
					,@UserID
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_SalesRefundHeader SRH WITH(NOLOCK)
					LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON SRH.IDX_M_Partner = MP.IDX_M_Partner 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				DECLARE @IDX_GL_T_JournalHeader AS BIGINT
				SET @IDX_GL_T_JournalHeader = (SELECT SCOPE_IDENTITY())


				-- ====================================================
				-- Create Journal Detail - Piutang Usaha (DEBET)
				-- ====================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				   ([IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[JournalSeqNo]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
				   ,[COADescription]
				   ,[RemarkDetail]
				   ,[OriginalCurrencyID]
				   ,[ODebetAmount]
				   ,[OCreditAmount]
				   ,[ExchangeRate]
				   ,[BaseCurrencyID]
				   ,[BDebetAmount]
				   ,[BCreditAmount]
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
				SELECT 
					@IDX_GL_T_JournalHeader
					,0
					,0
					,0
					,PIH.COAHeader 
					,@_IDX_M_Partner
					,COA.COADesc
					,'' -- RemarkDetail
					,1 -- Original Currency
					,0 -- ODebetAmount	
					,(@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) -- OCreditAmount				
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,((@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) * 1) -- BCreditAmount			
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_SalesRefundHeader PIH
					LEFT JOIN GL_M_COA COA ON PIH.COAHeader = COA.IDX_M_COA
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				
				-- ====================================================
				-- Create Journal Detail - Pendapatan
				-- ====================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				   ([IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[JournalSeqNo]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
				   ,[COADescription]
				   ,[RemarkDetail]
				   ,[OriginalCurrencyID]
				   ,[ODebetAmount]
				   ,[OCreditAmount]
				   ,[ExchangeRate]
				   ,[BaseCurrencyID]
				   ,[BDebetAmount]
				   ,[BCreditAmount]
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
				SELECT 
					@IDX_GL_T_JournalHeader
					,0 -- Project
					,0 -- Department
					,0 -- SeqNo
					,PID.IDX_M_COA 
					,@_IDX_M_Partner
					,COA.COADesc
					,'' -- RemarkDetail
					,1 -- Original Currency
					,PID.RefundPrice * PID.RefundQuantity -- ODebetAmount
					,0 -- OCreditAmount
					,1 -- Exchange Rate
					,1 -- Base Currency
					,(PID.RefundPrice * PID.RefundQuantity) * 1 -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_SalesRefundDetail PID
					LEFT JOIN GL_M_COA COA ON PID.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND PID.RefundQuantity <> 0

				-- ====================================================
				-- Create Journal Detail - PPN
				-- ====================================================

				IF @_TaxAmount > 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
					   ([IDX_T_JournalHeader]
					   ,[IDX_M_Project]
					   ,[IDX_M_Department]
					   ,[JournalSeqNo]
					   ,[IDX_M_COA]
					   ,[IDX_M_Partner]
					   ,[COADescription]
					   ,[RemarkDetail]
					   ,[OriginalCurrencyID]
					   ,[ODebetAmount]
					   ,[OCreditAmount]
					   ,[ExchangeRate]
					   ,[BaseCurrencyID]
					   ,[BDebetAmount]
					   ,[BCreditAmount]
					   ,[UCreate]
					   ,[DCreate]				  
					   ,[RecordStatus])
					SELECT 
						@IDX_GL_T_JournalHeader
						,0 -- Project
						,0 -- Department
						,0 -- SeqNo
						,@_TaxAccount 
						,@_IDX_M_Partner
						,'PPN Keluaran'
						,'' -- RemarkDetail
						,1 -- Original Currency
						,@_TaxAmount -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,(@_TaxAmount) * 1 -- BDebetAmount
						,0 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					--FROM CM_T_SalesInvoiceD
					--WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader
				END

				

				-- ====================================================
				-- Create Journal Detail - PPh 23 (Sales Tax)
				-- ====================================================

				IF ABS(@_WithholdingTax) > 0
				BEGIN
					INSERT INTO [dbo].[GL_T_JournalDetail]
					   ([IDX_T_JournalHeader]
					   ,[IDX_M_Project]
					   ,[IDX_M_Department]
					   ,[JournalSeqNo]
					   ,[IDX_M_COA]
					   ,[IDX_M_Partner]
					   ,[COADescription]
					   ,[RemarkDetail]
					   ,[OriginalCurrencyID]
					   ,[ODebetAmount]
					   ,[OCreditAmount]
					   ,[ExchangeRate]
					   ,[BaseCurrencyID]
					   ,[BDebetAmount]
					   ,[BCreditAmount]
					   ,[UCreate]
					   ,[DCreate]				  
					   ,[RecordStatus])
					SELECT 
						@IDX_GL_T_JournalHeader
						,0
						,0
						,0
						,@_WithholdingTaxAccount 
						,@_IDX_M_Partner 
						,'PPh 23 Sales Tax'
						,'' -- RemarkDetail
						,1 -- Original Currency
						,0 -- ODebetAmount
						,ABS(@_WithholdingTax) -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0 -- BDebetAmount
						,(ABS(@_WithholdingTax) * 1) -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A'
				END

				IF EXISTS (SELECT 1 FROM CM_T_SalesRefundHeader WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader AND IsCreateJournal <> 1)
				BEGIN
					UPDATE GL_T_JournalHeader SET RecordStatus = 'I' WHERE IDX_T_JournalHeader = @IDX_GL_T_JournalHeader
					UPDATE GL_T_JournalDetail SET RecordStatus = 'I' WHERE IDX_T_JournalHeader = @IDX_GL_T_JournalHeader
					INSERT INTO GL_T_JournalHeaderLog
						(IDX_T_JournalHeader, LogType, LogDate, LogRemark, UCreate, DCreate, RecordStatus)
					SELECT @IDX_GL_T_JournalHeader, 'Unposting', SYSDATETIME(), 'IsCreateJournal not checked', @UserID, SYSDATETIME(), 'A'
				END

				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesRefundHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesRefundHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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



