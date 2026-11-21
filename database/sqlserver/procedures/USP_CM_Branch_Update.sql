-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 29 Jan 2018
-- Description:	Update Table Master Branch
-- =============================================

/*		
	EXEC [dbo].[USP_CM_Branch_Update] 
		1,1,1,
		1,,1,
		'G12345',NULL,'2017-01-12',
		'2017-01-12','TEST',1,						
		1000000,10000,0,
		0,'D',
		'admin','A'	
*/

CREATE PROCEDURE [dbo].[USP_CM_Branch_Update] 
	@IDX_M_Branch				BIGINT,	
	@IDX_M_Parent				INT,
	@IDX_M_Company				INT,
	@BranchID					VARCHAR(50),
	@BranchName					VARCHAR(250),
	@BranchAlias				VARCHAR(50),
	@BranchAddress				VARCHAR(500),
	@IDX_M_LocationInventory	INT,
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
											Update Master Branch
			--------------------------------------------------------------------------------**/
			UPDATE [dbo].[GN_M_Branch] SET 
				 [IDX_M_Parent] = @IDX_M_Parent
				,[IDX_M_Company] = @IDX_M_Company
				,[BranchID] = @BranchID
				,[BranchName] = @BranchName
				,[BranchAlias] = @BranchAlias
				,[BranchAddress] = @BranchAddress
				,[IDX_M_LocationInventory] = @IDX_M_LocationInventory				
				,[DModified] = GETDATE()
				,[UModified] = @UserID				
				,[RecordStatus] = @RecordStatus
			WHERE IDX_M_Branch = @IDX_M_Branch					

			/**********************************************************************************************************/
			INSERT INTO @TableLog VALUES ('success', @IDX_M_Branch, 'Data Sudah Disimpan')
				
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


