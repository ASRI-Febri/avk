SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Update register aset tetap
--				  Nilai perolehan / umur / metode tidak boleh diubah bila
--				  aset sudah pernah disusutkan (posted) — sesuai PSAK 16
--				  perubahan estimasi ditangani terpisah (fase berikutnya)
-- =============================================

-- EXEC [dbo].[USP_FA_Asset_Update] 1,1,2,3,1,'FA/JKT/202607/0001','Mobil Operasional','Avanza 2026','2026-07-01','2026-07-01',250000000,25000000,96,'SL','2','SL',0,'INV-001','A',0,'it_febry','A'

CREATE PROCEDURE [dbo].[USP_FA_Asset_Update]
	@IDX_M_Asset			BIGINT,
	@IDX_M_Company			INT,
	@IDX_M_Branch			INT,
	@IDX_M_Department		INT,
	@IDX_M_AssetCategory	INT,
	@AssetCode				VARCHAR(50),
	@AssetName				VARCHAR(200),
	@AssetDesc				VARCHAR(5000),
	@AcquisitionDate		DATE,
	@UsageStartDate			DATE,
	@AcquisitionCost		DECIMAL(18,2),
	@ResidualValue			DECIMAL(18,2),
	@UsefulLifeMonth		INT,
	@DeprMethod				CHAR(2),
	@FiscalGroup			CHAR(2),
	@FiscalDeprMethod		CHAR(2),
	@IDX_T_PurchaseInvoice	BIGINT,
	@ReferenceNo			VARCHAR(50),
	@AssetStatus			CHAR(1),
	@OpeningAccumDepr		DECIMAL(18,2),
	@UserID					VARCHAR(36),
	@RecordStatus			VARCHAR(1)
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
		DECLARE @_CountDepr AS INT
		DECLARE @_CurrentStatus AS CHAR(1)

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF NOT EXISTS (SELECT 1 FROM FA_M_Asset WHERE IDX_M_Asset = @IDX_M_Asset)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Aset tidak ditemukan!')
		END

		SELECT @_CurrentStatus = AssetStatus
		FROM FA_M_Asset WITH(NOLOCK)
		WHERE IDX_M_Asset = @IDX_M_Asset

		IF @_CurrentStatus IN ('S','W','H')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Aset sudah dilepas (dijual/hapus buku/hibah), tidak dapat diubah!')
		END

		IF ISNULL(@IDX_M_AssetCategory,0) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kategori aset belum dipilih!')
		END

		IF RTRIM(ISNULL(@AssetName,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nama aset belum diisi!')
		END

		IF @UsageStartDate < @AcquisitionDate
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal mulai pakai tidak boleh sebelum tanggal perolehan!')
		END

		IF ISNULL(@AcquisitionCost,0) <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Harga perolehan harus lebih dari 0!')
		END

		IF ISNULL(@ResidualValue,0) < 0 OR ISNULL(@ResidualValue,0) >= ISNULL(@AcquisitionCost,0)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nilai residu tidak valid! Harus >= 0 dan lebih kecil dari harga perolehan.')
		END

		IF ISNULL(@UsefulLifeMonth,0) <= 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Umur manfaat (bulan) harus lebih dari 0!')
		END

		IF RTRIM(ISNULL(@DeprMethod,'')) NOT IN ('SL','DB')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Metode penyusutan tidak valid! Gunakan SL (Garis Lurus) atau DB (Saldo Menurun).')
		END

		IF EXISTS (
			SELECT 1 FROM FA_M_Asset
			WHERE RTRIM(ISNULL(AssetCode,'')) = RTRIM(ISNULL(@AssetCode,''))
				AND IDX_M_Asset <> @IDX_M_Asset
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode aset ' + RTRIM(@AssetCode) + ' sudah terdaftar!')
		END

		-- Aset yang sudah pernah disusutkan (posted) tidak boleh ubah nilai dasar penyusutan
		SELECT @_CountDepr = COUNT(*)
		FROM FA_T_DepreciationDetail DD WITH(NOLOCK)
			INNER JOIN FA_T_Depreciation D WITH(NOLOCK) ON DD.IDX_T_Depreciation = D.IDX_T_Depreciation
		WHERE DD.IDX_M_Asset = @IDX_M_Asset
			AND D.DeprStatus = 'P'
			AND DD.RecordStatus = 'A'

		IF @_CountDepr > 0
		BEGIN
			IF EXISTS (
				SELECT 1 FROM FA_M_Asset
				WHERE IDX_M_Asset = @IDX_M_Asset
					AND (ISNULL(AcquisitionCost,0) <> ISNULL(@AcquisitionCost,0)
						OR ISNULL(ResidualValue,0) <> ISNULL(@ResidualValue,0)
						OR ISNULL(UsefulLifeMonth,0) <> ISNULL(@UsefulLifeMonth,0)
						OR RTRIM(ISNULL(DeprMethod,'')) <> RTRIM(ISNULL(@DeprMethod,''))
						OR ISNULL(OpeningAccumDepr,0) <> ISNULL(@OpeningAccumDepr,0))
			)
			BEGIN
				INSERT INTO @TableLog VALUES ('error', 0, 'Aset sudah memiliki penyusutan yang diposting! Harga perolehan, residu, umur manfaat, metode dan saldo awal tidak dapat diubah.')
			END
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			UPDATE [dbo].[FA_M_Asset] SET
				 [IDX_M_Company]			= @IDX_M_Company
				,[IDX_M_Branch]				= @IDX_M_Branch
				,[IDX_M_Department]			= NULLIF(@IDX_M_Department,0)
				,[IDX_M_AssetCategory]		= @IDX_M_AssetCategory
				,[AssetCode]				= @AssetCode
				,[AssetName]				= @AssetName
				,[AssetDesc]				= @AssetDesc
				,[AcquisitionDate]			= @AcquisitionDate
				,[UsageStartDate]			= @UsageStartDate
				,[AcquisitionCost]			= @AcquisitionCost
				,[ResidualValue]			= @ResidualValue
				,[UsefulLifeMonth]			= @UsefulLifeMonth
				,[DeprMethod]				= @DeprMethod
				,[FiscalGroup]				= @FiscalGroup
				,[FiscalDeprMethod]			= @FiscalDeprMethod
				,[IDX_T_PurchaseInvoice]	= NULLIF(@IDX_T_PurchaseInvoice,0)
				,[ReferenceNo]				= @ReferenceNo
				,[AssetStatus]				= @AssetStatus
				,[OpeningAccumDepr]			= @OpeningAccumDepr
				,[RecordStatus]				= @RecordStatus
				,[UModified]				= @UserID
				,[DModified]				= GETDATE()
			WHERE IDX_M_Asset = @IDX_M_Asset

			INSERT INTO @TableLog VALUES ('success', @IDX_M_Asset, 'Data berhasil disimpan.')
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
