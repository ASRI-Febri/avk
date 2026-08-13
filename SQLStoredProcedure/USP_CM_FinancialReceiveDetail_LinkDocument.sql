USE [AVKDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 13 Agustus 2026
-- Description:	Menghubungkan baris detail Financial Receive yang belum punya
--				dokumen sumber (DocumentNo kosong) dengan transaksi Sales Order
--				valas. Hanya mengisi IDX_M_DocumentType, IDX_DocumentNo dan
--				DocumentNo; nilai penerimaan, COA dan project tidak disentuh.
--
--				Sengaja menolak baris yang DocumentNo-nya sudah terisi supaya
--				link yang sudah ada tidak tertimpa tanpa sengaja.
-- =============================================

/*
	EXEC [dbo].[USP_CM_FinancialReceiveDetail_LinkDocument] 40838, 12, 30804, 'SMC-100-2607-0855', 'it_febry'
*/

IF OBJECT_ID('[dbo].[USP_CM_FinancialReceiveDetail_LinkDocument]', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[USP_CM_FinancialReceiveDetail_LinkDocument]
GO

CREATE PROCEDURE [dbo].[USP_CM_FinancialReceiveDetail_LinkDocument]
	@IDX_T_FinancialReceiveDetail	BIGINT,
	@IDX_M_DocumentType				BIGINT,
	@IDX_DocumentNo					BIGINT,
	@DocumentNo						VARCHAR(50),
	@UserID							VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		/** TableLog **/
		DECLARE @TableLog TABLE (
			Result		VARCHAR(20),
			ID			BIGINT,
			LogDesc		VARCHAR(500)
		)

		DECLARE @_CountLog AS INT
		DECLARE @_IDX_T_FinancialReceiveHeader AS BIGINT
		DECLARE @_DocumentNoLama AS VARCHAR(50)
		/*****************************/

		SELECT @_IDX_T_FinancialReceiveHeader = IDX_T_FinancialReceiveHeader,
			@_DocumentNoLama = RTRIM(ISNULL(DocumentNo,''))
		FROM CM_T_FinancialReceiveDetail WITH(NOLOCK)
		WHERE IDX_T_FinancialReceiveDetail = @IDX_T_FinancialReceiveDetail

		IF @_IDX_T_FinancialReceiveHeader IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Detail penerimaan tidak ditemukan!')
		END
		ELSE IF @_DocumentNoLama <> ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @_IDX_T_FinancialReceiveHeader,
				'Detail ini sudah terhubung dengan dokumen ' + @_DocumentNoLama + '!')
		END

		-- Dokumen tujuan harus benar benar ada dan nomornya cocok dengan indexnya
		IF NOT EXISTS (SELECT 1 FROM MC_T_SalesOrder WITH(NOLOCK)
						WHERE IDX_T_SalesOrder = @IDX_DocumentNo
							AND RTRIM(SONumber) = RTRIM(@DocumentNo)
							AND SOStatus = 'A')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', ISNULL(@_IDX_T_FinancialReceiveHeader,0),
				'Transaksi penjualan ' + RTRIM(ISNULL(@DocumentNo,'')) + ' tidak ditemukan atau belum di-approve!')
		END

		/** If no error occured **/
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			UPDATE [dbo].[CM_T_FinancialReceiveDetail] SET
				 [IDX_M_DocumentType]	= @IDX_M_DocumentType
				,[IDX_DocumentNo]		= @IDX_DocumentNo
				,[DocumentNo]			= RTRIM(@DocumentNo)
				,[UModified]			= @UserID
				,[DModified]			= GETDATE()
			WHERE IDX_T_FinancialReceiveDetail = @IDX_T_FinancialReceiveDetail

			INSERT INTO @TableLog VALUES ('success', @_IDX_T_FinancialReceiveHeader,
				'Penerimaan sudah dihubungkan dengan ' + RTRIM(@DocumentNo))
		END

		COMMIT TRANSACTION;

		SELECT * FROM @TableLog

	END TRY

	BEGIN CATCH

		INSERT INTO @TableLog VALUES ('error', 0, CONVERT(VARCHAR, ERROR_NUMBER() + ' ' + ERROR_MESSAGE()))

		SELECT * FROM @TableLog

		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION;
		END;

	END CATCH;

END
GO
