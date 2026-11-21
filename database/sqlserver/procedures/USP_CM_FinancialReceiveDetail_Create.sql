-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Financial Receive Detail
-- =============================================

/*	
	
	EXEC [dbo].[USP_CM_FinancialReceiveDetail_Create] 
					1,1,1,
					1,,1,
					'G12345',NULL,'2017-01-12',
					'2017-01-12','TEST',1,						
					1000000,10000,0,
					0,'D',
					'admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceiveDetail_Create] 	
	@IDX_T_FinancialReceiveHeader			BIGINT,
	@IDX_M_Project							BIGINT,
	@IDX_M_DocumentType						BIGINT,
	@IDX_DocumentNo							BIGINT,
	@DocumentNo								VARCHAR(50),
	@COADetail								BIGINT,			
	@ReceiveAmount							DECIMAL(22,2),	
	@RemarkDetail							VARCHAR(500),		
	--------------------------------------------------------------	
	@UserID									VARCHAR(50),
	@RecordStatus							CHAR(1)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		
		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/			
		
		/** Check User Access Right **/
		/*
		DECLARE @_FormID AS VARCHAR(20)
		SET @_FormID = ''

		DECLARE @Output INT
		EXEC USP_CheckUserForm @UserID,@_FormID, @Output OUT

		IF @Output <> 1
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		END
		*/
		/****************************************************************************/		

		-- ================================================================================================
		-- Branch vs Project
		-- ================================================================================================
		IF @IDX_M_Project = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'Please select Project/LocationID!')
		END

		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM CM_T_FinancialReceiveHeader WITH(NOLOCK) WHERE IDX_T_FinancialReceiveHeader = @IDX_T_FinancialReceiveHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialReceiveHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
			
			-- COA 33 = Uang Muka Penjualan

			--SELECT @DocumentNo = Temp.DocumentNo, @COADetail = Temp.COAHeader 
			--FROM (				
			--	SELECT IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, InvoiceNo AS DocumentNo, COAHeader 
			--	FROM CM_T_SalesInvoiceHeader 
			--	WHERE IDX_M_DocumentType = @IDX_M_DocumentType AND IDX_T_SalesInvoiceHeader = @IDX_DocumentNo
			--) Temp
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Receive Detail 
			--------------------------------------------------------------------------------**/
			INSERT INTO [dbo].[CM_T_FinancialReceiveDetail]
				   ([IDX_T_FinancialReceiveHeader]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Project]
				   ,[IDX_M_Department]
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
				   ,@IDX_Branch
				   ,@IDX_M_Project
				   ,0
				   ,@IDX_M_DocumentType
				   ,@IDX_DocumentNo
				   ,@DocumentNo
				   ,@COADetail
				   ,@ReceiveAmount
				   ,@RemarkDetail				   
				   ,@UserID
				   ,GETDATE()				  
				   ,@RecordStatus)			
			
			DECLARE @IDX_T_FinancialReceiveDetail AS BIGINT
			SET @IDX_T_FinancialReceiveDetail = (SELECT SCOPE_IDENTITY())

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialReceiveHeader, 'Data Sudah Disimpan')
				
		END

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH       

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
		SELECT * FROM @TableLog
			
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



