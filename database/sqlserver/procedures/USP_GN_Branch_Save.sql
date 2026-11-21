
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 03 June 2023
-- Description:	Save table GN_M_Branch
-- =============================================

--EXEC [dbo].USP_GN_Branch_Save @IDX_M_BrandItem,'@BrandID','@BrandDesc','@BrandInitial','@UserID','@RecordStatus'

CREATE PROCEDURE [dbo].[USP_GN_Branch_Save] 
	@IDX_M_Branch				INT,
	@IDX_M_Parent				INT,
	@IDX_M_Company				INT,
	@IDX_M_LocationInventory	INT,
	@BranchID					VARCHAR(20),
	@BranchName					VARCHAR(50),
	@BranchAlias				VARCHAR(150),	
	@BranchAddress				VARCHAR(250),	
	@BranchRemark				VARCHAR(250),
	@COASales					INT,
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

		IF EXISTS (SELECT 1 FROM GN_M_Branch WHERE BranchID = @BranchID AND IDX_M_Branch <> @IDX_M_Branch)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Branch ID already exists!')
		END			
		--------------------------------------------------------------------------------------

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			IF @IDX_M_Branch = 0
			BEGIN				

				INSERT INTO [dbo].[GN_M_Branch]
				   ([IDX_M_Parent]
				   ,[IDX_M_Company]
				   ,[IDX_M_LocationInventory]
				   ,[BranchID]
				   ,[BranchName]
				   ,[BranchAlias]
				   ,[BranchAddress]		
				   ,[BranchRemark] 
				   ,[COASales]
				   ,[DCreate]
				   ,[UCreate]				   
				   ,[RecordStatus])
				VALUES
				   (@IDX_M_Parent
				   ,@IDX_M_Company
				   ,@IDX_M_LocationInventory
				   ,@BranchID
				   ,@BranchName
				   ,@BranchAlias
				   ,@BranchAddress	
				   ,@BranchRemark
				   ,@COASales
				   ,GETDATE()
				   ,@UserID
				   ,@RecordStatus)

			END
			ELSE
			BEGIN
				UPDATE [dbo].[GN_M_Branch]
				SET 
					 [IDX_M_Parent] = @IDX_M_Parent
					,[IDX_M_Company] = @IDX_M_Company
					,[IDX_M_LocationInventory] = @IDX_M_LocationInventory
					,[BranchID] = @BranchID 
					,[BranchName] = @BranchName
					,[BranchAlias] = @BranchAlias
					,[BranchAddress] = @BranchAddress
					,[BranchRemark] = @BranchRemark
					,[COASales] = @COASales
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_M_Branch = @IDX_M_Branch	
			END
			
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


