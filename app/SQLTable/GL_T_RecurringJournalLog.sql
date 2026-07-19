SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
Author		: Samuel Febrianto
Create date	: 19 Jul 2026
Description	: Log generate journal recurring per template per periode.
			  Satu template hanya boleh digenerate sekali per periode
			  (unique index) - mencegah jurnal dobel.
-- ============================================= */
CREATE TABLE [dbo].[GL_T_RecurringJournalLog](
	[IDX_T_RecurringJournalLog] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_RecurringJournal] [bigint] NULL,
	[RecurringPeriod] [varchar](6) NULL,
	[IDX_T_JournalHeader] [bigint] NULL,
	[GeneratedAmount] [decimal](18, 2) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_GL_T_RecurringJournalLog] PRIMARY KEY CLUSTERED
(
	[IDX_T_RecurringJournalLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GL_T_RecurringJournalLog] ADD  CONSTRAINT [DF_GL_T_RecurringJournalLog_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[GL_T_RecurringJournalLog] ADD  CONSTRAINT [DF_GL_T_RecurringJournalLog_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[GL_T_RecurringJournalLog] ADD  CONSTRAINT [DF_GL_T_RecurringJournalLog_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
-- Satu template hanya sekali per periode
CREATE UNIQUE NONCLUSTERED INDEX [UX_GL_T_RecurringJournalLog_Template_Period] ON [dbo].[GL_T_RecurringJournalLog]
(
	[IDX_M_RecurringJournal] ASC,
	[RecurringPeriod] ASC
)
WHERE ([RecordStatus]='A')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
