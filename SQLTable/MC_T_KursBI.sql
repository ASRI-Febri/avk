SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Tabel penyimpanan Kurs Transaksi Bank Indonesia (acuan kurs valuta asing).
-- Diisi harian oleh command `php artisan mc:fetch-bi-kurs` yang mengambil data
-- dari BI Web Service getSubKursLokal (https://www.bi.go.id/biwebservice).
-- Dipakai sebagai acuan tampilan kurs Money Changer (display_kurs_tv).
-- KursBeli / KursJual adalah kurs BI untuk `Nilai` unit valas (mis. JPY Nilai=100).
-- =============================================================================
CREATE TABLE [dbo].[MC_T_KursBI](
	[IDX_T_KursBI]	[bigint] IDENTITY(1,1) NOT NULL,
	[TanggalKurs]	[date] NOT NULL,
	[CurrencyID]	[varchar](10) NOT NULL,
	[Nilai]			[decimal](18, 4) NULL,
	[KursBeli]		[decimal](18, 4) NULL,
	[KursJual]		[decimal](18, 4) NULL,
	[UCreate]		[varchar](36) NULL,
	[DCreate]		[datetime] NULL,
	[UModified]		[varchar](36) NULL,
	[DModified]		[datetime] NULL,
	[RecordStatus]	[varchar](1) NULL,
 CONSTRAINT [PK_MC_T_KursBI] PRIMARY KEY CLUSTERED
(
	[IDX_T_KursBI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
-- Satu baris kurs per (tanggal, mata uang) -> dipakai untuk upsert.
ALTER TABLE [dbo].[MC_T_KursBI] ADD CONSTRAINT [UQ_MC_T_KursBI_TanggalCurrency] UNIQUE NONCLUSTERED
(
	[TanggalKurs] ASC,
	[CurrencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_KursBI] ADD CONSTRAINT [DF_MC_T_KursBI_UCreate] DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_KursBI] ADD CONSTRAINT [DF_MC_T_KursBI_DCreate] DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_KursBI] ADD CONSTRAINT [DF_MC_T_KursBI_RecordStatus] DEFAULT ('A') FOR [RecordStatus]
GO
