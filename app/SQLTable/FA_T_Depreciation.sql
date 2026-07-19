SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Header run penyusutan aset tetap per periode (YYYYMM)
			  DeprStatus: C = Calculated, P = Posted (jurnal sudah dibuat)
			  Dibuat di Fase 1 karena USP_FA_Asset_List/Info menghitung
			  nilai buku dari tabel ini; proses pengisiannya di Fase 2.
-- ============================================= */
CREATE TABLE [dbo].[FA_T_Depreciation](
	[IDX_T_Depreciation] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[DeprPeriod] [varchar](6) NULL,
	[IDX_T_JournalHeader] [bigint] NULL,
	[DeprStatus] [char](1) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_T_Depreciation] PRIMARY KEY CLUSTERED
(
	[IDX_T_Depreciation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FA_T_Depreciation] ADD  CONSTRAINT [DF_FA_T_Depreciation_DeprStatus]  DEFAULT ('C') FOR [DeprStatus]
GO
ALTER TABLE [dbo].[FA_T_Depreciation] ADD  CONSTRAINT [DF_FA_T_Depreciation_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_T_Depreciation] ADD  CONSTRAINT [DF_FA_T_Depreciation_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_T_Depreciation] ADD  CONSTRAINT [DF_FA_T_Depreciation_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
-- Satu run penyusutan per company per periode
CREATE UNIQUE NONCLUSTERED INDEX [UX_FA_T_Depreciation_Company_Period] ON [dbo].[FA_T_Depreciation]
(
	[IDX_M_Company] ASC,
	[DeprPeriod] ASC
)
WHERE ([RecordStatus]='A')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
