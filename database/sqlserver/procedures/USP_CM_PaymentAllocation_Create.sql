-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Financial Payment Detail Allocation 
-- =============================================

/*	
	EXEC [dbo].[USP_CM_PaymentAllocation_Create] 
					 13					
					,2
					,2
					,2
					,'asdfasd'
					,'PINV-0518-0002'
					,18
					,'2018-09-17'
					,250000
					,''	
					,'D'				
					,'1406069'
					,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_Create] 	
	@IDX_T_FinancialPaymentDetail			BIGINT,
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
		DECLARE @_PaymentAmount		DECIMAL(22,2)

		SELECT @_PaymentAmount = PaymentAmount FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail

		IF @AllocationAmount > @_PaymentAmount
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Allocation amount is more than Payment Amount !')
		END

		IF @COAAllocation = 0 OR @COAAllocation IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please check your COA Allocation !')
		END

		----------------------------------------------------------------------------------
		DECLARE @_InvoiceAmount		DECIMAL(22,2)

		SELECT @_InvoiceAmount = SUM(ID.Quantity * (ID.UntaxedAmount - DiscountAmount + TaxAmount) )
		FROM CM_T_PurchaseInvoiceHeader IH
		LEFT JOIN CM_T_PurchaseInvoiceDetail ID ON ID.IDX_T_PurchaseInvoiceHeader = IH.IDX_T_PurchaseInvoiceHeader 
		WHERE IDX_M_DocumentType = @IDX_M_DocumentType AND ID.IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo 

		----------------------------------------------------------------------------------
		IF @IDX_M_DocumentType <> 0 AND @IDX_DocumentNo <> 0 
		BEGIN
			DECLARE @_InvoicePaid		DECIMAL(22,2)

			SELECT @_InvoicePaid = ISNULL(SUM(RA.AllocationAmount),0)
			FROM CM_T_PurchaseInvoiceHeader PIH
			LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
			LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
			LEFT JOIN CM_T_FinancialPaymentHeader FRH ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
			WHERE RA.AllocationStatus = 'A' AND RA.IDX_M_DocumentType = @IDX_M_DocumentType AND RA.IDX_DocumentNo = @IDX_DocumentNo
		
			IF (ISNULL(@_InvoiceAmount,0) - ISNULL(@_InvoicePaid,0)) < ISNULL(@AllocationAmount,0)
			BEGIN
				INSERT INTO @TableLog VALUES ('error',0,'Allocation amount is more than Outstanding Amount !')
			END
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

			SET @DocumentNo = (SELECT InvoiceNo FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo)
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Payment Detail 
			--------------------------------------------------------------------------------**/
			INSERT INTO [dbo].[CM_T_PaymentAllocation]
				   ([IDX_T_FinancialPaymentDetail]
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
				   (@IDX_T_FinancialPaymentDetail
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
			
			DECLARE @IDX_T_PaymentAllocation AS BIGINT
			SET @IDX_T_PaymentAllocation = (SELECT SCOPE_IDENTITY())

			DECLARE @IDX_T_FinancialPaymentHeader AS BIGINT
			SET @IDX_T_FinancialPaymentHeader = (
				SELECT IDX_T_FinancialPaymentHeader FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail
			)

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')
				
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


