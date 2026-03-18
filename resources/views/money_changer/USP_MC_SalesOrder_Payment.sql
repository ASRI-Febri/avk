USE [AVKDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_MC_SalesOrder_Payment]    Script Date: 28/01/2026 15:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [USP_MC_SalesOrder_Payment] 210239, 1, 3, 225000, 'INV/20210929/MPL/1628894122/MUFID ADNANI', 'admin'

CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_Payment] 
	@IDX_T_SalesOrder					BIGINT,	
	@IDX_M_FinancialAccount				BIGINT,	
	@ReceiveAmount						DECIMAL(22,2),
	@RemarkHeader						VARCHAR(500),
	@ReceiveDate						DATE,
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
			-- DECLARE @_FormID AS VARCHAR(20)
			-- SET @_FormID = 'SL-SAOD-008' -- Approval Contract

			-- DECLARE @Output INT
			-- EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			-- IF @Output <> 1
			-- BEGIN
			-- 	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			-- END
			
			/****************************/
			

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 

				/** Insert Financial Receive Header **/

				DECLARE @_IDX_M_Company 				BIGINT
				DECLARE @_IDX_M_Branch 					BIGINT	
				DECLARE @_BranchID 						VARCHAR(20)
				DECLARE @_SalesOrderNo 					VARCHAR(50)			
				DECLARE @_IDX_M_Partner 				BIGINT
				DECLARE @_IDX_M_Currency 				BIGINT				
				DECLARE @_IDX_M_DocumentType 			BIGINT = 3 -- FINANCIAL RECEIVE
				DECLARE @_ReceiveID 					VARCHAR(50)

				--DECLARE @ReceiveDate DATETIME				
				DECLARE @_ReceiveStatus 				CHAR(1)				
				DECLARE @_RecordStatus 					CHAR(1)
				DECLARE @_SalesOrderDate				DATE
				DECLARE @_SalesDocumentType 			INT

				DECLARE @_IDX_T_FinancialReceiveHeader 	BIGINT
				DECLARE @_IDX_DocumentNo 				BIGINT
				DECLARE @_COADetail 					BIGINT = 5 -- PIUTANG USAHA				
				DECLARE @_RemarkDetail 					VARCHAR(500)
				DECLARE @_IsUnidentified 				CHAR(1)

				-- TODO: Set parameter values here.
				-- Document Type 305 : Receive Sales Order Payment

				SELECT * FROM GN_M_DocumentType

				SELECT @_IDX_M_Company = IDX_M_Company, @_IDX_M_Branch = IDX_M_Branch, 
					@_SalesOrderNo = SONumber, @_IDX_M_Partner = IDX_M_Partner,
					@_IDX_M_Currency = 1, @_SalesOrderDate = SODate, 
					@_SalesDocumentType = IDX_M_DocumentType
				FROM MC_T_SalesOrder 
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

				--SET @ReceiveDate = GETDATE()
				SET @_RecordStatus = 'A'				
				SET @_ReceiveStatus = 'A'

				/**********************************************************************************************************/
				
				DECLARE @_LastNumber AS INTEGER
				DECLARE @_Month AS VARCHAR(4)
				DECLARE @_Year AS VARCHAR(2)
				DECLARE @_DocumentTypeID AS CHAR(3)				
		
				SET @_LastNumber = 0

				SELECT @_DocumentTypeID = DocumentTypeID 
				FROM GN_M_DocumentType 
				WHERE IDX_M_DocumentType = @_IDX_M_DocumentType

				SELECT @_BranchID = RTRIM(CONVERT(VARCHAR,@_IDX_M_Branch)) 
				FROM GN_M_Branch 
				WHERE IDX_M_Branch = @_IDX_M_Branch

				--IF EXISTS(	SELECT TOP 1 ReceiveID
				--			FROM CM_T_FinancialReceiveH 
				--			WHERE MONTH(ReceiveDate) = MONTH(@SalesOrderDate)
				--				AND YEAR(ReceiveDate) = YEAR(@SalesOrderDate)
				--				AND LEFT(ReceiveID,3) = LEFT(RTRIM(@_DocumentTypeID),3)
				--			ORDER BY ReceiveID DESC)
				--BEGIN
				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
				--	FROM CM_T_FinancialReceiveH 
				--	WHERE MONTH(ReceiveDate) = MONTH(@SalesOrderDate)
				--		AND YEAR(ReceiveDate) = YEAR(@SalesOrderDate)
				--		AND LEFT(ReceiveID,3) = LEFT(RTRIM(@_DocumentTypeID),3)
				--	ORDER BY ReceiveID DESC
				--END			

				

				--SET @_Month = '00' + CONVERT(VARCHAR,MONTH(@SalesOrderDate))
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(@SalesOrderDate)),2)

				--/** Set Contract No by System **/
				--SET @_ReceiveID = RTRIM(@_DocumentTypeID) 
				--	+ @_BranchID + '-' 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)				

				INSERT INTO [dbo].[CM_T_FinancialReceiveHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]
				   ,[IDX_M_PaymentType]
				   ,[IDX_M_DocumentType]
				   ,[ReceiveID]
				   ,[ReceiveDate]
				   ,[RemarkHeader]
				   ,[ReceiveStatus]
				   ,[ReceiveAmount]	
				   ,[ApprovalDate]
				   ,[ApprovedBy]			  
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
			 VALUES
				   (@_IDX_M_Company
				   ,@_IDX_M_Branch
				   ,@IDX_M_FinancialAccount
				   ,@_IDX_M_Partner
				   ,@_IDX_M_Currency
				   ,0
				   ,@_IDX_M_DocumentType
				   ,@_ReceiveID
				   ,@ReceiveDate
				   ,@RemarkHeader
				   ,@_ReceiveStatus	
				   ,@ReceiveAmount	
				   ,@ReceiveDate
				   ,@UserID		   
				   ,@UserID
				   ,GETDATE()				  
				   ,@_RecordStatus)

				SET @_IDX_T_FinancialReceiveHeader = (SELECT SCOPE_IDENTITY())

				-- =====================================================================
				-- UPDATE RECEIVE ID
				-- =====================================================================
				SET @_ReceiveID = RTRIM(@_DocumentTypeID) + @_BranchID + '-' + CONVERT(VARCHAR, @_IDX_T_FinancialReceiveHeader)	
				
				UPDATE CM_T_FinancialReceiveHeader SET ReceiveID = @_ReceiveID
				WHERE IDX_T_FinancialReceiveHeader = @_IDX_T_FinancialReceiveHeader

				-- ====================================================================
				-- Insert Financial Receive Detail 
				-- ====================================================================		
								
				SET @_RemarkDetail = 'Pembayaran ' + @_SalesOrderNo				
				SET @_IDX_DocumentNo = @IDX_T_SalesOrder				
				SET @_IsUnidentified = 'N'		

				INSERT INTO [dbo].[CM_T_FinancialReceiveDetail]
					   ([IDX_T_FinancialReceiveHeader]
					   ,[IDX_M_DocumentType]
					   ,[IDX_DocumentNo]
					   ,[DocumentNo]
					   ,[COADetail]
					   ,[ReceiveAmount]
					   ,[RemarkDetail]
					   ,[UCreate]
					   ,[DCreate]
					   ,[RecordStatus])
				 VALUES
					   (@_IDX_T_FinancialReceiveHeader
					   ,@_SalesDocumentType
					   ,@_IDX_DocumentNo
					   ,@_SalesOrderNo
					   ,@_COADetail
					   ,@ReceiveAmount
					   ,@_RemarkDetail
					   ,@UserID
					   ,GETDATE()
					   ,@_RecordStatus)


				-- ========================================================
				-- GENERATE JOURNAL
				-- ========================================================
				DECLARE @_JournalResult		SMALLINT

				EXEC USP_CM_FinancialReceive_CreateJournal @_IDX_T_FinancialReceiveHeader, @UserID, @_JournalResult OUTPUT

				IF @_JournalResult <> 1
				BEGIN
					INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrder, 'Create journal failed!')
				END


				-- ========================================================
				-- OUTPUT
				-- ========================================================
				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesOrder, 'Data Sudah Disimpan')

				COMMIT TRANSACTION;

			END		

			SELECT * FROM @TableLog

			

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error', @IDX_T_SalesOrder, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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

