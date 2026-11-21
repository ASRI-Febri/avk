-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Update Table Financial Payment Detail Allocation 
-- =============================================

/*	
	
	EXEC [dbo].[USP_CM_PaymentAllocation_Update] 
					1,1,1,
					1,,1,
					'G12345',NULL,'2017-01-12',
					'2017-01-12','TEST',1,						
					1000000,10000,0,
					0,'D',
					'admin','A'
	
*/

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_Update] 	
	@IDX_T_PaymentAllocation			BIGINT,
	@IDX_T_FinancialPaymentDetail		BIGINT,
	@IDX_M_Partner						BIGINT,
	@IDX_M_DocumentType					BIGINT,
	@IDX_DocumentNo						BIGINT,
	@AllocationID						VARCHAR(50),
	@DocumentNo							VARCHAR(50),
	@COAAllocation						BIGINT,	
	@AllocationDate						DATETIME,		
	@AllocationAmount					DECIMAL(22,2),	
	@RemarkAllocation					VARCHAR(500),
	@AllocationStatus					CHAR(1),		
	--------------------------------------------------------------	
	@UserID								VARCHAR(50),
	@RecordStatus						CHAR(1)	
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

		DECLARE @_PaymentAmount		DECIMAL(22,2)

		SELECT @_PaymentAmount = PaymentAmount FROM CM_T_FinancialPaymentDetail WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail

		IF @AllocationAmount > @_PaymentAmount
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Allocation amount is more than Payment Amount !')
		END

		IF @COAAllocation = 0 OR @COAAllocation = NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Please check your COA Allocation !')
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

			SET @DocumentNo = (SELECT InvoiceNo FROM CM_T_PurchaseInvoiceHeader WITH(NOLOCK) WHERE IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo)

			/**----------------------------------------------------------------------------- 
											Insert Financial Payment Header 
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[CM_T_PaymentAllocation] SET
				 [IDX_T_FinancialPaymentDetail] = IDX_T_FinancialPaymentDetail
				,[IDX_M_Partner] = @IDX_M_Partner
				,[IDX_M_DocumentType] = @IDX_M_DocumentType
				,[IDX_DocumentNo] = @IDX_DocumentNo
				,[AllocationID] = @AllocationID 
				,[AllocationDate] = @AllocationDate 
				,[DocumentNo] = @DocumentNo
				,[COAAllocation] = @COAAllocation
				,[AllocationAmount] = @AllocationAmount
				,[RemarkAllocation] = @RemarkAllocation				  			  				  
				,[AllocationStatus] = @AllocationStatus 
				,[UModified] = @UserID
				,[DModified] = GETDATE()				  
				,[RecordStatus] = @RecordStatus
			WHERE IDX_T_PaymentAllocation = @IDX_T_PaymentAllocation

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


