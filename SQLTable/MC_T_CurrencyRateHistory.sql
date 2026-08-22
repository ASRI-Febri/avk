SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Aug 2026
-- Description:	Riwayat Rate Beli/Jual mata uang (MC_M_Currency).
--				Satu baris dicatat setiap kali BuyRate/SellRate suatu mata uang
--				diubah lewat layar Update Kurs. Kolom BuyRate/SellRate berisi
--				nilai SEBELUM perubahan, NewBuyRate/NewSellRate nilai sesudahnya,
--				sehingga kurs yang berlaku pada tanggal transaksi lama tetap bisa
--				ditelusuri walau master sudah diperbarui.
-- =============================================
CREATE TABLE [dbo].[MC_T_CurrencyRateHistory](
	[IDX_T_CurrencyRateHistory] [bigint] IDENTITY(1,1) NOT NULL,
	[IDX_M_Currency] [int] NOT NULL,
	[CurrencyID] [varchar](3) NULL,
	[BuyRate] [decimal](18, 4) NULL,
	[SellRate] [decimal](18, 4) NULL,
	[NewBuyRate] [decimal](18, 4) NULL,
	[NewSellRate] [decimal](18, 4) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeSource] [varchar](32) NULL,
	[Remarks] [varchar](256) NULL,
	[UCreate] [varchar](36) NULL,
	[DCreate] [datetime] NULL,
	[RecordStatus] [varchar](1) NULL,
 CONSTRAINT [PK_MC_T_CurrencyRateHistory] PRIMARY KEY CLUSTERED
(
	[IDX_T_CurrencyRateHistory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MC_T_CurrencyRateHistory] ADD  CONSTRAINT [DF_MC_T_CurrencyRateHistory_ChangeDate]  DEFAULT (getdate()) FOR [ChangeDate]
GO
ALTER TABLE [dbo].[MC_T_CurrencyRateHistory] ADD  CONSTRAINT [DF_MC_T_CurrencyRateHistory_ChangeSource]  DEFAULT ('MANUAL') FOR [ChangeSource]
GO
ALTER TABLE [dbo].[MC_T_CurrencyRateHistory] ADD  CONSTRAINT [DF_MC_T_CurrencyRateHistory_UCreate]  DEFAULT (suser_name()) FOR [UCreate]
GO
ALTER TABLE [dbo].[MC_T_CurrencyRateHistory] ADD  CONSTRAINT [DF_MC_T_CurrencyRateHistory_DCreate]  DEFAULT (sysdatetime()) FOR [DCreate]
GO
ALTER TABLE [dbo].[MC_T_CurrencyRateHistory] ADD  CONSTRAINT [DF_MC_T_CurrencyRateHistory_RecordStatus]  DEFAULT ('A') FOR [RecordStatus]
GO
-- Penelusuran riwayat selalu per mata uang dan diurutkan dari yang terbaru.
CREATE NONCLUSTERED INDEX [IX_MC_T_CurrencyRateHistory_Currency_Date]
	ON [dbo].[MC_T_CurrencyRateHistory] ([IDX_M_Currency] ASC, [ChangeDate] DESC)
	INCLUDE ([CurrencyID],[BuyRate],[SellRate],[NewBuyRate],[NewSellRate],[UCreate],[ChangeSource])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rate beli SEBELUM perubahan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_CurrencyRateHistory', @level2type=N'COLUMN',@level2name=N'BuyRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rate jual SEBELUM perubahan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_CurrencyRateHistory', @level2type=N'COLUMN',@level2name=N'SellRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asal perubahan: MANUAL (layar Update Kurs), IMPORT-PANIN, IMPORT-BCA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MC_T_CurrencyRateHistory', @level2type=N'COLUMN',@level2name=N'ChangeSource'
GO
