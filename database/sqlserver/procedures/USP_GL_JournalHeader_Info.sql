-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 18 November 2016
-- Description:	Get Detail Information for Journal Header
-- =============================================

-- EXEC [dbo].[USP_GL_JournalHeader_Info] 865

-- EXEC USP_GL_JournalHeader_Info 1

CREATE PROCEDURE [dbo].[USP_GL_JournalHeader_Info]
	-- Add the parameters for the stored procedure here
	@IDX_T_JournalHeader BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT GC.CompanyName, MB.BranchName, 
		[IDX_T_JournalHeader],JH.[IDX_M_Company],JH.[IDX_M_Branch],JH.[IDX_M_JournalType],JH.[IDX_M_Partner]
      ,[ApplicationID],[IDX_ReferenceNo],[ReferenceNo],[VoucherNo],[JournalDate],[JournalPeriod],[RemarkHeader]
      ,[PartnerDesc],[PostingStatus],[PostingDate],[PostedBy],[PostingNotes],[DebetAmount],[CreditAmount],[JournalSource],
	  JH.RecordStatus,
		JT.JournalTypeID, JT.JournalTypeDesc,
		StatusDesc = CASE JH.PostingStatus WHEN 'P' THEN 'Posted' WHEN 'U' THEN 'Unposted' END, 
		PartnerDesc = (MBP.PartnerName),
		--MU.UCreate AS CreateByID, MU.Name AS CreateByDate, MU.Name AS CreateByName,
		JH.UCreate AS CreateByID, JH.DCreate AS CreateByDate, MU.Name AS CreateByName,
		JH.UModified AS ModifiedByID, JH.DModified AS ModifiedByDate, MUM.Name AS ModifiedByName, 
		JH.PostedBy AS PostedByID, JH.PostingDate AS PostedByDate, MUA.Name AS PostedByName
	FROM GL_T_JournalHeader JH 
	LEFT JOIN GN_M_Company GC WITH (NOLOCK) ON JH.IDX_M_Company = GC.IDX_M_Company
	LEFT JOIN GN_M_Branch MB WITH (NOLOCK) ON JH.IDX_M_Branch = MB.IDX_M_Branch
	LEFT JOIN GL_M_JournalType JT WITH (NOLOCK) ON JT.IDX_M_JournalType = JH.IDX_M_JournalType
	LEFT JOIN GN_M_Partner MBP WITH (NOLOCK) ON JH.IDX_M_Partner = MBP.IDX_M_Partner
	LEFT JOIN SM_M_User MU WITH (NOLOCK) ON MU.LoginID = JH.UCreate
	LEFT JOIN SM_M_User MUM WITH (NOLOCK) ON MUM.LoginID = JH.UModified
	LEFT JOIN SM_M_User MUA WITH (NOLOCK) ON MUA.LoginID = JH.PostedBy
	WHERE JH.IDX_T_JournalHeader = @IDX_T_JournalHeader
	
END




