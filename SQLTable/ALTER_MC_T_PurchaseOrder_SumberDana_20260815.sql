USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Perubahan tabel, 15 Agustus 2026
--
-- Transaksi penjualan (MC_T_SalesOrder) sudah menyimpan sumber dana dan tujuan
-- transaksi, tetapi transaksi pembelian belum. Kolomnya ditambahkan supaya
-- input cepat pembelian (mc-purchase-quick) bisa merekam keduanya, sama seperti
-- sisi penjualan. Panjang kolom disamakan dengan MC_T_SalesOrder.
--
-- Script idempotent, aman dijalankan ulang.
-- =============================================
IF COL_LENGTH('dbo.MC_T_PurchaseOrder', 'FundSource') IS NULL
BEGIN
	ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD [FundSource] VARCHAR(250) NULL
END
GO

IF COL_LENGTH('dbo.MC_T_PurchaseOrder', 'TransactionPurpose') IS NULL
BEGIN
	ALTER TABLE [dbo].[MC_T_PurchaseOrder] ADD [TransactionPurpose] VARCHAR(250) NULL
END
GO

SELECT c.name AS Kolom, t.name AS Tipe, c.max_length AS Panjang, c.is_nullable AS BolehKosong
FROM sys.columns c
	JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.MC_T_PurchaseOrder')
	AND c.name IN ('FundSource','TransactionPurpose')
GO
