SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Register aset tetap (PSAK 16)
			  AssetStatus: D = Draft, A = Aktif (disusutkan), S = Dijual, W = Hapus Buku, H = Hibah
			  DeprMethod : SL = Garis Lurus, DB = Saldo Menurun
			  FiscalGroup: 1-4 = Kelompok Harta, BP = Bangunan Permanen, BN = Bangunan Non-Permanen
-- ============================================= */
CREATE TABLE [dbo].[FA_M_Asset](
	[IDX_M_Asset] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[IDX_M_Branch] [int] NULL,
	[IDX_M_Department] [int] NULL,
	[IDX_M_AssetCategory] [int] NULL,
	[AssetCode] [varchar](50) NULL,
	[AssetName] [varchar](200) NULL,
	[AssetDesc] [varchar](5000) NULL,
	[AcquisitionDate] [date] NULL,
	[UsageStartDate] [date] NULL,
	[AcquisitionCost] [decimal](18, 2) NULL,
	[ResidualValue] [decimal](18, 2) NULL,
	[UsefulLifeMonth] [int] NULL,
	[DeprMethod] [char](2) NULL,
	[FiscalGroup] [char](2) NULL,
	[FiscalDeprMethod] [char](2) NULL,
	[IDX_T_PurchaseInvoice] [bigint] NULL,
	[ReferenceNo] [varchar](50) NULL,
	[AssetStatus] [char](1) NULL,
	[DisposalDate] [date] NULL,
	[OpeningAccumDepr] [decimal](18, 2) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_M_Asset] PRIMARY KEY CLUSTERED
(
	[IDX_M_Asset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_ResidualValue]  DEFAULT ((0)) FOR [ResidualValue]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_DeprMethod]  DEFAULT ('SL') FOR [DeprMethod]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_AssetStatus]  DEFAULT ('D') FOR [AssetStatus]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_OpeningAccumDepr]  DEFAULT ((0)) FOR [OpeningAccumDepr]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_M_Asset] ADD  CONSTRAINT [DF_FA_M_Asset_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
CREATE NONCLUSTERED INDEX [IX_FA_M_Asset_IDX_M_AssetCategory] ON [dbo].[FA_M_Asset]
(
	[IDX_M_AssetCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
