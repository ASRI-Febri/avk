
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 25 Mar 2023
-- Description	: Save business partner bank
-- =============================================

/*		
	EXEC [dbo].[USP_GN_PartnerBank_Save] 1,2,2,2,'Trial street update','36135','Trial street update','XA.ADMIN','A'	
*/

CREATE PROCEDURE [dbo].[USP_GN_PartnerBank_Save] 
	@IDX_M_PartnerBank		BIGINT,	
	@IDX_M_Partner			BIGINT,
	@IDX_M_Bank				BIGINT,
	@IsDefault				CHAR(1),
	@BankAccountNo			VARCHAR(20),	
	@BankAccountName		VARCHAR(50),
	@BankAccountBranch		VARCHAR(50),
	@Remarks				VARCHAR(1000),
	------------------------------------------------
	@UserID					VARCHAR(10),
	@RecordStatus			CHAR(1)		
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
		IF RTRIM(@BankAccountNo) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Bank Account No is required!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			IF @IDX_M_PartnerBank = 0
			BEGIN
				INSERT INTO [dbo].[GN_M_PartnerBank](
					 IDX_M_Partner
					,IDX_M_Bank
					,IsDefault					
					,BankAccountNo
					,BankAccountBranch
					,BankAccountName
					,Remarks
					,DCreate
					,UCreate
					,RecordStatus)
				VALUES (
					 @IDX_M_Partner
					,@IDX_M_Bank
					,@IsDefault					
					,@BankAccountNo
					,@BankAccountBranch
					,@BankAccountName
					,@Remarks
					,GETDATE()
					,@UserID
					,@RecordStatus)
				   				
				SET @IDX_M_PartnerBank = (SELECT SCOPE_IDENTITY())	
			END
			ELSE
			BEGIN
				UPDATE [dbo].[GN_M_PartnerBank] SET
					 [IDX_M_Partner] = @IDX_M_Partner		
					,[IDX_M_Bank] = @IDX_M_Bank
					,[IsDefault] = @IsDefault
					,[BankAccountNo] = @BankAccountNo				
					,[BankAccountName] = @BankAccountName
					,[BankAccountBranch] = @BankAccountBranch
					,[Remarks] = @Remarks	
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus]	= @RecordStatus
				WHERE IDX_M_PartnerBank = @IDX_M_PartnerBank		
				
			END

			INSERT INTO @TableLog VALUES ('success', @IDX_M_Partner, 'Data Sudah Disimpan')

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

