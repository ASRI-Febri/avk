SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Samuel Febrianto
-- Create date	: 19 Jul 2026
-- Description	: Insert register aset tetap baru
--				  AssetCode dikosongkan = generate otomatis via USP_FA_Asset_GenerateCode
-- =============================================

-- EXEC [dbo].[USP_FA_Asset_Create] 1,2,3,1,'','Mobil Operasional','Avanza 2026','2026-07-01','2026-07-01',250000000,25000000,96,'SL','2','SL',0,'INV-001','A',0,'it_febry','A'

CREATE PROCEDURE [dbo].[USP_FA_Asset_Create]
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
		DECLARE @_IDX_M_Asset AS BIGINT
		DECLARE @_AssetCode AS VARCHAR(50)

		SET @_AssetCode = RTRIM(ISNULL(@AssetCode,''))

		-- ==================================================
		-- VALIDASI
		-- ==================================================
		IF ISNULL(@IDX_M_AssetCategory,0) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kategori aset belum dipilih!')
		END

		IF RTRIM(ISNULL(@AssetName,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Nama aset belum diisi!')
		END

		IF @AcquisitionDate IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal perolehan belum diisi!')
		END

		IF @UsageStartDate IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Tanggal mulai pakai belum diisi!')
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

		IF ISNULL(@OpeningAccumDepr,0) > (ISNULL(@AcquisitionCost,0) - ISNULL(@ResidualValue,0))
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Akumulasi penyusutan saldo awal melebihi dasar penyusutan (harga perolehan - residu)!')
		END

		-- Generate kode aset bila kosong
		IF @_AssetCode = ''
		BEGIN
			DECLARE @_BranchID	VARCHAR(20)
			DECLARE @_Period	VARCHAR(6)
			DECLARE @_Prefix	VARCHAR(40)
			DECLARE @_LastSeq	INT

			SELECT @_BranchID = RTRIM(ISNULL(BranchID,'XX'))
			FROM GN_M_Branch WITH(NOLOCK)
			WHERE IDX_M_Branch = @IDX_M_Branch

			SET @_Period = CONVERT(VARCHAR(6), ISNULL(@AcquisitionDate, GETDATE()), 112)
			SET @_Prefix = 'FA/' + ISNULL(@_BranchID,'XX') + '/' + @_Period + '/'

			SELECT @_LastSeq = ISNULL(MAX(CONVERT(INT, RIGHT(RTRIM(AssetCode), 4))), 0)
			FROM FA_M_Asset WITH(NOLOCK)
			WHERE AssetCode LIKE @_Prefix + '%'
				AND ISNUMERIC(RIGHT(RTRIM(AssetCode), 4)) = 1

			SET @_AssetCode = @_Prefix + RIGHT('0000' + CONVERT(VARCHAR, @_LastSeq + 1), 4)
		END

		IF EXISTS (
			SELECT 1 FROM FA_M_Asset
			WHERE RTRIM(ISNULL(AssetCode,'')) = @_AssetCode
				AND RecordStatus = 'A'
		)
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Kode aset ' + @_AssetCode + ' sudah terdaftar!')
		END

		-- ==================================================
		-- PROSES SIMPAN
		-- ==================================================
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN

			INSERT INTO [dbo].[FA_M_Asset]
				([IDX_M_Company]
				,[IDX_M_Branch]
				,[IDX_M_Department]
				,[IDX_M_AssetCategory]
				,[AssetCode]
				,[AssetName]
				,[AssetDesc]
				,[AcquisitionDate]
				,[UsageStartDate]
				,[AcquisitionCost]
				,[ResidualValue]
				,[UsefulLifeMonth]
				,[DeprMethod]
				,[FiscalGroup]
				,[FiscalDeprMethod]
				,[IDX_T_PurchaseInvoice]
				,[ReferenceNo]
				,[AssetStatus]
				,[OpeningAccumDepr]
				,[RecordStatus]
				,[UCreate]
				,[DCreate])
			VALUES
				(@IDX_M_Company
				,@IDX_M_Branch
				,NULLIF(@IDX_M_Department,0)
				,@IDX_M_AssetCategory
				,@_AssetCode
				,@AssetName
				,@AssetDesc
				,@AcquisitionDate
				,@UsageStartDate
				,@AcquisitionCost
				,@ResidualValue
				,@UsefulLifeMonth
				,@DeprMethod
				,@FiscalGroup
				,@FiscalDeprMethod
				,NULLIF(@IDX_T_PurchaseInvoice,0)
				,@ReferenceNo
				,@AssetStatus
				,@OpeningAccumDepr
				,@RecordStatus
				,@UserID
				,GETDATE())

			SET @_IDX_M_Asset = SCOPE_IDENTITY()

			INSERT INTO @TableLog VALUES ('success', @_IDX_M_Asset, 'Data berhasil disimpan. Kode aset: ' + @_AssetCode)
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
