-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Validate Internal Transfer
-- =============================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_InternalTransfer_Validate] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_InternalTransfer_Validate] 
	@IDX_T_InternalTransferHeader		BIGINT,
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

			SELECT @_CountDetail = COUNT(IDX_T_InternalTransferDetail), @_DetailAmount = SUM(TransferAmount) 
			FROM CM_T_InternalTransferDetail
			WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

			SELECT @_TotalAmount = TotalTransferAmount FROM CM_T_InternalTransferHeader WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

			--IF @_CountDetail = 0
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'No Data in Detail Transaction')
			--END					
			
			IF EXISTS(SELECT IDX_T_InternalTransferHeader FROM CM_T_InternalTransferHeader WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND TransferStatus = 'F')
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_InternalTransferHeader,'This transaction already validate!')
			END			

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
								
				-- ==========================
				-- Generate Payment No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_TransferID			AS VARCHAR(20)
				DECLARE @_TransferDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(3)

				--SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Internal Transfer Header
				-- ==========================================

				--SELECT @_PaymentDate = PaymentDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner 
				--FROM CM_T_InternalTransferHeader 
				--WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

				--SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				--IF EXISTS(	SELECT TOP 1 PaymentID
				--			FROM CM_T_InternalTransferHeader 
				--			WHERE MONTH(PaymentDate) = MONTH(@_PaymentDate)
				--				AND YEAR(PaymentDate) = YEAR(@_PaymentDate) AND PaymentStatus = 'A'
				--			ORDER BY PaymentID DESC)
				--BEGIN

				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(PaymentID),4))
				--	FROM CM_T_InternalTransferHeader 
				--	WHERE MONTH(PaymentDate) = MONTH(@_PaymentDate)
				--			AND YEAR(PaymentDate) = YEAR(@_PaymentDate) AND PaymentStatus = 'A'
				--	ORDER BY PaymentID DESC

				--END			

				--SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_PaymentDate))
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_PaymentDate)),2)

				--/** Set Sales Order No **/
				--SET @_PaymentID = @_DocumentTypeID + '-' 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				UPDATE CM_T_InternalTransferHeader 
				SET 
					TransferStatus = 'F',ValidationDate = @ValidationDate, ValidationBy = @UserID, 					
					ValidationRemark = @ValidateRemark, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader
			
				-- ====================================================
				-- Create Journal Header - Internal Transfer
				--
				-- Standard Journal :
				-- POS SILANG --> DEBET
				-- SOURCE ACCOUNT --> CREDIT							
				-- DESTINATION ACCOUNT --> DEBET
				-- BIAYA --> DEBET
				-- POS SILANG --> CREDIT
				-- ====================================================		
								

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_IDX_M_Branch			AS INT
				DECLARE @_BranchID				AS VARCHAR(20)
				DECLARE @_VoucherNo				AS VARCHAR(20)				
				DECLARE @_JournalDate			AS DATE
				DECLARE @_IDX_GL_M_JournalType	AS INT
				DECLARE @_JournalTypeID			AS CHAR(2)
				DECLARE @_AccountTemp			AS BIGINT -- POS SILANG
				DECLARE @_AccountTempID			AS VARCHAR(150) -- POS SILANG
				DECLARE @_AccountTempDesc		AS VARCHAR(150) -- POS SILANG
				DECLARE @_TotalTransfer			AS DECIMAL(22,2)
				DECLARE @_TotalFee				AS DECIMAL(22,2)

				SELECT @_IDX_M_Branch = IDX_M_Branch, @_TransferID = TransferID, @_IDX_M_DocumentType = IDX_M_DocumentType, @_TotalTransfer = TotalTransferAmount 
				FROM CM_T_InternalTransferHeader 
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader
				
				SELECT @_AccountTemp = ARAccount FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_AccountTempID = COAID, @_AccountTempDesc = COADesc FROM GL_M_COA WHERE IDX_M_COA = @_AccountTemp

				SELECT @_TotalFee = SUM(TransferAmount) FROM CM_T_InternalTransferDetail WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

				IF @_TotalFee IS NULL
					SET @_TotalFee = 0

				-- Journal Type 10 : Internal Transfer Journal
				SET @_IDX_GL_M_JournalType = 10

				SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WHERE IDX_M_JournalType = @_IDX_GL_M_JournalType

				SELECT @_BranchID = BranchID FROM GN_M_Branch WHERE IDX_M_Branch = @_IDX_M_Branch

				SET @_LastNumber = 0

				SET @_JournalDate = @ValidationDate 				

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE MONTH(PostingDate) = MONTH(@ValidationDate)
								AND YEAR(PostingDate) = YEAR(@ValidationDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = @_IDX_GL_M_JournalType
								AND IDX_M_Branch = @_IDX_M_Branch
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(PostingDate) = MONTH(@ValidationDate)
						AND YEAR(PostingDate) = YEAR(@ValidationDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = @_IDX_GL_M_JournalType
						AND IDX_M_Branch = @_IDX_M_Branch
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@ValidationDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@ValidationDate)),2)

				/** Set Journal Voucher No **/
				SET @_VoucherNo = @_JournalTypeID + '-' + @_BranchID + '-'
					+ @_Month
					+ @_Year  + '-' 
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- =================================================
				-- INSERT JOURNAL HEADER
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
					,@_IDX_GL_M_JournalType
					,0
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_InternalTransferHeader
					,@_TransferID -- Reference No
					,@_VoucherNo -- Voucher No
					,@ValidationDate					
					,'Internal Transfer Journal'
					,''
					,'P'
					,@ValidationDate
					,@UserID
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_InternalTransferHeader
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader

				DECLARE @IDX_T_JournalHeader AS BIGINT
				SET @IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ====================================================
				-- DEBET
				-- POS SILANG				
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
					,@_AccountTemp
					,0
					,@_AccountTempDesc
					,'' -- RemarkDetail
					,1 -- Original Currency
					,@_TotalTransfer -- ODebetAmount
					,0 -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,(@_TotalTransfer * 1) -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 

				-- ====================================================
				-- CREDIT
				-- SOURCE ACCOUNT
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
					,COA.IDX_M_COA
					,0
					,COA.COADesc
					,'' -- RemarkDetail
					,1 -- Original Currency
					,0 -- ODebetAmount
					,@_TotalTransfer -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,(@_TotalTransfer * 1) -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_InternalTransferHeader ITH
					LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = ITH.SourceAccount
					LEFT JOIN GL_M_COA COA ON MFA.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader 
				
				-- ====================================================
				-- DEBET
				-- FROM DESTINATION ACCOUNT				
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
					,COA.IDX_M_COA
					,0
					,ISNULL(COA.COADesc,'')
					,ITH.RemarkHeader -- RemarkDetail
					,1 -- Original Currency
					,(@_TotalTransfer - @_TotalFee) -- ODebetAmount
					,0 -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,(@_TotalTransfer - @_TotalFee) -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_InternalTransferHeader ITH
					LEFT JOIN CM_M_FinancialAccount MFA ON MFA.IDX_M_FinancialAccount = ITH.DestinationAccount
					LEFT JOIN GL_M_COA COA ON MFA.IDX_M_COA = COA.IDX_M_COA
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader 

				-- ====================================================
				-- DEBET
				-- OTHER FEE
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
					,ITD.COADetail 
					,0
					,ISNULL(COA.COADesc,'')
					,ITD.RemarkDetail -- RemarkDetail
					,1 -- Original Currency
					,TransferAmount -- ODebetAmount
					,0 -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,TransferAmount -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_InternalTransferDetail ITD
					LEFT JOIN GL_M_COA COA ON ITD.COADetail = COA.IDX_M_COA
				WHERE IDX_T_InternalTransferHeader = @IDX_T_InternalTransferHeader AND ITD.TransferAmount > 0
								
				-- ====================================================
				-- CREDIT
				-- POS SILANG				
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
					,@_AccountTemp
					,0
					,@_AccountTempDesc
					,'' -- RemarkDetail
					,1 -- Original Currency
					,0-- ODebetAmount
					,(@_TotalTransfer) -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,(@_TotalTransfer) -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 							

				INSERT INTO @TableLog VALUES ('success', @IDX_T_InternalTransferHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_InternalTransferHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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


