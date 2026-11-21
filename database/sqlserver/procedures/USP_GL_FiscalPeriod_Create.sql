-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Update Table Master FiscalPeriod
-- =============================================

/*		
	EXEC [dbo].[USP_GL_FiscalPeriod_Create] 
		1,1,1,
		1,,1,
		'G12345',NULL,'2017-01-12',
		'2017-01-12','TEST',1,						
		1000000,10000,0,
		0,'D',
		'admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_GL_FiscalPeriod_Create] 	
	@IDX_M_Company				INT,
	@IDX_M_Branch				INT,
	@FiscalPeriod				VARCHAR(6),
	@StartDate					DATETIME,
	@EndDate					DATETIME,
	@GLStatus					BIT,
	@SalesStatus				BIT,
	@PurchaseStatus				BIT,
	@FinanceStatus				BIT,
	--------------------------------------------------------------	
	@UserID						VARCHAR(10),
	@RecordStatus				CHAR(1)	
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
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'CM-MFIA-002' -- Create Financial Account

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END		
		/****************************************************************************/
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
						
			/**----------------------------------------------------------------------------- 
											Insert Master FiscalPeriod
			--------------------------------------------------------------------------------**/

			IF @IDX_M_Company = 0
			BEGIN
				SELECT @IDX_M_Company = IDX_M_Company FROM GN_M_Branch WHERE IDX_M_Branch = @IDX_M_Branch
			END

			INSERT INTO [dbo].[GL_M_FiscalPeriod]
				([IDX_M_Company]
				,[IDX_M_Branch]
				,[FiscalPeriod]
				,[StartDate]
				,[EndDate]
				,[GLStatus]
				,[SalesStatus]
				,[PurchaseStatus]
				,[FinanceStatus]				   			  
				,[UCreate]
				,[DCreate]				  
				,[RecordStatus])
			VALUES (
				 @IDX_M_Company
				,@IDX_M_Branch
				,@FiscalPeriod
				,@StartDate
				,@EndDate
				,@GLStatus
				,@SalesStatus
				,@PurchaseStatus
				,@FinanceStatus
				,@UserID
				,GETDATE()
				,@RecordStatus
			)

			DECLARE @IDX_M_FiscalPeriod AS BIGINT
			SET @IDX_M_FiscalPeriod = (SELECT SCOPE_IDENTITY())			 					

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_FiscalPeriod, 'Data Sudah Disimpan')
				
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


