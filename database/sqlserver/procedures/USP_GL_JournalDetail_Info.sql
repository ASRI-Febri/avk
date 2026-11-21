-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Get Detail Information for Journal Detail
-- =============================================

-- EXEC [dbo].[USP_GL_JournalDetail_Info] 2

CREATE PROCEDURE [dbo].[USP_GL_JournalDetail_Info]
	-- Add the parameters for the stored procedure here
	@IDX_T_JournalDetail BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JD.IDX_T_JournalDetail, JD.IDX_T_JournalHeader, JD.IDX_M_Project, JD.IDX_M_Department,
		JD.IDX_M_COA, JD.IDX_M_Partner, JD.IDX_M_CashflowID, JD.JournalSeqNo, JD.COADescription, 
		JD.RemarkDetail, JD.OriginalCurrencyID, JD.ODebetAmount, JD.OCreditAmount, 
		JD.ExchangeRate, JD.BaseCurrencyID, JD.BDebetAmount, JD.BCreditAmount, 
		JH.PostingStatus, COA.COAID,  COA.COADesc, COA.COADesc2, --= COA.COAID + ' - '  + COA.COADesc, 
		PartnerDesc = GMP.PartnerID + ' - '  + GMP.PartnerName,
		StatusDesc = CASE JH.PostingStatus WHEN 'P' THEN 'Posted' WHEN 'U' THEN 'Unposted' END
	FROM GL_T_JournalDetail JD
	LEFT JOIN GL_T_JournalHeader JH ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader  
	LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA 
	LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = JD.IDX_M_Partner
	LEFT JOIN GN_M_Company MC ON JH.IDX_M_Company = MC.IDX_M_Company
	LEFT JOIN GN_M_Branch MB ON JH.IDX_M_Branch = MB.IDX_M_Branch
	WHERE JD.IDX_T_JournalDetail = @IDX_T_JournalDetail
	
END




