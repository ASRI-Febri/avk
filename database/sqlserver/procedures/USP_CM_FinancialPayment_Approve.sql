-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Payment
-- Mod			: 2020-07-30 by Anton --> change format paymentID
--				  2024-01-08 by Anton --> Approve not changing document no if existing <> DRAFT
--				  2024-01-10 by Anton --> Adjust generating voucher running number logic
-- ==========================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialPayment_Approve] 1,'Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Approve] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@ApprovalDate						VARCHAR(10),
	@ApproveRemark						VARCHAR(8000),
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail			AS INT
			DECLARE @_TotalAmount			AS DECIMAL(22,2)
			DECLARE @_DetailAmount			AS DECIMAL(22,2)
			DECLARE @_AllocationAmount		AS DECIMAL(22,2)
			DECLARE @_CountLog				AS INT

			DECLARE @GlobalDateTime			DATETIME = SYSDATETIME()
			DECLARE @IDX_Partner			BIGINT

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

			SELECT @_CountDetail = COUNT(IDX_T_FinancialPaymentDetail), @_DetailAmount = SUM(PaymentAmount) 
			FROM CM_T_FinancialPaymentDetail WITH(NOLOCK)
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			SELECT @_TotalAmount = PaymentAmount FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			SELECT @_AllocationAmount = SUM(PA.AllocationAmount)
			FROM CM_T_PaymentAllocation PA WITH(NOLOCK)
			LEFT JOIN CM_T_FinancialPaymentDetail FPD WITH(NOLOCK) ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
			LEFT JOIN CM_T_FinancialPaymentHeader FPH WITH(NOLOCK) ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
			WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			IF @_TotalAmount = NULL SET @_TotalAmount = 0
			IF @_AllocationAmount = NULL SET @_AllocationAmount = 0

			
			SELECT @IDX_Partner = IDX_M_Partner 
			FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) 
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			IF @IDX_Partner = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Please Select Partner First')
			END

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'No Data in Detail Transaction')
			END	
			
			IF @_TotalAmount <> @_DetailAmount
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Total Amount <> Detail Amount')
			END				

			--comment validasi ini jika ada kasus pembayaran lebih besar dr invoice disebabkan oleh selisih kurs
			IF @_TotalAmount < @_AllocationAmount
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Total Amount Cannot < Allocation Amount')
			END

			-- Kunci bulan approval hanya untuk nomor berformat bulanan (...-YYMM-NNNN).
			-- Nomor FP1-<id> tidak memuat bulan sehingga boleh di-approve ulang
			-- sesuai tanggal transaksi walau ApprovalDate lama dari bulan lain.
			IF EXISTS (SELECT 1 FROM CM_T_FinancialPaymentHeader WITH(NOLOCK)
						WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader AND ApprovalDate IS NOT NULL
							AND PaymentID LIKE '%-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			BEGIN
				IF (SELECT MONTH(ApprovalDate) FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader) <> MONTH(@ApprovalDate)
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
				-- Generate Receive No
				-- ==========================
				DECLARE @_IDX_M_Company			AS INT
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

				SELECT	@_PaymentDate = @ApprovalDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_Branch = IDX_M_Branch,
						@_IDX_FA = IDX_M_FinancialAccount, @_IDX_M_Company = IDX_M_Company
				FROM	CM_T_FinancialPaymentHeader WITH(NOLOCK)
				WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

				--SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_DocumentTypeID = RTRIM(FA.FinancialAccountID) 
				FROM CM_T_FinancialPaymentHeader FPH WITH(NOLOCK)
				INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FPH.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
				WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader												

				SELECT @_BranchID = RTRIM(BranchID) 
				FROM GN_M_Branch WITH(NOLOCK) 
				WHERE IDX_M_Branch = @_IDX_M_Branch
								
				IF EXISTS(	
					SELECT TOP 1 PaymentID FROM
					(
						SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
						WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
							AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
						UNION
						SELECT PaymentID 
						FROM CM_T_FinancialPaymentHeader 
						WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
							AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
					) a 
					ORDER BY RIGHT(PaymentID,9) DESC)							
				BEGIN
					

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(PaymentID),4)) FROM
					(
						SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
							WHERE 
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
								AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
						UNION
						SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
							WHERE
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_PaymentDate)
								AND YEAR(ApprovalDate) = YEAR(@_PaymentDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
					) a
					ORDER BY RIGHT(PaymentID,9) DESC				
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
					+ @_BranchID + '-' 
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
							FPH.PaymentStatus = 'A', 
							FPH.ApprovalDate = @ApprovalDate, 
							FPH.ApprovedBy = @UserID, 
							FPH.ApprovalRemark = @ApproveRemark, 
							FPH.DModified = @GlobalDateTime, 
							FPH.UModified = @UserID 
					FROM	CM_T_FinancialPaymentHeader  FPH
					WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				END
				ELSE
				BEGIN
					UPDATE	FPH
						SET FPH.PaymentStatus = 'A', 
							FPH.ApprovalDate = @ApprovalDate, 
							FPH.ApprovedBy = @UserID, 
							FPH.ApprovalRemark = @ApproveRemark, 
							FPH.DModified = @GlobalDateTime, 
							FPH.UModified = @UserID 
					FROM	CM_T_FinancialPaymentHeader  FPH
					WHERE	IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
				END

				-- =======================================================================
				-- Approval Financial Receive Allocation
				-- =======================================================================	
				UPDATE	PA
					SET	PA.AllocationStatus = 'A',
						PA.DModified = @GlobalDateTime,
						PA.UModified = @UserID
				FROM	CM_T_PaymentAllocation PA 
				INNER JOIN CM_T_FinancialPaymentDetail FPD WITH (NOLOCK) ON PA.IDX_T_FinancialPaymentDetail=FPD.IDX_T_FinancialPaymentDetail
				WHERE	FPD.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader
									
				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[CM_T_FinancialPaymentLog]
					([IDX_T_FinancialPaymentHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_FinancialPaymentHeader, 'Approval', @ApprovalDate, @ApproveRemark, @UserID, GETDATE(), 'A'	
				
				-- =======================================================================
				-- GENERATE JOURNAL
				-- =======================================================================
				DECLARE @_JournalResult		SMALLINT

				EXEC USP_CM_FinancialPayment_CreateJournal @IDX_T_FinancialPaymentHeader, @UserID, @_JournalResult OUTPUT

				IF @_JournalResult <> 1
				BEGIN
					INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, 'Create journal failed!')
				END

				-- =====================================================================================================	
				-- OUTPUT
				-- =====================================================================================================
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