-- ================================================================================================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 November 2016
-- Description	: Delete Sales Invoice Detail
-- Mod			: 2023-08-25 by Anton --> Adjust TotalSalesAmount on Header for Upload Excel Transaction when deletetion of detail item occur
-- ================================================================================================================================================

/*		
	EXEC [dbo].[USP_CM_SalesInvoiceDetail_Delete] 1
*/

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoiceDetail_Delete] 	
	@IDX_T_SalesInvoiceDetail		BIGINT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY		
		
		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),	
			ID			BIGINT,			
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		/*****************************/
		
		DECLARE @IDX_T_SalesInvoiceHeader AS BIGINT

			SET @IDX_T_SalesInvoiceHeader = (
				SELECT IDX_T_SalesInvoiceHeader FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail
				)

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			DELETE [dbo].[CM_T_SalesInvoiceDetail] WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail		
			
			DELETE [dbo].[CM_T_SalesInvoiceTax] WHERE IDX_T_SalesInvoiceDetail = @IDX_T_SalesInvoiceDetail		

			IF	(	SELECT ISNULL(TotalSalesAmount,0) 
					FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
					WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	) > 0 
			BEGIN
				IF	(	SELECT TotalSalesAmount 
						FROM CM_T_SalesInvoiceHeader WITH(NOLOCK) 
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader	) <>
					(	SELECT SUM(UnitPrice)
						FROM CM_T_SalesInvoiceDetail WITH(NOLOCK)
						WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice > 0 AND RecordStatus = 'A'	)
				BEGIN
					UPDATE A
						SET A.TotalSalesAmount = X.NewUnitPrice
					FROM CM_T_SalesInvoiceHeader A WITH(NOLOCK)
						INNER JOIN 
						(	SELECT IDX_T_SalesInvoiceHeader, SUM(UnitPrice) AS NewUnitPrice
							FROM CM_T_SalesInvoiceDetail WITH(NOLOCK) 
							WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND UnitPrice > 0 AND RecordStatus = 'A'
							GROUP BY IDX_T_SalesInvoiceHeader
						) X ON A.IDX_T_SalesInvoiceHeader = X.IDX_T_SalesInvoiceHeader
					WHERE A.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader AND A.RecordStatus = 'A' 
				END
			END

			INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesInvoiceHeader, 'Data Sudah Dihapus')
		END

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



