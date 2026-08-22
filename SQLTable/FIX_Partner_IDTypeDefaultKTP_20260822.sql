SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 22 Aug 2026
-- Description:	Jenis identitas yang masih kosong dianggap KTP.
--				Sebagian besar konsumen memang memakai KTP, jadi kolom kosong
--				lebih menyusahkan daripada membantu; yang bukan KTP tinggal
--				diubah lewat menu Business Partner.
--
--				Script boleh dijalankan berulang.
-- =============================================
DECLARE @IDX_KTP BIGINT

SELECT TOP 1 @IDX_KTP = IDX_M_IDType
FROM GN_M_IDType WITH(NOLOCK)
WHERE RTRIM(ISNULL(Alias,'')) = 'KTP'
ORDER BY IDX_M_IDType

IF @IDX_KTP IS NULL
BEGIN
	RAISERROR('Jenis identitas KTP belum ada di GN_M_IDType.', 16, 1)
	RETURN
END

UPDATE GN_M_Partner SET
	IDX_M_IDType = @IDX_KTP
WHERE IDX_M_IDType IS NULL
GO
