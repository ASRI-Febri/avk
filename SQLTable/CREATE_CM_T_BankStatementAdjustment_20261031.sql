SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Tautan jurnal penyesuaian dari halaman Rekonsiliasi Ledger ke
--				transaksi yang disesuaikan, mis. bank menerima 1.500.000 tetapi
--				ledger mencatat 1.497.950: selisihnya dijurnal dan ketiganya
--				(baris bank, baris ledger, jurnal penyesuaian) tampil sebagai satu
--				kelompok "Disesuaikan".
--				  SourceType 'B' : SourceID = IDX_T_BankStatementDetail
--				  SourceType 'L' : SourceID = IDX_T_JournalDetail (baris COA bank)
--				Tautan diabaikan bila jurnal penyesuaiannya sudah tidak aktif.
--
--				Script boleh dijalankan berulang.
-- =============================================

IF OBJECT_ID('dbo.CM_T_BankStatementAdjustment') IS NULL
BEGIN
	CREATE TABLE [dbo].[CM_T_BankStatementAdjustment](
		[IDX_T_BankStatementAdjustment]	[bigint] IDENTITY(1,1) NOT NULL,
		[IDX_T_BankStatementHeader]		[bigint] NOT NULL,
		[IDX_T_JournalHeader]			[bigint] NOT NULL,
		[SourceType]					[char](1) NOT NULL,
		[SourceID]						[bigint] NOT NULL,
		[UCreate]						[varchar](36) NULL,
		[DCreate]						[datetime] NULL,
		[RecordStatus]					[varchar](1) NULL,
	 CONSTRAINT [PK_CM_T_BankStatementAdjustment] PRIMARY KEY CLUSTERED ([IDX_T_BankStatementAdjustment] ASC),
	 CONSTRAINT [FK_CM_T_BankStatementAdjustment_Header] FOREIGN KEY ([IDX_T_BankStatementHeader])
		REFERENCES [dbo].[CM_T_BankStatementHeader] ([IDX_T_BankStatementHeader])
	)

	CREATE INDEX [IX_CM_T_BankStatementAdjustment_Header]
		ON [dbo].[CM_T_BankStatementAdjustment] ([IDX_T_BankStatementHeader])
END
GO
