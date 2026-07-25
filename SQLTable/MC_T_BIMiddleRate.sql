SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Kurs tengah Bank Indonesia per tanggal akhir bulan.
--				Diupload dari file Excel "Kurs Transaksi" hasil download website BI.
--				Kurs tengah = (Kurs Jual + Kurs Beli) / 2, dipakai sebagai kurs
--				pada Laporan Bulanan BI form B0001.
-- =============================================
CREATE TABLE [dbo].[MC_T_BIMiddleRate](
	[IDX_T_BIMiddleRate] [bigint] IDENTITY(1,1) NOT NULL,
	[RateDate] [date] NULL,
	[CurrencyID] [varchar](3) NULL,
	[RateUnit] [int] NULL,
	[SellRate] [decimal](18, 4) NULL,
	[BuyRate] [decimal](18, 4) NULL,
	[MiddleRate] [decimal](18, 4) NULL,
	[FileName] [varchar](256) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_BIMiddleRate] PRIMARY KEY CLUSTERED
(
	[IDX_T_BIMiddleRate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_BIMiddleRate] ADD  CONSTRAINT [DF_MC_T_BIMiddleRate_RateUnit]  DEFAULT ((1)) FOR [RateUnit]
GO
ALTER TABLE [dbo].[MC_T_BIMiddleRate] ADD  CONSTRAINT [DF_MC_T_BIMiddleRate_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_BIMiddleRate] ADD  CONSTRAINT [DF_MC_T_BIMiddleRate_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_BIMiddleRate] ADD  CONSTRAINT [DF_MC_T_BIMiddleRate_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tanggal akhir bulan periode kurs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_BIMiddleRate', @level2type=N'COLUMN',@level2name=N'RateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Kolom Nilai pada file BI (JPY dikuotasi per 100)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_BIMiddleRate', @level2type=N'COLUMN',@level2name=N'RateUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'(SellRate + BuyRate) / 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_BIMiddleRate', @level2type=N'COLUMN',@level2name=N'MiddleRate'
GO
