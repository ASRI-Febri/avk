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