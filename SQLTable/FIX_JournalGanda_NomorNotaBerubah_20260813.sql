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
--   Beberapa nota valas punya DUA jurnal: satu memakai nomor lama, satu memakai
--   nomor yang berlaku sekarang. Akibatnya penjualan di Profit & Loss lebih
--   besar dari laporan penjualan, dan nilai persediaan di Neraca menggelembung.
--
--   Rangkaian kejadiannya: nota di-approve (jurnal dibuat dengan nomor saat itu),
--   lalu nomornya berubah karena nota sempat kembali ke DRAFT dan di-approve
--   ulang. [USP_MC_SalesJournal_Create] / [USP_MC_PurchaseJournal_Create]
--   menghapus jurnal lama dengan syarat nomor nota, sehingga jurnal bernomor
--   lama tidak ketemu, tidak terhapus, dan jurnal baru ditambahkan.
--
--   Sudah dicegah: penghapusan jurnal lama sekarang memakai kunci
--   IDX_M_JournalType + IDX_ReferenceNo saja (tanpa nomor nota), dan
--   [USP_MC_PurchaseOrder_Save] / [USP_MC_SalesOrder_Save] tidak lagi bisa
--   mengembalikan nota Approved menjadi DRAFT.
--
-- Perbaikan:
--   Hapus jurnal yang nomornya sudah tidak dipakai lagi oleh notanya, DAN
--   hanya bila nota tersebut masih punya jurnal lain dengan nomor yang berlaku
--   (jadi tidak ada transaksi yang kehilangan jurnalnya).
--
--   Nota yang notanya sendiri kehilangan nomor (sekarang DRAFT-xxxx) sengaja
--   TIDAK disentuh; kasus itu perlu keputusan terpisah dan dilaporkan di bagian
--   akhir script.
-- =============================================

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- Kandidat: jurnal bernomor basi yang notanya sudah punya jurnal pengganti
-- ---------------------------------------------------------------------------
CREATE TABLE #JurnalBasi (
	IDX_T_JournalHeader	BIGINT,
	IDX_M_JournalType	INT,
	ReferenceNo			VARCHAR(50),
	NomorSekarang		VARCHAR(50),
	JournalDate			DATE,
	Nilai				DECIMAL(22,2)
)

-- Sisi penjualan
INSERT INTO #JurnalBasi
SELECT JH.IDX_T_JournalHeader, JH.IDX_M_JournalType, RTRIM(JH.ReferenceNo), RTRIM(S.SONumber), JH.JournalDate,
	ISNULL((SELECT SUM(BDebetAmount) FROM GL_T_JournalDetail D WHERE D.IDX_T_JournalHeader = JH.IDX_T_JournalHeader), 0)
FROM GL_T_JournalHeader JH
	INNER JOIN MC_T_SalesOrder S ON S.IDX_T_SalesOrder = JH.IDX_ReferenceNo
WHERE JH.ReferenceNo LIKE 'SMC-%'
	AND RTRIM(JH.ReferenceNo) <> RTRIM(S.SONumber)
	AND S.SONumber NOT LIKE 'DRAFT-%'
	AND EXISTS (SELECT 1 FROM GL_T_JournalHeader X
				WHERE X.IDX_M_JournalType = JH.IDX_M_JournalType
					AND X.IDX_ReferenceNo = JH.IDX_ReferenceNo
					AND RTRIM(X.ReferenceNo) = RTRIM(S.SONumber))

-- Sisi pembelian
INSERT INTO #JurnalBasi
SELECT JH.IDX_T_JournalHeader, JH.IDX_M_JournalType, RTRIM(JH.ReferenceNo), RTRIM(P.PONumber), JH.JournalDate,
	ISNULL((SELECT SUM(BDebetAmount) FROM GL_T_JournalDetail D WHERE D.IDX_T_JournalHeader = JH.IDX_T_JournalHeader), 0)
FROM GL_T_JournalHeader JH
	INNER JOIN MC_T_PurchaseOrder P ON P.IDX_T_PurchaseOrder = JH.IDX_ReferenceNo
WHERE JH.ReferenceNo LIKE 'PMC-%'
	AND RTRIM(JH.ReferenceNo) <> RTRIM(P.PONumber)
	AND P.PONumber NOT LIKE 'DRAFT-%'
	AND EXISTS (SELECT 1 FROM GL_T_JournalHeader X
				WHERE X.IDX_M_JournalType = JH.IDX_M_JournalType
					AND X.IDX_ReferenceNo = JH.IDX_ReferenceNo
					AND RTRIM(X.ReferenceNo) = RTRIM(P.PONumber))

SELECT 'AKAN DIHAPUS' AS Tahap, * FROM #JurnalBasi ORDER BY JournalDate

-- ---------------------------------------------------------------------------
-- Hapus
-- ---------------------------------------------------------------------------
DELETE GL_T_JournalDetail
WHERE IDX_T_JournalHeader IN (SELECT IDX_T_JournalHeader FROM #JurnalBasi)

DELETE GL_T_JournalHeader
WHERE IDX_T_JournalHeader IN (SELECT IDX_T_JournalHeader FROM #JurnalBasi)

-- ---------------------------------------------------------------------------
-- Sisa yang perlu keputusan manual: notanya sendiri kehilangan nomor
-- ---------------------------------------------------------------------------
SELECT 'PERLU DICEK' AS Tahap, JH.IDX_T_JournalHeader, JH.IDX_M_JournalType, JH.ReferenceNo,
	S.SONumber AS NomorSekarang, S.SOStatus, JH.JournalDate, JH.PostingStatus
FROM GL_T_JournalHeader JH
	INNER JOIN MC_T_SalesOrder S ON S.IDX_T_SalesOrder = JH.IDX_ReferenceNo
WHERE JH.ReferenceNo LIKE 'SMC-%' AND RTRIM(JH.ReferenceNo) <> RTRIM(S.SONumber) AND S.SONumber LIKE 'DRAFT-%'

DROP TABLE #JurnalBasi

COMMIT TRANSACTION;
GO
