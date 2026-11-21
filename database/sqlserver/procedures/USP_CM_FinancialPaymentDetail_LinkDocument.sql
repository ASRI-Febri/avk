
CREATE PROCEDURE [dbo].[USP_CM_FinancialPaymentDetail_LinkDocument]
	@IDX_T_FinancialPaymentDetail	BIGINT,
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
		DECLARE @_IDX_T_FinancialPaymentHeader AS BIGINT
		DECLARE @_DocumentNoLama AS VARCHAR(50)
		/*****************************/

		SELECT @_IDX_T_FinancialPaymentHeader = IDX_T_FinancialPaymentHeader,
			@_DocumentNoLama = RTRIM(ISNULL(DocumentNo,''))
		FROM CM_T_FinancialPaymentDetail WITH(NOLOCK)
		WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail

		IF @_IDX_T_FinancialPaymentHeader IS NULL
		BEGIN
			INSERT INTO @TableLog VALUES ('error', 0, 'Detail pembayaran tidak ditemukan!')
		END
		ELSE IF @_DocumentNoLama <> ''
		BEGIN
			INSERT INTO @TableLog VALUES ('error', @_IDX_T_FinancialPaymentHeader,
				'Detail ini sudah terhubung dengan dokumen ' + @_DocumentNoLama + '!')
		END

		-- Dokumen tujuan harus benar benar ada dan nomornya cocok dengan indexnya
		IF NOT EXISTS (SELECT 1 FROM MC_T_PurchaseOrder WITH(NOLOCK)
						WHERE IDX_T_PurchaseOrder = @IDX_DocumentNo
							AND RTRIM(PONumber) = RTRIM(@DocumentNo)
							AND POStatus = 'A')
		BEGIN
			INSERT INTO @TableLog VALUES ('error', ISNULL(@_IDX_T_FinancialPaymentHeader,0),
				'Transaksi pembelian ' + RTRIM(ISNULL(@DocumentNo,'')) + ' tidak ditemukan atau belum di-approve!')
		END

		/** If no error occured **/
		SELECT @_CountLog = COUNT(*) FROM @TableLog

		IF @_CountLog = 0
		BEGIN
			UPDATE [dbo].[CM_T_FinancialPaymentDetail] SET
				 [IDX_M_DocumentType]	= @IDX_M_DocumentType
				,[IDX_DocumentNo]		= @IDX_DocumentNo
				,[DocumentNo]			= RTRIM(@DocumentNo)
				,[UModified]			= @UserID
				,[DModified]			= GETDATE()
			WHERE IDX_T_FinancialPaymentDetail = @IDX_T_FinancialPaymentDetail

			INSERT INTO @TableLog VALUES ('success', @_IDX_T_FinancialPaymentHeader,
				'Pembayaran sudah dihubungkan dengan ' + RTRIM(@DocumentNo))
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
