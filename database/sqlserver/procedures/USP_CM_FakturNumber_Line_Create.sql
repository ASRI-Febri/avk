/*	
	BEGIN TRAN
		EXEC [dbo].[USP_CM_FakturNumber_Line_Create] 1, 1, 1, 5, 20, 1999002, 'A'
	ROLLBACK TRAN

	SELECT * FROM CM_M_FakturNumberLine
*/

CREATE PROCEDURE [dbo].[USP_CM_FakturNumber_Line_Create] 	
	@IDX_M_FakturNumber			BIGINT,
	@Qty						INT,
	@StartingNo					VARCHAR(32), -- FakturNumber
	@PrefixNo					VARCHAR(3) = NULL,
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

		DECLARE @GlobalDateTime DATETIME = SYSDATETIME()
		
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

		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			
			--DECLARE @MaxLoop VARCHAR(32)
			--SET @MaxLoop = @StartingNo + @Qty
			--WHILE @StartingNo < @MaxLoop
			--BEGIN
			--	INSERT INTO CM_M_FakturNumberLine(
			--		IDX_M_FakturNumber, FakturNumber, DCreate, UCreate, RecordStatus
			--	) 
			--	VALUES (@IDX_M_FakturNumber, @StartingNo, GETDATE(), @UserID, 'A')

			--	SET @StartingNo = (@StartingNo + 1);
			--END;
			



			DECLARE @x INT = 0

			WHILE @x < @Qty
			BEGIN

				DECLARE @PrefixNo_ VARCHAR(250), @Pad3 INT = 3


				SET @PrefixNo_ = CONVERT(numeric,@PrefixNo) 
			
				IF(@Pad3 > LEN(@PrefixNo_))
					SET @PrefixNo_ = REPLICATE('0', @Pad3 - LEN(@PrefixNo_)) + @PrefixNo_;
				

				DECLARE @NumStr VARCHAR(250), @Pad INT = 13


				SET @NumStr = CONVERT(numeric,@StartingNo) + @x
			
				IF(@pad > LEN(@NumStr))
					SET @NumStr = REPLICATE('0', @Pad - LEN(@NumStr)) + @NumStr;


				INSERT INTO CM_M_FakturNumberLine(
					IDX_M_FakturNumber, FakturNumber, DCreate, UCreate, RecordStatus
				) 
				VALUES (@IDX_M_FakturNumber, @PrefixNo_ + '.'+ LEFT(@NumStr,3) + '-' + SUBSTRING(@NumStr,4,2) + '.' + RIGHT(@NumStr,8) , GETDATE(), @UserID, 'A')

				SET @x += 1

			END


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



