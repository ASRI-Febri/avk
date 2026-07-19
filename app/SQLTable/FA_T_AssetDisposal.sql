SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Pelepasan aset tetap (PSAK 16 - penghentian pengakuan).
			  DisposalType: S = Dijual, W = Hapus Buku (write-off), H = Hibah
			  IDX_M_COA_Proceed = akun penerima hasil penjualan (kas/bank/piutang),
			  hanya terisi untuk tipe S.
			  GainLossAmount = DisposalProceed - BookValueAtDisposal
			  (positif = laba, negatif = rugi pelepasan).
-- ============================================= */
CREATE TABLE [dbo].[FA_T_AssetDisposal](
	[IDX_T_AssetDisposal] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Asset] [bigint] NULL,
	[DisposalDate] [date] NULL,
	[DisposalType] [char](1) NULL,
	[DisposalProceed] [decimal](18, 2) NULL,
	[IDX_M_COA_Proceed] [bigint] NULL,
	[AccumDeprAtDisposal] [decimal](18, 2) NULL,
	[BookValueAtDisposal] [decimal](18, 2) NULL,
	[GainLossAmount] [decimal](18, 2) NULL,
	[DisposalNotes] [varchar](5000) NULL,
	[IDX_T_JournalHeader] [bigint] NULL,
	[DisposalStatus] [char](1) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_FA_T_AssetDisposal] PRIMARY KEY CLUSTERED
(
	[IDX_T_AssetDisposal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FA_T_AssetDisposal] ADD  CONSTRAINT [DF_FA_T_AssetDisposal_DisposalProceed]  DEFAULT ((0)) FOR [DisposalProceed]
GO
ALTER TABLE [dbo].[FA_T_AssetDisposal] ADD  CONSTRAINT [DF_FA_T_AssetDisposal_DisposalStatus]  DEFAULT ('A') FOR [DisposalStatus]
GO
ALTER TABLE [dbo].[FA_T_AssetDisposal] ADD  CONSTRAINT [DF_FA_T_AssetDisposal_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[FA_T_AssetDisposal] ADD  CONSTRAINT [DF_FA_T_AssetDisposal_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[FA_T_AssetDisposal] ADD  CONSTRAINT [DF_FA_T_AssetDisposal_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
CREATE NONCLUSTERED INDEX [IX_FA_T_AssetDisposal_IDX_M_Asset] ON [dbo].[FA_T_AssetDisposal]
(
	[IDX_M_Asset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
