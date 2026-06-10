SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MC_T_SalesOrder](
	[IDX_T_SalesOrder] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[IDX_M_Branch] [int] NULL,
	[IDX_M_DocumentType] [int] NULL,
	[IDX_M_Partner] [bigint] NULL,
	[SONumber] [varchar](50) NULL,
	[SODate] [date] NULL,
	[SONotes] [varchar](5000) NULL,
	[SOStatus] [char](1) NULL,
	[ReferenceNo] [varchar](50) NULL,
	[FundSource] [varchar](250) NULL,
	[TransactionPurpose] [varchar](250) NULL,
	[SOApprovalDate] [date] NULL,
	[SOApprovalNotes] [varchar](5000) NULL,
	[SOApprovalBy] [varchar](50) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_SalesOrder] PRIMARY KEY CLUSTERED 
(
	[IDX_T_SalesOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_SalesOrder] ADD  CONSTRAINT [DF_MC_T_SalesOrder_IDX_M_DocumentType]  DEFAULT ((11)) FOR [IDX_M_DocumentType]
GO
ALTER TABLE [dbo].[MC_T_SalesOrder] ADD  CONSTRAINT [DF_Table_1_POStatus]  DEFAULT ('D') FOR [SOStatus]
GO
ALTER TABLE [dbo].[MC_T_SalesOrder] ADD  CONSTRAINT [DF_MC_T_SalesOrder_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_SalesOrder] ADD  CONSTRAINT [DF_MC_T_SalesOrder_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_SalesOrder] ADD  CONSTRAINT [DF_MC_T_SalesOrder_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
