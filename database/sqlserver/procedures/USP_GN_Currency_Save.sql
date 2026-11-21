
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 03 June 2023
-- Description:	Save table GN_M_Currency
-- =============================================

--EXEC [dbo].USP_GN_Currency_Save @IDX_M_BrandItem,'@BrandID','@BrandDesc','@BrandInitial','@UserID','@RecordStatus'

CREATE PROCEDURE [dbo].[USP_GN_Currency_Save] 
	@IDX_M_Currency				INT,
	@IDX_M_Country				INT,	
	@CurrencyID					VARCHAR(20),
	@CurrencyName				VARCHAR(150),	
	@Symbol						VARCHAR(20),
	@Remarks					VARCHAR(5000),
	@Rounding					DECIMAL(18,4),
	@Accuracy					INT,
	------------------------------------------------
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

		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'CM-PINV-001' -- Receiving item 

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END

		IF EXISTS (SELECT 1 FROM GN_M_Currency WHERE CurrencyID = @CurrencyID AND IDX_M_Currency <> @IDX_M_Currency)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Currency ID already exists!')
		END			
		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			IF @IDX_M_Currency = 0
			BEGIN				

				INSERT INTO [dbo].[GN_M_Currency]
				   ([IDX_M_Country]
				   ,[CurrencyID]
				   ,[CurrencyName]	
				   ,[Symbol]
				   ,[Remarks]
				   ,[Rounding]
				   ,[Accuracy]   
				   ,[DCreate]
				   ,[UCreate]				   
				   ,[RecordStatus])
				VALUES
				   (@IDX_M_Country				   
				   ,@CurrencyID
				   ,@CurrencyName	
				   ,@Symbol
				   ,@Remarks
				   ,@Rounding
				   ,@Accuracy		   
				   ,GETDATE()
				   ,@UserID
				   ,@RecordStatus)

                SET @IDX_M_Currency = (SELECT SCOPE_IDENTITY())

			END
			ELSE
			BEGIN
				UPDATE [dbo].[GN_M_Currency]
				SET  [CurrencyID] = @CurrencyID 
					,[CurrencyName] = @CurrencyName
					,[Symbol] = @Symbol
					,[Remarks] = @Remarks
					,[Rounding] = @Rounding
					,[Accuracy] = @Accuracy
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_M_Currency = @IDX_M_Currency	
			END
			
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Currency, 'Data Sudah Disimpan')
			
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


