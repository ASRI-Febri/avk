/*	
	BEGIN TRAN
		EXEC [dbo].[USP_CM_FakturNumber_Create] '2020','admin','A'
	ROLLBACK TRAN
*/

CREATE PROCEDURE [dbo].[USP_CM_FakturNumber_Create] 	
	@PeriodYear					VARCHAR(4),
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

		IF EXISTS (SELECT '' FROM CM_M_FakturNumber WHERE RecordStatus = 'A' AND LEFT(PeriodFaktur,4) = @PeriodYear)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Period Faktur is already exists!')
		END
		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			

			INSERT INTO CM_M_FakturNumber
			(
				PeriodFaktur, DCreate, UCreate, RecordStatus
			)
			SELECT	@PeriodYear + RIGHT('00' + CONVERT(VARCHAR,number),2), @GlobalDateTime, @UserID, 'A'
			FROM master..spt_values 
			WHERE type ='p' 
			AND number BETWEEN 1 AND 12


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



