-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 November 2016
-- Description:	Create Table Financial Payment Detail Allocation 
-- =============================================

/*	
	EXEC [dbo].[USP_CM_PaymentAllocation_CreateMultiple] 
		 7
		,1
		,'5,7,'
		,'1406069'
		,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_PaymentAllocation_CreateMultiple] 	
	@IDX_T_FinancialPaymentDetail			BIGINT,
	@IDX_M_Partner							BIGINT,
	@InvoiceList							VARCHAR(5000),		
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
						
			/**----------------------------------------------------------------------------- 
											Insert Financial Payment Detail 
			--------------------------------------------------------------------------------**/
			DECLARE @pos INT
			DECLARE @len INT
			DECLARE @value varchar(8000)
			
			SET @pos = 0
			SET @len = 0

			WHILE CHARINDEX(',', @InvoiceList, @pos + 1) > 0
			BEGIN
				SET @len = CHARINDEX(',', @InvoiceList, @pos+1) - @pos
				SET @value = SUBSTRING(@InvoiceList, @pos, @len)
				
				--SELECT @pos, @len, @value /*this is here for debugging*/
        
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
				SELECT 
					 @IDX_T_FinancialPaymentDetail
					,@IDX_M_Partner
					,PIH.IDX_M_DocumentType
					,PIH.IDX_T_PurchaseInvoiceHeader
					,'APP-' + CONVERT(VARCHAR,PIH.IDX_T_PurchaseInvoiceHeader)
					,GETDATE()
					,PIH.InvoiceNo
					,PIH.COAHeader, 
					(PID.TotalInvoice - ISNULL(FP.PaymentAmount,0))
					,'Payment allocation'
					,'D'
					,@UserID
					,GETDATE()
					,@RecordStatus
				FROM CM_T_PurchaseInvoiceHeader PIH				
				LEFT JOIN (	SELECT PID.IDX_T_PurchaseInvoiceHeader, SUM(Quantity * (UnitPrice - DiscountAmount)) AS TotalInvoice 
							FROM CM_T_PurchaseInvoiceDetail PID
							GROUP BY IDX_T_PurchaseInvoiceHeader) PID ON PID.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader 
				--LEFT JOIN (	SELECT PIH.IDX_T_PurchaseInvoiceHeader, PIH.InvoiceNo, ISNULL(FPD.PaymentAmount,0) AS PaymentAmount
				--			FROM CM_T_PurchaseInvoiceHeader PIH
				--			LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
				--			LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader) FP 
				LEFT JOIN (
						SELECT SUM(ISNULL(RA.AllocationAmount,0)) AS PaymentAmount, SIH.IDX_T_PurchaseInvoiceHeader
						FROM CM_T_PurchaseInvoiceHeader SIH
						LEFT JOIN CM_T_PaymentAllocation RA ON RA.IDX_M_DocumentType = SIH.IDX_M_DocumentType AND RA.IDX_DocumentNo = SIH.IDX_T_PurchaseInvoiceHeader
						LEFT JOIN CM_T_FinancialPaymentDetail FRD ON FRD.IDX_T_FinancialPaymentDetail = RA.IDX_T_FinancialPaymentDetail
						LEFT JOIN CM_T_FinancialPaymentHeader FRH ON FRH.IDX_T_FinancialPaymentHeader = FRD.IDX_T_FinancialPaymentHeader
						WHERE RA.AllocationStatus = 'A'
						GROUP BY SIH.IDX_T_PurchaseInvoiceHeader
				) FP
					ON FP.IDX_T_PurchaseInvoiceHeader = PIH.IDX_T_PurchaseInvoiceHeader
				WHERE PIH.IDX_T_PurchaseInvoiceHeader = @value 
			
				
				SET @pos = CHARINDEX(',', @InvoiceList, @pos + @len) + 1
			END


						
			
			--DECLARE @IDX_T_PaymentAllocation AS BIGINT
			--SET @IDX_T_PaymentAllocation = (SELECT SCOPE_IDENTITY())

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', 0, 'Data Sudah Disimpan')
				
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


