USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Perbaikan data, 13 Agustus 2026
--
-- Masalah:
--   Baris detail Financial Receive / Financial Payment yang sudah tertaut ke
--   transaksi valas (IDX_DocumentNo + DocumentNo benar) menyimpan
--   IDX_M_DocumentType yang salah: 1 (Sales Invoice) atau 2 (Purchase Invoice),
--   padahal transaksinya bertipe 12 (SMC / Sales Order Money Changer) atau
--   11 (PMC / Purchase Order Money Changer).
--
--   Penyebabnya controller detail Financial Receive/Payment yang dulu menulis
--   IDX_M_DocumentType secara hardcode setiap kali detail disunting; sudah
--   diperbaiki di FinancialReceiveDetailController / FinancialPaymentDetailController.
--
--   Akibatnya laporan mc-rpt-ar dan mc-rpt-ap tidak menghitung pembayaran
--   tersebut, karena join-nya menyertakan syarat document type.
--
-- Perbaikan:
--   Selaraskan IDX_M_DocumentType di detail dengan document type transaksi
--   yang benar benar ditunjuk oleh IDX_DocumentNo + DocumentNo. Hanya baris
--   yang pasangan nomor + index-nya cocok yang disentuh, jadi script ini aman
--   dijalankan ulang (idempotent) dan tidak menyentuh detail yang memang
--   mengacu ke Sales Invoice / Purchase Invoice sungguhan.
-- =============================================

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- SEBELUM
-- ---------------------------------------------------------------------------
SELECT 'SEBELUM - RECEIVE' AS Tahap, FPD.IDX_T_FinancialReceiveDetail,
	FPD.IDX_M_DocumentType AS DocTypeDetail, MH.IDX_M_DocumentType AS DocTypeTransaksi,
	FPD.DocumentNo, FPH.ReceiveStatus
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	INNER JOIN MC_T_SalesOrder MH ON MH.SONumber = FPD.DocumentNo AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

SELECT 'SEBELUM - PAYMENT' AS Tahap, FPD.IDX_T_FinancialPaymentDetail,
	FPD.IDX_M_DocumentType AS DocTypeDetail, MH.IDX_M_DocumentType AS DocTypeTransaksi,
	FPD.DocumentNo, FPH.PaymentStatus
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	INNER JOIN MC_T_PurchaseOrder MH ON MH.PONumber = FPD.DocumentNo AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

-- ---------------------------------------------------------------------------
-- PERBAIKAN
-- ---------------------------------------------------------------------------
UPDATE FPD SET
	 FPD.IDX_M_DocumentType	= MH.IDX_M_DocumentType
	,FPD.UModified			= 'FIX-DOCTYPE-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder MH ON MH.SONumber = FPD.DocumentNo AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

UPDATE FPD SET
	 FPD.IDX_M_DocumentType	= MH.IDX_M_DocumentType
	,FPD.UModified			= 'FIX-DOCTYPE-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder MH ON MH.PONumber = FPD.DocumentNo AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

-- ---------------------------------------------------------------------------
-- SESUDAH (harus kosong)
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH - RECEIVE' AS Tahap, COUNT(*) AS SisaTidakSinkron
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder MH ON MH.SONumber = FPD.DocumentNo AND MH.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

SELECT 'SESUDAH - PAYMENT' AS Tahap, COUNT(*) AS SisaTidakSinkron
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder MH ON MH.PONumber = FPD.DocumentNo AND MH.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE ISNULL(FPD.IDX_M_DocumentType,0) <> MH.IDX_M_DocumentType

COMMIT TRANSACTION;
GO
