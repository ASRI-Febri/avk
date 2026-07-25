SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Laporan Transaksi Keuangan Tunai (LTKT) - transaksi tunai >= Rp 500.000.000
--				per nasabah per hari kerja, wajib lapor 14 hari kerja sejak transaksi.
-- =============================================
CREATE TABLE [dbo].[MC_T_LTKT](
	[IDX_T_LTKT] [bigint] IDENTITY(1,1) NOT NULL,
	[LTKTPeriod] [varchar](6) NULL,
	[IDX_T_SalesOrder] [bigint] NULL,
	[SONumber] [varchar](50) NULL,
	[TransactionDate] [date] NULL,
	[IDX_M_Partner] [bigint] NULL,
	[PartnerID] [varchar](32) NULL,
	[PartnerName] [varchar](256) NULL,
	[SingleIdentityNumber] [varchar](64) NULL,
	[PlaceOfBirth] [varchar](64) NULL,
	[DateOfBirth] [date] NULL,
	[Street] [varchar](1024) NULL,
	[TotalSalesAmount] [decimal](18, 4) NULL,
	[PaymentCashAmount] [decimal](18, 4) NULL,
	[DailyCashAmount] [decimal](18, 4) NULL,
	[ReportDueDate] [date] NULL,
	[ReportStatus] [char](1) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_LTKT] PRIMARY KEY CLUSTERED
(
	[IDX_T_LTKT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_LTKT] ADD  CONSTRAINT [DF_MC_T_LTKT_ReportStatus]  DEFAULT ('O') FOR [ReportStatus]
GO
ALTER TABLE [dbo].[MC_T_LTKT] ADD  CONSTRAINT [DF_MC_T_LTKT_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_LTKT] ADD  CONSTRAINT [DF_MC_T_LTKT_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_LTKT] ADD  CONSTRAINT [DF_MC_T_LTKT_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total pembayaran tunai nasabah pada hari transaksi (basis threshold 500 juta)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKT', @level2type=N'COLUMN',@level2name=N'DailyCashAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batas waktu lapor: 14 hari kerja sejak tanggal transaksi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKT', @level2type=N'COLUMN',@level2name=N'ReportDueDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'O = Open (belum lapor), R = Reported (sudah lapor)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKT', @level2type=N'COLUMN',@level2name=N'ReportStatus'
GO
