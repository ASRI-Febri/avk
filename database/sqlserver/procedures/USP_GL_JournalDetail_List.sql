-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 6 February 2018
-- Description:	InquiryJournal Detail
-- =============================================

-- EXEC [USP_GL_JournalDetail_List] 2

CREATE PROCEDURE [dbo].[USP_GL_JournalDetail_List] 	
	@IDX_T_JournalHeader	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JD.*, COA.COAID, COA.COADesc, COA.COADesc2, JH.PostingStatus,
		GMP.PartnerID, GMP.PartnerName AS PartnerName,  
		PartnerDesc = GMP.PartnerID + ' - '  + GMP.PartnerName,
		GC.CompanyName, MB.BranchName,
		OCur.CurrencyName AS OriginalCurrency, BCur.CurrencyName AS BaseCurrency  
	FROM GL_T_JournalDetail JD
		LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = JD.IDX_M_COA
		LEFT JOIN GL_T_JournalHeader JH ON JH.IDX_T_JournalHeader = JD.IDX_T_JournalHeader 
		LEFT JOIN GN_M_Partner GMP ON GMP.IDX_M_Partner = JD.IDX_M_Partner 
		LEFT JOIN GN_M_Company GC ON GC.IDX_M_Company = JH.IDX_M_Company
		LEFT JOIN GN_M_Branch MB ON MB.IDX_M_Branch = JH.IDX_M_Branch
		LEFT JOIN GN_M_Currency OCur ON OCur.IDX_M_Currency = JD.OriginalCurrencyID
		LEFT JOIN GN_M_Currency BCur ON BCur.IDX_M_Currency = JD.BaseCurrencyID
	WHERE JD.RecordStatus = 'A' AND JD.IDX_T_JournalHeader = @IDX_T_JournalHeader
	ORDER BY JD.IDX_T_JournalDetail

END



