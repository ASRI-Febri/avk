

/*	
		EXEC [dbo].[USP_MC_PurchaseOrderDetail_List] 2
*/
CREATE PROCEDURE [dbo].[USP_MC_PurchaseOrderDetail_List]
	@IDX_T_PurchaseOrder			BIGINT = 0

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT POD.IDX_T_PurchaseOrderDetail, POD.IDX_T_PurchaseOrder, POD.IDX_M_Valas, POD.IDX_M_Tax, 
		POD.ForeignCurrency, POD.Quantity, POD.ForeignAmount, POD.ExchangeRate, 
		POD.BaseCurrency, POD.BaseCurrencyAmount, POD.DetailNotes,
		PO.POStatus, 
		MV.ValasSKU, MV.ValasName, 
		MVC.ValasChangeID, MVC.ValasChangeName, MVC.ValasChangeNumber, 
		MT.TaxID, MT.TaxName, 
		CF.CurrencyID AS ForeignCurrencyID, 
		CB.CurrencyID AS BaseCurrencyID
	FROM MC_T_PurchaseOrderDetail POD
		LEFT JOIN MC_T_PurchaseOrder PO ON POD.IDX_T_PurchaseOrder = PO.IDX_T_PurchaseOrder
		LEFT JOIN MC_M_Valas AS MV ON MV.IDX_M_Valas = POD.IDX_M_Valas
		LEFT JOIN MC_M_ValasChange AS MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN GL_M_Tax MT ON POD.IDX_M_Tax = MT.IDX_M_Tax
		LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN GN_M_Currency CB ON CB.IDX_M_Currency = POD.BaseCurrency
	WHERE POD.IDX_T_PurchaseOrder = @IDX_T_PurchaseOrder

END
