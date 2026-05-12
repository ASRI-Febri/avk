SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Create and update sales order for money changer 
-- =============================================

/*		
	EXEC [dbo].[USP_MC_SalesOrder_Save] 'Admin','Administrator','',0,'','','admin','A'	
    EXEC [dbo].[USP_MC_SalesOrder_Save] 0,1,1,1,'','-','2025-06-16','Pembelian stok awal','D','it_febry','A'
*/

CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_Save] 
	@IDX_T_SalesOrder		BIGINT,	
	@IDX_M_Company				INT,
	@IDX_M_Branch				INT,	
	@IDX_M_Partner				INT,
	@SONumber					VARCHAR(50),
    @ReferenceNo                VARCHAR(50),
	@FundSource					VARCHAR(150),
	@TransactionPurpose			VARCHAR(150),
	@SODate						DATE,
	@SONotes					VARCHAR(5000),
	@SOStatus					CHAR(1),
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
		IF RTRIM(@IDX_M_Company) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Perusahaan uang belum diisi!')
		END

		IF RTRIM(@IDX_M_Branch) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Cabang belum diisi!')
		END
		
		IF RTRIM(@ReferenceNo) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nomor nota belum diisi!')
		END

		IF EXISTS(SELECT 1 FROM [dbo].[MC_T_SalesOrder] WHERE RTRIM(@ReferenceNo) = RTRIM(ReferenceNo) AND IDX_T_SalesOrder <> @IDX_T_SalesOrder)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nomor nota sudah digunakan!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			IF @IDX_T_SalesOrder = 0
			BEGIN

				INSERT INTO [dbo].[MC_T_SalesOrder]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Partner]
				   ,[IDX_M_DocumentType]
				   ,[SONumber]
                   ,[ReferenceNo]
				   ,[FundSource]
				   ,[TransactionPurpose]
				   ,[SODate]
				   ,[SONotes]
				   ,[SOStatus]                   
				   ,[UCreate]
				   ,[DCreate]				   
				   ,[RecordStatus])
			 VALUES
				   (@IDX_M_Company
                   ,@IDX_M_Branch
				   ,@IDX_M_Partner
				   ,12
				   ,@SONumber
                   ,@ReferenceNo
				   ,@FundSource
				   ,@TransactionPurpose
				   ,@SODate
                   ,@SONotes
				   ,@SOStatus
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus)
				   				
				SET @IDX_T_SalesOrder = (SELECT SCOPE_IDENTITY())

				UPDATE [dbo].[MC_T_SalesOrder]
				SET SONumber = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_SalesOrder))
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

			END
			ELSE
			BEGIN

				UPDATE [dbo].[MC_T_SalesOrder] SET
					 [IDX_M_Company] = @IDX_M_Company
					,[IDX_M_Branch] = @IDX_M_Branch
					,[IDX_M_Partner] = @IDX_M_Partner
					,[SONumber] = @SONumber
                    ,[ReferenceNo] = @ReferenceNo
					,[FundSource] = @FundSource
					,[TransactionPurpose] = @TransactionPurpose
					,[SODate] = @SODate	
					,[SONotes] = @SONotes		
					,[SOStatus] = @SOStatus
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_T_SalesOrder, 'Data Sudah Disimpan')
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

GO
