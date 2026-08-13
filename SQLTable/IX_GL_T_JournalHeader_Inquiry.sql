USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Index pendukung [dbo].[USP_GL_Journal_List] (halaman /ac-journal).
--
-- GL_T_JournalHeader sebelumnya hanya punya clustered PK
-- (IDX_T_JournalHeader), sehingga setiap kali list dibuka SQL Server harus
-- scan seluruh tabel: baik untuk mengambil satu halaman data maupun untuk
-- menghitung TotalRows.
--
-- Kedua index di bawah dimulai dari IDX_M_Branch karena SP selalu membatasi
-- baris ke cabang yang boleh diakses user (#UserBranch), lalu:
--   1. ..._Branch_Date  -> untuk filter/sort berdasarkan JournalDate
--                          (filter range tanggal journal).
--   2. ..._Branch_IDX   -> untuk urutan default list (IDX_T_JournalHeader DESC).
--
-- Kolom yang ditampilkan di grid ikut di-INCLUDE supaya paging bisa dilayani
-- langsung dari index (covering) tanpa lookup ke clustered index.
-- RemarkHeader sengaja TIDAK di-INCLUDE karena varchar(8000) akan membuat
-- index sangat besar; kolom itu hanya di-lookup untuk baris pada halaman aktif.
-- =============================================
IF NOT EXISTS (
	SELECT 1 FROM sys.indexes
	WHERE name = 'IX_GL_T_JournalHeader_Branch_Date'
		AND object_id = OBJECT_ID('[dbo].[GL_T_JournalHeader]')
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_GL_T_JournalHeader_Branch_Date]
		ON [dbo].[GL_T_JournalHeader] ([IDX_M_Branch] ASC, [JournalDate] DESC)
		INCLUDE ([IDX_M_Company], [IDX_M_Partner], [PartnerDesc], [ReferenceNo],
			[VoucherNo], [PostingStatus])
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
			DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		ON [PRIMARY]
END
GO

IF NOT EXISTS (
	SELECT 1 FROM sys.indexes
	WHERE name = 'IX_GL_T_JournalHeader_Branch_IDX'
		AND object_id = OBJECT_ID('[dbo].[GL_T_JournalHeader]')
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_GL_T_JournalHeader_Branch_IDX]
		ON [dbo].[GL_T_JournalHeader] ([IDX_M_Branch] ASC, [IDX_T_JournalHeader] DESC)
		INCLUDE ([IDX_M_Company], [IDX_M_Partner], [PartnerDesc], [ReferenceNo],
			[VoucherNo], [JournalDate], [PostingStatus])
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
			DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		ON [PRIMARY]
END
GO

-- Mempercepat resolve hak akses cabang user (#UserBranch) di awal SP.
IF NOT EXISTS (
	SELECT 1 FROM sys.indexes
	WHERE name = 'IX_SM_M_UserBranch_User'
		AND object_id = OBJECT_ID('[dbo].[SM_M_UserBranch]')
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_SM_M_UserBranch_User]
		ON [dbo].[SM_M_UserBranch] ([IDX_M_User] ASC)
		INCLUDE ([IDX_M_Branch], [RecordStatus])
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
			DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		ON [PRIMARY]
END
GO
