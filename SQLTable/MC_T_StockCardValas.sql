SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MC_T_StockCardValas](
	[IDX_T_StockCardValas] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Branch] [int] NULL,
	[IDX_M_Valas] [int] NULL,
	[IDX_M_TransactionType] [int] NULL,
	[IDX_Transaction] [bigint] NULL,
	[TransactionNo] [varchar](50) NULL,
	[TransactionDate] [date] NULL,
	[StockInQty] [decimal](18, 4) NULL,
	[ExchangeRateIn] [decimal](18, 4) NULL,
	[StockInForeignAmount] [decimal](18, 4) NULL,
	[StockInBaseAmount] [decimal](18, 4) NULL,
	[StockOutQty] [decimal](18, 4) NULL,
	[ExchangeRateOut] [decimal](18, 4) NULL,
	[StockOutForeignAmount] [decimal](18, 4) NULL,
	[StockOutBaseAmount] [decimal](18, 4) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_StockCardValas] PRIMARY KEY CLUSTERED 
(
	[IDX_T_StockCardValas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_StockCardValas] ADD  CONSTRAINT [DF_MC_T_StockCardValas_TransactionType]  DEFAULT ('') FOR [IDX_M_TransactionType]
GO
ALTER TABLE [dbo].[MC_T_StockCardValas] ADD  CONSTRAINT [DF_MC_T_StockCardValas_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_StockCardValas] ADD  CONSTRAINT [DF_MC_T_StockCardValas_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_StockCardValas] ADD  CONSTRAINT [DF_MC_T_StockCardValas_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_StockCardValas', @level2type=N'COLUMN',@level2name=N'IDX_M_TransactionType'
GO
