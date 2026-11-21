-- ====================================================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Sales Invoice
-- Mod			: 2019-02-19 by Anton --> Adjustment kode voucher
--				  2019-05-15 by Anton --> Adjust hardcode pak feb utk idx_journal_type dari 2 rubah jadi 1 & tambah filter IDX_Branch utk dpt lastnumber column voucherNo di table JH
--				  2020-01-20 by Anton --> Change value param @_JournalDate --> @ApprovalDate
--				  2020-06-04 by Anton --> Added remarks information when insert to Journal Detail
--				  2020-09-21 by Anton --> Added PartnerDesc Information on JH
--				  2020-10-02 by Anton --> Added Journal Closing Period Validation
--				  2021-03-10 by Anton --> Adjust inserted value on remarks table journal detail on COA TAX
--				  2023-08-25 by Anton --> Adjust logic insert detail journal for Upload Excel Parking Sales Transaction
--				  2024-01-08 by Anton --> Approve not changing document no if existing <> DRAFT
--				  2024-02-15 by Anton --> Adjust insert value to journal detail when amount detail transaction < 0
--				  2024-05-16 by Anton --> Added Value IDX_M_Project on Journal Detail - Piutang Usaha (DEBET)
-- ====================================================================================================================================================================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_SalesInvoice_Approve] 3, '2019-02-19', 'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Approve] 
	@IDX_T_SalesInvoiceHeader			BIGINT,
	@ApprovalDate						VARCHAR(10),
	@ApprovalRemark						VARCHAR(500),
	@UserID								VARCHAR(50)
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

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@ApprovalDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Journal Period Already Closed!')
			END	

			SELECT @_CountDetail = COUNT(IDX_T_SalesInvoiceDetail) 
			FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
			WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'No Data in Detail Transaction')
			END				

			-- =======================================
			-- Validate and check current invoice status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_SalesInvoiceHeader 
						FROM CM_T_SalesInvoiceHeader WITH(NOLOCK)
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND InvoiceStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'This invoice already approved!')
			END		

			-- =======================================
			-- Validate and check journal period
			-- =======================================
			IF EXISTS (	SELECT IDX_M_FiscalPeriod 
						FROM GL_M_FiscalPeriod WITH(NOLOCK) 
						WHERE @ApprovalDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'GL period is already closed!')
			END

			-- =======================================
			-- Validate and check tax amount
			-- =======================================
			IF EXISTS(	SELECT 1
						FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND TaxAmount < 0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Please Input PPH Tax Type on Add Additional Tax Section!')
			END	

			-- =======================================
			-- Validate approval date and invoice date
			-- =======================================
			IF EXISTS(	SELECT IDX_T_SalesInvoiceHeader 
						FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND InvoiceDate > @ApprovalDate)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Approval date < Invoice Date !')
			END

			IF (SELECT ApprovedDate FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) IS NOT NULL
			BEGIN
				IF (SELECT MONTH(ApprovedDate) FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) <> MONTH(@ApprovalDate)
				BEGIN
					INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'VoucherNo Already Exist, Cannot Change Month Approval. Please Void Transaction!')
				END
			END

			IF EXISTS ( SELECT 1 FROM
						CM_T_SalesInvoiceDetail WITH(NOLOCK)
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND (UnitPrice = 0 OR UnitPrice IS NULL) )
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesInvoiceHeader,'Please Check Amount Unit Price On Detail Transaction!')
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
				--DECLARE @_DocumentTypeID		AS CHAR(5) --mod anton 20190219
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_BranchID				AS VARCHAR(3)
				DECLARE @_IDX_M_Branch			AS INT

				DECLARE @_TaxInvoiceNo			AS VARCHAR(64)

				DECLARE @_ERPNo					AS VARCHAR(64)

				DECLARE @_ReferenceNo			AS VARCHAR(100)

				SET @_LastNumber = 0

				--SELECT @_InvoiceDate = InvoiceDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType --mod anton 20190219 
				SELECT	@_InvoiceDate = InvoiceDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType,  @_BranchID = IDX_M_Branch, 
						@_IDX_M_Branch = IDX_M_Branch, @_TaxInvoiceNo = TaxInvoiceNo, @_ReferenceNo = ReferenceNo
				FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WITH(NOLOCK) WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @_BranchID --Added anton 20190219 

				IF EXISTS(	SELECT TOP 1 InvoiceNo
							FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
							WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
								AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND LEFT(InvoiceNo,5) <> 'DRAFT'
							ORDER BY RIGHT(InvoiceNo,9) DESC) --MOD Anton 2019-03-19
							--ORDER BY InvoiceNo DESC)
				BEGIN
					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(InvoiceNo),4))
					FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
					WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
							AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND LEFT(InvoiceNo,5) <> 'DRAFT'
					ORDER BY RIGHT(InvoiceNo,9) DESC --MOD Anton 2019-03-19
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
				SET @_InvoiceNo = RTRIM(@_DocumentTypeID) + '-' 
					+ @_BranchID + '-' --Added anton 20190219 
					+ @_Year 
					+ @_Month + '-'
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)


				DECLARE @_StartERPNo AS INT

				SET @_StartERPNo = (SELECT ISNULL(MAX(RIGHT(ERPNo,5)),10719) + 1 FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE YEAR(InvoiceDate) = YEAR(@_InvoiceDate))

				
				-- SPECIAL REQUEST
				SET @_ERPNo = CASE WHEN @ApprovalDate >= '2019-12-16' THEN 'SAJ/' + CONVERT(VARCHAR,YEAR(@_InvoiceDate)) + '/' + CONVERT(VARCHAR,@_StartERPNo) ELSE NULL END

				DECLARE @CurrentTransNo VARCHAR(50)
				SET @CurrentTransNo = (SELECT InvoiceNo FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)

				-- Update status
				IF LEFT(@CurrentTransNo,5) = 'DRAFT'
				BEGIN
					UPDATE CM_T_SalesInvoiceHeader 
						SET InvoiceNo = @_InvoiceNo,
							InvoiceStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
							ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
							, ERPNo = @_ERPNo --temporary no
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	
				END
				ELSE
				BEGIN
					UPDATE CM_T_SalesInvoiceHeader 
						SET InvoiceStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
							ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
							, ERPNo = @_ERPNo --temporary no
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	
				END

				UPDATE	CM_M_FakturNumberLine
					SET isUsed = 1,
						IDX_T_Transaction = @IDX_T_SalesInvoiceHeader,
						DModified=GETDATE(),
						UModified=@UserID
				WHERE	FakturNumber = @_TaxInvoiceNo
					
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
				DECLARE @_IDXProject					AS BIGINT

				-- Untaxed Amount
				SELECT @_UntaxedAmount = SUM((UntaxedAmount - DiscountAmount) * Quantity)
				FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) 
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	
				
				-- PPN
				IF EXISTS(	SELECT IDX_T_SalesInvoiceDetail 
							FROM CM_T_SalesInvoiceTax PIT
								LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
							WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 0)
				BEGIN
					SELECT @_TaxAccount = PIT.TaxCOA, @_TaxAmount = SUM(PIT.TaxAmount * PID.Quantity)
					FROM CM_T_SalesInvoiceTax PIT WITH(NOLOCK)
						LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_SalesInvoiceDetail PID WITH(NOLOCK) ON PIT.IDX_T_SalesInvoiceDetail = PID.IDX_T_SalesInvoiceDetail 
					WHERE PIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 0
					GROUP BY PIT.IDX_M_Tax, TaxCOA
				END
				ELSE
				BEGIN
					SET @_TaxAccount = 0
					SET @_TaxAmount = 0
				END					

				-- PPh
				IF EXISTS(SELECT IDX_T_SalesInvoiceDetail 
							FROM CM_T_SalesInvoiceTax PIT WITH(NOLOCK)
							LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 1)
				BEGIN
					SELECT @_WithholdingTaxAccount = PIT.TaxCOA, @_WithholdingTax = SUM(PIT.TaxAmount * PID.Quantity)
					FROM CM_T_SalesInvoiceTax PIT WITH(NOLOCK)
						LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_SalesInvoiceDetail PID WITH(NOLOCK) ON PIT.IDX_T_SalesInvoiceDetail = PID.IDX_T_SalesInvoiceDetail 
					WHERE PIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 1
					GROUP BY PIT.IDX_M_Tax, TaxCOA	
				END
				ELSE
				BEGIN
					SET @_WithholdingTaxAccount = 0
					SET @_WithholdingTax = 0
				END				
				
				SET @_IDXProject = (SELECT DISTINCT TOP 1 (IDX_M_Project)
									FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) 
									WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_VoucherNo AS VARCHAR(20)				
				DECLARE @_JournalDate AS DATE

				SET @_LastNumber = 0

				SET @_JournalDate = @ApprovalDate				

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader WITH(NOLOCK) 
							WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
								AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = 1
								AND IDX_M_Branch = @_IDX_M_Branch
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader WITH(NOLOCK) 
					WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
						AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = 1
						AND IDX_M_Branch = @_IDX_M_Branch
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

				/** Set Voucher No **/
				SET @_VoucherNo = 'SJ' + '-' + @_BranchID + '-' 
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
					,SIH.IDX_M_Partner
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_SalesInvoiceHeader
					,CASE WHEN LEFT(@CurrentTransNo,5) = 'DRAFT' THEN @_InvoiceNo ELSE @CurrentTransNo END
					,@_VoucherNo
					,@ApprovalDate					
					,UPPER(SIH.RemarkHeader)
					,MP.PartnerName
					,'P'
					,@ApprovalDate
					,@UserID
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
					LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON SIH.IDX_M_Partner = MP.IDX_M_Partner
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				DECLARE @IDX_GL_T_JournalHeader AS BIGINT
				SET @IDX_GL_T_JournalHeader = (SELECT SCOPE_IDENTITY())


				-- ====================================================
				-- Create Journal Detail - Piutang Usaha (DEBET)
				-- ====================================================

				IF EXISTS
				(
					SELECT 1 
					FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
						LEFT JOIN X_SalesSummary_Quality X WITH(NOLOCK) ON SIH.ReferenceNo = LTRIM(RTRIM(X.UploadID)) 
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND X.UploadStatus = 'A' AND X.RecordStatus = 'A'
				)
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
						,ISNULL(DIFF.IDX_M_Project,@_IDXProject)
						,0
						,0
						,PIH.COAHeader 
						,@_IDX_M_Partner
						,COA.COADesc
						,PIH.RemarkHeader -- RemarkDetail
						,1 -- Original Currency
						--,(@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) -- ODebetAmount
						,TotalSalesAmount - ISNULL(DIFF.DiffFactor,0) -- Adjustment Calculation ODebetAmount by Anton 2023-08-28
						,0 -- OCreditAmount					
						,1 -- Exchange Rate
						,1 -- Base Currency
						--,((@_UntaxedAmount + @_TaxAmount - ABS(@_WithholdingTax)) * 1) -- BDebetAmount
						,TotalSalesAmount - ISNULL(DIFF.DiffFactor,0) -- Adjustment Calculation ODebetAmount by Anton 2023-08-28
						,0 -- BCreditAmount 					
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_SalesInvoiceHeader PIH WITH(NOLOCK)
						INNER JOIN GL_M_COA COA WITH(NOLOCK) ON PIH.COAHeader = COA.IDX_M_COA
						LEFT JOIN
						(	SELECT IDX_T_SalesInvoiceHeader, IDX_M_Project, (SUM(ISNULL(UnitPrice,0)))*-1 AS DiffFactor
							FROM CM_T_SalesInvoiceDetail
							WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice < 0
							GROUP BY IDX_T_SalesInvoiceHeader, IDX_M_Project) DIFF ON PIH.IDX_T_SalesInvoiceHeader = DIFF.IDX_T_SalesInvoiceHeader
					WHERE PIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader
				END
				ELSE
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
						,@_IDXProject
						,0
						,0
						,PIH.COAHeader 
						,@_IDX_M_Partner
						,COA.COADesc
						,PIH.RemarkHeader -- RemarkDetail
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
					FROM CM_T_SalesInvoiceHeader PIH WITH(NOLOCK)
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PIH.COAHeader = COA.IDX_M_COA
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader
				END

				
				-- ====================================================
				-- Create Journal Detail - Pendapatan
				-- ====================================================

				IF EXISTS
				(
					SELECT 1 
					FROM CM_T_SalesInvoiceHeader SIH WITH(NOLOCK)
						LEFT JOIN X_SalesSummary_Quality X WITH(NOLOCK) ON SIH.ReferenceNo = LTRIM(RTRIM(X.UploadID)) 
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND X.UploadStatus = 'A' AND X.RecordStatus = 'A'
				)
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
						,PID.IDX_M_Project -- Project
						,0 -- Department
						,0 -- SeqNo
						,PID.IDX_M_COA 
						,@_IDX_M_Partner
						,COA.COADesc
						,PID.RemarkDetail -- RemarkDetail
						,1 -- Original Currency
						,(ABS(PID.UntaxedAmount) - PID.DiscountAmount) * PID.Quantity -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,((ABS(PID.UntaxedAmount) - PID.DiscountAmount) * PID.Quantity) * 1 -- BDebetAmount
						,0 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_SalesInvoiceDetail PID WITH(NOLOCK)
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PID.IDX_M_COA = COA.IDX_M_COA
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND PID.UnitPrice < 0

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
						,PID.IDX_M_Project -- Project
						,0 -- Department
						,0 -- SeqNo
						,PID.IDX_M_COA 
						,@_IDX_M_Partner
						,COA.COADesc
						,PID.RemarkDetail -- RemarkDetail
						,1 -- Original Currency
						,0 -- ODebetAmount
						,(PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0-- BDebetAmount
						,((PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity) * 1 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_SalesInvoiceDetail PID WITH(NOLOCK)
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PID.IDX_M_COA = COA.IDX_M_COA
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND PID.UnitPrice > 0
				END
				ELSE
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
						,PID.IDX_M_Project -- Project
						,0 -- Department
						,0 -- SeqNo
						,PID.IDX_M_COA 
						,@_IDX_M_Partner
						,COA.COADesc
						,PID.RemarkDetail -- RemarkDetail
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
					FROM CM_T_SalesInvoiceDetail PID WITH(NOLOCK)
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PID.IDX_M_COA = COA.IDX_M_COA
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice > 0

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
						,PID.IDX_M_Project -- Project
						,0 -- Department
						,0 -- SeqNo
						,PID.IDX_M_COA 
						,@_IDX_M_Partner
						,COA.COADesc
						,PID.RemarkDetail -- RemarkDetail
						,1 -- Original Currency
						,(ABS(PID.UntaxedAmount) - PID.DiscountAmount) * PID.Quantity -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,((ABS(PID.UntaxedAmount) - PID.DiscountAmount) * PID.Quantity) * 1 -- BDebetAmount
						,0 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_SalesInvoiceDetail PID WITH(NOLOCK)
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PID.IDX_M_COA = COA.IDX_M_COA
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice < 0
				END

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
						,PID.IDX_M_Project -- Project
						,0 -- Department
						,0 -- SeqNo
						,@_TaxAccount 
						,@_IDX_M_Partner
						,COA.COADesc
						,PID.RemarkDetail + ' ' + ISNULL(@_TaxInvoiceNo,'') + ' ' + ISNULL(@_ReferenceNo,'') --RemarkDetail, jika table PID > 1 bakal error
						,1 -- Original Currency
						,0 -- ODebetAmount
						,PIT.TaxAmount * PID.Quantity --,@_TaxAmount -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0 -- BDebetAmount
						,PIT.TaxAmount * PID.Quantity --,(@_TaxAmount) * 1 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_SalesInvoiceTax PIT WITH(NOLOCK)
						LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PIT.TaxCOA = COA.IDX_M_COA
						LEFT JOIN CM_T_SalesInvoiceDetail PID WITH(NOLOCK) ON PIT.IDX_T_SalesInvoiceDetail = PID.IDX_T_SalesInvoiceDetail 
					WHERE PIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 0 AND COA.IDX_M_COA = @_TaxAccount
					--FROM GL_M_COA WITH(NOLOCK) WHERE IDX_M_COA = @_TaxAccount
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
						,PID.IDX_M_Project
						,0
						,0
						--,@_WithholdingTaxAccount 
						,PIT.TaxCOA
						,@_IDX_M_Partner 
						,COA.COADesc
						,PID.RemarkDetail + ' ' + ISNULL(@_TaxInvoiceNo,'') + ' ' + ISNULL(@_ReferenceNo,'') --RemarkDetail, jika table PID > 1 bakal error
						,1 -- Original Currency
						--,ABS(@_WithholdingTax) -- ODebetAmount 
						,ABS(PIT.TaxAmount * PID.Quantity) -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						--,(ABS(@_WithholdingTax) * 1) -- BDebetAmount
						,ABS(PIT.TaxAmount * PID.Quantity) -- BDebetAmount
						,0 -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A'
					FROM CM_T_SalesInvoiceTax PIT WITH(NOLOCK)
						LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PIT.TaxCOA = COA.IDX_M_COA
						LEFT JOIN CM_T_SalesInvoiceDetail PID WITH(NOLOCK) ON PIT.IDX_T_SalesInvoiceDetail = PID.IDX_T_SalesInvoiceDetail 
					WHERE PIT.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND MT.IsWithHoldingTax = 1 AND COA.IDX_M_COA = @_WithholdingTaxAccount
					--FROM GL_M_COA WITH(NOLOCK) WHERE IDX_M_COA = @_WithholdingTaxAccount
				END

				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesInvoiceHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesInvoiceHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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



