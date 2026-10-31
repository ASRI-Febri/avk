SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Pasangan transaksi yang ditandai cocok secara manual di halaman
--				Rekonsiliasi Ledger, untuk transaksi yang nilainya sudah sama tetapi
--				tidak terpasang otomatis, mis. satu transfer bank 2.622.080 yang
--				dicatat di ledger sebagai dua penerimaan (1.138.880 + 1.483.200)
--				pada hari berikutnya. Tidak membuat jurnal.
--				  Header : satu kelompok pasangan (RecordStatus 'D' = dibatalkan)
--				  Detail : SourceType 'B' = IDX_T_BankStatementDetail,
--				           SourceType 'L' = IDX_T_JournalDetail (baris COA bank)
--
--				Script boleh dijalankan berulang.
-- =============================================

IF OBJECT_ID('dbo.CM_T_BankStatementMatch') IS NULL
BEGIN
	CREATE TABLE [dbo].[CM_T_BankStatementMatch](
		[IDX_T_BankStatementMatch]	[bigint] IDENTITY(1,1) NOT NULL,
		[IDX_T_BankStatementHeader]	[bigint] NOT NULL,
		[UCreate]					[varchar](36) NULL,
		[DCreate]					[datetime] NULL,
		[UModified]					[varchar](36) NULL,
		[DModified]					[datetime] NULL,
		[RecordStatus]				[varchar](1) NULL,
	 CONSTRAINT [PK_CM_T_BankStatementMatch] PRIMARY KEY CLUSTERED ([IDX_T_BankStatementMatch] ASC),
	 CONSTRAINT [FK_CM_T_BankStatementMatch_Header] FOREIGN KEY ([IDX_T_BankStatementHeader])
		REFERENCES [dbo].[CM_T_BankStatementHeader] ([IDX_T_BankStatementHeader])
	)

	CREATE INDEX [IX_CM_T_BankStatementMatch_Header]
		ON [dbo].[CM_T_BankStatementMatch] ([IDX_T_BankStatementHeader])
END
GO

IF OBJECT_ID('dbo.CM_T_BankStatementMatchDetail') IS NULL
BEGIN
	CREATE TABLE [dbo].[CM_T_BankStatementMatchDetail](
		[IDX_T_BankStatementMatchDetail]	[bigint] IDENTITY(1,1) NOT NULL,
		[IDX_T_BankStatementMatch]			[bigint] NOT NULL,
		[SourceType]						[char](1) NOT NULL,
		[SourceID]							[bigint] NOT NULL,
	 CONSTRAINT [PK_CM_T_BankStatementMatchDetail] PRIMARY KEY CLUSTERED ([IDX_T_BankStatementMatchDetail] ASC),
	 CONSTRAINT [FK_CM_T_BankStatementMatchDetail_Match] FOREIGN KEY ([IDX_T_BankStatementMatch])
		REFERENCES [dbo].[CM_T_BankStatementMatch] ([IDX_T_BankStatementMatch])
	)

	CREATE INDEX [IX_CM_T_BankStatementMatchDetail_Match]
		ON [dbo].[CM_T_BankStatementMatchDetail] ([IDX_T_BankStatementMatch])
END
GO
