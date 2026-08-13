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
--   DocumentNo di detail Financial Payment / Financial Receive adalah salinan
--   nomor nota pada saat pembayaran dibuat. Kalau nomor notanya berubah setelah
--   itu, salinan tersebut jadi basi. Bahkan ada nomor basi yang sekarang sudah
--   dipakai nota lain, jadi pembayaran seolah menunjuk transaksi yang salah.
--
--   Nomor nota bisa berubah karena Save di form pembelian/penjualan dulu ikut
--   menimpa PONumber/SONumber dan POStatus/SOStatus dari hidden field. Halaman
--   yang dibuka sebelum approval, lalu di-Save setelah approval, mengembalikan
--   nota ke DRAFT-xxxx; approval berikutnya memberi nomor urut baru, sedangkan
--   nomor lamanya bisa terpakai oleh nota lain. Sudah dicegah di
--   [USP_MC_PurchaseOrder_Save] dan [USP_MC_SalesOrder_Save].
--
-- Perbaikan:
--   IDX_DocumentNo (kunci ke tabel transaksi) selalu benar, jadi DocumentNo dan
--   teks nomor di RemarkDetail diselaraskan dengan nomor nota yang berlaku
--   sekarang. Nota yang saat ini justru bernomor DRAFT-xxxx sengaja dilewati:
--   di kasus itu yang hilang adalah nomor notanya, jadi perbaikannya di sisi
--   nota, bukan di pembayaran. Baris seperti itu dilaporkan terpisah di bawah.
-- =============================================

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- SEBELUM
-- ---------------------------------------------------------------------------
SELECT 'SEBELUM - PAYMENT' AS Tahap, FPD.IDX_T_FinancialPaymentDetail, FPD.IDX_DocumentNo,
	FPD.DocumentNo AS DocumentNoLama, PO.PONumber AS DocumentNoBaru, PO.ReferenceNo, FPH.PaymentID
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(PO.PONumber) AND PO.PONumber NOT LIKE 'DRAFT-%'

SELECT 'SEBELUM - RECEIVE' AS Tahap, FPD.IDX_T_FinancialReceiveDetail, FPD.IDX_DocumentNo,
	FPD.DocumentNo AS DocumentNoLama, SO.SONumber AS DocumentNoBaru, SO.ReferenceNo, FPH.ReceiveID
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(SO.SONumber) AND SO.SONumber NOT LIKE 'DRAFT-%'

-- ---------------------------------------------------------------------------
-- PERBAIKAN
-- ---------------------------------------------------------------------------
UPDATE FPD SET
	 FPD.RemarkDetail		= REPLACE(ISNULL(FPD.RemarkDetail,''), RTRIM(FPD.DocumentNo), RTRIM(PO.PONumber))
	,FPD.DocumentNo			= RTRIM(PO.PONumber)
	,FPD.UModified			= 'FIX-DOCNO-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(PO.PONumber) AND PO.PONumber NOT LIKE 'DRAFT-%'

UPDATE FPD SET
	 FPD.RemarkDetail		= REPLACE(ISNULL(FPD.RemarkDetail,''), RTRIM(FPD.DocumentNo), RTRIM(SO.SONumber))
	,FPD.DocumentNo			= RTRIM(SO.SONumber)
	,FPD.UModified			= 'FIX-DOCNO-20260813'
	,FPD.DModified			= GETDATE()
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(SO.SONumber) AND SO.SONumber NOT LIKE 'DRAFT-%'

-- ---------------------------------------------------------------------------
-- SESUDAH (harus 0)
-- ---------------------------------------------------------------------------
SELECT 'SESUDAH - PAYMENT' AS Tahap, COUNT(*) AS SisaTidakSinkron
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(PO.PONumber) AND PO.PONumber NOT LIKE 'DRAFT-%'

SELECT 'SESUDAH - RECEIVE' AS Tahap, COUNT(*) AS SisaTidakSinkron
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(SO.SONumber) AND SO.SONumber NOT LIKE 'DRAFT-%'

-- ---------------------------------------------------------------------------
-- PERLU DITANGANI MANUAL: notanya sendiri kehilangan nomor (kembali ke DRAFT-)
-- padahal pembayaran/penerimaan dan kartu stoknya sudah terlanjur jalan.
-- ---------------------------------------------------------------------------
SELECT 'PERLU DICEK - SALES ORDER' AS Tahap, SO.IDX_T_SalesOrder, SO.SONumber, SO.SOStatus,
	SO.SOApprovalDate, SO.SOApprovalBy, FPD.DocumentNo AS NomorDiPenerimaan, FPH.ReceiveID, FPH.ReceiveStatus
FROM CM_T_FinancialReceiveDetail FPD
	INNER JOIN CM_T_FinancialReceiveHeader FPH ON FPH.IDX_T_FinancialReceiveHeader = FPD.IDX_T_FinancialReceiveHeader
	INNER JOIN MC_T_SalesOrder SO ON SO.IDX_T_SalesOrder = FPD.IDX_DocumentNo
WHERE SO.SONumber LIKE 'DRAFT-%' AND RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(SO.SONumber)

SELECT 'PERLU DICEK - PURCHASE ORDER' AS Tahap, PO.IDX_T_PurchaseOrder, PO.PONumber, PO.POStatus,
	PO.POApprovalDate, PO.POApprovalBy, FPD.DocumentNo AS NomorDiPembayaran, FPH.PaymentID, FPH.PaymentStatus
FROM CM_T_FinancialPaymentDetail FPD
	INNER JOIN CM_T_FinancialPaymentHeader FPH ON FPH.IDX_T_FinancialPaymentHeader = FPD.IDX_T_FinancialPaymentHeader
	INNER JOIN MC_T_PurchaseOrder PO ON PO.IDX_T_PurchaseOrder = FPD.IDX_DocumentNo
WHERE PO.PONumber LIKE 'DRAFT-%' AND RTRIM(ISNULL(FPD.DocumentNo,'')) <> RTRIM(PO.PONumber)

COMMIT TRANSACTION;
GO
