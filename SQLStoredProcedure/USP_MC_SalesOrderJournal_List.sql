
/****** Object:  StoredProcedure [dbo].[USP_MC_SalesOrderJournal_List]    Script Date: 5/11/2026 11:02:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*	
	EXEC [dbo].[USP_MC_SalesOrderJournal_List] 2
*/

ALTER PROCEDURE [dbo].[USP_MC_SalesOrderJournal_List]
	@IDX_T_SalesOrder			BIGINT = 0

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_SalesOrderNo			VARCHAR(20)
	DECLARE @_IDX_M_DocumentType	INT

	SELECT @_SalesOrderNo = SONumber 
	FROM MC_T_SalesOrder
	WHERE IDX_T_SalesOrder = @IDX_T_SalesOrder

   SELECT JH.IDX_T_JournalHeader, JH.IDX_M_JournalType, 
	MJT.JournalTypeDesc, 
	JH.JournalDate, JH.VoucherNo, JH.JournalDate, JH.PostingStatus, JH.PostingDate, 
	JH.RemarkHeader, JD.RemarkDetail, 
	JD.IDX_M_COA, JD.BDebetAmount, JD.BCreditAmount, 
	COA.COAID, COA.COADesc 
   FROM GL_T_JournalHeader JH
   INNER JOIN GL_T_JournalDetail JD ON JD.IDX_T_JournalHeader = JH.IDX_T_JournalHeader
   INNER JOIN GL_M_JournalType MJT ON MJT.IDX_M_JournalType = JH.IDX_M_JournalType
   INNER JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA
   WHERE JH.IDX_ReferenceNo = @IDX_T_SalesOrder AND RTRIM(JH.ReferenceNo) = RTRIM(@_SalesOrderNo)
   ORDER BY JH.JournalDate, MJT.JournalTypeDesc

END

