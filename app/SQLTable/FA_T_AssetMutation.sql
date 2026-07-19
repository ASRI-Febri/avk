SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Riwayat mutasi aset tetap antar cabang / departemen.
			  Posisi terkini aset tetap tersimpan di FA_M_Asset
			  (IDX_M_Branch / IDX_M_Department); tabel ini menyimpan jejaknya.
-- ============================================= */
CREATE TABLE [dbo].[FA_T_AssetMutation](
	[IDX_T_AssetMutation] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Asset] [bigint] NULL,
	[MutationDate] [date] NULL,
	[IDX_M_Branch_From] [int] NULL,
	[IDX_M_Branch_To] [int] NULL,
	[IDX_M_Department_From] [int] NULL,
	[IDX_M_Department_To] [int] NULL,
	[MutationNotes] [varchar](5000) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_T_AssetMutation] PRIMARY KEY CLUSTERED
(
	[IDX_T_AssetMutation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FA_T_AssetMutation] ADD  CONSTRAINT [DF_FA_T_AssetMutation_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_T_AssetMutation] ADD  CONSTRAINT [DF_FA_T_AssetMutation_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_T_AssetMutation] ADD  CONSTRAINT [DF_FA_T_AssetMutation_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
CREATE NONCLUSTERED INDEX [IX_FA_T_AssetMutation_IDX_M_Asset] ON [dbo].[FA_T_AssetMutation]
(
	[IDX_M_Asset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
