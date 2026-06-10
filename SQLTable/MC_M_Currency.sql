/****** Object:  Table [dbo].[MC_M_Currency]    Script Date: 6/10/2026 9:41:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MC_M_Currency](
	[IDX_M_Currency] [int] IDENTITY(1,1) NOT NULL,
	[IDX_M_Country] [int] NULL,
	[CurrencyID] [varchar](3) NULL,
	[CurrencyName] [varchar](32) NULL,
	[Symbol] [varchar](8) NULL,
	[Remarks] [varchar](128) NULL,
	[Rounding] [decimal](18, 4) NULL,
	[Accuracy] [int] NULL,
	[BuyRate] [decimal](18, 4) NULL,
	[SellRate] [decimal](18, 4) NULL,
	[IconFlag] [varchar](50) NULL,
	[SortPriority] [smallint] NULL,
	[PurchaseAccount] [int] NULL,
	[SalesAccount] [int] NULL,
	[COGSAccount] [int] NULL,
	[DCreate] [datetime] NULL,
	[UCreate] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[Recordstatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_M_Currency] PRIMARY KEY CLUSTERED 
(
	[IDX_M_Currency] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_SortPriority]  DEFAULT ((0)) FOR [SortPriority]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_COAPurchase]  DEFAULT ((0)) FOR [PurchaseAccount]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_COASales]  DEFAULT ((0)) FOR [SalesAccount]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_SalesAccount1]  DEFAULT ((0)) FOR [COGSAccount]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO

ALTER TABLE [dbo].[MC_M_Currency] ADD  CONSTRAINT [DF_MC_M_Currency_Recordstatus]  DEFAULT ('A') FOR [Recordstatus]
GO
