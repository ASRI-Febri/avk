-- ===================================================================
-- Author		: Samuel Febrianto
-- Create date	: 20 Oktober 2016
-- Description	: Inquiry Journal For Financial Receive ALlocation
-- Mod			: 2020-07-21 by Anton - Adjust join logic with IDX
-- ===================================================================

-- EXEC [USP_CM_ReceiveAllocation_Journal_List] 10150

CREATE PROCEDURE [dbo].[USP_CM_ReceiveAllocation_Journal_List] 
	-- Add the parameters for the stored procedure here
	@IDX_T_FinancialReceiveHeader	BIGINT
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
	FROM GL_T_JournalHeader JH WITH(NOLOCK)
		LEFT JOIN GL_T_JournalDetail JD WITH(NOLOCK) ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		INNER JOIN (
			SELECT FRH.IDX_T_FinancialReceiveHeader, FRD.IDX_T_FinancialReceiveDetail, RA.IDX_T_ReceiveAllocation
			FROM CM_T_FinancialReceiveHeader FRH WITH(NOLOCK)
			LEFT JOIN CM_T_FinancialReceiveDetail FRD WITH(NOLOCK) ON FRD.IDX_T_FinancialReceiveHeader = FRH.IDX_T_FinancialReceiveHeader
			LEFT JOIN CM_T_ReceiveAllocation RA WITH(NOLOCK) ON RA.IDX_T_FinancialReceiveDetail = FRD.IDX_T_FinancialReceiveDetail
			WHERE FRH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader 
		) FRH ON FRH.IDX_T_ReceiveAllocation = JH.IDX_ReferenceNo
		LEFT JOIN GL_M_COA COA WITH(NOLOCK) ON JD.IDX_M_COA = COA.IDX_M_COA
		LEFT JOIN GL_M_JournalType MJT WITH(NOLOCK) ON JH.IDX_M_JournalType = MJT.IDX_M_JournalType
	WHERE JH.IDX_M_JournalType = 8 AND FRH.IDX_T_FinancialReceiveHeader  = @IDX_T_FinancialReceiveHeader 
	ORDER BY JH.IDX_T_JournalHeader, JD.IDX_T_JournalDetail

END




