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
--   Ada detail Financial Payment / Financial Receive yang DocumentNo-nya masih
--   'DRAFT-xxxxx'. Pembayaran itu diinput ketika nota pembelian/penjualannya
--   masih berstatus Draft. Saat nota di-approve, [USP_MC_PurchaseOrder_Approve]
--   dan [USP_MC_SalesOrder_Approve] mengganti nomor nota menjadi PMC-/SMC-,
--   tetapi DocumentNo yang sudah tersimpan di detail pembayaran tidak ikut
--   diperbarui, sehingga pembayarannya putus dari notanya (mis. di laporan
--   mc-rpt-ar / mc-rpt-ap yang join lewat nomor dokumen).
--
--   Pencegahannya sudah dipasang di [USP_MC_PurchaseOrder_Payment] dan
--   [USP_MC_SalesOrder_Payment]: pembayaran hanya boleh untuk nota Approved.
--
-- Perbaikan:
--   Selaraskan DocumentNo (dan teks nomor di RemarkDetail) dengan nomor nota
--   yang berlaku sekarang. IDX_DocumentNo tidak disentuh karena sudah benar,
--   dan hanya baris yang IDX-nya cocok dengan notanya yang diperbarui, jadi
--   script ini aman dijalankan ulang.
-- =============================================

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- SEBELUM
-- ---------------------------------------------------------------------------
SELECT 'SEBELUM - PAYMENT' AS Tahap, FPD.IDX_T_FinancialPaymentDetail,
	FPD.DocumentNo AS DocumentNoLama, PO.PONumber AS DocumentNoBaru, PO.POStatus, FPH.PaymentStatus
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND PO.PONumber NOT LIKE 'DRAFT-%'

SELECT 'SEBELUM - RECEIVE' AS Tahap, FPD.IDX_T_FinancialReceiveDetail,
	FPD.DocumentNo AS DocumentNoLama, SO.SONumber AS DocumentNoBaru, SO.SOStatus, FPH.ReceiveStatus
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND SO.SONumber NOT LIKE 'DRAFT-%'

-- ---------------------------------------------------------------------------
-- PERBAIKAN
-- ---------------------------------------------------------------------------
UPDATE FPD SET
	 FPD.RemarkDetail		= REPLACE(ISNULL(FPD.RemarkDetail,''), RTRIM(FPD.DocumentNo), RTRIM(PO.PONumber))
	,FPD.DocumentNo			= RTRIM(PO.PONumber)
	,FPD.UModified			= 'FIX-DRAFTNO-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND PO.PONumber NOT LIKE 'DRAFT-%'

UPDATE FPD SET
	 FPD.RemarkDetail		= REPLACE(ISNULL(FPD.RemarkDetail,''), RTRIM(FPD.DocumentNo), RTRIM(SO.SONumber))
	,FPD.DocumentNo			= RTRIM(SO.SONumber)
	,FPD.UModified			= 'FIX-DRAFTNO-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND SO.SONumber NOT LIKE 'DRAFT-%'

-- ---------------------------------------------------------------------------
-- SESUDAH (harus 0)
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH - PAYMENT' AS Tahap, COUNT(*) AS SisaDraft
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND PO.PONumber NOT LIKE 'DRAFT-%'

SELECT 'SESUDAH - RECEIVE' AS Tahap, COUNT(*) AS SisaDraft
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE FPD.DocumentNo LIKE 'DRAFT-%' AND SO.SONumber NOT LIKE 'DRAFT-%'

COMMIT TRANSACTION;
GO
