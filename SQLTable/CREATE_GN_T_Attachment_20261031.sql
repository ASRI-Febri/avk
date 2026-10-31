SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 31 Oct 2026
-- Description:	Lampiran (PDF / gambar) sebagai data pendukung transaksi. Satu
--				transaksi bisa punya banyak lampiran.
--				  SourceType 'FP' : SourceID = IDX_T_FinancialPaymentHeader
--				  SourceType 'JE' : SourceID = IDX_T_JournalHeader
--				File disimpan di storage/app/attachment/<SourceType>/<SourceID>/
--				dengan nama acak (StoredName); FileName = nama asli dari user.
--				Hapus = RecordStatus 'D', file fisik tetap disimpan untuk audit.
--
--				Script boleh dijalankan berulang.
-- =============================================

IF OBJECT_ID('dbo.GN_T_Attachment') IS NULL
BEGIN
	CREATE TABLE [dbo].[GN_T_Attachment](
		[IDX_T_Attachment]	[bigint] IDENTITY(1,1) NOT NULL,
		[SourceType]		[varchar](10) NOT NULL,
		[SourceID]			[bigint] NOT NULL,
		[Category]			[varchar](50) NULL,
		[FileName]			[varchar](255) NOT NULL,
		[StoredName]		[varchar](100) NOT NULL,
		[FileSize]			[bigint] NOT NULL DEFAULT 0,
		[Description]		[varchar](500) NULL,
		[UCreate]			[varchar](36) NULL,
		[DCreate]			[datetime] NULL,
		[UModified]			[varchar](36) NULL,
		[DModified]			[datetime] NULL,
		[RecordStatus]		[varchar](1) NULL,
	 CONSTRAINT [PK_GN_T_Attachment] PRIMARY KEY CLUSTERED ([IDX_T_Attachment] ASC)
	)

	CREATE INDEX [IX_GN_T_Attachment_Source] ON [dbo].[GN_T_Attachment] ([SourceType], [SourceID])
END
GO
