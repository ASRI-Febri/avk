-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Maret 2023
-- Description:	New version apps for Business partner bank information
-- =============================================

-- USP_GN_PartnerBank_List 303 

CREATE PROCEDURE [dbo].[USP_GN_PartnerBank_Info] 
	@IDX_M_PartnerBank		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT PB.IDX_M_PartnerBank, PB.IDX_M_Partner, PB.IDX_M_Bank, PB.Remarks, PB.IsDefault,
		MB.BankName, PB.BankAccountNo, PB.BankAccountName, PB.BankAccountBranch 
	FROM GN_M_PartnerBank PB
	LEFT JOIN GN_M_Partner MP ON MP.IDX_M_Partner = PB.IDX_M_Partner
	LEFT JOIN GN_M_Bank MB ON MB.IDX_M_Bank = PB.IDX_M_Bank
	WHERE PB.IDX_M_PartnerBank = @IDX_M_PartnerBank
	ORDER BY PB.IDX_M_PartnerBank

END
