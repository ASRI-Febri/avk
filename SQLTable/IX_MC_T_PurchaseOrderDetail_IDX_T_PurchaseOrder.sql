SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Covering index untuk mempercepat agregasi
-- SUM(BaseCurrencyAmount) per IDX_T_PurchaseOrder yang dipakai di
-- [dbo].[USP_MC_PurchaseOrder_List] (kolom Nilai Transaksi).
--
-- Seek by IDX_T_PurchaseOrder + BaseCurrencyAmount & RecordStatus
-- tersedia di leaf level (INCLUDE), sehingga agregasi tidak perlu
-- lookup ke clustered index (covering index).
-- =============================================
IF NOT EXISTS (
	SELECT 1 FROM sys.indexes
	WHERE name = 'IX_MC_T_PurchaseOrderDetail_IDX_T_PurchaseOrder'
		AND object_id = OBJECT_ID('[dbo].[MC_T_PurchaseOrderDetail]')
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_MC_T_PurchaseOrderDetail_IDX_T_PurchaseOrder]
		ON [dbo].[MC_T_PurchaseOrderDetail] ([IDX_T_PurchaseOrder] ASC)
		INCLUDE ([BaseCurrencyAmount], [RecordStatus])
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
			DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		ON [PRIMARY]
END
GO
