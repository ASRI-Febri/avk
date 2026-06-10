SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MC_T_PurchaseOrder](
	[IDX_T_PurchaseOrder] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Company] [int] NULL,
	[IDX_M_Branch] [int] NULL,
	[IDX_M_DocumentType] [int] NULL,
	[IDX_M_Partner] [bigint] NULL,
	[PONumber] [varchar](50) NULL,
	[PODate] [date] NULL,
	[PONotes] [varchar](5000) NULL,
	[POStatus] [char](1) NULL,
	[ReferenceNo] [varchar](50) NULL,
	[POApprovalDate] [date] NULL,
	[POApprovalNotes] [varchar](5000) NULL,
	[POApprovalBy] [varchar](50) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_PurchaseOrder] PRIMARY KEY CLUSTERED 
(
	[IDX_T_PurchaseOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD  CONSTRAINT [DF_MC_T_PurchaseOrder_IDX_M_DocumentType]  DEFAULT ((11)) FOR [IDX_M_DocumentType]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD  CONSTRAINT [DF_MC_T_PurchaseOrder_POStatus]  DEFAULT ('D') FOR [POStatus]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD  CONSTRAINT [DF_MC_T_PurchaseOrder_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD  CONSTRAINT [DF_MC_T_PurchaseOrder_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD  CONSTRAINT [DF_MC_T_PurchaseOrder_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
