

/*	
		EXEC [dbo].[USP_MC_SalesOrderDetail_List] 2
*/
CREATE PROCEDURE [dbo].[USP_MC_SalesOrderDetail_List]
	@IDX_T_SalesOrder			BIGINT = 0

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT SOD.IDX_T_SalesOrderDetail, SOD.IDX_T_SalesOrder, SOD.IDX_M_Valas, SOD.IDX_M_Tax, 
		SOD.IDX_M_TransactionType, MTY.TransactionTypeID, MTY.TransactionTypeName,
		SOD.ForeignCurrency, SOD.Quantity, SOD.ForeignAmount, 
		--ExchangeRate = CASE SOD.IDX_M_TransactionType WHEN 2 THEN -1 * SOD.ExchangeRate ELSE SOD.ExchangeRate END,
		SOD.ExchangeRate, 
		SOD.BaseCurrency, SOD.BaseCurrencyAmount, SOD.DetailNotes,
		SO.SOStatus, 
		MV.ValasSKU, MV.ValasName, 
		MVC.ValasChangeID, MVC.ValasChangeName, MVC.ValasChangeNumber, 
		MT.TaxID, MT.TaxName, 
		CF.CurrencyID AS ForeignCurrencyID, 
		CB.CurrencyID AS BaseCurrencyID
	FROM MC_T_SalesOrderDetail SOD
		LEFT JOIN MC_T_SalesOrder SO ON SOD.IDX_T_SalesOrder = SO.IDX_T_SalesOrder
		LEFT JOIN MC_M_Valas AS MV ON MV.IDX_M_Valas = SOD.IDX_M_Valas
		LEFT JOIN MC_M_ValasChange AS MVC ON MVC.IDX_M_ValasChange = MV.IDX_M_ValasChange
		LEFT JOIN GL_M_Tax MT ON SOD.IDX_M_Tax = MT.IDX_M_Tax
		LEFT JOIN MC_M_Currency CF ON CF.IDX_M_Currency = MV.IDX_M_Currency
		LEFT JOIN GN_M_Currency CB ON CB.IDX_M_Currency = SOD.BaseCurrency
		LEFT JOIN MC_M_TransactionType MTY ON MTY.IDX_M_TransactionType = SOD.IDX_M_TransactionType
	WHERE SOD.IDX_T_SalesOrder = @IDX_T_SalesOrder

END
