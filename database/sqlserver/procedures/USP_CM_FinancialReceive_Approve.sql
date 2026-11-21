-- ===============================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Approval Financial Receive
-- Modified		: 2019-05-15 by Anton --> tambah filter IDX_Branch utk dpt lastnumber column voucherNo di table JH
--				  2020-08-03 by Anton --> change format receiveID
--				  2020-09-21 by Anton --> Added PartnerDesc information on JH
--				  2020-10-02 by Anton --> Added Journal Closing Period Validation
--				  2021-12-13 by Anton --> Added logic for CashflowID
--				  2023-07-27 by Anton --> Added VoucherNoManual on JournalHeader
--				  2024-01-08 by Anton --> Approve not changing document no if existing <> DRAFT
--				  2024-01-10 by Anton --> Adjust generate voucher running number logic
--				  2024-07-04 by Anton --> Add validation COA on table Receive Allocation must be same with COA Detail on table Receive Detail
-- ===============================================================================================================


/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_FinancialReceive_Approve] 1,'2019-02-28','Ok, Test Hutang dan Journal','admin'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceive_Approve] 
	@IDX_T_FinancialReceiveHeader		BIGINT,
	@ApprovalDate						VARCHAR(10),
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

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@ApprovalDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Journal Period Already Closed!')
			END	

			SELECT @_CountDetail = COUNT(IDX_T_FinancialReceiveDetail), @_SumDetail = SUM(ReceiveAmount) 
			FROM CM_T_FinancialReceiveDetail
			WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

			SELECT @_SumHeader = ReceiveAmount
			FROM CM_T_FinancialReceiveHeader
			WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

			DECLARE @IDX_Partner BIGINT
			SELECT @IDX_Partner = IDX_M_Partner FROM CM_T_FinancialReceiveHeader WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

			IF @IDX_Partner = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Please Select Partner First')
			END

			IF @_SumHeader <> @_SumDetail
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Total receive ' +  CONVERT(VARCHAR,@_SumHeader) + ' <> total detail ' + CONVERT(VARCHAR,@_SumDetail))
			END

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'No Data in Detail Transaction')
			END			
			
			-- Kunci bulan approval hanya untuk nomor berformat bulanan (...-YYMM-NNNN).
			-- Nomor FR1-<id> tidak memuat bulan sehingga boleh di-approve ulang
			-- sesuai tanggal transaksi walau ApprovalDate lama dari bulan lain.
			IF EXISTS (SELECT 1 FROM CM_T_FinancialReceiveHeader WITH(NOLOCK)
						WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND ApprovalDate IS NOT NULL
							AND ReceiveID LIKE '%-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
			BEGIN
				IF (SELECT MONTH(ApprovalDate) 
					FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) 
					WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader) <> MONTH(@ApprovalDate)
				BEGIN
					INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'VoucherNo Already Exist, Cannot Change Month Approval. Please Void Transaction!')
				END
			END

			IF EXISTS (SELECT 1 FROM CM_T_FinancialReceiveDetail WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND COADetail = 0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Please Check Detail COA on Invoice Item')
			END

			IF EXISTS ( SELECT 1
						FROM CM_T_FinancialReceiveHeader FRH WITH(NOLOCK)
							INNER JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
							INNER JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
						WHERE FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader AND FRD.COADetail <> RA.COAAllocation )
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialReceiveHeader,'Every Selected COA Receive Allocation Detail Must be Same With Detail COA Transaction Item!')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
				
				-- ==========================
				-- Generate Receive No
				-- ==========================
				DECLARE @_IDX_M_Branch			AS INT
				DECLARE @_BranchID				AS VARCHAR(20)
				DECLARE @_LastNumber			AS INTEGER
				DECLARE @_Month					AS VARCHAR(4)
				DECLARE @_Year					AS VARCHAR(2)
				DECLARE @_ReceiveNo				AS VARCHAR(20)
				DECLARE @_ReceiveDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS VARCHAR(5)
				DECLARE @_VoucherNoManual		AS VARCHAR(50)
				DECLARE @_IDX_FA				AS BIGINT

				SET @_LastNumber = 0

				-- ==========================================
				-- Get Data From Financial Receive Header
				-- ==========================================

				SELECT	@_ReceiveDate = @ApprovalDate, @_IDX_M_DocumentType = IDX_M_DocumentType, @_BranchID = IDX_M_Branch, @_IDX_M_Branch = IDX_M_Branch,
						@_VoucherNoManual = VoucherNoManual, @_IDX_FA = IDX_M_FinancialAccount
				FROM CM_T_FinancialReceiveHeader 
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				SELECT @_DocumentTypeID = RTRIM(DocumentTypeID) FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @_IDX_M_DocumentType
				SELECT @_DocumentTypeID =	RTRIM(FA.FinancialAccountID) 
											FROM CM_T_FinancialReceiveHeader FRH WITH(NOLOCK)
												INNER JOIN CM_M_FinancialAccount FA WITH(NOLOCK) ON FRH.IDX_M_FinancialAccount = FA.IDX_M_FinancialAccount
											WHERE FRH.IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				SELECT @_BranchID = RTRIM(BranchID) FROM GN_M_Branch WHERE IDX_M_Branch = @_BranchID

				IF EXISTS(	
							
							SELECT TOP 1 ReceiveID FROM
							(
								SELECT ReceiveID FROM CM_T_FinancialReceiveHeader 
									WHERE 
										IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
										AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(ReceiveID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
								UNION
								SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
									WHERE
										IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
										AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
							) a
							ORDER BY RIGHT(ReceiveID,9) DESC

							--SELECT TOP 1 ReceiveID
							--FROM CM_T_FinancialReceiveHeader 
							--WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
							--	--AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND ReceiveStatus IN ('A','F')
							--	AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(ReceiveID) = '19' AND SUBSTRING(ReceiveID,1,5) = @_DocumentTypeID
							--ORDER BY RIGHT(ReceiveID,9) DESC
							
							) --MOD Anton 2019-03-19
							----ORDER BY ReceiveID DESC)
				BEGIN
					--SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
					--FROM CM_T_FinancialReceiveHeader 
					--WHERE IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
					--		--AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND ReceiveStatus IN ('A','F')
					--		AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(ReceiveID) = '19' AND SUBSTRING(ReceiveID,1,5) = @_DocumentTypeID
					--ORDER BY RIGHT(ReceiveID,9) DESC --MOD Anton 2019-03-19
					----ORDER BY ReceiveID DESC

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4)) FROM
					(
						SELECT ReceiveID FROM CM_T_FinancialReceiveHeader 
							WHERE 
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
								AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(ReceiveID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
						UNION
						SELECT PaymentID FROM CM_T_FinancialPaymentHeader 
							WHERE
								IDX_M_Branch = @_IDX_M_Branch AND MONTH(ApprovalDate) = MONTH(@_ReceiveDate)
								AND YEAR(ApprovalDate) = YEAR(@_ReceiveDate) AND LEN(PaymentID) = '19' AND IDX_M_FinancialAccount = @_IDX_FA
					) a
					ORDER BY RIGHT(ReceiveID,9) DESC
				END			
				ELSE
				BEGIN
					SET @_LastNumber = '00000'
				END

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@_ReceiveDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@_ReceiveDate)),2)

				/** Set Sales Order No **/
				SET @_ReceiveNo = RTRIM(@_DocumentTypeID) + '-' 
					+ @_BranchID + '-' --Added anton 20190219 
					+ @_Year 
					+ @_Month + '-'
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				DECLARE @CurrentTransNo VARCHAR(50)
				SET @CurrentTransNo = (SELECT ReceiveID FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader)

				-- Update status
				IF LEFT(@CurrentTransNo,5) = 'DRAFT'
				BEGIN
					UPDATE CM_T_FinancialReceiveHeader 
					SET ReceiveID = @_ReceiveNo,
						ReceiveStatus = 'A', ApprovalDate = @ApprovalDate, ApprovedBy = @UserID, 
						ApprovalRemark = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
				END
				ELSE
				BEGIN
					UPDATE CM_T_FinancialReceiveHeader 
					SET ReceiveStatus = 'A', ApprovalDate = @ApprovalDate, ApprovedBy = @UserID, 
						ApprovalRemark = @ApproveRemark, DModified = GETDATE(), UModified = @UserID 
					WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
				END
			
				-- ====================================================
				-- Create Journal Header - Financial Receive
				--
				-- Standard Journal :
				-- Bank, Cash or Deposit --> Debet
				-- Piutang Usaha --> Credit				
				-- ====================================================		
				
				DECLARE @_ReceiveAmount					AS DECIMAL(22,2)				

				-- Untaxed Amount
				SELECT @_ReceiveAmount = SUM(ReceiveAmount)
				FROM CM_T_FinancialReceiveDetail 
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader	

				-- ========================================================
				-- GENERATE JOURNAL
				-- ========================================================				
				
				DECLARE @_JournalResult		SMALLINT

				EXEC USP_CM_FinancialReceive_CreateJournal @IDX_T_FinancialReceiveHeader, @UserID, @_JournalResult OUTPUT

				IF @_JournalResult <> 1
				BEGIN
					INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'Create journal failed!')
				END
				

					-- =======================================================================
					-- Approval Financial Receive Allocation
					-- =======================================================================
					UPDATE CM_T_ReceiveAllocation SET AllocationStatus = 'A', UModified = @UserID, DModified = GETDATE()
					FROM (
						SELECT IDX_T_FinancialReceiveDetail FROM CM_T_FinancialReceiveDetail WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader
					) FRD
					INNER JOIN CM_T_ReceiveAllocation ON CM_T_ReceiveAllocation.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail 

									

				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialReceiveHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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