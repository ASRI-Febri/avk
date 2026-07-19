SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MC_T_COGSValasCalculation](
	[IDX_T_COGSValasCalculation] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Currency] [int] NULL,
	[IDX_M_Valas] [int] NULL,
	[COGSPeriod] [varchar](6) NULL,
	[ValasChangeNumber] [decimal](18, 2) NULL,
	[BB_ForeignAmount] [decimal](18, 4) NULL,
	[BB_Qty] [int] NULL,
	[BB_BaseAmount] [decimal](18, 4) NULL,
	[IN_ForeignAmount] [decimal](18, 4) NULL,
	[IN_Qty] [int] NULL,
	[IN_BaseAmount] [decimal](18, 4) NULL,
	[EB_ForeignAmount] [decimal](18, 4) NULL,
	[EB_Qty] [int] NULL,
	[EB_BaseAmount] [decimal](18, 4) NULL,
	[AverageAmount] [decimal](18, 4) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[UModified] [varchar](36) NULL,
	[DModified] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_COGSValasCalculation] PRIMARY KEY CLUSTERED 
(
	[IDX_T_COGSValasCalculation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_ValasChangeNumber]  DEFAULT ((0)) FOR [ValasChangeNumber]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_BB_Qty]  DEFAULT ((0)) FOR [BB_Qty]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_IN_Qty]  DEFAULT ((0)) FOR [IN_Qty]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_EB_Qty]  DEFAULT ((0)) FOR [EB_Qty]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_COGSValasCalculation] ADD  CONSTRAINT [DF_MC_T_COGSValasCalculation_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total saldo awal nilai valas dari saldo akhir peridoe sebelumnya' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'BB_ForeignAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total saldo awal rupiah dari periode sebelumnya' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'BB_BaseAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total pembelian valas sesuai periode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'IN_ForeignAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total pembelian rupiah sesuai periode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'IN_BaseAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total saldo akhir valas sesuai periode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'EB_ForeignAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'total saldo rupiah sesuai periode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'EB_BaseAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'HPP atau COGS sesuai periode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_COGSValasCalculation', @level2type=N'COLUMN',@level2name=N'AverageAmount'
GO
