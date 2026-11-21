
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Create and update valas 
-- =============================================

/*		
	EXEC [dbo].[USP_MC_Valas_Save] 'Admin','Administrator','',0,'','','admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_MC_Valas_Save] 
	@IDX_M_Valas				BIGINT,	
	@IDX_M_Currency				INT,
	@IDX_M_ValasChange			INT,	
	@ValasName					VARCHAR(150),
	@EffectiveDate				DATE,
	@BuyValue					DECIMAL(18,4),
	@SellValue					DECIMAL(18,4),
	------------------------------------------------
	@UserID						VARCHAR(50),
	@RecordStatus				CHAR(1)		
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
		
		/** Check User Access Right **/
		--DECLARE @_FormID AS VARCHAR(20)
		--SET @_FormID = 'MS-BPAR-002'

		--DECLARE @Output INT
		--EXEC USP_SM_CheckUserForm @UserID,@_FormID, @Output OUT

		--IF @Output <> 1
		--BEGIN
		--	INSERT INTO @TableLog VALUES ('error',0,'You Dont Have Access!')
		--END
		/***************************************************************************************/
		
		/** Cek Partner Name **/
		IF RTRIM(@IDX_M_Currency) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nama mata uang belum diisi!')
		END

		IF RTRIM(@IDX_M_ValasChange) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nama pecahan mata uang belum diisi!')
		END
		
		/** Cek Duplicate Partner ID **/
		IF EXISTS(	SELECT IDX_M_ValasChange, IDX_M_Currency, IDX_M_Valas	
					FROM MC_M_Valas
					WHERE IDX_M_Currency = @IDX_M_Currency 
					AND IDX_M_ValasChange = @IDX_M_ValasChange
                    AND IDX_M_Valas <> @IDX_M_Valas)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Kode valas dengan nilai pecahan ini sudah ada!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 
			
			DECLARE @_ValasSKU				VARCHAR(50)
			DECLARE @_CurrencyID			VARCHAR(50)
			DECLARE @_ValasChangeNumber		VARCHAR(50)
			DECLARE @_ValasChangeName		VARCHAR(50)

			SELECT @_CurrencyID = CurrencyID 
			FROM MC_M_Currency
			WHERE IDX_M_Currency = @IDX_M_Currency

			SELECT @_ValasChangeNumber = ValasChangeNumber 
			FROM MC_M_ValasChange
			WHERE IDX_M_ValasChange = @IDX_M_ValasChange

			IF @IDX_M_Valas = 0
			BEGIN	
				
				SET @_ValasSKU = @_CurrencyID + '-' + @_ValasChangeNumber

				INSERT INTO [dbo].[MC_M_Valas]
				   ([IDX_M_Currency]
				   ,[IDX_M_ValasChange]
				   ,[ValasSKU]
				   ,[ValasName]
				   ,[EffectiveDate]
				   ,[BuyValue]
				   ,[SellValue]
				   ,[UCreate]
				   ,[DCreate]				   
				   ,[RecordStatus])
			 VALUES
				   (@IDX_M_Currency
                   ,@IDX_M_ValasChange
				   ,@_ValasSKU
				   ,@ValasName
                   ,@EffectiveDate
				   ,@BuyValue
				   ,@SellValue
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus)
				   				
				SET @IDX_M_Valas = (SELECT SCOPE_IDENTITY())

			END
			ELSE
			BEGIN

				UPDATE [dbo].[MC_M_Valas] SET
					 [IDX_M_Currency] = @IDX_M_Currency
					,[IDX_M_ValasChange] = @IDX_M_ValasChange
					,[ValasName] = @ValasName
					,[EffectiveDate] = @EffectiveDate	
					,[BuyValue] = @BuyValue		
					,[SellValue] = @SellValue
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_M_Valas = @IDX_M_Valas

			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Valas, 'Data Sudah Disimpan')
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

