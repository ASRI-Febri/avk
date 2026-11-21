
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 11 Dec 2025
-- Description:	Create and update open and closing daily detail
-- =============================================

/*		
	EXEC [dbo].[USP_MC_OpenCloseDailyDetail_Save] 'Admin','Administrator','',0,'','','admin','A'	    
*/

CREATE PROCEDURE [dbo].[USP_MC_OpenCloseDailyDetail_Save] 
    @IDX_T_OpenCloseDailyDetail     BIGINT,
    @IDX_T_OpenCloseDaily		    BIGINT,	
    @IDX_M_Valas                    INT,
	@OpenQty                        DECIMAL(18,2),
    @InQty                          DECIMAL(18,2),
    @OutQty                         DECIMAL(18,2),
    @CloseQty                       DECIMAL(18,2),
    @DiffQty                        DECIMAL(18,2),
    @DetailNotes                    VARCHAR(5000),
	------------------------------------------------
	@UserID						    VARCHAR(50),
	@RecordStatus				    CHAR(1)		
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
		
		
		
        IF @IDX_T_OpenCloseDailyDetail = 0 AND EXISTS(
            SELECT IDX_T_OpenCloseDaily 
            FROM MC_T_OpenCloseDailyDetail 
            WHERE IDX_T_OpenCloseDaily = @IDX_T_OpenCloseDaily AND IDX_M_Valas = @IDX_M_Valas
        )
        BEGIN 
            INSERT INTO @TableLog VALUES ('error',0,'Data valas ini sudah ada!')
        END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			IF @IDX_T_OpenCloseDailyDetail = 0
			BEGIN
				
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
                VALUES (
                    @IDX_T_OpenCloseDaily
                    ,@IDX_M_Valas
                    ,@OpenQty
                    ,@InQty
                    ,@OutQty
                    ,@DiffQty
                    ,@DetailNotes
                    ,@UserID
                    ,GETDATE()
                    ,@RecordStatus
                )

                SET @IDX_T_OpenCloseDailyDetail = (SELECT SCOPE_IDENTITY())

			END
			ELSE
			BEGIN

				UPDATE [dbo].[MC_T_OpenCloseDailyDetail] SET
					 [OpenQty] = @OpenQty	
					,[InQty] = @InQty
                    ,[OutQty] = @OutQty
                    ,[DiffQty] = @DiffQty
					,[CloseQty] = @CloseQty
                    ,[DetailNotes] = @DetailNotes
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_T_OpenCloseDailyDetail = @IDX_T_OpenCloseDailyDetail

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

