-- =======================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Payment
-- Modified		: 2019-05-15 by Anton --> tambah filter IDX_Branch utk dpt lastnumber column voucherNo di table JH
--				  2020-01-31 by Anton --> added validation validate date not allowed < handover date
--				  2020-09-21 by Anton --> Added PartnerDesc information on JH
--				  2020-10-02 by Anton --> Added Journal Closing Period Validation
--				  2021-12-13 by Anton --> Added logic for CashflowID
--				  2023-07-27 by Anton --> Added VoucherNoManual on JournalHeader
--				  2024-07-04 by Anton --> Add validation COA on table Payment Allocation must be same with COA Detail on table Payment Detail
--				  2024-07-08 by Anton --> Adjust (bypass) approve transaction feature become posting/validate transaction (generate PaymentID + posting journal)
-- =======================================================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_Validate] 35,'2019-06-20','Testing','GBB463501','Testing Validate', '1305276'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Validate] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@ValidationDate						VARCHAR(20),
	@VoucherNoManual					VARCHAR(50),
	@PDCNo								VARCHAR(500),
	@ValidateRemark						VARCHAR(500),
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
			DECLARE @_TotalAmount AS DECIMAL(22,2)
			DECLARE @_DetailAmount AS DECIMAL(22,2)
			DECLARE @_CountLog AS INT
			DECLARE @GlobalDateTime DATETIME = SYSDATETIME()
			DECLARE @_LastValidationDate	DATE
			DECLARE	@_LastIDX_T_JournalHeader BIGINT


			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID AS VARCHAR(20)
			--SET @_FormID = 'CM-FIRC-005' -- Approval Receiving Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@ValidationDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Journal Period Already Closed!')
			END	

			SELECT @_CountDetail = COUNT(IDX_T_FinancialPaymentDetail), @_DetailAmount = SUM(PaymentAmount) 
			FROM CM_T_FinancialPaymentDetail
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			SELECT @_TotalAmount = PaymentAmount FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			DECLARE @HandoverDate DATE
			DECLARE @TransactionDate DATE

			SELECT @HandoverDate = HandoverDate, @TransactionDate = PaymentDate FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			IF @ValidationDate < @TransactionDate
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Validation Date cannot earlier than Transaction Date')
			END	

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'No Data in Detail Transaction')
			END	
			
			IF @_TotalAmount <> @_DetailAmount
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Total Amount <> Detail Allocation Amount')
			END		
			
			IF EXISTS(SELECT IDX_T_FinancialPaymentHeader FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND PaymentStatus = 'F')
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'This payment already validate!')
			END			

			IF EXISTS (SELECT 1 FROM CM_T_FinancialPaymentDetail WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND COADetail = 0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Please Check Detail COA on Invoice Item')
			END

			IF EXISTS ( SELECT 1
						FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
							INNER JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
							INNER JOIN CM_T_PaymentAllocation PA WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
						WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND FPD.COADetail <> PA.COAAllocation )
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Every Selected COA Payment Allocation Detail Must be Same With Detail COA Transaction Item!')
			END

			IF (SELECT ApprovalDate FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader) IS NOT NULL
			BEGIN
				IF (SELECT MONTH(ApprovalDate) FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader) <> MONTH(@ValidationDate)
				BEGIN
					INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'VoucherNo Already Exist, Cannot Change Month Approval. Please VOID TRANSACTION!')
				END
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				DECLARE @_IDX_M_Partner			BIGINT
				-- ==========================
				-- Generate Payment No
				-- ==========================
				DECLARE @_IDX_M_Branch			AS INT
				DECLARE @_BranchID				AS VARCHAR(20)
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_PaymentID				AS VARCHAR(20)
				DECLARE @_PaymentDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(5)
				DECLARE @_IDX_FA				AS BIGINT

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Payment Header
				-- ==========================================

				SELECT	@_PaymentDate = @ValidationDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_Branch = IDX_M_Branch,
						@_IDX_FA = IDX_M_FinancialAccount
				FROM	CM_T_FinancialPaymentHeader WITH(NOLOCK)
				WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				SELECT @_DocumentTypeID =	RTRIM(FA.FinancialAccountID) 
							FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
								INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FPH.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
							WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader												

				SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @_IDX_M_Branch

				IF EXISTS(	
							SELECT TOP 1 ReceiveID FROM
							(
								SELECT ReceiveID FROM CM_T_FinancialReceiveHeader 
									WHERE 
										IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
										AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(ReceiveID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
								UNION
								SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
									WHERE
										IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
										AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
							) a
							ORDER BY RIGHT(ReceiveID,9) DESC )

				BEGIN
					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4)) FROM
					(
						SELECT ReceiveID FROM CM_T_FinancialReceiveHeader 
							WHERE 
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
								AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(ReceiveID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
						UNION
						SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
							WHERE
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
								AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
					) a
					ORDER BY RIGHT(ReceiveID,9) DESC
				END		
				ELSE
				BEGIN
					SET @_LastNumber = '00000'
				END	

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_PaymentDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_PaymentDate)),2)

				/** Set Sales Order No **/
				SET @_PaymentID = RTRIM(@_DocumentTypeID) + '-'
					+ @_BranchID + '-' --Added anton 20190220 
					+ @_Year 
					+ @_Month + '-'
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				DECLARE @CurrentTransNo VARCHAR(50)
				SET @CurrentTransNo = (SELECT PaymentID FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader)

				-- Update status
				IF LEFT(@CurrentTransNo,5) = 'DRAFT'
				BEGIN
					UPDATE	FPH
						SET FPH.PaymentID = @_PaymentID,
							FPH.PaymentStatus = 'F', 
							FPH.ApprovalDate = @ValidationDate, 
							FPH.ApprovedBy = @UserID, 
							FPH.ApprovalRemark = @ValidateRemark, 
							FPH.ValidationDate = @ValidationDate, 
							FPH.ValidateBy = @UserID, 
							FPH.VoucherNoManual = @VoucherNoManual, 
							FPH.PDCNo = @PDCNo, 
							FPH.ValidationRemark = @ValidateRemark, 
							FPH.DModified = @GlobalDateTime, 
							FPH.UModified = @UserID 
					FROM	CM_T_FinancialPaymentHeader  FPH
					WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				END
				ELSE
				BEGIN
					UPDATE	FPH
						SET FPH.PaymentStatus = 'F', 
							FPH.ApprovalDate = @ValidationDate, 
							FPH.ApprovedBy = @UserID, 
							FPH.ApprovalRemark = @ValidateRemark, 
							FPH.ValidationDate = @ValidationDate, 
							FPH.ValidateBy = @UserID, 
							FPH.VoucherNoManual = @VoucherNoManual, 
							FPH.PDCNo = @PDCNo, 
							FPH.ValidationRemark = @ValidateRemark, 
							FPH.DModified = @GlobalDateTime, 
							FPH.UModified = @UserID 
					FROM	CM_T_FinancialPaymentHeader  FPH
					WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				END

				UPDATE	PA
					SET	PA.AllocationStatus = 'A',
						PA.DModified = @GlobalDateTime,
						PA.UModified = @UserID
				FROM	CM_T_PaymentAllocation PA 
				INNER JOIN CM_T_FinancialPaymentDetail FPD WITH (NOLOCK) ON PA.IDX_T_FinancialPaymentDetail=FPD.IDX_T_FinancialPaymentDetail
				WHERE	FPD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
			
				INSERT INTO [dbo].[CM_T_FinancialPaymentLog]
					([IDX_T_FinancialPaymentHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_FinancialPaymentHeader, 'Approval', @ValidationDate, @ValidateRemark, @UserID, GETDATE(), 'A'
				-- ====================================================
				-- Create Journal Header - Sales Receive
				--
				-- Standard Journal :
				-- Hutang / AP --> Debet
				-- Bank --> Credit				
				-- ====================================================		
								

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_IDX_M_Branch2			AS INT
				DECLARE @_BranchID2				AS VARCHAR(20)
				DECLARE @_VoucherNo				AS VARCHAR(20)				
				DECLARE @_JournalDate			AS DATE
				DECLARE @_IDX_GL_M_JournalType	AS INT
				DECLARE @_JournalTypeID			AS CHAR(2)
				DECLARE @_VoucherNoManual		AS VARCHAR(50)

				SELECT @_IDX_M_Branch2 = IDX_M_Branch, @_PaymentID = PaymentID, @_VoucherNoManual = VoucherNoManual, @_IDX_M_Partner = IDX_M_Partner
				FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				-- Journal Type 5 : Financial Payment Journal
				SET @_IDX_GL_M_JournalType = 7

				SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WHERE IDX_M_JournalType = @_IDX_GL_M_JournalType

				SELECT @_BranchID2 = BranchID FROM GN_M_Branch WHERE IDX_M_Branch = @_IDX_M_Branch2

				SET @_LastNumber = 0

				SET @_JournalDate = @ValidationDate 				

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE MONTH(PostingDate) = MONTH(@ValidationDate)
								AND YEAR(PostingDate) = YEAR(@ValidationDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = @_IDX_GL_M_JournalType
								AND IDX_M_Branch = @_IDX_M_Branch2
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(PostingDate) = MONTH(@ValidationDate)
						AND YEAR(PostingDate) = YEAR(@ValidationDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = @_IDX_GL_M_JournalType
						AND IDX_M_Branch = @_IDX_M_Branch2
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ValidationDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ValidationDate)),2)

				/** Set Journal Voucher No **/
				SET @_VoucherNo = @_JournalTypeID + '-' + @_BranchID2 + '-' 
				+ @_Month
				+ @_Year + '-' 
				+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				--SET @_VoucherNo = (SELECT PaymentID FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader)
				
				--IF EXISTS (
				--	SELECT	1 
				--	FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
				--	INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
				--	INNER JOIN GL_T_JournalHeaderLog JHL WITH (NOLOCK) ON JH.IDX_T_JournalHeader=JHL.IDX_T_JournalHeader
				--	WHERE	FPH.RecordStatus='A'
				--	AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				--	AND		JHL.LogType='Unposting'
				--)
				--BEGIN

				--	SELECT	@_LastValidationDate = JH.PostingDate,
				--			@_LastIDX_T_JournalHeader = JH.IDX_T_JournalHeader 
				--	FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
				--	INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
				--	INNER JOIN GL_T_JournalHeaderLog JHL WITH (NOLOCK) ON JH.IDX_T_JournalHeader=JHL.IDX_T_JournalHeader
				--	WHERE	FPH.RecordStatus='A'
				--	AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				--	AND		JHL.LogType='Unposting'


				--	IF YEAR(CONVERT(DATE,@ValidationDate)) * 100 +  MONTH(CONVERT(DATE,@ValidationDate)) = YEAR(CONVERT(DATE,@_LastValidationDate)) * 100 +  MONTH(CONVERT(DATE,@_LastValidationDate))
				--	BEGIN
				--		-- Aktifkan kembali Journal lama
				--		UPDATE	JH
				--			SET	JH.RecordStatus='A',
				--				JH.PostingDate=@ValidationDate,
				--				JH.DModified=@GlobalDateTime,
				--				JH.UModified=@UserID
				--		FROM	GL_T_JournalHeader JH
				--		WHERE	IDX_T_JournalHeader = @_LastIDX_T_JournalHeader												
				--	END
				--	ELSE
				--	BEGIN
				--		UPDATE	JH
				--			SET	JH.RecordStatus='A',
				--				JH.VoucherNo=@_VoucherNo,
				--				JH.PostingDate=@ValidationDate,
				--				JH.JournalDate=@ValidationDate,
				--				JH.DModified=@GlobalDateTime,
				--				JH.UModified=@UserID
				--		FROM	GL_T_JournalHeader JH
				--		WHERE	IDX_T_JournalHeader = @_LastIDX_T_JournalHeader		
				--	END
				--END

				-- =================================================
				-- Insert Journal Header
				-- =================================================

				--IF NOT EXISTS (
				--	SELECT	1 
				--	FROM	CM_T_FinancialPaymentHeader FPH WITH (NOLOCK)
				--	INNER JOIN GL_T_JournalHeader JH WITH (NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader=JH.IDX_ReferenceNo AND FPH.PaymentID=JH.ReferenceNo
				--	INNER JOIN GL_T_JournalHeaderLog JHL WITH (NOLOCK) ON JH.IDX_T_JournalHeader=JHL.IDX_T_JournalHeader
				--	WHERE	FPH.RecordStatus='A'
				--	AND		FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				--	AND		JHL.LogType='Unposting'
				--)
				--BEGIN
					INSERT INTO [dbo].[GL_T_JournalHeader]
						([IDX_M_Company]
						,[IDX_M_Branch]				  
						,[IDX_M_JournalType]
						,[IDX_M_Partner]
						,[ApplicationID]
						,[IDX_ReferenceNo]
						,[ReferenceNo]
						,[VoucherNo]
						,[VoucherNoManual]
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
						,@_IDX_GL_M_JournalType -- 5 = SJ / Sales Journal
						,FPH.IDX_M_Partner
						,1 -- Application ID, 1 = ASBS
						,@IDX_T_FinancialPaymentHeader
						,@_PaymentID -- Reference No
						,@_VoucherNo -- Voucher No
						,@_VoucherNoManual
						,@ValidationDate				
						,UPPER(FPH.RemarkHeader)
						,MP.PartnerName
						,'P'
						,@ValidationDate
						,@UserID
						,0
						,0
						,'S' -- S = System Generated Journal
						,@UserID
						,GETDATE()
						,'A'
					FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
						LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON FPH.IDX_M_Partner = MP.IDX_M_Partner
					WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

					DECLARE @IDX_T_JournalHeader AS BIGINT
					SET @IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())
				
				--END
				--ELSE
				--BEGIN
				--	SET @IDX_T_JournalHeader=@_LastIDX_T_JournalHeader
				--END
				-- ====================================================
				-- Create Journal Detail - Hutang Usaha / AP (Debet)
				-- Payment Amount > 0 (DEBET)
				-- ====================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				   ([IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[JournalSeqNo]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
				   ,[IDX_M_CashflowID]
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
					@IDX_T_JournalHeader
					,FRD.IDX_M_Project
					,0
					,0
					,FRD.COADetail 
					,@_IDX_M_Partner
					,ISNULL(CF.IDX_M_CashflowID,0) --CASHFLOW
					,ISNULL(COA.COADesc,'')
					,FRD.RemarkDetail -- RemarkDetail
					,1 -- Original Currency
					,FRD.PaymentAmount -- ODebetAmount
					,0 -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,(FRD.PaymentAmount * 1) -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_FinancialPaymentDetail FRD
					LEFT JOIN GL_M_COA COA ON FRD.COADetail = COA.IDX_M_COA
					LEFT JOIN CM_M_CashflowID CF ON COA.IDX_M_CashflowOut = CF.IDX_M_CashflowID
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND FRD.PaymentAmount > 0

				-- ====================================================
				-- Create Journal Detail - Hutang Usaha / AP (Credit)
				-- Payment Amount < 0 (CREDIT)
				-- Contra Balance, biasanya untuk pajak pengurang atau witholding tax
				-- ====================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				   ([IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[JournalSeqNo]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
				   ,[IDX_M_CashflowID]
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
					@IDX_T_JournalHeader
					,FRD.IDX_M_Project
					,0
					,0
					,FRD.COADetail 
					,@_IDX_M_Partner
					,ISNULL(CF.IDX_M_CashflowID,0) --CASHFLOW
					,ISNULL(COA.COADesc,'')
					,FRD.RemarkDetail -- RemarkDetail
					,1 -- Original Currency
					,0 -- ODebetAmount
					,ABS(FRD.PaymentAmount) -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,(ABS(FRD.PaymentAmount) * 1) -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_FinancialPaymentDetail FRD
					LEFT JOIN GL_M_COA COA ON FRD.COADetail = COA.IDX_M_COA
					LEFT JOIN CM_M_CashflowID CF ON COA.IDX_M_CashflowIn = CF.IDX_M_CashflowID
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND FRD.PaymentAmount < 0

				-- ====================================================
				-- Create Journal Detail - Bank, Cash Or Customer Deposit (Credit)
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
					@IDX_T_JournalHeader
					,0
					,0
					,0
					,MFA.IDX_M_COA 					
					,FRH.IDX_M_Partner
					,COA.COADesc
					,FRH.RemarkHeader -- RemarkDetail
					,1 -- Original Currency
					,0 -- ODebetAmount
					,(@_DetailAmount) -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,(@_DetailAmount * 1) -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_FinancialPaymentHeader FRH
					LEFT JOIN CM_M_FinancialAccount MFA ON FRH.IDX_M_FinancialAccount = MFA.IDX_M_FinancialAccount
					LEFT JOIN GL_M_COA COA ON MFA.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader					
				
				
				-- ====================================================
				-- Create Journal Detail Allocation (If Any)
				-- (DEBET OR CREDIT)
				-- AR, Deposit, Unidentified, Other
				-- If COA Allocation <> COA Detail Then
				-- create allocation journal
				-- else
				-- do nothing
				-- ====================================================
				
				IF EXISTS(	SELECT RA.IDX_T_FinancialPaymentDetail, RA.COAAllocation, FPD.COADetail, RA.AllocationAmount, FPD.PaymentAmount 
							FROM CM_T_PaymentAllocation RA 
							INNER JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
							WHERE RA.AllocationStatus = 'A' AND IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND COAAllocation <> COADetail)
				BEGIN
					
					-- =======================================================
					-- DEBET
					-- COA from financial payment detail allocation
					-- =======================================================
					INSERT INTO [dbo].[GL_T_JournalDetail]
					   ([IDX_T_JournalHeader]
					   ,[IDX_M_Project]
					   ,[IDX_M_Department]
					   ,[JournalSeqNo]
					   ,[IDX_M_COA]
					   ,[IDX_M_Partner]
					   ,[IDX_M_CashflowID]
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
						 @IDX_T_JournalHeader
						,FPD.IDX_M_Project
						,0
						,0
						,RA.COAAllocation
						,RA.IDX_M_Partner
						,ISNULL(CF.IDX_M_CashflowID,0) --CASHFLOW
						,ISNULL(COA.COADesc,'')
						,RA.RemarkAllocation
						,1 -- Original Currency
						,RA.AllocationAmount -- ODebetAmount
						,0 -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,RA.AllocationAmount -- Base Debet Amount
						,0 -- Base Credit Amount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_PaymentAllocation RA 
					INNER JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					INNER JOIN GL_M_COA COA ON COA.IDX_M_COA = RA.COAAllocation
					LEFT JOIN CM_M_CashflowID CF ON COA.IDX_M_CashflowOut = CF.IDX_M_CashflowID
					WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND COAAllocation <> COADetail AND COAAllocation <> 0

					-- =======================================================
					-- CREDIT
					-- COA from financial payment detail
					-- =======================================================
					INSERT INTO [dbo].[GL_T_JournalDetail]
					   ([IDX_T_JournalHeader]
					   ,[IDX_M_Project]
					   ,[IDX_M_Department]
					   ,[JournalSeqNo]
					   ,[IDX_M_COA]
					   ,[IDX_M_Partner]
					   ,[IDX_M_CashflowID]
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
						 @IDX_T_JournalHeader
						,FPD.IDX_M_Project
						,0
						,0
						,FPD.COADetail
						,RA.IDX_M_Partner
						,ISNULL(CF.IDX_M_CashflowID,0) --CASHFLOW
						,ISNULL(COA.COADesc,'')
						,RA.RemarkAllocation
						,1 -- Original Currency
						,0 -- ODebetAmount
						,RA.AllocationAmount -- OCreditAmount
						,1 -- Exchange Rate
						,1 -- Base Currency
						,0 
						,RA.AllocationAmount
						,@UserID
						,GETDATE()
						,'A' 
					FROM CM_T_PaymentAllocation RA 
						INNER JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
						INNER JOIN GL_M_COA COA ON COA.IDX_M_COA = FPD.COADetail
						LEFT JOIN CM_M_CashflowID CF ON COA.IDX_M_CashflowIn = CF.IDX_M_CashflowID
					WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND COAAllocation <> COADetail AND COAAllocation <> 0

				END
					
									

				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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

