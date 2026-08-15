USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 15 Agustus 2026
-- Description:	Sisa stok valas per pecahan di satu cabang sampai tanggal
--				tertentu, dalam satuan lembar/koin.
--
--				Dipakai form input cepat penjualan untuk memberi tahu kasir
--				sisa stok sebelum menyimpan. Rumusnya sengaja disamakan dengan
--				validasi di [USP_MC_SalesOrderDetail_Save]:
--
--					stok = SUM(StockInQty) - SUM(StockOutQty)
--					WHERE cabang, pecahan, dan TransactionDate <= tanggal nota
--
--				Kalau rumus di sana berubah, ubah juga di sini supaya angka di
--				layar tidak berbeda dengan yang menolak saat simpan.
-- =============================================

/*
	EXEC [dbo].[USP_MC_ValasStock_List] 1, '2026-08-15'
*/

IF OBJECT_ID('[dbo].[USP_MC_ValasStock_List]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_ValasStock_List]
GO

CREATE PROCEDURE [dbo].[USP_MC_ValasStock_List]
	@IDX_M_Branch	BIGINT,
	@AsOfDate		DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @AsOfDate IS NULL
		SET @AsOfDate = CONVERT(DATE, GETDATE())

	SELECT
		V.IDX_M_Valas,
		ValasSKU	= RTRIM(ISNULL(V.ValasSKU,'')),
		StockQty	= ISNULL(S.Sisa, 0)
	FROM MC_M_Valas V WITH(NOLOCK)
		LEFT JOIN (
			SELECT IDX_M_Valas, Sisa = SUM(ISNULL(StockInQty,0)) - SUM(ISNULL(StockOutQty,0))
			FROM MC_T_StockCardValas WITH(NOLOCK)
			WHERE IDX_M_Branch = @IDX_M_Branch
				AND CONVERT(DATE, TransactionDate) <= @AsOfDate
			GROUP BY IDX_M_Valas
		) S ON S.IDX_M_Valas = V.IDX_M_Valas
	WHERE RTRIM(ISNULL(V.RecordStatus,'')) = 'A'
	ORDER BY V.IDX_M_Valas
END
GO
