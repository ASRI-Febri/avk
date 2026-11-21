-- =============================================
-- Author:		Jonathan
-- Create date: 2023-06-02
-- Description:	Search Purchase Order by value (for ajax searching)
-- =============================================

-- USP_CM_PurchaseOrderSearchByValue_List ''

CREATE PROCEDURE [dbo].[USP_CM_PurchaseOrderSearchByValue_List] 
	@SearchValue		VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SqlSelect			VARCHAR(1000)
	DECLARE @_SqlFrom			VARCHAR(1000)
	DECLARE @_SqlWhere			VARCHAR(1000)

	SET @SearchValue = '%' + RTRIM(@SearchValue) + '%'

    SET @_SqlSelect = '	SELECT
							a.PONumber,
							a.PODescription,
							c.ReferenceNo, 
							(b.Quantity * b.UntaxedAmount) - b.DiscountAmount + b.TaxAmount AS POAmount,
							(d.Quantity * d.UntaxedAmount) - b.DiscountAmount + b.TaxAmount AS PIAmount,
							((b.Quantity * b.UntaxedAmount) - b.DiscountAmount + b.TaxAmount) - ((d.Quantity * d.UntaxedAmount) - b.DiscountAmount + b.TaxAmount) AS OutstandingAmount  ' 							
	
	SET @_SqlFrom = 'FROM PR_T_PurchaseOrder a
							JOIN PR_T_PurchaseOrderDetail b ON a.IDX_T_PurchaseOrder = b.IDX_T_PurchaseOrder
							JOIN CM_T_PurchaseInvoiceHeader c ON a.PONumber = c.ReferenceNo
							JOIN CM_T_PurchaseInvoiceDetail d ON c.IDX_T_PurchaseInvoiceHeader = d.IDX_T_PurchaseInvoiceHeader '

	SET @_SqlWhere = 'WHERE a.RecordStatus = ''A'' AND ((b.Quantity * b.UntaxedAmount) - b.DiscountAmount + b.TaxAmount) - ((d.Quantity * d.UntaxedAmount) - b.DiscountAmount + b.TaxAmount) > 0 AND (
						RTRIM(ISNULL(a.PONumber,''''))  LIKE ''' + @SearchValue + ''')' 

	PRINT(@_SqlSelect + @_SqlFrom + @_SqlWhere)
	EXEC(@_SqlSelect + @_SqlFrom + @_SqlWhere)
END
