SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Aug 2026
-- Description:	Jenis identitas konsumen. Tidak semua konsumen memakai KTP —
--				WNA memakai paspor atau KITAS — jadi GN_M_Partner menunjuk ke
--				master GN_M_IDType, sementara nomornya tetap di kolom
--				SingleIdentityNumber yang sudah ada.
--
--				Script boleh dijalankan berulang: setiap langkah diperiksa dulu.
-- =============================================

-- ---------------------------------------------------------------------------
-- 1. ISI MASTER JENIS IDENTITAS
-- ---------------------------------------------------------------------------
-- Alias dipakai sebagai kode pendek pada tampilan dan laporan.
IF NOT EXISTS (SELECT 1 FROM GN_M_IDType WHERE RTRIM(ISNULL(Alias,'')) = 'KTP')
	INSERT INTO GN_M_IDType (Name, Alias, Notes, RecordStatus)
	VALUES ('Kartu Tanda Penduduk', 'KTP', 'WNI, nomor 16 digit angka', 'A')
GO

IF NOT EXISTS (SELECT 1 FROM GN_M_IDType WHERE RTRIM(ISNULL(Alias,'')) = 'SIM')
	INSERT INTO GN_M_IDType (Name, Alias, Notes, RecordStatus)
	VALUES ('Surat Izin Mengemudi', 'SIM', 'WNI', 'A')
GO

IF NOT EXISTS (SELECT 1 FROM GN_M_IDType WHERE RTRIM(ISNULL(Alias,'')) = 'PASPOR')
	INSERT INTO GN_M_IDType (Name, Alias, Notes, RecordStatus)
	VALUES ('Paspor', 'PASPOR', 'WNI maupun WNA, nomor berisi huruf dan angka', 'A')
GO

IF NOT EXISTS (SELECT 1 FROM GN_M_IDType WHERE RTRIM(ISNULL(Alias,'')) = 'KITAS')
	INSERT INTO GN_M_IDType (Name, Alias, Notes, RecordStatus)
	VALUES ('Kartu Izin Tinggal Terbatas', 'KITAS', 'WNA tinggal terbatas', 'A')
GO

IF NOT EXISTS (SELECT 1 FROM GN_M_IDType WHERE RTRIM(ISNULL(Alias,'')) = 'KITAP')
	INSERT INTO GN_M_IDType (Name, Alias, Notes, RecordStatus)
	VALUES ('Kartu Izin Tinggal Tetap', 'KITAP', 'WNA tinggal tetap', 'A')
GO

-- ---------------------------------------------------------------------------
-- 2. KOLOM BARU DI GN_M_Partner
-- ---------------------------------------------------------------------------
-- NULL diizinkan: data konsumen lama belum tentu diketahui jenis identitasnya.
IF NOT EXISTS (SELECT 1 FROM sys.columns
	WHERE object_id = OBJECT_ID('[dbo].[GN_M_Partner]') AND name = 'IDX_M_IDType')
BEGIN
	ALTER TABLE [dbo].[GN_M_Partner] ADD [IDX_M_IDType] [bigint] NULL
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GN_M_Partner_GN_M_IDType')
BEGIN
	ALTER TABLE [dbo].[GN_M_Partner] WITH CHECK
		ADD CONSTRAINT [FK_GN_M_Partner_GN_M_IDType]
		FOREIGN KEY ([IDX_M_IDType]) REFERENCES [dbo].[GN_M_IDType] ([IDX_M_IDType])
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_GN_M_Partner_IDX_M_IDType')
BEGIN
	CREATE NONCLUSTERED INDEX [IX_GN_M_Partner_IDX_M_IDType]
		ON [dbo].[GN_M_Partner] ([IDX_M_IDType] ASC)
END
GO

-- ---------------------------------------------------------------------------
-- 3. ISI AWAL UNTUK DATA LAMA
-- ---------------------------------------------------------------------------
-- Hanya yang nomor identitasnya 16 digit angka yang dianggap KTP. Sisanya
-- dibiarkan kosong supaya tidak menebak jenis identitas orang lain.
DECLARE @IDX_KTP BIGINT

SELECT TOP 1 @IDX_KTP = IDX_M_IDType
FROM GN_M_IDType
WHERE RTRIM(ISNULL(Alias,'')) = 'KTP'
ORDER BY IDX_M_IDType

IF @IDX_KTP IS NOT NULL
BEGIN
	UPDATE GN_M_Partner SET
		IDX_M_IDType = @IDX_KTP
	WHERE IDX_M_IDType IS NULL
		AND LEN(RTRIM(ISNULL(SingleIdentityNumber,''))) = 16
		AND RTRIM(ISNULL(SingleIdentityNumber,'')) NOT LIKE '%[^0-9]%'
END
GO
