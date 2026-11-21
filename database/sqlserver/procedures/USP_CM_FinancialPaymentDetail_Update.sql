-- =======================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Update Table Financial Payment Detail
-- Modified		: 2021-01-25 by Anton --> Adjust logic validation Total Payment Amount > Outstanding Amount
--				  2024-07-04 by Anton --> Update COA Allocation on table Payment Allocation must be same with COA Detail on table Payment Detail
-- =======================================================================================================================================

/*	
	EXEC [dbo].[USP_CM_FinancialPaymentDetail_Update] 
					 577
					,406					
					,2
					,134
					,'PI-CAR-1020-0026'
					,44
					,3340000
					,'CV. MITRA PERSADA - PBY PO-CAR-0920-0010 PENGADAAN 4.000 KG PAC POWDER 30% - tes'					
					,'1305276'
					,'A'
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPaymentDetail_Update] 	
	@IDX_T_FinancialPaymentDetail			BIGINT,
	@IDX_T_FinancialPaymentHeader			BIGINT,
	@IDX_M_Project							BIGINT,
	@IDX_M_DocumentType						BIGINT,
	@IDX_DocumentNo							BIGINT,
	@DocumentNo								VARCHAR(50),
	@COADetail								BIGINT,			
	@PaymentAmount							DECIMAL(22,2),	
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

		IF NOT EXISTS(SELECT IDX_M_COA FROM GL_M_COA WHERE IDX_M_COA = @COADetail)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Invalid chart of account!')
		END

		-- ==============================================
		-- Check outstanding vs payment
		-- ==============================================
		DECLARE @_OutstandingAmount DECIMAL(18,2)
		DECLARE @_PrevPaymentAmount DECIMAL(18,2)

		--SELECT @_OutstandingAmount = SUM(Quantity * UnitPrice) 
		SELECT @_OutstandingAmount = SUM(((Quantity*(UntaxedAmount-DiscountAmount)) + (Quantity*TaxAmount))) --Adjust by Anton 2021-01-25
		FROM CM_T_PurchaseInvoiceDetail PID
		WHERE PID.IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo
		GROUP BY IDX_T_PurchaseInvoiceHeader

		SELECT @_PrevPaymentAmount = ISNULL(FPD.PaymentAmount,0)
		FROM CM_T_PurchaseInvoiceHeader PIH
		LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_M_DocumentType = PIH.IDX_M_DocumentType AND FPD.IDX_DocumentNo = PIH.IDX_T_PurchaseInvoiceHeader
		LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
		WHERE PIH.IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo AND FPH.PaymentStatus <> 'D'

		IF @_PrevPaymentAmount IS NULL SET @_PrevPaymentAmount = 0

		IF @_PrevPaymentAmount + @PaymentAmount > @_OutstandingAmount
		BEGIN
			INSERT INTO @TableLog VALUES ('error',@IDX_DocumentNo,'Total Payment Amount > Outstanding Amount !')
		END

		-- ================================================================================================
		-- Branch vs Project
		-- ================================================================================================
		IF @IDX_M_Project = 0 OR @IDX_M_Project = NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, 'Please select Project/LocationID!')
		END

		DECLARE @IDX_Branch BIGINT
		SELECT @IDX_Branch = IDX_M_Branch FROM GN_M_Project WITH(NOLOCK) WHERE IDX_M_Project = @IDX_M_Project

		IF (SELECT IDX_M_Branch FROM CM_T_FinancialPaymentHeader WITH(NOLOCK) WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader) <> @IDX_Branch
		BEGIN 
			INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, 'Selected Project Not Under The Same Group Company / Branch!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			-- COA 33 = Uang Muka Penjualan

			--SELECT @DocumentNo = Temp.DocumentNo, @COADetail = Temp.COAHeader 
			--FROM (				
			--	SELECT IDX_T_PurchaseInvoiceHeader AS IDX_DocumentNo, InvoiceNo AS DocumentNo, COAHeader 
			--	FROM CM_T_PurchaseInvoiceHeader 
			--	WHERE IDX_M_DocumentType = @IDX_M_DocumentType AND IDX_T_PurchaseInvoiceHeader = @IDX_DocumentNo
			--) Temp

			/**----------------------------------------------------------------------------- 
											Insert Financial Payment Header 
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[CM_T_FinancialPaymentDetail] SET
				    [IDX_T_FinancialPaymentHeader] = IDX_T_FinancialPaymentHeader
				   ,[IDX_M_Branch] = @IDX_Branch
				   ,[IDX_M_Project] = @IDX_M_Project
				   ,[IDX_M_DocumentType] = @IDX_M_DocumentType
				   ,[IDX_DocumentNo] = @IDX_DocumentNo
				   ,[DocumentNo] = @DocumentNo
				   ,[COADetail] = @COADetail
				   ,[PaymentAmount] = @PaymentAmount
				   ,[RemarkDetail] = @RemarkDetail				  			  				  
				   ,[UModified] = @UserID
				   ,[DModified] = GETDATE()				  
				   ,[RecordStatus] = @RecordStatus
			WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail

			IF EXISTS (SELECT 1 FROM CM_T_PaymentAllocation WITH(NOLOCK) WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail)
			BEGIN
				UPDATE CM_T_PaymentAllocation SET COAAllocation = @COADetail WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail	
			END

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



