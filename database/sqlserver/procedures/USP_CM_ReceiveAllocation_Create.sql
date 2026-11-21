-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Financial Receive Detail Allocation 
-- =============================================

/*	
	EXEC [CoreDB].[dbo].[USP_CM_ReceiveAllocation_Create] 
					 17					
					,2
					,1
					,118
					,'KWT-1903'
					,'SINV-0818-0001'
					,7
					,'2018-09-04'
					,150000
					,''	
					,'D'				
					,'1406069'
					,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_ReceiveAllocation_Create] 	
	@IDX_T_FinancialReceiveDetail			BIGINT,
	@IDX_M_Partner							BIGINT,
	@IDX_M_DocumentType						BIGINT,
	@IDX_DocumentNo							BIGINT,
	@AllocationID							VARCHAR(50),	
	@DocumentNo								VARCHAR(50),
	@COAAllocation							BIGINT,	
	@AllocationDate							DATETIME,		
	@AllocationAmount						DECIMAL(22,2),	
	@RemarkAllocation						VARCHAR(500),
	@AllocationStatus						CHAR(1),		
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

		----------------------------------------------------------------------------------
		DECLARE @_ReceiveAmount		DECIMAL(22,2)

		SELECT @_ReceiveAmount = ReceiveAmount FROM CM_T_FinancialReceiveDetail WHERE IDX_T_FinancialReceiveDetail = @IDX_T_FinancialReceiveDetail

		--IF @AllocationAmount > @_ReceiveAmount
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'Allocation amount is more than Receive Amount !')
		--END

		----------------------------------------------------------------------------------
		DECLARE @_InvoiceAmount		DECIMAL(22,2)

		--SELECT @_InvoiceAmount = SUM(ID.Quantity * ID.UnitPrice) --mod anton 2020-02-03, replaced with below condition
		SELECT @_InvoiceAmount = SUM(ID.Quantity * (ID.UntaxedAmount - ID.DiscountAmount + ID.TaxAmount))
		FROM CM_T_SalesInvoiceHeader IH
		LEFT JOIN CM_T_SalesInvoiceDetail ID ON ID.IDX_T_SalesInvoiceHeader = IH.IDX_T_SalesInvoiceHeader 
		WHERE IDX_M_DocumentType = @IDX_M_DocumentType AND ID.IDX_T_SalesInvoiceHeader = @IDX_DocumentNo 

		----------------------------------------------------------------------------------
		--DECLARE @_InvoicePaid		DECIMAL(22,2)

		--SELECT @_InvoicePaid = ISNULL(SUM(RA.AllocationAmount),0)
		--FROM CM_T_SalesInvoiceHeader SIH
		--LEFT JOIN CM_T_ReceiveAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_SalesInvoiceHeader
		--LEFT JOIN CM_T_FinancialReceiveDetail FRD ON FRD.IDX_T_FinancialReceiveDetail = RA.IDX_T_FinancialReceiveDetail
		--LEFT JOIN CM_T_FinancialReceiveHeader FRH ON FRH.IDX_T_FinancialReceiveHeader = FRD.IDX_T_FinancialReceiveHeader
		--WHERE RA.AllocationStatus = 'A' AND RA.IDX_M_DocumentType = @IDX_M_DocumentType AND RA.IDX_DocumentNo = @IDX_DocumentNo
		
		--IF (ISNULL(@_InvoiceAmount,0) - ISNULL(@_InvoicePaid,0)) < ISNULL(@AllocationAmount,0)
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'Allocation amount is more than Outstanding Amount !')
		--END

		IF @COAAllocation = 0 OR @COAAllocation = NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please check your COA Allocation !')
		END

		-- ========================================================================
		-- If no error occured
		-- ========================================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
			
			-- COA 33 = Uang Muka Penjualan

			--SELECT @DocumentNo = Temp.DocumentNo, @COAAllocation = Temp.COAHeader 
			--FROM (				
			--	SELECT IDX_T_SalesInvoiceHeader AS IDX_DocumentNo, InvoiceNo AS DocumentNo, COAHeader 
			--	FROM CM_T_SalesInvoiceHeader 
			--	WHERE IDX_M_DocumentType = @IDX_M_DocumentType AND IDX_T_SalesInvoiceHeader = @IDX_DocumentNo
			--) Temp

			SET @DocumentNo = (SELECT InvoiceNo FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) WHERE IDX_T_SalesInvoiceHeader = @IDX_DocumentNo)
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Receive Detail 
			--------------------------------------------------------------------------------**/
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
				   ,@IDX_M_DocumentType
				   ,@IDX_DocumentNo
				   ,@AllocationID
				   ,@AllocationDate
				   ,@DocumentNo
				   ,@COAAllocation
				   ,@AllocationAmount
				   ,@RemarkAllocation	
				   ,@AllocationStatus			   
				   ,@UserID
				   ,GETDATE()				  
				   ,@RecordStatus)			
			
			DECLARE @IDX_T_ReceiveAllocation AS BIGINT
			SET @IDX_T_ReceiveAllocation = (SELECT SCOPE_IDENTITY())

			DECLARE @IDX_T_FinancialReceiveHeader AS BIGINT
			SET @IDX_T_FinancialReceiveHeader = (
				SELECT IDX_T_FinancialReceiveHeader FROM CM_T_FinancialReceiveDetail WHERE IDX_T_FinancialReceiveDetail = @IDX_T_FinancialReceiveDetail
			)

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



