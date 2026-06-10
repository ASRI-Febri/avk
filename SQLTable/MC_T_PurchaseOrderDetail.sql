SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MC_T_PurchaseOrderDetail](
	[IDX_T_PurchaseOrderDetail] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_T_PurchaseOrder] [bigint] NOT NULL,
	[IDX_M_Valas] [int] NULL,
	[IDX_M_Tax] [int] NULL,
	[ForeignCurrency] [int] NULL,
	[Quantity] [int] NULL,
	[ForeignAmount] [decimal](22, 4) NULL,
	[ExchangeRate] [decimal](22, 4) NULL,
	[BaseCurrency] [int] NULL,
	[BaseCurrencyAmount] [decimal](22, 4) NULL,
	[DetailNotes] [varchar](5000) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_PurchaseOrderDetail] PRIMARY KEY CLUSTERED 
(
	[IDX_T_PurchaseOrderDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrderDetail] ADD  CONSTRAINT [DF_MC_T_PurchaseOrderDetail_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrderDetail] ADD  CONSTRAINT [DF_MC_T_PurchaseOrderDetail_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrderDetail] ADD  CONSTRAINT [DF_MC_T_PurchaseOrderDetail_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_PurchaseOrderDetail] ADD  CONSTRAINT [DF_MC_T_PurchaseOrderDetail_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
