-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 20 Oktober 2016
-- Description:	Inquiry Journal For Sales Invoice
-- =============================================

-- EXEC [USP_CM_SalesInvoice_Journal_List] 53

CREATE PROCEDURE [dbo].[USP_CM_SalesInvoice_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_SalesInvoiceHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, CONVERT(DATE,JH.JournalDate) AS JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		INNER JOIN CM_T_SalesInvoiceHeader PIH ON JH.ReferenceNo = PIH.InvoiceNo AND JH.PostingStatus = 'P'		
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE PIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader 
	--ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail
	UNION
	SELECT JH.IDX_T_JournalHeader, JH.VoucherNo, CONVERT(DATE,JH.JournalDate) AS JournalDate,
		JD.IDX_T_JournalDetail, JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount,
		JD.RemarkDetail,
		MJT.JournalTypeID, MJT.JournalTypeDesc,
		COA.COAID, COA.COADesc, COA.IDX_M_COA  
	FROM GL_T_JournalHeader JH
		LEFT JOIN GL_T_JournalDetail JD ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 				
		INNER JOIN CM_T_FinancialReceiveHeader FPH ON JH.ReferenceNo = FPH.ReceiveID
		LEFT JOIN CM_T_FinancialReceiveDetail FPD ON FPD.IDX_T_FinancialReceiveHeader = FPH.IDX_T_FinancialReceiveHeader
		INNER JOIN CM_T_SalesInvoiceHeader PIH ON PIH.IDX_M_DocumentType = FPD.IDX_M_DocumentType AND PIH.IDX_T_SalesInvoiceHeader = FPD.IDX_DocumentNo
		LEFT JOIN GL_M_COA COA ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE PIH.IDX_T_SalesInvoiceHeader = @IDX_T_SalesInvoiceHeader 
END




