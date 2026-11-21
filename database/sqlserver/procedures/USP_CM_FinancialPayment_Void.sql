-- =======================================================================================================================================
-- Author		: Anton
-- Create date	: 2023-01-10
-- Description	: Void Financial Payment
-- Modified		: 
-- =======================================================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_Void] 18, '2026-03-24', 'Double input', 'it_febry'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Void] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@VoidDate							DATE,
	@VoidReason							VARCHAR(1000),
	@UserID								VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			--DECLARE @_CountDetail AS INT
			--DECLARE @_TotalAmount AS DECIMAL(22,2)
			--DECLARE @_DetailAmount AS DECIMAL(22,2)
			DECLARE @_CountLog AS INT
			DECLARE @GlobalDateTime DATETIME = SYSDATETIME()
			--DECLARE @_LastValidationDate	DATE
			--DECLARE	@_LastIDX_T_JournalHeader BIGINT

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

			DECLARE @ValidateDate DATE
			SET @ValidateDate = (SELECT ValidationDate FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader)
			
			IF @VoidDate < @ValidateDate
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Void Date < Validate Date!')
			END				

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				-- Update status
				UPDATE	FPH 
					SET FPH.PaymentStatus = 'V',
						FPH.VoidDate = @VoidDate, 
						FPH.VoidReason = @VoidReason, 
						FPH.VoidBy = @UserID,
						FPH.DModified = @GlobalDateTime, 
						FPH.UModified = @UserID 
				FROM	CM_T_FinancialPaymentHeader FPH
				WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader	
				
				IF EXISTS ( SELECT 1 
							FROM CM_T_FinancialPaymentHeader FRH WITH(NOLOCK)
								INNER JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
								INNER JOIN CM_T_PaymentAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
							WHERE FRH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader)
				BEGIN
					DELETE RA
					FROM CM_T_FinancialPaymentHeader FRH WITH(NOLOCK)
						INNER JOIN CM_T_FinancialPaymentDetail FRD WITH(NOLOCK) ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
						INNER JOIN CM_T_PaymentAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
					WHERE FRH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				END
				
				-- ==========================
				-- Generate Payment No
				-- ==========================
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_PaymentID				AS VARCHAR(20)
				DECLARE @_VoidID				AS VARCHAR(20)
				DECLARE @_PaymentDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(3)
				DECLARE @_IDX_M_Branch			AS INT
				DECLARE @_BranchID				AS VARCHAR(20)
				DECLARE @_VoucherNo				AS VARCHAR(20)				
				DECLARE @_JournalDate			AS DATE
				DECLARE @_IDX_GL_M_JournalType	AS INT
				DECLARE @_JournalTypeID			AS CHAR(2)
				DECLARE @_VoucherNoManual		AS VARCHAR(50)
				DECLARE @_IDX_M_Partner			BIGINT

				SELECT @_IDX_M_Branch = IDX_M_Branch, @_PaymentID = PaymentID, @_VoucherNoManual = VoucherNoManual, @_IDX_M_Partner = IDX_M_Partner
				FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				-- Journal Type 12 : Financial Payment Void Journal
				SET @_IDX_GL_M_JournalType = 12

				SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WITH(NOLOCK) WHERE IDX_M_JournalType = @_IDX_GL_M_JournalType
				SELECT @_BranchID = BranchID FROM GN_M_Branch WITH(NOLOCK) WHERE IDX_M_Branch = @_IDX_M_Branch

				SET @_LastNumber = 0
				SET @_JournalDate = @VoidDate 				

				/** Set Journal Voucher No **/
				IF EXISTS(	
							SELECT TOP 1 VoucherNo FROM
							(
								SELECT VoucherNo 
								FROM GL_T_JournalHeader WITH(NOLOCK)
								WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(PostingDate) = MONTH(@VoidDate)
									  AND YEAR(@VoidDate) = YEAR(@VoidDate) AND LEN(VoucherNo) = '16' AND IDX_M_JournalType = @_IDX_GL_M_JournalType
							) a
							ORDER BY RIGHT(VoucherNo,9) DESC
				)
				BEGIN
							SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4)) FROM
							(
								SELECT VoucherNo 
								FROM GL_T_JournalHeader WITH(NOLOCK)
								WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(PostingDate) = MONTH(@VoidDate)
									  AND YEAR(@VoidDate) = YEAR(@VoidDate) AND LEN(VoucherNo) = '16' AND IDX_M_JournalType = @_IDX_GL_M_JournalType
							) a
							ORDER BY RIGHT(VoucherNo,9) DESC
				END
				ELSE
				BEGIN
					SET @_LastNumber = '00000'
				END

				SET @_Month		= '00' + CONVERT(VARCHAR,MONTH(@VoidDate))
				SET @_Month		= RIGHT(RTRIM(@VoidDate),2)
				SET @_Year		= RIGHT(CONVERT(VARCHAR,YEAR(@VoidDate)),2)
				SET @_VoidID	=	RTRIM(@_JournalTypeID) + '-'
									+ @_BranchID + '-' --Added anton 20190220 
									+ @_Year 
									+ @_Month + '-'
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
						,@_IDX_GL_M_JournalType -- 12 = PV / Financial Payment Void Journal
						,FPH.IDX_M_Partner
						,1 -- Application ID, 1 = ASBS
						,@IDX_T_FinancialPaymentHeader
						,@_PaymentID -- Reference No
						,@_VoidID -- Voucher No
						,@_VoucherNoManual
						,@VoidDate				
						,'VOID TRANSACTION - ' + FPH.RemarkHeader
						,MP.PartnerName
						,'P'
						,@VoidDate
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
				
				-- =================================================
				-- Insert Journal Detail
				-- =================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				   ([IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
				   ,[IDX_M_CashflowID]
				   ,[JournalSeqNo]
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
					,JD.IDX_M_Project
					,0
					,JD.IDX_M_COA
					,@_IDX_M_Partner
					,0 --CASHFLOW
				    ,JD.JournalSeqNo
					,JD.COADescription
					,'VOID TRANSACTION - ' + JD.RemarkDetail -- RemarkDetail
					,1 -- Original Currency
					,CASE WHEN JD.ODebetAmount = 0 THEN JD.OCreditAmount ELSE 0 END -- ODebetAmount
					,CASE WHEN JD.OCreditAmount = 0 THEN JD.ODebetAmount ELSE 0 END -- OCreditAmount					
					,1 -- Exchange Rate
					,1 -- Base Currency
					,CASE WHEN JD.BDebetAmount = 0 THEN JD.BCreditAmount ELSE 0 END -- ODebetAmount
					,CASE WHEN JD.BCreditAmount = 0 THEN JD.BDebetAmount ELSE 0 END -- OCreditAmount
					,@UserID
					,GETDATE()
					,'A' 
				FROM GL_T_JournalHeader JH WITH(NOLOCK)
					INNER JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
				WHERE	JH.IDX_M_JournalType = 7 --FP
						AND IDX_ReferenceNo = @IDX_T_FinancialPaymentHeader AND PostingStatus = 'P' AND JH.RecordStatus = 'A' AND JD.RecordStatus = 'A'

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

