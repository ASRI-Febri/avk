-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 06 Feb 2018
-- Description	: Journal Posting
-- Mod			: 2020-10-02 by Anton --> Added Journal Closing Period Validation
--				  2022-07-22 by Anton --> Added validation checking journal type (only memorial can be posted)
--				  2024-06-04 by Anton --> Added validation cannot change month posted when already have voucherno
-- ==========================================================================================

-- EXEC [dbo].[USP_GL_Journal_Posting] 190,'2026-03-28','Revisi dan penambahan kas','it_febry'

CREATE PROCEDURE [dbo].[USP_GL_Journal_Posting]
	@IDX_T_JournalHeader		BIGINT,
	@PostingDate				DATE,
	@ApprovalRemark				VARCHAR(500),
	@UserID						VARCHAR(50),
	@RecordStatus				CHAR(1) = 'A'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail AS INT
			DECLARE @_CountLog AS INT
			DECLARE @_Discount AS DECIMAL(22,2)
			DECLARE @_Commission AS DECIMAL(22,2)

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID		VARCHAR(20)
			--DECLARE @_RoleID		CHAR(1)
			--DECLARE @Output			INT

			--SET @_FormID = 'GL-JOUR-006' -- Journal Posting
			--SET @_RoleID = 'R'
			
			--EXEC USP_SM_CheckUserForm @UserID, @_FormID, @_RoleID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			-- ===========================================================================================================
			-- Check detail item
			-- ===========================================================================================================
			SELECT @_CountDetail = COUNT(IDX_T_JournalDetail) 
			FROM GL_T_JournalDetail WITH(NOLOCK)
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'No Data in Detail Transaction')
			END			

			-- ===========================================================================================================
			-- Check Journal Type
			-- ===========================================================================================================

			--IF (SELECT IDX_M_JournalType FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) <> 5 -- 5 --> Journal Memorial
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Only Journal Memorial Type can be posted!')
			--END
			
			-- ===========================================================================================================
			-- Check journal balance
			-- ===========================================================================================================
			DECLARE @_TotalDebet	DECIMAL(24,4)
			DECLARE @_TotalCredit	DECIMAL(24,4)	

			SELECT @_TotalDebet = SUM(JD.BDebetAmount) FROM GL_T_JournalDetail JD WITH(NOLOCK) WHERE JD.RecordStatus = 'A' AND IDX_T_JournalHeader = @IDX_T_JournalHeader
			SELECT @_TotalCredit = SUM(JD.BCreditAmount) FROM GL_T_JournalDetail JD WITH(NOLOCK) WHERE JD.RecordStatus = 'A' AND IDX_T_JournalHeader = @IDX_T_JournalHeader

			IF @_TotalDebet IS NULL SET @_TotalDebet = 0
			IF @_TotalCredit IS NULL SET @_TotalCredit = 0

			IF @_TotalDebet <> @_TotalCredit
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Journal is not balance!')
			END

			DECLARE @Curr_VoucherNo VARCHAR(100)
			SET @Curr_VoucherNo = (SELECT VoucherNo FROM GL_T_JournalHeader WITH(NOLOCK) WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader)

			--IF (LEFT(@Curr_VoucherNo,5) <> 'DRAFT')
			--BEGIN
			--	IF (SELECT LEFT(RIGHT(VoucherNo,9),4) 
			--		FROM GL_T_JournalHeader WITH(NOLOCK) 
			--		WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader) <> (SELECT RIGHT(LEFT(CONVERT(VARCHAR,@PostingDate,112),6),4))
			--	BEGIN
			--		INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'VoucherNo Already Exist, Cannot Change Month Approval. Please Void & Create New Transaction!')
			--	END
			--END

			-- ===========================================================================================================
			-- Check journal date vs open period
			-- ===========================================================================================================
			DECLARE @_JournalDate			DATE
			DECLARE @_IDX_M_JournalType		INT
			DECLARE @_IDX_M_Branch			INT

			SELECT @_IDX_M_Branch = IDX_M_Branch, @_JournalDate = CONVERT(DATE,JournalDate), @_IDX_M_JournalType = IDX_M_JournalType  
			FROM GL_T_JournalHeader WITH(NOLOCK)
			WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader

			IF (SELECT GLStatus FROM GL_M_FiscalPeriod WITH(NOLOCK) WHERE FiscalPeriod = LEFT(CONVERT(VARCHAR,@PostingDate,112),6)) = 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'Journal Period Already Closed!')
			END	

			--IF EXISTS (	SELECT IDX_M_FiscalPeriod 
			--			FROM GL_M_FiscalPeriod 
			--			WHERE @PostingDate BETWEEN StartDate AND EndDate AND GLStatus = 1)
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',@IDX_T_JournalHeader,'GL period is already closed!')
			--END

			-- ===========================================================================================================
			--Check Error Log
			-- ===========================================================================================================
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			-- ===========================================================================================================
			-- If no error, then post journal
			-- ===========================================================================================================
			IF @_CountLog = 0
			BEGIN 
				
				-- ==========================
				-- Generate Voucher No
				-- ==========================
				DECLARE @_BranchID			AS VARCHAR(20)
				DECLARE @_JournalTypeDesc	AS VARCHAR(20)

				DECLARE @_LastNumber		AS INTEGER
				DECLARE @_Month				AS VARCHAR(4)
				DECLARE @_Year				AS VARCHAR(2)
				DECLARE @_VoucherNo			AS VARCHAR(20)				

				SET @_LastNumber = 0

				SELECT @_BranchID = BranchID 
				FROM GN_M_Branch 
				WHERE IDX_M_Branch = @_IDX_M_Branch

				SELECT @_JournalTypeDesc = JournalTypeID 
				FROM GL_M_JournalType 
				WHERE IDX_M_JournalType = @_IDX_M_JournalType

				PRINT @_JournalTypeDesc

				IF EXISTS(	SELECT TOP 1 VoucherNo
							FROM GL_T_JournalHeader WITH(NOLOCK)
							WHERE MONTH(PostingDate) = MONTH(@PostingDate) AND YEAR(PostingDate) = YEAR(@PostingDate) 
								AND IDX_M_Branch = @_IDX_M_Branch AND IDX_M_JournalType = @_IDX_M_JournalType 
								AND LEFT(VoucherNo,5) <> 'DRAFT'  --AND PostingStatus = 'P'
							ORDER BY VoucherNo DESC)
				BEGIN

					PRINT 'Exists'

					SELECT TOP 1 @_LastNumber = IDX_T_JournalHeader --CONVERT(INT,RIGHT(RTRIM(VoucherNo),4))
					FROM GL_T_JournalHeader WITH(NOLOCK)
					WHERE MONTH(PostingDate) = MONTH(@PostingDate) AND YEAR(PostingDate) = YEAR(@PostingDate) 
						AND IDX_M_Branch = @_IDX_M_Branch AND IDX_M_JournalType = @_IDX_M_JournalType 
						AND LEFT(VoucherNo,5) <> 'DRAFT' --AND PostingStatus = 'P'
					ORDER BY IDX_T_JournalHeader DESC

				END			

				SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@PostingDate))
				SET @_Month = RIGHT(RTRIM(@_Month),2)

				SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@PostingDate)),2)

				PRINT 'Before Set Voucher'

				/** Set Sales Order No **/
				SET @_VoucherNo = @_JournalTypeDesc + '-' + @_BranchID + '-' 
					+ @_Year 
					+ @_Month + '-'
					+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				PRINT 'After Set Voucher'

				UPDATE GL_T_JournalHeader SET 
					VoucherNo = CASE WHEN LEFT(@Curr_VoucherNo,5) = 'DRAFT' THEN @_VoucherNo ELSE @Curr_VoucherNo END, 
					PostingStatus = 'P', PostedBy = @UserID,
					PostingNotes = @ApprovalRemark, PostingDate = @PostingDate, UModified = @UserID, DModified = GETDATE() 
				WHERE IDX_T_JournalHeader = @IDX_T_JournalHeader				

				-- =======================================================================
				-- Insert into log table
				-- =======================================================================
				INSERT INTO [dbo].[GL_T_JournalHeaderLog]
					([IDX_T_JournalHeader]
					,[LogType]
					,[LogDate]
					,[LogRemark]
					,[UCreate]
					,[DCreate]						   
					,[RecordStatus])
				SELECT @IDX_T_JournalHeader, 'Posting', GETDATE(), @ApprovalRemark, @UserID, GETDATE(), 'A'

				INSERT INTO @TableLog VALUES ('success', @IDX_T_JournalHeader, 'Data Sudah Disimpan')
					
			END			

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog		

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_JournalHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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




