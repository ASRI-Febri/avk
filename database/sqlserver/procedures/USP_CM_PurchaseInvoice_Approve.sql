-- ===============================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Purchase Invoice
-- Mod			:	Anton 2019-02-20 --> Adjustment kode voucher 
--					Anton 2019-05-15 --> tambah filter IDX_Branch utk dpt lastnumber column voucherNo di table JH
--					Anton 2020-01-20 --> change value @_JournalDate with --> @ApprovalDate
--					Anton 2020-03-23 --> Added validation checking for IDX_M_COA on CM_T_PurchaseInvoiceDetail
--					Anton 2020-03-27 --> Added validation checking amount PI not allowed greater than amount PO
--					Anton 2020-05-14 --> added condition on insert to journal detail statement when condition for unit price and tax amount < 0
--					Anton 2020-05-27 --> added validation on "Checklist Tax" status must be checked first before transaction can be approved
--					Anton 2020-06-04 --> added column FakturPajak information from PIH into inserted journal detail - PPN
--					Anton 2020-06-18 --> adjustment calculation for rundown PPN/PPH
--					Anton 2020-06-19 --> adjustment calculation for rundown PPH when value < 0
--					Anton 2020-09-21 --> Added PartnerDesc information on JH
--					Anton 2020-09-25 --> Adjust logic amount PI cannot more than amount PO/SPK
--					Anton 2020-10-02 --> Added Journal Closing Period Validation
--					Anton 2021-09-20 --> Adjust logic total amount PI cannot more than amount PO/SPK
--					Anton 2024-01-08 --> Approve not changing document no if existing <> DRAFT
-- ===============================================================================================================================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_PurchaseInvoice_Approve] 148,'2020-12-01','Trial','1305276'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_Approve] 
	@IDX_T_PurchaseInvoiceHeader		BIGINT,
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

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@ApprovalDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Journal Period Already Closed!')
			END	

			-- =======================================
			-- Validate and check detail item
			-- =======================================
			SELECT @_CountDetail = COUNT(IDX_T_PurchaseInvoiceDetail) 
			FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
			WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'No Data in Detail Transaction')
			END		
			
			-- =======================================
			-- Validate and check current invoice status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseInvoiceDetail
						FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK) 
						WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND IDX_M_COA = 0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Detail Item Must Have COA Information!')
			END	

			-- =======================================
			-- Validate and check current tax checklist
			-- =======================================
			--IF EXISTS(	SELECT 1
			--			FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK)
			--			WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND IsTaxChecked <> '1')
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Please Checked The Checklist Tax First!')
			--END	

			-- =======================================
			-- Validate and check tax amount
			-- =======================================
			IF EXISTS(	SELECT 1
						FROM CM_T_PurchaseInvoiceDetail WITH(NOLOCK)
						WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND TaxAmount < 0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Please Input PPH Tax Type on Add Additional Tax Section!')
			END	

			-- =======================================================================
			-- Validate and check amount PI not allowed greater than amount PO
			-- =======================================================================

			DECLARE @_IDX_PurchaseOrder BIGINT
			SELECT	@_IDX_PurchaseOrder = IDX_ReferenceNo FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

			IF EXISTS(	SELECT PIH.IDX_T_PurchaseInvoiceHeader 
						FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
						WHERE PIH.IDX_ReferenceNo = @_IDX_PurchaseOrder	)
			
			BEGIN
				DECLARE @AmountPO DECIMAL(20,3)
				DECLARE @AmountPI_Approved DECIMAL(20,3)
				DECLARE @AmountPI_WillBeApproved DECIMAL(20,3)
				DECLARE @AmountPI DECIMAL(20,3)
			
				SELECT @AmountPO = FLOOR(SUM((POD.Quantity*(POD.UntaxedAmount-POD.DiscountAmount))+(POD.Quantity*POD.TaxAmount)))
				FROM PR_T_PurchaseOrder PO WITH(NOLOCK)
					INNER JOIN PR_T_PurchaseOrderDetail POD WITH(NOLOCK) ON PO.IDX_T_PurchaseOrder = POD.IDX_T_PurchaseOrder
				WHERE PO.IDX_T_PurchaseOrder = @_IDX_PurchaseOrder
			
				SELECT @AmountPI_Approved = ISNULL(FLOOR(SUM((PID.Quantity*(PID.UntaxedAmount-PID.DiscountAmount))+(PID.Quantity*PID.TaxAmount))),0)
				FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) 
					INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				WHERE PIH.IDX_ReferenceNo = @_IDX_PurchaseOrder AND PIH.InvoiceStatus = 'A'

				SELECT @AmountPI_WillBeApproved = ISNULL(FLOOR(SUM((PID.Quantity*(PID.UntaxedAmount-PID.DiscountAmount))+(PID.Quantity*PID.TaxAmount))),0)
				FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) 
					INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				SET @AmountPI = @AmountPI_WillBeApproved + @AmountPI_Approved
			
				--SELECT @AmountPO AS AmountPO 
				--SELECT @AmountPI AS AmountPI 
				--SELECT @AmountPI - @AmountPO AS DELTA
			
				IF @AmountPI > @AmountPO
				BEGIN
					INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Total Amount Invoice (' + CONVERT(VARCHAR,@AmountPI) + ') > Total Amount PO/SPK (' + CONVERT(VARCHAR,@AmountPO) + ') !')
					--SELECT 'Total Amount Invoice (' + CONVERT(VARCHAR,@AmountPI) + ') > Total Amount PO/SPK (' + CONVERT(VARCHAR,@AmountPO) + ') !'
				END
			END

			--IF EXISTS(	SELECT PIH.IDX_T_PurchaseInvoiceHeader 
			--			FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			--				INNER JOIN PR_T_PurchaseOrder PO WITH(NOLOCK) ON PIH.IDX_ReferenceNo = PO.IDX_T_PurchaseOrder
			--			WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND PO.POStatus = 'F')
			--BEGIN
			--	DECLARE @AmountPO DECIMAL(20,3)
			--	DECLARE @AmountPI DECIMAL(20,3)

			--	SELECT @AmountPO = SUM((POD.Quantity*(POD.UntaxedAmount-POD.DiscountAmount))+(POD.Quantity*POD.TaxAmount))
			--	FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
			--		INNER JOIN PR_T_PurchaseOrder PO WITH(NOLOCK) ON PIH.IDX_ReferenceNo = PO.IDX_T_PurchaseOrder
			--		INNER JOIN PR_T_PurchaseOrderDetail POD WITH(NOLOCK) ON PO.IDX_T_PurchaseOrder = POD.IDX_T_PurchaseOrder
			--	WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND PO.POStatus = 'F'

			--	SELECT @AmountPI = SUM((PID.Quantity*(PID.UntaxedAmount-PID.DiscountAmount))+(PID.Quantity*PID.TaxAmount))
			--	FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK) 
			--		INNER JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
			--	WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

			--	IF @AmountPI > @AmountPO
			--	BEGIN
			--		INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'Amount invoice cannot greater than amount PO/SPK!')
			--	END
			--END	
			
			-- =======================================
			-- Validate and check current invoice status
			-- =======================================
			IF EXISTS(	SELECT IDX_T_PurchaseInvoiceHeader 
						FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK)
						WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND InvoiceStatus IN ('A','F'))
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'This invoice already approved!')
			END		

			-- =======================================
			-- Validate and check journal period
			-- =======================================
			IF EXISTS (	SELECT IDX_M_FiscalPeriod 
						FROM GL_M_FiscalPeriod WITH(NOLOCK) 
						WHERE @ApprovalDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'GL period is already closed!')
			END

			IF (SELECT ApprovedDate FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) IS NOT NULL
			BEGIN
				IF (SELECT MONTH(ApprovedDate) FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) <> MONTH(@ApprovalDate)
				BEGIN
					INSERT INTO @TableLog VALUES ('error',@IDX_T_PurchaseInvoiceHeader,'VoucherNo Already Exist, Cannot Change Month Approval. Please Void Transaction!')
				END
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
				--DECLARE @_DocumentTypeID		AS CHAR(5) --mod anton 20190220
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_BranchID				AS VARCHAR(3)
				DECLARE @_IDX_M_Branch			AS INT

				SET @_LastNumber = 0

				SELECT @_InvoiceDate = InvoiceDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType,  @_BranchID = IDX_M_Branch, @_IDX_M_Branch = IDX_M_Branch
				FROM CM_T_PurchaseInvoiceHeader 
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WHERE IDX_M_Branch = @_BranchID --Added anton 20190219 

				IF EXISTS(	SELECT TOP 1 InvoiceNo
							FROM CM_T_PurchaseInvoiceHeader 
							WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
								AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND LEFT(InvoiceNo,5) <> 'DRAFT'
							ORDER BY RIGHT(InvoiceNo,9) DESC) --MOD Anton 2019-03-19
							--ORDER BY InvoiceNo DESC)
				BEGIN
					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(InvoiceNo),4))
					FROM CM_T_PurchaseInvoiceHeader 
					WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovedDate) = MONTH(@ApprovalDate)
							AND YEAR(ApprovedDate) = YEAR(@ApprovalDate) AND LEFT(InvoiceNo,5) <> 'DRAFT'
					ORDER BY RIGHT(InvoiceNo,9) DESC --MOD Anton 2019-03-19
					--ORDER BY InvoiceNo DESC
				END
				--Added area anton 20190220
				ELSE
				BEGIN
					SET @_LastNumber = '00000'
				END
				--End added area anton 20190220

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ApprovalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ApprovalDate)),2)

				/** Set Sales Order No **/
				SET @_InvoiceNo = @_DocumentTypeID + '-' 
					+ @_BranchID + '-' --Added anton 20190220
					+ @_Year 
					+ @_Month + '-'
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status

				DECLARE @CurrentTransNo VARCHAR(50)
				SET @CurrentTransNo = (SELECT InvoiceNo FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader)

				IF LEFT(@CurrentTransNo,5) = 'DRAFT'
				BEGIN
					UPDATE CM_T_PurchaseInvoiceHeader 
					SET InvoiceNo = @_InvoiceNo,
						InvoiceStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
						ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
				END
				ELSE
				BEGIN
					UPDATE CM_T_PurchaseInvoiceHeader 
					SET InvoiceStatus = 'A', ApprovedDate = @ApprovalDate, ApproveBy = @UserID, 
						ApproveRemark = @ApprovalRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
				END

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
				--	'PurchaseInvoice',RIH.InvoiceDate, 
				--	RIH.IDX_T_PurchaseInvoiceHeader, RIH.RemarkHeader,							
				--	RID.Quantity, RID.UntaxedAmount, (RID.Quantity * RID.UntaxedAmount),	
				--	RID.Quantity, RID.UntaxedAmount, (RID.Quantity * RID.UntaxedAmount)					
				--FROM CM_T_PurchaseInvoiceD RID
				--	LEFT JOIN CM_T_PurchaseInvoiceH RIH ON RID.IDX_T_PurchaseInvoiceHeader = RIH.IDX_T_PurchaseInvoiceHeader
				--	LEFT JOIN IN_M_Item MI ON RID.IDX_IN_M_Item = MI.IDX_IN_M_Item
				--	LEFT JOIN IN_M_UOM MU ON MI.IDX_IN_M_UOM = MU.IDX_IN_M_UOM 
				--WHERE RIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				-- Update Base Price (Last Purchase Price) in table IN_M_Item
				--UPDATE IN_M_Item SET BasePrice = A.UntaxedAmount
				--FROM (SELECT * FROM CM_T_PurchaseInvoiceD WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader) A
				--	INNER JOIN IN_M_Item ON A.IDX_IN_M_Item = IN_M_Item.IDX_IN_M_Item				 
											
			
				-- ====================================================
				-- Create Journal Header - Purchase Invoice
				--
				-- Standard Journal :
				-- Biaya atau Persediaan --> Debet
				-- Hutang Usaha --> Credit
				-- ====================================================			

				
				DECLARE @_UntaxedAmount					AS DECIMAL(22,2)
				DECLARE @_AccountPayable				AS DECIMAL(22,2)
				DECLARE @_TaxAmount						AS DECIMAL(22,2)
				DECLARE @_TaxAccount					AS BIGINT
				DECLARE @_WithholdingTax				AS DECIMAL(22,2)
				DECLARE @_WithholdingTaxAccount			AS BIGINT
				DECLARE @_IDX_ProjectPPN				AS BIGINT = 0
				--DECLARE @_IDX_ProjectPPH				AS BIGINT = 0

				-- Untaxed Amount
				SELECT @_UntaxedAmount = SUM((UntaxedAmount - DiscountAmount) * Quantity)
				FROM CM_T_PurchaseInvoiceDetail 
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader	
				
				-- PPN
				IF EXISTS(	SELECT PIT.IDX_T_PurchaseInvoiceDetail 
							FROM CM_T_PurchaseInvoiceTax PIT
								LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax								
							WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 0)
				BEGIN
					--SELECT @_TaxAccount = PIT.TaxCOA, @_TaxAmount = SUM(PIT.TaxAmount * PID.Quantity) --comment by Anton 2020-06-18, replaced with below statement
					SELECT @_TaxAccount = PIT.TaxCOA, @_TaxAmount = CONVERT(DECIMAL(22,2),FLOOR(SUM(PIT.TaxAmount * PID.Quantity))), @_IDX_ProjectPPN = PID.IDX_M_Project
					FROM CM_T_PurchaseInvoiceTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIT.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
					WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 0
					GROUP BY PIT.IDX_M_Tax, TaxCOA, PID.IDX_M_Project
				END
				ELSE
				BEGIN
					SET @_TaxAccount = 0
					SET @_TaxAmount = 0
				END					

				-- PPh
				IF EXISTS(SELECT IDX_T_PurchaseInvoiceDetail 
							FROM CM_T_PurchaseInvoiceTax PIT
							LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 1)
				BEGIN
					--SELECT @_WithholdingTaxAccount = PIT.TaxCOA, @_WithholdingTax = SUM(PIT.TaxAmount * PID.Quantity) --comment by Anton 2020-06-19, replaced with below statement
					SELECT @_WithholdingTaxAccount = PIT.TaxCOA, @_WithholdingTax = CONVERT(DECIMAL(22,2),FLOOR(SUM(ABS(PIT.TaxAmount) * PID.Quantity))*-1) --, @_IDX_ProjectPPH = PID.IDX_M_Project
					FROM CM_T_PurchaseInvoiceTax PIT
						LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIT.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
					WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 1
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
								AND IDX_M_JournalType = 2
								AND IDX_M_Branch = @_IDX_M_Branch
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
						AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = 2
						AND IDX_M_Branch = @_IDX_M_Branch
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

				/** Set Voucher No **/
				SET @_VoucherNo = 'PJ' + '-' + @_BranchID + '-'
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
					,2 -- 2 = PJ / Purchase Journal
					,PIH.IDX_M_Partner
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_PurchaseInvoiceHeader
					,CASE WHEN LEFT(@CurrentTransNo,5) = 'DRAFT' THEN @_InvoiceNo ELSE @CurrentTransNo END
					,@_VoucherNo
					,@_JournalDate				
					,UPPER(PIH.RemarkHeader)
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
				FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
					LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON PIH.IDX_M_Partner = MP.IDX_M_Partner
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				DECLARE @IDX_GL_T_JournalHeader AS BIGINT
				SET @IDX_GL_T_JournalHeader = (SELECT SCOPE_IDENTITY())
				
				-- ====================================================
				-- Create Journal Detail - Biaya / Persediaan
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
					,PID.IDX_M_Project -- Project
					,0 -- Department
					,0 -- SeqNo
					,PID.IDX_M_COA 
					,@_IDX_M_Partner
					,COA.COADesc
					,RemarkDetail
					,1 -- Original Currency
					--,(PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity -- ODebetAmount
					,CASE WHEN PID.UntaxedAmount > 0 THEN (PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity ELSE 0 END AS ODebetAmount --condition for unit price < 0
					--,0 -- OCreditAmount
					,CASE WHEN PID.UntaxedAmount > 0 THEN 0 ELSE ((PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity) * -1  END AS OCreditAmount --condition for unit price < 0
					,1 -- Exchange Rate
					,1 -- Base Currency
					--,(PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity -- BDebetAmount
					,CASE WHEN PID.UntaxedAmount > 0 THEN (PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity ELSE 0 END AS BDebetAmount --condition for unit price < 0
					--,0 -- BCreditAmount
					,CASE WHEN PID.UntaxedAmount > 0 THEN 0 ELSE ((PID.UntaxedAmount - PID.DiscountAmount) * PID.Quantity) * -1  END AS BCreditAmount --condition for unit price < 0
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PurchaseInvoiceDetail PID
					LEFT JOIN GL_M_COA COA ON PID.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				-- ====================================================
				-- Create Journal Detail - PPN
				-- ====================================================

				IF ABS(@_TaxAmount) > 0
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
						,PIT.TaxCOA 
						,@_IDX_M_Partner
						,COA.COADesc
						,COA.COADesc + ' ' + UPPER(PID.RemarkDetail) AS RemarkDetail
						,1 -- Original Currency
						--,@_TaxAmount -- ODebetAmount
						,CASE WHEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) > 0 THEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) ELSE 0 END AS ODebetAmount -- ODebetAmount
						--,0 -- OCreditAmount
						,CASE WHEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) > 0 THEN 0 ELSE FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) * -1 END AS OCreditAmount -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						--,(@_TaxAmount) * 1 -- BDebetAmount
						,CASE WHEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) > 0 THEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) ELSE 0 END AS BDebetAmount -- BDebetAmount
						--,0 -- BCreditAmount
						,CASE WHEN FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) > 0 THEN 0 ELSE FLOOR(SUM(PIT.TaxAmount * PID.Quantity)) * -1 END AS BCreditAmount -- BCreditAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_PurchaseInvoiceTax PIT WITH(NOLOCK)
						LEFT JOIN GL_M_Tax MT WITH(NOLOCK) ON PIT.IDX_M_Tax = MT.IDX_M_Tax
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON MT.COAOut = COA.IDX_M_COA
						LEFT JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIT.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
					WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 0
					GROUP BY PIT.IDX_M_Tax, TaxCOA, PID.IDX_M_Project, COA.COADesc, PID.RemarkDetail
					--FROM CM_T_PurchaseInvoiceTax PIT
					--	LEFT JOIN GL_M_Tax MT ON PIT.IDX_M_Tax = MT.IDX_M_Tax
					--	LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIT.IDX_T_PurchaseInvoiceDetail = PID.IDX_T_PurchaseInvoiceDetail 
					--WHERE PIT.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 0
					--GROUP BY PIT.IDX_M_Tax, TaxCOA, PID.IDX_M_Project
					--FROM CM_T_PurchaseInvoiceDetail PID
					--	LEFT JOIN GL_M_COA COA ON PID.IDX_M_COA = COA.IDX_M_COA
					--WHERE IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND PID.IDX_M_Tax = 1
				END

				-- ====================================================
				-- Create Journal Detail - Hutang Usaha
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
					,UPPER(RemarkHeader)
					,1 -- Original Currency
					,0 -- ODebetAmount
					,(SUM(PID.Quantity * (PID.UntaxedAmount + PID.TaxAmount - PID.DiscountAmount))) - ABS(@_WithholdingTax) -- OCreditAmount
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,(SUM(PID.Quantity * (PID.UntaxedAmount + PID.TaxAmount - PID.DiscountAmount))) - ABS(@_WithholdingTax) -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
					LEFT JOIN CM_T_PurchaseInvoiceDetail PID WITH(NOLOCK) ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
					LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON PIH.COAHeader = COA.IDX_M_COA
				WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader
				GROUP BY PIH.COAHeader, COA.COADesc, RemarkHeader
				--FROM CM_T_PurchaseInvoiceHeader PIH WITH(NOLOCK)
				--	LEFT JOIN CM_T_PurchaseInvoiceDetail PID ON PIH.IDX_T_PurchaseInvoiceHeader = PID.IDX_T_PurchaseInvoiceHeader
				--	LEFT JOIN GL_M_COA COA ON PIH.COAHeader = COA.IDX_M_COA
				--WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader

				-- ====================================================
				-- Create Journal Detail - PPh 23 (Purchase Tax)
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
						,TaxCOA 
						,@_IDX_M_Partner 
						,COADesc
						,PID.RemarkDetail
						,1 -- Original Currency
						,0 -- ODebetAmount
						--,ABS(@_WithholdingTax) -- OCreditAmount
						,CONVERT(DECIMAL(22,2),FLOOR(ABS(PIT.TaxAmount * PID.Quantity))) -- OCreditAmount --akomodir jika line di PIT lebih dari 1 data & rundown pajak
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0 -- BDebetAmount
						--,(ABS(@_WithholdingTax) * 1) -- BCreditAmount
						,CONVERT(DECIMAL(22,2),FLOOR((ABS(PIT.TaxAmount * PID.Quantity) * 1))) -- BCreditAmount --akomodir jika line di PIT lebih dari 1 data & rundown pajak
						,@UserID
						,GETDATE()
						,'A'
					FROM CM_T_PurchaseInvoiceDetail PID
						--LEFT JOIN GL_M_COA COA ON PID.IDX_M_COA = COA.IDX_M_COA
						LEFT JOIN CM_T_PurchaseInvoiceTax PIT on PID.IDX_T_PurchaseInvoiceDetail = PIT.IDX_T_PurchaseInvoiceDetail
						LEFT JOIN GL_M_Tax MT on PIT.IDX_M_Tax = MT.IDX_M_Tax 
						LEFT JOIN GL_M_COA COA ON PIT.TaxCOA = COA.IDX_M_COA
					WHERE PID.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader AND MT.IsWithHoldingTax = 1
				END

				INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseInvoiceHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_PurchaseInvoiceHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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



