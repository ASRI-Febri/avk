SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Laporan Bulanan Bank Indonesia form B0001 (Laporan Kegiatan Usaha Bulanan PVA).
--				Satu baris per jenis valuta per periode. Angka hasil hitung sistem yang
--				sudah dikonfirmasi/dikoreksi admin, menjadi sumber generate file txt BI.
-- =============================================
CREATE TABLE [dbo].[MC_T_BIMonthly](
	[IDX_T_BIMonthly] [bigint] IDENTITY(1,1) NOT NULL,
	[ReportPeriod] [varchar](6) NULL,
	[CurrencyID] [varchar](3) NULL,
	[ProductType] [char](1) NULL,
	[OpeningForeign] [decimal](18, 2) NULL,
	[OpeningIDR] [decimal](18, 2) NULL,
	[BuyForeign] [decimal](18, 2) NULL,
	[BuyIDR] [decimal](18, 2) NULL,
	[SellForeign] [decimal](18, 2) NULL,
	[SellIDR] [decimal](18, 2) NULL,
	[ClosingForeign] [decimal](18, 2) NULL,
	[MiddleRate] [decimal](18, 4) NULL,
	[ClosingIDR] [decimal](18, 2) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_BIMonthly] PRIMARY KEY CLUSTERED
(
	[IDX_T_BIMonthly] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_BIMonthly] ADD  CONSTRAINT [DF_MC_T_BIMonthly_ProductType]  DEFAULT ('1') FOR [ProductType]
GO
ALTER TABLE [dbo].[MC_T_BIMonthly] ADD  CONSTRAINT [DF_MC_T_BIMonthly_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_BIMonthly] ADD  CONSTRAINT [DF_MC_T_BIMonthly_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_BIMonthly] ADD  CONSTRAINT [DF_MC_T_BIMonthly_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = UKA (Uang Kertas Asing)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_BIMonthly', @level2type=N'COLUMN',@level2name=N'ProductType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Kurs tengah, max 99999.9999 (di file txt dikali 10000)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_BIMonthly', @level2type=N'COLUMN',@level2name=N'MiddleRate'
GO
