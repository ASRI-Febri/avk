SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Update kategori aset tetap
-- =============================================

-- EXEC [dbo].[USP_FA_AssetCategory_Update] 1,1,'BLD','Bangunan',10,20,30,40,50,240,'SL','BP','it_febry','A'

CREATE PROCEDURE [dbo].[USP_FA_AssetCategory_Update]
	@IDX_M_AssetCategory		INT,
	@IDX_M_Company				INT,
	@CategoryCode				VARCHAR(20),
	@CategoryName				VARCHAR(100),
	@IDX_M_COA_Asset			BIGINT,
	@IDX_M_COA_AccumDepr		BIGINT,
	@IDX_M_COA_DeprExpense		BIGINT,
	@IDX_M_COA_GainDisposal		BIGINT,
	@IDX_M_COA_LossDisposal		BIGINT,
	@DefaultUsefulLifeMonth		INT,
	@DefaultDeprMethod			CHAR(2),
	@FiscalGroup				CHAR(2),
	@UserID						VARCHAR(36),
	@RecordStatus				VARCHAR(1)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF NOT EXISTS (SELECT 1 FROM FA_M_AssetCategory WHERE IDX_M_AssetCategory = @IDX_M_AssetCategory)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kategori aset tidak ditemukan!')
		END

		IF RTRIM(ISNULL(@CategoryCode,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode kategori belum diisi!')
		END

		IF RTRIM(ISNULL(@CategoryName,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nama kategori belum diisi!')
		END

		IF RTRIM(ISNULL(@DefaultDeprMethod,'')) NOT IN ('SL','DB')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Metode penyusutan tidak valid! Gunakan SL (Garis Lurus) atau DB (Saldo Menurun).')
		END

		IF ISNULL(@DefaultUsefulLifeMonth,0) <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Umur manfaat (bulan) harus lebih dari 0!')
		END

		IF ISNULL(@IDX_M_COA_Asset,0) = 0 OR ISNULL(@IDX_M_COA_AccumDepr,0) = 0 OR ISNULL(@IDX_M_COA_DeprExpense,0) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Akun Aset, Akumulasi Penyusutan dan Beban Penyusutan wajib dipilih!')
		END

		IF EXISTS (
			SELECT 1 FROM FA_M_AssetCategory
			WHERE RTRIM(ISNULL(CategoryCode,'')) = RTRIM(@CategoryCode)
				AND IDX_M_AssetCategory <> @IDX_M_AssetCategory
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode kategori ' + RTRIM(@CategoryCode) + ' sudah terdaftar!')
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			UPDATE [dbo].[FA_M_AssetCategory] SET
				 [IDX_M_Company]			= @IDX_M_Company
				,[CategoryCode]				= @CategoryCode
				,[CategoryName]				= @CategoryName
				,[IDX_M_COA_Asset]			= @IDX_M_COA_Asset
				,[IDX_M_COA_AccumDepr]		= @IDX_M_COA_AccumDepr
				,[IDX_M_COA_DeprExpense]	= @IDX_M_COA_DeprExpense
				,[IDX_M_COA_GainDisposal]	= NULLIF(@IDX_M_COA_GainDisposal,0)
				,[IDX_M_COA_LossDisposal]	= NULLIF(@IDX_M_COA_LossDisposal,0)
				,[DefaultUsefulLifeMonth]	= @DefaultUsefulLifeMonth
				,[DefaultDeprMethod]		= @DefaultDeprMethod
				,[FiscalGroup]				= @FiscalGroup
				,[RecordStatus]				= @RecordStatus
				,[UModified]				= @UserID
				,[DModified]				= GETDATE()
			WHERE IDX_M_AssetCategory = @IDX_M_AssetCategory

			INSERT INTO @TableLog VALUES ('success', @IDX_M_AssetCategory, 'Data berhasil disimpan.')
		END

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE())

		SELECT * FROM @TableLog

		IF (XACT_STATE()) = -1
		BEGIN
			PRINT N'The transaction is in an uncommittable state. Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		IF (XACT_STATE()) = 1
		BEGIN
			PRINT N'The transaction is committable. Committing transaction.'
			COMMIT TRANSACTION;
		END;

	END CATCH;

END
GO
