SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Master kategori aset tetap + mapping COA (PSAK 16)
-- ============================================= */
CREATE TABLE [dbo].[FA_M_AssetCategory](
	[IDX_M_AssetCategory] [int] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[CategoryCode] [varchar](20) NULL,
	[CategoryName] [varchar](100) NULL,
	[IDX_M_COA_Asset] [bigint] NULL,
	[IDX_M_COA_AccumDepr] [bigint] NULL,
	[IDX_M_COA_DeprExpense] [bigint] NULL,
	[IDX_M_COA_GainDisposal] [bigint] NULL,
	[IDX_M_COA_LossDisposal] [bigint] NULL,
	[DefaultUsefulLifeMonth] [int] NULL,
	[DefaultDeprMethod] [char](2) NULL,
	[FiscalGroup] [char](2) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_M_AssetCategory] PRIMARY KEY CLUSTERED
(
	[IDX_M_AssetCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
-- DefaultDeprMethod: SL = Garis Lurus (Straight Line), DB = Saldo Menurun (Declining Balance)
ALTER TABLE [dbo].[FA_M_AssetCategory] ADD  CONSTRAINT [DF_FA_M_AssetCategory_DefaultDeprMethod]  DEFAULT ('SL') FOR [DefaultDeprMethod]
GO
ALTER TABLE [dbo].[FA_M_AssetCategory] ADD  CONSTRAINT [DF_FA_M_AssetCategory_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_M_AssetCategory] ADD  CONSTRAINT [DF_FA_M_AssetCategory_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_M_AssetCategory] ADD  CONSTRAINT [DF_FA_M_AssetCategory_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
