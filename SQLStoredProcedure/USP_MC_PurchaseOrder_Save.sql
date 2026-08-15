USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Revisi 13 Agustus 2026: Save tidak lagi menimpa nomor sistem dan status transaksi.

IF OBJECT_ID('[dbo].[USP_MC_PurchaseOrder_Save]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_PurchaseOrder_Save]
GO

-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 04 Jun 2025
-- Description:	Create and update purchase order for money changer 
-- =============================================

/*		
	EXEC [dbo].[USP_MC_PurchaseOrder_Save] 'Admin','Administrator','',0,'','','admin','A'	
    EXEC [dbo].[USP_MC_PurchaseOrder_Save] 0,1,1,1,'','-','2025-06-16','Pembelian stok awal','D','it_febry','A'
*/

CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrder_Save] 
	@IDX_T_PurchaseOrder		BIGINT,	
	@IDX_M_Company				INT,
	@IDX_M_Branch				INT,	
	@IDX_M_Partner				INT,
	@PONumber					VARCHAR(50),
    @ReferenceNo                VARCHAR(50),
	@PODate						DATE,
	@PONotes					VARCHAR(5000),
	@POStatus					CHAR(1),
	------------------------------------------------
	@UserID						VARCHAR(50),
	@RecordStatus				CHAR(1),
	------------------------------------------------
	-- Sengaja di akhir dan boleh kosong: pemanggil lama hanya mengirim 11
	-- parameter. NULL berarti "jangan ubah", supaya menyimpan dari form
	-- pembelian penuh tidak menghapus isian dari input cepat.
	@FundSource					VARCHAR(250) = NULL,
	@TransactionPurpose			VARCHAR(250) = NULL
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

		IF EXISTS(SELECT 1 FROM [dbo].[MC_T_PurchaseOrder] WHERE RTRIM(@ReferenceNo) = RTRIM(ReferenceNo) AND IDX_T_PurchaseOrder <> @IDX_T_PurchaseOrder)
		BEGIN
			INSERT INTO @TableLog VALUES ('error',0,'Nomor nota sudah digunakan!')
		END

		/** If no error occured **/		
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN 

			IF @IDX_T_PurchaseOrder = 0
			BEGIN

				INSERT INTO [dbo].[MC_T_PurchaseOrder]
				   ([IDX_M_Company]
				   ,[IDX_M_Branch]
				   ,[IDX_M_Partner]
				   ,[PONumber]
                   ,[ReferenceNo]
				   ,[PODate]
				   ,[PONotes]
				   ,[POStatus]                   
				   ,[FundSource]
				   ,[TransactionPurpose]
				   ,[UCreate]
				   ,[DCreate]				   
				   ,[RecordStatus])
			 	VALUES
				   (@IDX_M_Company
                   ,@IDX_M_Branch
				   ,@IDX_M_Partner
				   ,@PONumber
                   ,@ReferenceNo
				   ,@PODate
                   ,@PONotes
				   ,@POStatus
				   ,ISNULL(@FundSource,'')
				   ,ISNULL(@TransactionPurpose,'')
				   ,@UserID
				   ,GETDATE()			  
				   ,@RecordStatus)
				   				
				SET @IDX_T_PurchaseOrder = (SELECT SCOPE_IDENTITY())

				UPDATE [dbo].[MC_T_PurchaseOrder]
				SET PONumber = 'DRAFT-' + RTRIM(CONVERT(VARCHAR,@IDX_T_PurchaseOrder))
				WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

			END
			ELSE
			BEGIN

				-- PONumber dan POStatus SENGAJA TIDAK DIIKUTSERTAKAN.
				-- Keduanya milik sistem: nomor dibuat saat approval
				-- ([USP_MC_PurchaseOrder_Approve]) dan status diatur oleh proses
				-- approve/reverse. Dulu keduanya ditimpa dari hidden field form,
				-- sehingga halaman yang dibuka sebelum approval lalu di-Save bisa
				-- mengembalikan nota pembelian yang sudah Approved menjadi
				-- DRAFT-xxxx kembali, padahal kartu stok, jurnal dan pembayarannya
				-- sudah terlanjur mengacu ke nomor lama.
				UPDATE [dbo].[MC_T_PurchaseOrder] SET
					 [IDX_M_Company] = @IDX_M_Company
					,[IDX_M_Branch] = @IDX_M_Branch
					,[IDX_M_Partner] = @IDX_M_Partner
                    ,[ReferenceNo] = @ReferenceNo
					,[PODate] = @PODate	
					,[PONotes] = @PONotes		
					,[FundSource] = ISNULL(@FundSource, [FundSource])
					,[TransactionPurpose] = ISNULL(@TransactionPurpose, [TransactionPurpose])
					,[UModified] = @UserID
					,[DModified] = GETDATE()
					,[RecordStatus] = @RecordStatus
				WHERE IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

			END
		
			INSERT INTO @TableLog VALUES ('success', @IDX_T_PurchaseOrder, 'Data Sudah Disimpan')
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
