-- ==========================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 18 November 2016
-- Description	: Sales Invoice Payment
-- Mod			: 2021-12-02 by Anton --> Update ReceiveID column
--				  2024-06-07 by Anton --> Added Selected Value COA for Detail Item on FR
-- ==========================================================================================


-- EXEC [dbo].[USP_CM_SalesInvoice_Payment] 2  ,36,2,    1,        250000,'admin'
-- EXEC [dbo].[USP_CM_SalesInvoice_Payment] 353,10,4,52000,'IGH 01/01/24',1305276

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Payment] 
	@IDX_T_SalesInvoiceHeader			BIGINT,	
	@IDX_M_COA							BIGINT,
	@IDX_M_FinancialAccount				BIGINT,
	@IDX_M_PaymentType					BIGINT,
	@ReceiveAmount						DECIMAL(22,2),
	@RemarkDetail						VARCHAR(500),
	@UserID								VARCHAR(50)
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
			/*
			DECLARE @_FormID AS VARCHAR(20)
			SET @_FormID = 'CF-APPR-001' -- Approval Contract

			DECLARE @Output INT
			EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			IF @Output <> 1
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			END
			*/
			/****************************/
			

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 

				/** Insert Financial Receive Header **/

				/** Receive Header **/
				DECLARE @IDX_M_Company						BIGINT
				DECLARE @IDX_M_Branch						BIGINT				
				DECLARE @IDX_M_Partner						BIGINT
				DECLARE @IDX_M_Currency						BIGINT				
				DECLARE @IDX_M_DocumentType_Header			BIGINT
				DECLARE @ReceiveID							VARCHAR(50)
				DECLARE @ReceiveDate						DATETIME				
				DECLARE @ReceiveStatus						CHAR(1)				
				DECLARE @RecordStatus						CHAR(1)
				DECLARE @_BranchID							VARCHAR(5)

				/** Receive Detail **/
				DECLARE @IDX_T_FinancialReceiveHeader		BIGINT
				DECLARE @IDX_M_DocumentType_Detail			BIGINT
				DECLARE @IDX_DocumentNo						BIGINT
				DECLARE @DocumentNo							VARCHAR(20)
				DECLARE @COADetail							BIGINT				

				/** Document Type Untuk Sales Invoice Payment **/
				SET @IDX_M_DocumentType_Header = 3

				-- TODO: Set parameter values here.
				SELECT	 @IDX_M_Company = IDX_M_Company
						,@IDX_M_Branch = IDX_M_Branch
						,@IDX_M_Partner = IDX_M_Partner
						,@IDX_M_Currency = IDX_M_Currency
						,@IDX_M_DocumentType_Detail = IDX_M_DocumentType
						,@IDX_DocumentNo = IDX_T_SalesInvoiceHeader
						,@DocumentNo = InvoiceNo
						,@COADetail = COAHeader
						,@_BranchID = IDX_M_Branch
				FROM CM_T_SalesInvoiceHeader 
				WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader

				SET @ReceiveDate = GETDATE()
				SET @RecordStatus = 'A'				
				SET @ReceiveStatus = 'D' --Draft

				/**********************************************************************************************************/
				DECLARE @_ReceiveID AS VARCHAR(20)
				DECLARE @_LastNumber AS INTEGER
				DECLARE @_Month AS VARCHAR(4)
				DECLARE @_Year AS VARCHAR(2)
				DECLARE @_DocumentTypeID AS VARCHAR(5)
		
				SET @_LastNumber = 0

				SELECT @_DocumentTypeID = DocumentTypeID FROM GN_M_DocumentType WHERE IDX_M_DocumentType = @IDX_M_DocumentType_Header
				SELECT @_BranchID = BranchID FROM GN_M_Branch WHERE IDX_M_Branch = @_BranchID

				IF @_DocumentTypeID IS NULL 
					SET @_DocumentTypeID = ''

				--IF EXISTS(	SELECT TOP 1 ReceiveID
				--			FROM CM_T_FinancialReceiveHeader 
				--			WHERE MONTH(ReceiveDate) = MONTH(GETDATE())
				--				AND YEAR(ReceiveDate) = YEAR(GETDATE())
				--				AND LEFT(ReceiveID,2) = @_DocumentTypeID
				--			ORDER BY ReceiveID DESC)
				--BEGIN
				--	SELECT TOP 1 @_LastNumber = CONVERT(INT,RIGHT(RTRIM(ReceiveID),4))
				--	FROM CM_T_FinancialReceiveHeader 
				--	WHERE MONTH(ReceiveDate) = MONTH(GETDATE())
				--		AND YEAR(ReceiveDate) = YEAR(GETDATE())
				--		AND LEFT(ReceiveID,2) = @_DocumentTypeID
				--	ORDER BY ReceiveID DESC
				--END			
				--ELSE
				--BEGIN
				--	SET @_LastNumber = '00000'
				--END

				--SET @_Month = RIGHT('00' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2)
				--SET @_Month = RIGHT(RTRIM(@_Month),2)

				--SET @_Year = RIGHT(CONVERT(VARCHAR,YEAR(GETDATE())),2)

				--/** Set Contract No by System **/
				--SET @_ReceiveID = @_DocumentTypeID + '-' 
				--	+ @_BranchID + '-' --Added anton 20190219 
				--	+ @_Month
				--	+ @_Year + '-' 
				--	+ RIGHT('00000' + CONVERT(VARCHAR,@_LastNumber + 1),4)

				DECLARE @COAHeaderFR BIGINT
				SELECT @COAHeaderFR = IDX_M_COA FROM CM_M_FinancialAccount WITH(NOLOCK) WHERE IDX_M_FinancialAccount = @IDX_M_FinancialAccount

				INSERT INTO [dbo].[CM_T_FinancialReceiveHeader]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_FinancialAccount]
				   ,[IDX_M_DocumentType]
				   ,[IDX_M_Partner]
				   ,[IDX_M_Currency]
				   ,[IDX_M_PaymentType]
				   ,[COAHeader]
				   ,[ReceiveID]
				   ,[ReceiveDate]
				   ,[RemarkHeader]
				   ,[ReceiveStatus]
				   ,[ReceiveAmount]				  
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
			 VALUES
				   (@IDX_M_Company
				   ,@IDX_M_Branch
				   ,@IDX_M_FinancialAccount
				   ,@IDX_M_DocumentType_Header
				   ,@IDX_M_Partner
				   ,@IDX_M_Currency
				   ,@IDX_M_PaymentType	
				   ,@COAHeaderFR
				   ,''
				   ,@ReceiveDate
				   ,@RemarkDetail
				   ,@ReceiveStatus	
				   ,@ReceiveAmount			   
				   ,@UserID
				   ,GETDATE()				  
				   ,@RecordStatus)

				SET @IDX_T_FinancialReceiveHeader = (SELECT SCOPE_IDENTITY())
				
				UPDATE CM_T_FinancialReceiveHeader SET ReceiveID = 'DRAFT-' + CONVERT(VARCHAR,@IDX_T_FinancialReceiveHeader) 
				WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader

				/************************************************************************************************** 
					Insert Financial Payment Detail 
				***************************************************************************************************/		
				
				DECLARE @IDX_Project BIGINT
				IF (SELECT COUNT(DISTINCT(IDX_M_Project)) FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader) = 1
				BEGIN
					SET @IDX_Project = (SELECT DISTINCT(IDX_M_Project) FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader)
				END
				ELSE
				BEGIN
					SET @IDX_Project = (SELECT IDX_M_Project FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Branch IN 
											(SELECT IDX_M_Branch 
											 FROM GN_M_Branch WITH(NOLOCK)
											 WHERE IDX_M_Branch = @IDX_M_Branch) AND ProjectName LIKE '%ho')
				END

				INSERT INTO [dbo].[CM_T_FinancialReceiveDetail]
					   ([IDX_T_FinancialReceiveHeader]		
					   ,[IDX_M_Branch]
					   ,[IDX_M_Project]
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
					   (@IDX_T_FinancialReceiveHeader	
					   ,@IDX_M_Branch
					   ,@IDX_Project
					   ,@IDX_M_DocumentType_Detail
					   ,@IDX_DocumentNo
					   ,@DocumentNo
					   --,@COADetail
					   ,@IDX_M_COA
					   ,@ReceiveAmount
					   ,@RemarkDetail					   
					   ,@UserID
					   ,GETDATE()
					   ,@RecordStatus)

				DECLARE @IDX_T_FinancialReceiveDetail AS BIGINT
				SET @IDX_T_FinancialReceiveDetail = (SELECT SCOPE_IDENTITY())

				/************************************************************************************************** 
					Insert Financial Receive Detail Allocation
				***************************************************************************************************/
				INSERT INTO [dbo].[CM_T_ReceiveAllocation]
				   ([IDX_T_FinancialReceiveDetail]
				   ,[IDX_M_Partner]
				   ,[IDX_M_DocumentType]
				   ,[IDX_DocumentNo]
				   ,[AllocationID]
				   ,[AllocationDate]
				   ,[DocumentNo]
				   ,[COAAllocation]
				   ,[AllocationAmount]
				   ,[RemarkAllocation]
				   ,[AllocationStatus]				  
				   ,[UCreate]
				   ,[DCreate]				  
				   ,[RecordStatus])
			 VALUES
				   (@IDX_T_FinancialReceiveDetail
				   ,@IDX_M_Partner
				   ,@IDX_M_DocumentType_Detail
				   ,@IDX_DocumentNo
				   ,@_ReceiveID
				   ,GETDATE()
				   ,@DocumentNo
				   --,@COADetail
				   ,@IDX_M_COA
				   ,@ReceiveAmount
				   ,@RemarkDetail	
				   ,@ReceiveStatus			   
				   ,@UserID
				   ,GETDATE()				  
				   ,@RecordStatus)


				INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesInvoiceHeader, 'Data Sudah Disimpan')
			END		

		SELECT * FROM @TableLog

		COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH		

		INSERT INTO @TableLog VALUES ('error',0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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



