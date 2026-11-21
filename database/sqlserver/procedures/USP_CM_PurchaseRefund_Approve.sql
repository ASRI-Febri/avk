-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Approval Purchase Refund
-- =============================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_PurchaseRefund_Approve] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseRefund_Approve] 
	@IDX_T_PurchaseRefundHeader			BIGINT,
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

			SELECT @_CountDetail = COUNT(IDX_T_PurchaseRefundDetail) 
			FROM CM_T_PurchaseRefundDetail
			WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseRefundHeader,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current invoice status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseRefundHeader 
						FROM CM_T_PurchaseRefundHeader 
						WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader AND InvoiceStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseRefundHeader,'This invoice already approved!')
			END		

			-- =======================================
			-- Validate and check journal period
			-- =======================================
			IF EXISTS (	SELECT IDX_M_FiscalPeriod 
						FROM GL_M_FiscalPeriod 
						WHERE @ApprovalDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseRefundHeader,'GL period is already closed!')
			END

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
				DECLARE @_InvoiceNo				AS VARCHAR(20)
				DECLARE @_InvoiceDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(5)

				SET @_LastNumber = 0

				SELECT @_InvoiceDate = InvoiceDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType   
				FROM CM_T_PurchaseRefundHeader 
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				IF EXISTS(	SELECT TOP 1 InvoiceNo
							FROM CM_T_PurchaseRefundHeader 
							WHERE MONTH(InvoiceDate) = MONTH(@ApprovalDate)
								AND YEAR(InvoiceDate) = YEAR(@ApprovalDate) AND InvoiceStatus = 'A'
							ORDER BY InvoiceNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(InvoiceNo),4))
					FROM CM_T_PurchaseRefundHeader 
					WHERE MONTH(InvoiceDate) = MONTH(@ApprovalDate)
							AND YEAR(InvoiceDate) = YEAR(@ApprovalDate) AND InvoiceStatus = 'A'
					ORDER BY InvoiceNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ApprovalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ApprovalDate)),2)

				/** Set Sales Order No **/
				SET @_InvoiceNo = @_DocumentTypeID + '-' 
					+ @_Month
					+ @_Year + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				UPDATE CM_T_PurchaseRefundHeader 
				SET InvoiceNo = @_InvoiceNo,
					InvoiceStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
					ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader
							
			
				-- ====================================================
				-- Create Journal Header - Purchase Refund
				--
				-- Standard Journal :
				-- Piutang Usaha / COA Header from Purchase Refund --> Debet
				-- Pendapatan --> Credit
				-- ====================================================			

				
				DECLARE @_UntaxedAmount					AS DECIMAL(22,2)
				DECLARE @_AccountPayable				AS DECIMAL(22,2)
				DECLARE @_TaxAmount						AS DECIMAL(22,2)
				DECLARE @_TaxAccount					AS BIGINT
				DECLARE @_WithholdingTax				AS DECIMAL(22,2)
				DECLARE @_WithholdingTaxAccount			AS BIGINT

				-- Untaxed Amount
				SELECT @_UntaxedAmount = SUM((UntaxedAmount - DiscountAmount) * Quantity)
				FROM CM_T_PurchaseRefundDetail 
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader	
				
				-- PPN
				IF EXISTS(	SELECT IDX_T_PurchaseRefundDetail 
							FROM CM_T_PurchaseRefundTax PIT
								LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
							WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader AND MT.IsWithHoldingTax = 0)
				BEGIN
					SELECT @_TaxAccount = PIT.TaxCOA, @_TaxAmount = SUM(PIT.TaxAmount * PID.Quantity)
					FROM CM_T_PurchaseRefundTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_PurchaseRefundDetail PID ON PIT.IDX_T_PurchaseRefundDetail = PID.IDX_T_PurchaseRefundDetail 
					WHERE PIT.IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader AND MT.IsWithHoldingTax = 0
					GROUP BY PIT.IDX_M_Tax, TaxCOA
				END
				ELSE
				BEGIN
					SET @_TaxAccount = 0
					SET @_TaxAmount = 0
				END					

				-- PPh
				IF EXISTS(SELECT IDX_T_PurchaseRefundDetail 
							FROM CM_T_PurchaseRefundTax PIT
							LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader AND MT.IsWithHoldingTax = 1)
				BEGIN
					SELECT @_WithholdingTaxAccount = PIT.TaxCOA, @_WithholdingTax = SUM(PIT.TaxAmount * PID.Quantity)
					FROM CM_T_PurchaseRefundTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_PurchaseRefundDetail PID ON PIT.IDX_T_PurchaseRefundDetail = PID.IDX_T_PurchaseRefundDetail 
					WHERE PIT.IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader AND MT.IsWithHoldingTax = 1
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

				SET @_JournalDate = GETDATE() 				

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
								AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = 2
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
						AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = 2
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

				/** Set Voucher No **/
				SET @_VoucherNo = 'PJ-' 
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
					,1 -- 1 = SJ / Sales Journal
					,IDX_M_Partner
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_PurchaseRefundHeader
					,@_InvoiceNo
					,@_VoucherNo
					,GETDATE()					
					,'Purchase Refund Journal'
					,''
					,'P'
					,GETDATE()
					,@UserID
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_PurchaseRefundHeader
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader

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
					,(@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) -- ODebetAmount
					,0 -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,((@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) * 1) -- BDebetAmount
					,0 -- BCreditAmount 					
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PurchaseRefundHeader PIH
					LEFT JOIN GL_M_COA COA ON PIH.COAHeader = COA.IDX_M_COA
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader

				
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
					,0 -- ODebetAmount
					,(PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity -- OCreditAmount
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,((PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity) * 1 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PurchaseRefundDetail PID
					LEFT JOIN GL_M_COA COA ON PID.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader

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
						,0 -- ODebetAmount
						,@_TaxAmount -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0 -- BDebetAmount
						,(@_TaxAmount) * 1 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					--FROM CM_T_PurchaseRefundD
					--WHERE IDX_T_PurchaseRefundHeader = @IDX_T_PurchaseRefundHeader
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
						,ABS(@_WithholdingTax) -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,(ABS(@_WithholdingTax) * 1) -- BDebetAmount
						,0 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A'
				END

				INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseRefundHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseRefundHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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



