SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Template journal recurring - jurnal berulang yang digenerate
			  setiap akhir periode (YYYYMM), contoh: amortisasi sewa dibayar
			  dimuka menjadi biaya sewa bulanan.
			  Debet IDX_M_COA_Debet, Kredit IDX_M_COA_Credit sebesar
			  RecurringAmount per periode, aktif dari StartPeriod s/d EndPeriod.
-- ============================================= */
CREATE TABLE [dbo].[GL_M_RecurringJournal](
	[IDX_M_RecurringJournal] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[IDX_M_Branch] [int] NULL,
	[RecurringCode] [varchar](32) NULL,
	[RecurringName] [varchar](200) NULL,
	[RecurringDesc] [varchar](5000) NULL,
	[IDX_M_COA_Debet] [bigint] NULL,
	[IDX_M_COA_Credit] [bigint] NULL,
	[RecurringAmount] [decimal](18, 2) NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[AdjustLastPeriod] [char](1) NULL,
	[StartPeriod] [varchar](6) NULL,
	[EndPeriod] [varchar](6) NULL,
	[RecurringStatus] [char](1) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_GL_M_RecurringJournal] PRIMARY KEY CLUSTERED
(
	[IDX_M_RecurringJournal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
-- RecurringStatus: A = Aktif (ikut digenerate), I = Non-aktif
ALTER TABLE [dbo].[GL_M_RecurringJournal] ADD  CONSTRAINT [DF_GL_M_RecurringJournal_RecurringStatus]  DEFAULT ('A') FOR [RecurringStatus]
GO
-- AdjustLastPeriod: Y = nilai periode terakhir dihitung ulang dari
-- TotalAmount dikurangi akumulasi yang sudah digenerate (hindari sisa
-- pembulatan, contoh sewa 58.000.000 / 12 bulan), N = nilai flat tiap periode
ALTER TABLE [dbo].[GL_M_RecurringJournal] ADD  CONSTRAINT [DF_GL_M_RecurringJournal_AdjustLastPeriod]  DEFAULT ('N') FOR [AdjustLastPeriod]
GO
ALTER TABLE [dbo].[GL_M_RecurringJournal] ADD  CONSTRAINT [DF_GL_M_RecurringJournal_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[GL_M_RecurringJournal] ADD  CONSTRAINT [DF_GL_M_RecurringJournal_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[GL_M_RecurringJournal] ADD  CONSTRAINT [DF_GL_M_RecurringJournal_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
