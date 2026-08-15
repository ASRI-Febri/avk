USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 15 Agustus 2026
-- Description:	Simpan alamat KTP konsumen dari form input cepat valas.
--
--				[USP_CM_PartnerAddress_Create] tidak bisa dipakai di sini karena
--				mewajibkan @IDX_M_PostalCode, sedangkan input cepat hanya
--				meminta data wajib: nama, NIK, alamat, dan no handphone.
--
--				Kode pos tetap dihubungkan ke master bila kasir mengisinya:
--				@Zip dicocokkan ke GN_M_PostalCode. Bila kosong atau tidak
--				ketemu, alamat tetap tersimpan dengan kode pos NULL dan bisa
--				dilengkapi belakangan lewat menu Business Partner.
-- =============================================

/*
	EXEC [dbo].[USP_GN_PartnerQuickAddress_Create] 61387, 'JL MERDEKA NO 1', '17423', 'it_febry'
*/

IF OBJECT_ID('[dbo].[USP_GN_PartnerQuickAddress_Create]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_GN_PartnerQuickAddress_Create]
GO

CREATE PROCEDURE [dbo].[USP_GN_PartnerQuickAddress_Create]
	@IDX_M_Partner	BIGINT,
	@Street			VARCHAR(1024),
	@Zip			VARCHAR(32) = '',
	@UserID			VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog	AS INT

		IF ISNULL(@IDX_M_Partner, 0) = 0
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Konsumen belum diisi!')
		END

		IF RTRIM(ISNULL(@Street,'')) = ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Alamat belum diisi!')
		END

		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			-- Kode pos hanya dihubungkan bila cocok dengan master
			DECLARE @_IDX_M_PostalCode	BIGINT = NULL

			IF RTRIM(ISNULL(@Zip,'')) <> ''
			BEGIN
				SELECT TOP 1 @_IDX_M_PostalCode = IDX_M_PostalCode
				FROM GN_M_PostalCode WITH(NOLOCK)
				WHERE RTRIM(ISNULL(Zip,'')) = RTRIM(@Zip)
					AND RTRIM(ISNULL(Recordstatus,'A')) = 'A'
				ORDER BY IDX_M_PostalCode
			END

			-- Alamat pertama konsumen dijadikan alamat utama
			DECLARE @_IsDefault	CHAR(1) = 'Y'

			IF EXISTS (SELECT 1 FROM GN_M_PartnerAddress WITH(NOLOCK)
					WHERE IDX_M_Partner = @IDX_M_Partner)
			BEGIN
				SET @_IsDefault = 'N'
			END

			INSERT INTO [dbo].[GN_M_PartnerAddress]
				([IDX_M_Partner], [IDX_M_AddressType], [IDX_M_PostalCode], [IsDefault],
				 [Street], [Zip], [Notes], [DCreate], [UCreate], [RecordStatus])
			VALUES
				(@IDX_M_Partner, 1, @_IDX_M_PostalCode, @_IsDefault,
				 @Street, RTRIM(ISNULL(@Zip,'')), 'Input cepat transaksi valas',
				 GETDATE(), @UserID, 'A')

			INSERT INTO @TableLog
			VALUES ('success', SCOPE_IDENTITY(), 'Data Sudah Disimpan')
		END

		SELECT TOP 1 * FROM @TableLog ORDER BY CASE Result WHEN 'error' THEN 0 ELSE 1 END

	END TRY
	BEGIN CATCH
		SELECT 'error' AS Result, 0 AS ID,
			CONVERT(VARCHAR, ERROR_NUMBER()) + ' ' + ERROR_MESSAGE() AS LogDesc
	END CATCH
END
GO
