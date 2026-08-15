/*
	FIX_Partner_NIKGanda_KelompokA_20260815.sql

	Menggabungkan empat pasang konsumen ber-NIK sama, kelompok A: data yang
	dibuang sama sekali belum dipakai transaksi, jadi tidak ada nota, jurnal,
	penerimaan, maupun pembayaran yang perlu dipindah.

	Pasangannya (dipertahankan <- dibuang):
		10572 BP-2600613 ALEXANDER WILSON WALEAN <- 10574 BP-2600615
		10194 BP-2600235 Sri Ulina               <- 10992 BP-2601033 SRI UNILA
		10300 BP-2600341 IR H ALWIE SYAROFIE     <- 61330 BP-2601440 IR H WIE SYAROFIE
		   99 BP-2600092 Khresna Nurmansyah      <- 10406 BP-2600447 KHRESNA NURMANSYAH

	Yang dipertahankan adalah data yang sudah punya riwayat transaksi.

	Alamat diperlakukan begini: bila yang dipertahankan belum punya alamat,
	alamat milik data yang dibuang dipindahkan ke sana supaya keterangan
	alamatnya tidak hilang; bila sudah punya, alamat kembarnya ikut dibuang.

	Baris yang dihapus disalin lebih dulu ke tabel cadangan, jadi bisa
	dikembalikan bila ternyata keliru.

	Dijalankan sekali di AVKDB pada 15 Agustus 2026.
*/

USE [AVKDB]
GO

SET XACT_ABORT ON
GO

BEGIN TRANSACTION

	/* ---------- 1. Tabel cadangan ---------- */
	IF OBJECT_ID('dbo.GN_M_Partner_MergeBackup_20260815', 'U') IS NULL
		CREATE TABLE dbo.GN_M_Partner_MergeBackup_20260815 (
			IDX_M_Partner		BIGINT,
			IDX_Dipertahankan	BIGINT,
			PartnerID			VARCHAR(50),
			PartnerName			VARCHAR(150),
			SingleIdentityNumber VARCHAR(64),
			MobilePhone			VARCHAR(50),
			DCreate				DATETIME,
			UCreate				VARCHAR(36),
			DBackup				DATETIME
		)

	IF OBJECT_ID('dbo.GN_M_PartnerAddress_MergeBackup_20260815', 'U') IS NULL
		CREATE TABLE dbo.GN_M_PartnerAddress_MergeBackup_20260815 (
			IDX_M_PartnerAddress BIGINT,
			IDX_M_Partner		BIGINT,
			IDX_M_AddressType	BIGINT,
			IDX_M_PostalCode	BIGINT,
			IsDefault			CHAR(1),
			Street				VARCHAR(1024),
			Zip					VARCHAR(32),
			Tindakan			VARCHAR(20),
			DBackup				DATETIME
		)

	/* ---------- 2. Daftar pasangan ---------- */
	DECLARE @Pasangan TABLE (Tetap BIGINT, Buang BIGINT)

	INSERT INTO @Pasangan (Tetap, Buang)
	VALUES (10572, 10574), (10194, 10992), (10300, 61330), (99, 10406)

	/* ---------- 3. Pengaman: batalkan bila ternyata sudah dipakai ---------- */
	DECLARE @Terpakai INT = 0

	SELECT @Terpakai = COUNT(*) FROM (
		SELECT IDX_M_Partner FROM MC_T_SalesOrder
		UNION ALL SELECT IDX_M_Partner FROM MC_T_PurchaseOrder
		UNION ALL SELECT IDX_M_Partner FROM CM_T_FinancialReceiveHeader
		UNION ALL SELECT IDX_M_Partner FROM CM_T_FinancialPaymentHeader
		UNION ALL SELECT IDX_M_Partner FROM GL_T_JournalHeader
		UNION ALL SELECT IDX_M_Partner FROM GL_T_JournalDetail
		UNION ALL SELECT IDX_M_Partner FROM CM_T_PettyCashDetail
		UNION ALL SELECT IDX_M_Partner FROM GN_M_PartnerBank
	) X WHERE IDX_M_Partner IN (SELECT Buang FROM @Pasangan)

	IF @Terpakai > 0
	BEGIN
		RAISERROR('Dibatalkan: data yang akan dibuang ternyata sudah dipakai transaksi.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

	/* ---------- 4. Alamat ---------- */
	-- Dipindahkan bila yang dipertahankan belum punya alamat
	INSERT INTO dbo.GN_M_PartnerAddress_MergeBackup_20260815
	SELECT A.IDX_M_PartnerAddress, A.IDX_M_Partner, A.IDX_M_AddressType, A.IDX_M_PostalCode,
		A.IsDefault, A.Street, A.Zip, 'dipindahkan', GETDATE()
	FROM GN_M_PartnerAddress A
		JOIN @Pasangan P ON P.Buang = A.IDX_M_Partner
	WHERE NOT EXISTS (SELECT 1 FROM GN_M_PartnerAddress B WHERE B.IDX_M_Partner = P.Tetap)

	UPDATE A
		SET A.IDX_M_Partner = P.Tetap,
			A.UModified = 'it_febry',
			A.DModified = GETDATE()
	FROM GN_M_PartnerAddress A
		JOIN @Pasangan P ON P.Buang = A.IDX_M_Partner
	WHERE NOT EXISTS (SELECT 1 FROM GN_M_PartnerAddress B WHERE B.IDX_M_Partner = P.Tetap)

	-- Sisanya kembaran dari alamat yang sudah ada, ikut dibuang
	INSERT INTO dbo.GN_M_PartnerAddress_MergeBackup_20260815
	SELECT A.IDX_M_PartnerAddress, A.IDX_M_Partner, A.IDX_M_AddressType, A.IDX_M_PostalCode,
		A.IsDefault, A.Street, A.Zip, 'dihapus', GETDATE()
	FROM GN_M_PartnerAddress A
		JOIN @Pasangan P ON P.Buang = A.IDX_M_Partner

	DELETE A
	FROM GN_M_PartnerAddress A
		JOIN @Pasangan P ON P.Buang = A.IDX_M_Partner

	/* ---------- 5. Konsumen kembar ---------- */
	INSERT INTO dbo.GN_M_Partner_MergeBackup_20260815
	SELECT M.IDX_M_Partner, P.Tetap, M.PartnerID, M.PartnerName, M.SingleIdentityNumber,
		M.MobilePhone, M.DCreate, M.UCreate, GETDATE()
	FROM GN_M_Partner M
		JOIN @Pasangan P ON P.Buang = M.IDX_M_Partner

	DELETE M
	FROM GN_M_Partner M
		JOIN @Pasangan P ON P.Buang = M.IDX_M_Partner

COMMIT TRANSACTION
GO

/* ---------- Pemeriksaan sesudah ---------- */
SELECT RTRIM(LTRIM(SingleIdentityNumber)) AS NIK, COUNT(*) AS Jumlah
FROM GN_M_Partner
WHERE LEN(RTRIM(LTRIM(ISNULL(SingleIdentityNumber,'')))) >= 8
	AND RTRIM(LTRIM(SingleIdentityNumber)) NOT LIKE '%[^0-9]%'
GROUP BY RTRIM(LTRIM(SingleIdentityNumber))
HAVING COUNT(*) > 1
ORDER BY NIK
GO
