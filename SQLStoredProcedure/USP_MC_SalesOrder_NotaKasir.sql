USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 14 Agustus 2026
-- Description:	Data kop Nota Kasir transaksi valas (cetak dot matrix LX-310).
--				Satu baris berisi identitas perusahaan, cabang, nasabah, dan
--				ringkasan transaksi. Baris transaksinya diambil terpisah lewat
--				[USP_MC_SalesOrderDetail_List].
--
--				Alamat nasabah diambil dari alamat default GN_M_PartnerAddress,
--				kalau tidak ada dipakai alamat mana pun yang tersedia.
-- =============================================

/*
	EXEC [dbo].[USP_MC_SalesOrder_NotaKasir] 50901
*/

IF OBJECT_ID('[dbo].[USP_MC_SalesOrder_NotaKasir]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_MC_SalesOrder_NotaKasir]
GO

CREATE PROCEDURE [dbo].[USP_MC_SalesOrder_NotaKasir]
	@IDX_T_SalesOrder	BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		S.IDX_T_SalesOrder,
		SONumber			= RTRIM(ISNULL(S.SONumber,'')),
		S.SODate,
		ReferenceNo			= RTRIM(ISNULL(S.ReferenceNo,'')),
		SONotes				= RTRIM(ISNULL(S.SONotes,'')),
		S.SOStatus,
		FundSource			= RTRIM(ISNULL(S.FundSource,'')),
		TransactionPurpose	= RTRIM(ISNULL(S.TransactionPurpose,'')),
		-- PERUSAHAAN
		CompanyName			= UPPER(RTRIM(ISNULL(MC.CompanyName,''))),
		CompanyAddress		= UPPER(RTRIM(ISNULL(MC.LegalAddress,''))),
		CompanyAddress2		= UPPER(LTRIM(RTRIM(
								RTRIM(ISNULL(MC.Subdistrict,'')) + ' ' + RTRIM(ISNULL(MC.District,'')) + ' ' +
								RTRIM(ISNULL(MC.City,'')) + ' ' + RTRIM(ISNULL(MC.Province,''))))),
		CompanyPhone		= RTRIM(ISNULL(MC.Phone,'')),
		CompanyLicense		= RTRIM(ISNULL(NULLIF(RTRIM(ISNULL(MC.SIUP,'')), '0'), '')),
		-- CABANG
		BranchID			= RTRIM(ISNULL(MB.BranchID,'')),
		BranchName			= UPPER(RTRIM(ISNULL(MB.BranchName,''))),
		BranchAddress		= UPPER(RTRIM(ISNULL(MB.BranchAddress,''))),
		-- NASABAH
		PartnerID			= RTRIM(ISNULL(MP.PartnerID,'')),
		PartnerName			= UPPER(RTRIM(ISNULL(MP.PartnerName,''))),
		PartnerNIK			= RTRIM(ISNULL(MP.SingleIdentityNumber,'')),
		PartnerPhone		= RTRIM(ISNULL(NULLIF(RTRIM(ISNULL(MP.MobilePhone,'')), '0'),
								NULLIF(RTRIM(ISNULL(MP.Phone1,'')), '0'))),
		PartnerAddress		= UPPER(RTRIM(ISNULL(PA.Alamat,''))),
		PartnerAddress2		= UPPER(RTRIM(ISNULL(PA.Alamat2,''))),
		-- PETUGAS
		AdminName			= UPPER(RTRIM(ISNULL(NULLIF(RTRIM(ISNULL(SU.Name,'')),''), ISNULL(S.UCreate,'')))),
		S.DCreate
	FROM MC_T_SalesOrder S WITH(NOLOCK)
		LEFT JOIN GN_M_Company MC WITH(NOLOCK) ON MC.IDX_M_Company = S.IDX_M_Company
		LEFT JOIN GN_M_Branch MB WITH(NOLOCK) ON MB.IDX_M_Branch = S.IDX_M_Branch
		LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON MP.IDX_M_Partner = S.IDX_M_Partner
		LEFT JOIN SM_M_User SU WITH(NOLOCK) ON RTRIM(SU.LoginID) = RTRIM(S.UCreate)
		OUTER APPLY (
			SELECT TOP 1
				Alamat	= LTRIM(RTRIM(ISNULL(A.Street,''))),
				Alamat2	= LTRIM(RTRIM(RTRIM(ISNULL(PC.Subdistrict,'')) + ' ' + RTRIM(ISNULL(PC.District,''))
							+ ' ' + RTRIM(ISNULL(PC.City,'')) + ' ' + RTRIM(ISNULL(A.Zip,''))))
			FROM GN_M_PartnerAddress A WITH(NOLOCK)
				LEFT JOIN GN_M_PostalCode PC WITH(NOLOCK) ON PC.IDX_M_PostalCode = A.IDX_M_PostalCode
			WHERE A.IDX_M_Partner = S.IDX_M_Partner
			ORDER BY CASE WHEN RTRIM(ISNULL(A.IsDefault,'')) = 'Y' THEN 0 ELSE 1 END, A.IDX_M_PartnerAddress
		) PA
	WHERE S.IDX_T_SalesOrder = @IDX_T_SalesOrder
END
GO
