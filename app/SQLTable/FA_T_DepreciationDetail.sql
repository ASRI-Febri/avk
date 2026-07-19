SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Detail penyusutan per aset per periode
			  DeprAmount       = penyusutan komersial (dijurnal)
			  FiscalDeprAmount = penyusutan fiskal (laporan pajak, tidak dijurnal)
-- ============================================= */
CREATE TABLE [dbo].[FA_T_DepreciationDetail](
	[IDX_T_DepreciationDetail] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_T_Depreciation] [bigint] NULL,
	[IDX_M_Asset] [bigint] NULL,
	[DeprAmount] [decimal](18, 2) NULL,
	[FiscalDeprAmount] [decimal](18, 2) NULL,
	[AccumDeprAfter] [decimal](18, 2) NULL,
	[BookValueAfter] [decimal](18, 2) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_T_DepreciationDetail] PRIMARY KEY CLUSTERED
(
	[IDX_T_DepreciationDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FA_T_DepreciationDetail] ADD  CONSTRAINT [DF_FA_T_DepreciationDetail_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_T_DepreciationDetail] ADD  CONSTRAINT [DF_FA_T_DepreciationDetail_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_T_DepreciationDetail] ADD  CONSTRAINT [DF_FA_T_DepreciationDetail_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
CREATE NONCLUSTERED INDEX [IX_FA_T_DepreciationDetail_IDX_T_Depreciation] ON [dbo].[FA_T_DepreciationDetail]
(
	[IDX_T_Depreciation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FA_T_DepreciationDetail_IDX_M_Asset] ON [dbo].[FA_T_DepreciationDetail]
(
	[IDX_M_Asset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
