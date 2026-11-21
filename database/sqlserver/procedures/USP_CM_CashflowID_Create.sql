
-- =============================================
-- Author		: Anton
-- Create date	: 2021-10-19
-- Description	: Create CashflowID
-- =============================================

CREATE PROCEDURE [dbo].[USP_CM_CashflowID_Create] 	
	@IDX_ParentCashflowID		BIGINT,
	@CategoryType				CHAR(1),
	@CashflowID					VARCHAR(10),			
	@CashflowDesc				VARCHAR(200),
	--------------------------------------------------------------	
	@UserID						VARCHAR(10),
	@RecordStatus				CHAR(1)	

--EXEC [USP_CM_CashflowID_Create] 77, 'H', '9.06.00', 'Trial', '1305276', 'A'

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
		--SET @_FormID = 'CM-MFIA-001' -- Create Financial Account

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		IF EXISTS (SELECT 1 FROM CM_M_CashflowID WITH(NOLOCK) WHERE CashflowID = @CashflowID)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'CashflowID already exists!')
		END		

		IF (LEN(@CashflowID) <> 7)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'CashflowID must contain exactly 7 amount of characters!')
		END	
		/****************************************************************************/
		
		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN		
				
			/**----------------------------------------------------------------------------- 
											Insert Cashflow
			--------------------------------------------------------------------------------**/			
			--select @CashflowID
			--select LEFT(RTRIM(LTRIM(@CashflowID)),1)

			INSERT INTO [dbo].[CM_M_CashflowID]
			   ([IDX_ParentCashflowID]
			   ,[CategoryType]
			   ,[CashflowID]
			   ,[CashflowDesc]
			   ,[InFlag]
			   ,[OutFlag]
			   ,[UCreate]
			   ,[DCreate]			   
			   ,[RecordStatus])
			 VALUES
				(@IDX_ParentCashflowID
				,@CategoryType
				,@CashflowID
				,CASE @CategoryType WHEN 'A' THEN @CashflowDesc WHEN 'H' THEN UPPER(@CashflowDesc) END
				,CASE WHEN LEFT(RTRIM(LTRIM(@CashflowID)),1) IN ('1','2') THEN 1 ELSE 0 END
				,CASE WHEN LEFT(RTRIM(LTRIM(@CashflowID)),1) NOT IN ('1','2') THEN 1 ELSE 0 END				   
				,@UserID
				,GETDATE()				  
				,@RecordStatus)			
			
			DECLARE @IDX_M_CashflowID AS BIGINT
			SET @IDX_M_CashflowID = (SELECT SCOPE_IDENTITY())

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_CashflowID, 'Data Sudah Disimpan')
				
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


