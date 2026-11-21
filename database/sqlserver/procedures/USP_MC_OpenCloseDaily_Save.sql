
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Create and update open and closing daily
-- =============================================

/*		
	EXEC [dbo].[USP_MC_OpenCloseDaily_Save] 'Admin','Administrator','',0,'','','admin','A'	    
*/

CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDaily_Save] 
	@IDX_T_OpenCloseDaily		BIGINT,	
	@TransactionDate    		DATE,	
	@TransactionStatus			CHAR(1),
    @TellerID                   VARCHAR(50),
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
		IF RTRIM(@TellerID) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Teller belum diisi!')
		END

		IF RTRIM(@TransactionStatus) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Status belum diisi!')
		END
		
        IF @IDX_T_OpenCloseDaily = 0 AND EXISTS(
            SELECT IDX_T_OpenCloseDaily 
			FROM MC_T_OpenCloseDaily 
            WHERE CONVERT(DATE, TransactionDate) = @TransactionDate
        )
        BEGIN 
            INSERT INTO @TableLog VALUES ('error',0,'Data transaksi hari ini sudah ada!')
        END

		IF @IDX_T_OpenCloseDaily = 0 AND EXISTS(
            SELECT IDX_T_OpenCloseDaily 
			FROM MC_T_OpenCloseDaily 
            WHERE TransactionStatus <> 'C' AND CONVERT(DATE, TransactionDate) <> @TransactionDate
        )
        BEGIN 
            INSERT INTO @TableLog VALUES ('error',0,'Masih ada transaksi perhitungan yang belum diselesaikan!')
        END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			IF @IDX_T_OpenCloseDaily = 0
			BEGIN

				INSERT INTO [dbo].[MC_T_OpenCloseDaily]
				   ([TransactionDate]
				   ,[TransactionStatus]                   
                   ,[TellerID]
				   ,[UCreate]
				   ,[DCreate]				   
				   ,[RecordStatus])
			 VALUES
				   (@TransactionDate
                   ,@TransactionStatus
                   ,@TellerID
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus)
				   				
				SET @IDX_T_OpenCloseDaily = (SELECT SCOPE_IDENTITY())

                -- INSERT DETAIL BASED ON VALAS
                INSERT INTO MC_T_OpenCloseDailyDetail
                    (IDX_T_OpenCloseDaily
                    ,IDX_M_Valas
                    ,OpenQty
                    ,InQty
                    ,OutQty
                    ,DiffQty
                    ,DetailNotes
                    ,UCreate
                    ,DCreate
                    ,RecordStatus)
                SELECT @IDX_T_OpenCloseDaily, IDX_M_Valas, 0, 0, 0, 0, 
                    'Persiapan harian ' + CONVERT(VARCHAR, @TransactionDate, 106),
                    @UserID, GETDATE(), 'A'  
                FROM MC_M_Valas
                WHERE RecordStatus = 'A'
                ORDER BY IDX_M_Currency, IDX_M_Valas

			END
			ELSE
			BEGIN

				UPDATE [dbo].[MC_T_OpenCloseDaily] SET
					 [TransactionDate] = @TransactionDate	
					,[TransactionStatus] = @TransactionStatus
                    ,[TellerID] = @TellerID
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily

			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_T_OpenCloseDaily, 'Data Sudah Disimpan')
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

