-- ==========================================================================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Handover Financial Payment PDC (Giro)
-- Mod: 2020-01-31 by Anton - added validation handover date not allowed < approve date
-- Mod: 2020-11-02 by Anton - Adjust validation total amount cannot < allocation amount
-- ==========================================================================================


/* 
	BEGIN TRAN
		EXEC [dbo].[USP_CM_FinancialPayment_Handover] 
			7
			,'2019-03-21'
			,'Vendor'
			,'BG12345'
			,'Test'
			,'1406069'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FinancialPayment_Handover] 
	@IDX_T_FinancialPaymentHeader		BIGINT,
	@HandoverDate						VARCHAR(10),
	@HandoverTo							VARCHAR(100),
	@PDCNo								VARCHAR(100),
	@HandoverNotes						VARCHAR(8000),
	@UserID								VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY

		BEGIN TRANSACTION;
			
			DECLARE @_CountDetail			AS INT
			DECLARE @_TotalAmount			AS DECIMAL(22,2)
			DECLARE @_DetailAmount			AS DECIMAL(22,2)
			DECLARE @_AllocationAmount		AS DECIMAL(22,2)
			DECLARE @_CountLog				AS INT

			/** TableLog **/
			DECLARE @TableLog TABLE (
				Result		VARCHAR(20),	
				ID			BIGINT,			
				LogDesc		VARCHAR(500)
			)

			/** Check User Access Right **/
			--DECLARE @_FormID AS VARCHAR(20)
			--SET @_FormID = 'CM-FIRC-005' -- Approval Receiving Item

			--DECLARE @Output INT
			--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

			--IF @Output <> 1
			--BEGIN
			--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
			--END
			/****************************/

			SELECT @_CountDetail = COUNT(IDX_T_FinancialPaymentDetail), @_DetailAmount = SUM(PaymentAmount) 
			FROM CM_T_FinancialPaymentDetail
			WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			SELECT @_TotalAmount = PaymentAmount FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			SELECT @_AllocationAmount = SUM(PA.AllocationAmount)
			FROM CM_T_PaymentAllocation PA
			LEFT JOIN CM_T_FinancialPaymentDetail FPD ON FPD.IDX_T_FinancialPaymentDetail = PA.IDX_T_FinancialPaymentDetail
			LEFT JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
			WHERE FPH.IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			DECLARE @ApprovalDate DATE
			SELECT @ApprovalDate = ApprovalDate FROM CM_T_FinancialPaymentHeader WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader

			IF @_TotalAmount = NULL SET @_TotalAmount = 0
			IF @_AllocationAmount = NULL SET @_AllocationAmount = 0

			IF @HandoverDate < @ApprovalDate
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Handover Date cannot earlier than Approve Date')
			END	

			IF @_CountDetail = 0
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'No Data in Detail Transaction')
			END	
			
			IF @_TotalAmount <> @_DetailAmount
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Total Amount <> Detail Amount')
			END				

			IF @_TotalAmount < @_AllocationAmount
			BEGIN
				INSERT INTO @TableLog VALUES ('error',@IDX_T_FinancialPaymentHeader,'Total Amount Cannot Less Than Allocation Amount')
			END

			--Check Error Log
			SELECT @_CountLog = COUNT(*) FROM @TableLog

			IF @_CountLog = 0
			BEGIN 			
								
				UPDATE CM_T_FinancialPaymentHeader 
				SET PaymentStatus = 'H', HandoverDate = @HandoverDate, HandoverBy = @UserID, HandoverTo = @HandoverTo, 
					PDCNo = @PDCNo, HandoverNotes = @HandoverNotes, DModified = GETDATE(), UModified = @UserID 
				WHERE IDX_T_FinancialPaymentHeader = @IDX_T_FinancialPaymentHeader 				

				INSERT INTO @TableLog VALUES ('success', @IDX_T_FinancialPaymentHeader, 'Data Sudah Disimpan')
			END		

			SELECT * FROM @TableLog

			COMMIT TRANSACTION;	

	END TRY

	BEGIN CATCH				

		INSERT INTO @TableLog VALUES ('error', @IDX_T_FinancialPaymentHeader, CONVERT(VARCHAR, ERROR_NUMBER() + ' '  + ERROR_MESSAGE()))
				
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


