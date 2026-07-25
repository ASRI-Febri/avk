SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Jul 2026
-- Description:	Laporan Transaksi Keuangan Mencurigakan (LTKM) - tidak ada batasan nominal,
--				wajib lapor 3 hari sejak ditetapkan sebagai TKM.
-- =============================================
CREATE TABLE [dbo].[MC_T_LTKM](
	[IDX_T_LTKM] [bigint] IDENTITY(1,1) NOT NULL,
	[LTKMPeriod] [varchar](6) NULL,
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
	[IsDTTOT] [char](1) NULL,
	[TotalSalesAmount] [decimal](18, 4) NULL,
	[PaymentCashAmount] [decimal](18, 4) NULL,
	[TKMDate] [date] NULL,
	[TKMIndicator] [varchar](1000) NULL,
	[ReportDueDate] [date] NULL,
	[ReportStatus] [char](1) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_LTKM] PRIMARY KEY CLUSTERED
(
	[IDX_T_LTKM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_LTKM] ADD  CONSTRAINT [DF_MC_T_LTKM_IsDTTOT]  DEFAULT ('N') FOR [IsDTTOT]
GO
ALTER TABLE [dbo].[MC_T_LTKM] ADD  CONSTRAINT [DF_MC_T_LTKM_ReportStatus]  DEFAULT ('O') FOR [ReportStatus]
GO
ALTER TABLE [dbo].[MC_T_LTKM] ADD  CONSTRAINT [DF_MC_T_LTKM_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_LTKM] ADD  CONSTRAINT [DF_MC_T_LTKM_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_LTKM] ADD  CONSTRAINT [DF_MC_T_LTKM_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tanggal transaksi ditetapkan sebagai TKM (Transaksi Keuangan Mencurigakan)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKM', @level2type=N'COLUMN',@level2name=N'TKMDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indikator / alasan transaksi dianggap mencurigakan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKM', @level2type=N'COLUMN',@level2name=N'TKMIndicator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batas waktu lapor: 3 hari sejak ditetapkan sebagai TKM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKM', @level2type=N'COLUMN',@level2name=N'ReportDueDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'O = Open (belum lapor), R = Reported (sudah lapor)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_LTKM', @level2type=N'COLUMN',@level2name=N'ReportStatus'
GO
