-- =======================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Payment
-- Mod			: 2020-09-21 by Anton --> Added IDX_M_Partner & PartnerDesc information on JH
--				  2020-10-02 by Anton --> Added Journal Closing Period Validation
-- =======================================================================================================================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_PaymentAllocation_Approve] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_Approve] 
	@IDX_T_PaymentAllocation			BIGINT,
	@ApproveRemark						VARCHAR(500),
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail	AS INT
			DECLARE @_CountLog		AS INT
			DECLARE @_SumHeader		AS DECIMAL(22,2)
			DECLARE @_SumDetail		AS DECIMAL(22,2)

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

			DECLARE @_ValidationDate DATE
			SELECT	@_ValidationDate = AllocationDate FROM CM_T_PaymentAllocation WITH(NOLOCK) WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation
			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@_ValidationDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_PaymentAllocation,'Journal Period Already Closed!')
			END	

			IF (SELECT ISNULL(COAAllocation,0) FROM CM_T_PaymentAllocation WITH(NOLOCK) WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Please check your COA Allocation !')
			END
			
			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				-- ==========================
				-- Generate Payment No
				-- ==========================
				DECLARE @_LastNumber AS INTEGER
				DECLARE @_Month AS VARCHAR(4)
				DECLARE @_Year AS VARCHAR(2)
				DECLARE @_PaymentNo AS VARCHAR(20)
				DECLARE @_PaymentDate AS DATE
				DECLARE @_IDX_M_DocumentType AS BIGINT
				DECLARE @_DocumentTypeID AS CHAR(3)
				DECLARE @_IDXFinancialPaymentHeader BIGINT

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Payment Header
				-- ==========================================

				--SELECT @_PaymentDate = PaymentDate, @_IDX_M_DocumentType = IDX_M_DocumentType 
				--FROM CM_T_PaymentAllocation
				--WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation

				--SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				--IF EXISTS(	SELECT TOP 1 PaymentID
				--			FROM CM_T_PaymentAllocationHeader 
				--			WHERE MONTH(PaymentDate) = MONTH(@_PaymentDate)
				--				AND YEAR(PaymentDate) = YEAR(@_PaymentDate) AND PaymentStatus = 'A'
				--			ORDER BY PaymentID DESC)
				--BEGIN

				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(PaymentID),4))
				--	FROM CM_T_PaymentAllocationHeader 
				--	WHERE MONTH(PaymentDate) = MONTH(@_PaymentDate)
				--			AND YEAR(PaymentDate) = YEAR(@_PaymentDate) AND PaymentStatus = 'A'
				--	ORDER BY PaymentID DESC

				--END			

				--SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_PaymentDate))
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_PaymentDate)),2)

				--/** Set Sales Order No **/
				--SET @_PaymentNo = @_DocumentTypeID + '-' 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status
				UPDATE CM_T_PaymentAllocation
				SET AllocationStatus = 'A', RemarkAllocation = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation
			
				-- ====================================================
				-- Create Journal Header - Financial Payment
				--
				-- Standard Journal :
				-- Bank, Cash or Deposit --> Debet
				-- Piutang Usaha --> Credit				
				-- ====================================================		
				
				DECLARE @_AllocationAmount					AS DECIMAL(22,2)				

				-- Untaxed Amount
				SELECT @_AllocationAmount = SUM(AllocationAmount)
				FROM CM_T_PaymentAllocation 
				WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation	

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_VoucherNo				AS VARCHAR(20)				
				DECLARE @_JournalDate			AS DATE
				DECLARE @_IDX_GL_M_JournalType	AS INT
				DECLARE @_JournalTypeID			AS CHAR(2)

				-- Journal Type 9 : Payment Allocation Journal
				SET @_IDX_GL_M_JournalType = 9

				SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WHERE IDX_M_JournalType = @_IDX_GL_M_JournalType

				SET @_LastNumber = 0

				SET @_JournalDate = GETDATE() 				

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
								AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = @_IDX_GL_M_JournalType
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
						AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = @_IDX_GL_M_JournalType
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

				/** Set Journal Voucher No **/
				SET @_VoucherNo = @_JournalTypeID + '-' + 
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
					,FRD.IDX_M_Branch					
					,@_IDX_GL_M_JournalType 
					,RA.IDX_M_Partner
					,1 -- Application ID, 1 = ASBS
					,@IDX_T_PaymentAllocation
					,AllocationID -- Reference No
					,@_VoucherNo -- Voucher No
					,GETDATE()					
					,'Payment Allocation Journal'
					,MP.PartnerName
					,'P'
					,GETDATE()
					,@UserID
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_PaymentAllocation RA WITH(NOLOCK)
					LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON RA.IDX_M_Partner = MP.IDX_M_Partner
					LEFT JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					LEFT JOIN CM_T_FinancialPaymentHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
				WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation

				DECLARE @IDX_T_JournalHeader AS BIGINT
				SET @IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())
				
				-- ====================================================
				-- Create Journal Detail - Bank, Cash Or Customer Deposit (Debet)
				-- DEBET : Detail record from table CM_T_FinancialPaymentDetail
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
					,RA.COAAllocation
					,RA.IDX_M_Partner
					,ISNULL(COA.COADesc,'')
					,FRD.RemarkDetail -- RemarkDetail
					,1 -- Original Currency
					,AllocationAmount -- ODebetAmount
					,0 -- OCreditAmount
					,1 -- Exchange Rate
					,1 -- Base Currency
					,AllocationAmount -- BDebetAmount
					,0 -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PaymentAllocation RA
					LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					LEFT JOIN GL_M_COA COA ON RA.COAAllocation = COA.IDX_M_COA
				WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation	


				-- ====================================================
				-- Create Journal Detail - (Credit)
				-- (CREDIT)
				-- Detail record from table CM_T_PaymentAllocation
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
					,FRD.COADetail 
					,RA.IDX_M_Partner
					,COA.COADesc
					,FRD.RemarkDetail
					,1 -- Original Currency
					,0 -- ODebetAmount
					,AllocationAmount -- OCreditAmount
					,1 -- Exchange Rate
					,1 -- Base Currency
					,0 -- BDebetAmount
					,AllocationAmount -- BCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM CM_T_PaymentAllocation RA
					LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					LEFT JOIN GL_M_COA COA ON FRD.COADetail = COA.IDX_M_COA
				WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation

				SELECT @_IDXFinancialPaymentHeader = FRH.IDX_T_FinancialPaymentHeader 
				FROM CM_T_PaymentAllocation RA WITH(NOLOCK)
					INNER JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					INNER JOIN CM_T_FinancialPaymentHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
				WHERE RA.IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation


				INSERT INTO @TableLog VALUES ('success', @_IDXFinancialPaymentHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @_IDXFinancialPaymentHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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


