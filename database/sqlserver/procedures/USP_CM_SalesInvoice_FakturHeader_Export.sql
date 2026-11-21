/* =============================================
Author			: Samuel Febrianto
Create date		: 22 Desember 2017
Description		: Sales Invoice List
Mod date		: 2019-08-12
Mod desc		: Adjust logic for calculate total Invoice (using temp table #SUMInvoice)

/*	

	EXEC [PralonDB].[dbo].[USP_CM_SalesInvoice_FakturHeader_Export]
		'10792'
	
*/
-- ============================================= */

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_FakturHeader_Export]
	@IDX_T_SalesInvoice	VARCHAR(512)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	CREATE TABLE #TempInvoice
	(IDX_T_SalesInvoiceHeader BIGINT, TotalDPP DECIMAL(18,2), TotalPPN DECIMAL(18,2))

	CREATE CLUSTERED INDEX ix_tempCIndexBef ON #TempInvoice ([IDX_T_SalesInvoiceHeader]);

	INSERT INTO #TempInvoice
	SELECT SID.IDX_T_SalesInvoiceHeader, SUM(Quantity * (UntaxedAmount -  DiscountAmount)), SUM(Quantity * (TaxAmount))
	FROM CM_T_SalesInvoiceDetail SID
	WHERE IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoice
	GROUP BY IDX_T_SalesInvoiceHeader


	SELECT	'FK' As FK, LEFT(TSIH.TaxInvoiceNo,2) As KD_JENIS_TRANSAKSI, SUBSTRING(TSIH.TaxInvoiceNo,3,1) As FG_PENGGANTI, 
			REPLACE(REPLACE(SUBSTRING(TSIH.TaxInvoiceNo,5,15),'.',''),'-','') As NOMOR_FAKTUR, MONTH(TSIH.InvoiceDate) As MASA_PAJAK, 
			YEAR(TSIH.InvoiceDate) As TAHUN_PAJAK, CONVERT (VARCHAR(10), TSIH.InvoiceDate, 103) As TANGGAL_FAKTUR, REPLACE(REPLACE(MP.TaxIdentityNumber,'.',''),'-','') As NPWP, 
			MP.PartnerName As NAMA,  REPLACE(MPA.Street,',',' ') + ' ' + MPC.Zip As ALAMAT_LENGKAP, 
			CONVERT(DECIMAL(18,0),FLOOR(TI.TotalDPP)) As JUMLAH_DPP, CONVERT(DECIMAL(18,0),FLOOR(TI.TotalPPN)) As JUMLAH_PPN, '0' As JUMLAH_PPNBM, '' As ID_KETERANGAN_TAMBAHAN,
			'0' As FG_UANG_MUKA, '0' As UANG_MUKA_DPP, '0' As UANG_MUKA_PPN, '0' As UANG_MUKA_PPNBM, TSIH.InvoiceNo As REFERENSI

	FROM	CM_T_SalesInvoiceHeader TSIH
	LEFT JOIN #TempInvoice TI ON TSIH.IDX_T_SalesInvoiceHeader=TI.IDX_T_SalesInvoiceHeader
	LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = TSIH.IDX_M_Partner 
	LEFT JOIN GN_M_PartnerAddress MPA ON MP.IDX_M_Partner=MPA.IDX_M_Partner AND MPA.IDX_M_AddressType = 1
	LEFT JOIN GN_M_PostalCode MPC ON MPA.IDX_M_PostalCode=MPC.IDX_M_PostalCode
	WHERE TSIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoice
	
	


	--INSERT INTO CM_T_FakturPajak
	--(
	--	IDX_T_Transaction, TransactionType, KodeTransaksi, NomorFaktur, TanggalFaktur, MasaPajak, TahunPajak, StatusPajak,UCreate,  DCreate
	--)
	--SELECT	@IDX_T_SalesInvoice, 'SI', '01', TaxInvoiceNo,  TSIH.InvoiceDate, MONTH(TSIH.InvoiceDate), YEAR(TSIH.InvoiceDate), 'A', SUSER_SNAME(), SYSDATETIME()
	--FROM	CM_T_SalesInvoiceHeader TSIH
	--WHERE	TSIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoice


	DROP TABLE #TempInvoice

END
