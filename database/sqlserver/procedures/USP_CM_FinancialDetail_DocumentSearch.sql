
CREATE PROCEDURE [dbo].[USP_CM_FinancialDetail_DocumentSearch]
	@TransactionType	CHAR(1)			= 'R',
	@SearchValue		VARCHAR(50)		= '',
	@RowLimit			INT				= 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @_Search AS VARCHAR(52)

	IF ISNULL(@RowLimit,0) < 1 SET @RowLimit = 20
	IF @RowLimit > 100 SET @RowLimit = 100

	SET @_Search = '%' + RTRIM(ISNULL(@SearchValue,'')) + '%'

	IF @TransactionType = 'P'
	BEGIN
		SELECT TOP (@RowLimit)
			IDX_M_DocumentType	= PO.IDX_M_DocumentType,
			IDX_DocumentNo		= PO.IDX_T_PurchaseOrder,
			DocumentNo			= RTRIM(PO.PONumber),
			DocumentDate		= CONVERT(VARCHAR(10), PO.PODate, 120),
			PartnerName			= RTRIM(ISNULL(MP.PartnerName,'')),
			DocumentAmount		= ISNULL(D.TotalAmount,0)
		FROM MC_T_PurchaseOrder PO WITH(NOLOCK)
			LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON MP.IDX_M_Partner = PO.IDX_M_Partner
			LEFT JOIN (	SELECT IDX_T_PurchaseOrder, SUM(BaseCurrencyAmount) AS TotalAmount
						FROM MC_T_PurchaseOrderDetail WITH(NOLOCK)
						WHERE RecordStatus = 'A'
						GROUP BY IDX_T_PurchaseOrder) D ON D.IDX_T_PurchaseOrder = PO.IDX_T_PurchaseOrder
		WHERE PO.POStatus = 'A'
			AND ISNULL(PO.RecordStatus,'A') = 'A'
			AND (RTRIM(ISNULL(@SearchValue,'')) = ''
				OR PO.PONumber LIKE @_Search
				OR MP.PartnerName LIKE @_Search)
		ORDER BY PO.IDX_T_PurchaseOrder DESC
	END
	ELSE
	BEGIN
		SELECT TOP (@RowLimit)
			IDX_M_DocumentType	= SO.IDX_M_DocumentType,
			IDX_DocumentNo		= SO.IDX_T_SalesOrder,
			DocumentNo			= RTRIM(SO.SONumber),
			DocumentDate		= CONVERT(VARCHAR(10), SO.SODate, 120),
			PartnerName			= RTRIM(ISNULL(MP.PartnerName,'')),
			DocumentAmount		= ISNULL(D.TotalAmount,0)
		FROM MC_T_SalesOrder SO WITH(NOLOCK)
			LEFT JOIN GN_M_Partner MP WITH(NOLOCK) ON MP.IDX_M_Partner = SO.IDX_M_Partner
			LEFT JOIN (	SELECT IDX_T_SalesOrder, SUM(BaseCurrencyAmount) AS TotalAmount
						FROM MC_T_SalesOrderDetail WITH(NOLOCK)
						WHERE RecordStatus = 'A'
						GROUP BY IDX_T_SalesOrder) D ON D.IDX_T_SalesOrder = SO.IDX_T_SalesOrder
		WHERE SO.SOStatus = 'A'
			AND ISNULL(SO.RecordStatus,'A') = 'A'
			AND (RTRIM(ISNULL(@SearchValue,'')) = ''
				OR SO.SONumber LIKE @_Search
				OR MP.PartnerName LIKE @_Search)
		ORDER BY SO.IDX_T_SalesOrder DESC
	END
END
