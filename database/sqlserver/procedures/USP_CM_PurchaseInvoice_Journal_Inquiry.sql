-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Purchase Invoice
-- =============================================

-- EXEC [USP_CM_PurchaseInvoice_Journal_Inquiry] 1

CREATE PROCEDURE [dbo].[USP_CM_PurchaseInvoice_Journal_Inquiry] 
	-- Add the parameters for the stored procedure here
	@IDX_T_PurchaseInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, JH.JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		INNER JOIN CM_T_PurchaseInvoiceHeader RIH ON JH.ReferenceNo = RIH.InvoiceNo		
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE RIH.IDX_T_PurchaseInvoiceHeader = @IDX_T_PurchaseInvoiceHeader 
	ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail

END




