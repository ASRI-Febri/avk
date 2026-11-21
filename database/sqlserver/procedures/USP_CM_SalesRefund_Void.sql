-- =============================================
-- Author		:	Anton
-- Create date	:	2019-12-13
-- Description	:	Void Sales Refund
-- =============================================

/* 
	BEGIN TRAN
	EXEC [dbo].[USP_CM_SalesRefund_Void] 961,'2019-09-02','Testing void transaction','1305276'
	ROLLBACK TRAN

	BEGIN TRAN
	EXEC [dbo].[USP_CM_SalesRefund_Void] 1233,'2019-09-02','Testing void transaction','1305276'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesRefund_Void] 
	@IDX_T_SalesRefundHeader			BIGINT,
	@VoidDate							DATE,
	@VoidReason							VARCHAR(500),
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

			-- =======================================
			-- Validate Process - START
			-- =======================================
			SELECT @_CountDetail = COUNT(IDX_T_SalesRefundDetail) 
			FROM CM_T_SalesRefundDetail
			WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'No data in detail transaction')
			END			

			IF EXISTS (	SELECT IDX_M_FiscalPeriod 
						FROM GL_M_FiscalPeriod 
						WHERE @VoidDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'GL period is already closed!')
			END

			IF (SELECT CONVERT(DATE,ApprovedDate) FROM CM_T_SalesRefundHeader WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader) > @VoidDate
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_SalesRefundHeader,'Void date must be same or older than approved date!')
			END

			-- =======================================
			-- Validate Process - END
			-- =======================================

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
				DECLARE @_RefundNo				AS VARCHAR(20)
				DECLARE @_RefundDate			AS DATE
				DECLARE @_IDX_M_DocumentType	AS BIGINT
				DECLARE @_DocumentTypeID		AS CHAR(5)

				SET @_LastNumber = 0

				SELECT @_RefundDate = RefundDate, @_IDX_M_Partner = IDX_M_Partner, @_IDX_M_DocumentType = IDX_M_DocumentType, @_RefundNo = RefundNo 
				FROM CM_T_SalesRefundHeader 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				-- Update status
				UPDATE CM_T_SalesRefundHeader 
				SET 
					RefundStatus = 'V', VoidDate = @VoidDate, VoidBy = @UserID, 
					VoidReason = @VoidReason, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader						

				-- =================================================
				-- Generate Voucher No
				-- =================================================
				DECLARE @_VoucherNo AS VARCHAR(20)				
				DECLARE @_JournalDate AS DATE
				DECLARE @_IDX_Branch AS INT
				DECLARE @_BranchID AS VARCHAR(5)
				DECLARE @_JournalTypeID AS VARCHAR(4)

				SET @_LastNumber = 0
				SET @_JournalDate = GETDATE()
				SELECT @_IDX_Branch = IDX_M_Branch FROM CM_T_SalesRefundHeader WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader
				SELECT @_BranchID = BranchID FROM GN_M_Branch WHERE IDX_M_Branch = @_IDX_Branch
				SELECT @_JournalTypeID = JournalTypeID FROM GL_M_JournalType WHERE IDX_M_JournalType = 11

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader 
							WHERE	IDX_M_Branch = @_IDX_Branch
								AND MONTH(PostingDate) = MONTH(@VoidDate)
								AND YEAR(PostingDate) = YEAR(@VoidDate) AND PostingStatus = 'P'
								AND IDX_M_JournalType = 11
							ORDER BY VoucherNo DESC)
				BEGIN

					SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader 
					WHERE	IDX_M_Branch = @_IDX_Branch
						AND MONTH(PostingDate) = MONTH(@VoidDate)
						AND YEAR(PostingDate) = YEAR(@VoidDate) AND PostingStatus = 'P'
						AND IDX_M_JournalType = 11
					ORDER BY VoucherNo DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@VoidDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)
				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@VoidDate)),2)

				/** Set Voucher No **/
				SET @_VoucherNo =	@_JournalTypeID 
									+ '-' + @_BranchID
									+ '-' +
									+ @_Month + @_Year
									+ '-' + RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				-- =================================================
				-- Create Journal Header
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
					,IDX_M_Branch					
					,11 -- 11 = SV / Sales Void Journal
					,IDX_M_Partner
					,1
					,@IDX_T_SalesRefundHeader
					,@_RefundNo
					,@_VoucherNo
					,@VoidDate				
					,'Sales Refund Void Journal'
					,''
					,'P'
					,@VoidDate
					,@UserID
					,@VoidReason
					,0
					,0
					,'S' -- S = System Generated Journal
					,@UserID
					,GETDATE()
					,'A'
				FROM CM_T_SalesRefundHeader
				WHERE IDX_T_SalesRefundHeader = @IDX_T_SalesRefundHeader

				DECLARE @IDX_GL_T_JournalHeader AS BIGINT
				SET @IDX_GL_T_JournalHeader = (SELECT SCOPE_IDENTITY())

				-- ====================================================
				-- Create Journal Detail
				-- ====================================================

				INSERT INTO [dbo].[GL_T_JournalDetail]
				(
					[IDX_T_JournalHeader]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
				   ,[IDX_M_COA]
				   ,[IDX_M_Partner]
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
				   ,[RecordStatus]
				)
				SELECT
					@IDX_GL_T_JournalHeader
				   ,JD.IDX_M_Project
				   ,JD.IDX_M_Department
				   ,JD.IDX_M_COA
				   ,JD.IDX_M_Partner
				   ,JD.JournalSeqNo
				   ,JD.COADescription
				   ,'VOID JOURNAL - ' + JD.RemarkDetail
				   ,JD.OriginalCurrencyID
				   ,JD.OCreditAmount
				   ,JD.ODebetAmount
				   ,JD.ExchangeRate
				   ,JD.BaseCurrencyID
				   ,JD.BCreditAmount
				   ,JD.BDebetAmount
				   ,JD.UCreate
				   ,JD.DCreate		  
				   ,JD.RecordStatus
				FROM GL_T_JournalHeader JH
					LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader
				WHERE JH.IDX_ReferenceNo = @IDX_T_SalesRefundHeader AND JH.ReferenceNo = @_RefundNo AND JH.PostingStatus= 'P' AND JD.IDX_M_COA IS NOT NULL

				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesRefundHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesRefundHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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

