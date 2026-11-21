-- ================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Receive
-- Mod			: 2020-07-13 Anton --> Added validation, status FR must approve first
--				  2020-07-21 Anton --> Finalize logic
--				  2020-09-08 Anton --> Change JD.RemarkDetail info from @ApproveRemark
--				  2020-09-21 Anton --> Added PartnerDesc Information on JH
--				  2020-09-24 Anton --> Added validation detail amount & insert journal with cut PPH cases
--				  2020-10-02 Anton --> Added Journal Closing Period Validation
-- ================================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_ReceiveAllocation_Approve] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_ReceiveAllocation_Approve] 
	@IDX_T_ReceiveAllocation			BIGINT,
	@ApproveRemark						VARCHAR(500),
	@ApproveDate						DATETIME,
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountLog			AS INT
			DECLARE @_AllocationDate	AS DATETIME

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

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@ApproveDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Journal Period Already Closed!')
			END	

			SELECT @_AllocationDate = AllocationDate
			FROM CM_T_ReceiveAllocation
			WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

			IF CONVERT(DATE,@_AllocationDate) > CONVERT(DATE,@ApproveDate)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Approval Allocation Date Must be Same or Above Than Allocation Date!')
			END

			IF (SELECT ISNULL(COAAllocation,0) FROM CM_T_ReceiveAllocation WITH(NOLOCK) WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation) = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Please check your COA Allocation !')
			END

			IF (
					SELECT FRH.ReceiveStatus
					FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
						INNER JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON RA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
						INNER JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader
					WHERE RA.IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation
				) = 'D'
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Approve Financial Receive Transaction First!')
			END

			DECLARE @_IDX_FR_Detail				BIGINT
			DECLARE @_AmountDetail				DECIMAL(22,2)
			DECLARE @_AmountReceiveAllocation	DECIMAL(22,2)
			DECLARE @_IDX_SIH					BIGINT

			SELECT @_IDX_FR_Detail			 = IDX_T_FinancialReceiveDetail FROM CM_T_ReceiveAllocation WITH(NOLOCK) WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation
			SELECT @_AmountDetail			 = ReceiveAmount FROM CM_T_FinancialReceiveDetail WITH(NOLOCK) WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail
			SELECT @_AmountReceiveAllocation = SUM(AllocationAmount) FROM CM_T_ReceiveAllocation WITH(NOLOCK) WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail
			SELECT @_IDX_SIH				 = IDX_DocumentNo FROM CM_T_ReceiveAllocation WITH(NOLOCK) WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

			IF @_AmountReceiveAllocation > @_AmountDetail
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Total Receive Allocation > Detail Amount!')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				-- ==========================
				-- Generate Receive No
				-- ==========================
				DECLARE @_LastNumber AS INTEGER
				DECLARE @_Month AS VARCHAR(4)
				DECLARE @_Year AS VARCHAR(2)
				DECLARE @_ReceiveNo AS VARCHAR(20)
				DECLARE @_ReceiveDate AS DATE
				DECLARE @_IDX_M_DocumentType AS BIGINT
				DECLARE @_DocumentTypeID AS CHAR(3)
				DECLARE @_IDXFinancialReceiveHeader BIGINT

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Receive Header
				-- ==========================================

				--SELECT @_ReceiveDate = ReceiveDate, @_IDX_M_DocumentType = IDX_M_DocumentType 
				--FROM CM_T_ReceiveAllocation
				--WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

				--SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				--IF EXISTS(	SELECT TOP 1 ReceiveID
				--			FROM CM_T_ReceiveAllocationHeader 
				--			WHERE MONTH(ReceiveDate) = MONTH(@_ReceiveDate)
				--				AND YEAR(ReceiveDate) = YEAR(@_ReceiveDate) AND ReceiveStatus = 'A'
				--			ORDER BY ReceiveID DESC)
				--BEGIN

				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
				--	FROM CM_T_ReceiveAllocationHeader 
				--	WHERE MONTH(ReceiveDate) = MONTH(@_ReceiveDate)
				--			AND YEAR(ReceiveDate) = YEAR(@_ReceiveDate) AND ReceiveStatus = 'A'
				--	ORDER BY ReceiveID DESC

				--END			

				--SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_ReceiveDate))
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_ReceiveDate)),2)

				--/** Set Sales Order No **/
				--SET @_ReceiveNo = @_DocumentTypeID + '-' 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- Update status

				-- ====================================================
				-- Create Journal Detail Allocation (If Any)
				-- (DEBET OR CREDIT)
				-- AR, Deposit, Unidentified, Other
				-- If COA Allocation <> COA Detail Then
				-- create allocation journal
				-- else
				-- do nothing
				-- ====================================================

				SELECT @_IDXFinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader 
				FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
					INNER JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					INNER JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
				WHERE RA.IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

				IF EXISTS
				(
					SELECT RA.IDX_T_FinancialReceiveDetail, RA.COAAllocation, FRD.COADetail, RA.AllocationAmount, FRD.ReceiveAmount 
					FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
						INNER JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
					WHERE RA.AllocationStatus = 'D' AND RA.IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation AND COAAllocation <> COADetail
				)
				BEGIN
					UPDATE CM_T_ReceiveAllocation
					SET AllocationStatus = 'A', RemarkAllocation = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation
			
					-- ====================================================
					-- Create Journal Header - Financial Receive
					--
					-- Standard Journal :
					-- Bank, Cash or Deposit --> Debet
					-- Piutang Usaha --> Credit				
					-- ====================================================		
				
					DECLARE @_AllocationAmount					AS DECIMAL(22,2)				

					-- Untaxed Amount
					SELECT @_AllocationAmount = SUM(AllocationAmount)
					FROM CM_T_ReceiveAllocation WITH(NOLOCK)
					WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation	

					-- =================================================
					-- Generate Voucher No
					-- =================================================
					DECLARE @_VoucherNo				AS VARCHAR(20)				
					DECLARE @_JournalDate			AS DATE
					DECLARE @_IDX_GL_M_JournalType	AS INT
					DECLARE @_JournalTypeID			AS CHAR(2)
					DECLARE @_BranchID				AS VARCHAR(3)
					DECLARE @_IDX_M_Branch			AS INT

					-- Journal Type 8 : Receive Allocation Journal
					SET @_IDX_GL_M_JournalType = 8

					SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WHERE IDX_M_JournalType = @_IDX_GL_M_JournalType

					SELECT @_IDX_M_Branch = FRH.IDX_M_Branch
					FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
						INNER JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON RA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
						INNER JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader
					WHERE RA.IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

					SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WHERE IDX_M_Branch = @_IDX_M_Branch

					SET @_LastNumber = 0

					SET @_JournalDate = @ApproveDate 				

					IF EXISTS(	SELECT TOP 1 VoucherNo
								FROM GL_T_JournalHeader WITH(NOLOCK)
								WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
									AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
									AND IDX_M_JournalType = @_IDX_GL_M_JournalType
									AND IDX_M_Branch = @_IDX_M_Branch
								ORDER BY VoucherNo DESC)
					BEGIN

						SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
						FROM GL_T_JournalHeader WITH(NOLOCK)
						WHERE MONTH(JournalDate) = MONTH(@_JournalDate)
							AND YEAR(JournalDate) = YEAR(@_JournalDate) AND PostingStatus = 'P'
							AND IDX_M_JournalType = @_IDX_GL_M_JournalType
							AND IDX_M_Branch = @_IDX_M_Branch
						ORDER BY VoucherNo DESC

					END			

					SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_JournalDate))
					SET @_Month = RIGHT(RTRIM(@_Month),2)

					SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_JournalDate)),2)

					/** Set Journal Voucher No **/
					SET @_VoucherNo = @_JournalTypeID + '-'
						+ @_BranchID + '-' 
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
					   ,[PostingNotes]
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
						,@IDX_T_ReceiveAllocation
						,@_VoucherNo -- Reference No
						,@_VoucherNo -- Voucher No
						,@_JournalDate				
						,'Receive Allocation Journal ' + AllocationID 
						,MP.PartnerName
						,'P'
						,@_JournalDate
						,@UserID
						,@ApproveRemark
						,0
						,0
						,'S' -- S = System Generated Journal
						,@UserID
						,GETDATE()
						,'A'
					FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
						LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON RA.IDX_M_Partner = MP.IDX_M_Partner
						LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
						LEFT JOIN CM_T_FinancialReceiveHeader FRH WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
					WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

					DECLARE @IDX_T_JournalHeader AS BIGINT
					SET @IDX_T_JournalHeader = (SELECT SCOPE_IDENTITY())
				
					-- ====================================================
					-- Create Journal Detail - Bank, Cash Or Customer Deposit (Debet)
					-- DEBET : Detail record from table CM_T_FinancialReceiveDetail
					-- ====================================================
					IF EXISTS (	SELECT AllocationAmount 
								FROM CM_T_ReceiveAllocation WITH(NOLOCK) 
								WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail AND IDX_DocumentNo = @_IDX_SIH AND AllocationAmount < 0 )
					BEGIN
						DECLARE @_AmountHeaderDebet DECIMAL(22,2)
						SELECT  @_AmountHeaderDebet = SUM(AllocationAmount) 
													  FROM CM_T_ReceiveAllocation WITH(NOLOCK) 
													  WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail AND IDX_DocumentNo = @_IDX_SIH

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
							,@ApproveRemark
							,1 -- Original Currency
							,@_AmountHeaderDebet -- ODebetAmount
							,0 -- OCreditAmount
							,1 -- Exchange Rate
							,1 -- Base Currency
							,@_AmountHeaderDebet -- BDebetAmount
							,0 -- BCreditAmount
							,@UserID
							,GETDATE()
							,'A' 
						FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
							LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
							LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON FRD.COADetail = COA.IDX_M_COA
						WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation

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
							,COA.COADesc
							,@ApproveRemark
							,1 -- Original Currency
							,ABS(RA.AllocationAmount) -- ODebetAmount
							,0 -- OCreditAmount
							,1 -- Exchange Rate
							,1 -- Base Currency
							,ABS(RA.AllocationAmount) -- BDebetAmount
							,0 -- BCreditAmount
							,@UserID
							,GETDATE()
							,'A' 
						FROM  CM_T_ReceiveAllocation RA WITH(NOLOCK)
							INNER JOIN GL_M_COA COA WITH(NOLOCK) ON RA.COAAllocation = COA.IDX_M_COA
						WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail AND AllocationAmount < 0 AND RA.IDX_DocumentNo = @_IDX_SIH

						UPDATE CM_T_ReceiveAllocation
						SET AllocationStatus = 'A', RemarkAllocation = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
						WHERE IDX_T_FinancialReceiveDetail = @_IDX_FR_Detail AND IDX_DocumentNo = @_IDX_SIH
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
							@IDX_T_JournalHeader
							,0
							,0
							,0
							,FRD.COADetail 
							,RA.IDX_M_Partner
							,COA.COADesc
							,@ApproveRemark
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
						FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
							LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
							LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON FRD.COADetail = COA.IDX_M_COA
						WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation
					END

					-- ====================================================
					-- Create Journal Detail - (Credit)
					-- (CREDIT)
					-- Detail record from table CM_T_ReceiveAllocation
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
						,@ApproveRemark -- RemarkDetail
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
					FROM CM_T_ReceiveAllocation RA WITH(NOLOCK)
						LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
						LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON RA.COAAllocation = COA.IDX_M_COA
					WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation	
				END
				ELSE
				BEGIN
					UPDATE CM_T_ReceiveAllocation
					SET AllocationStatus = 'A', RemarkAllocation = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_ReceiveAllocation = @IDX_T_ReceiveAllocation
				END
									

				INSERT INTO @TableLog VALUES ('success', @_IDXFinancialReceiveHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @_IDXFinancialReceiveHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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
