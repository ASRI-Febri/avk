
-- =============================================
-- Author		: Anton
-- Create date	: 2019-04-24
-- Description	: Get detail Business Partner Address
-- =============================================

-- EXEC [USP_CM_PartnerAddress_Info] 1

CREATE PROCEDURE [dbo].[USP_CM_PartnerAddress_Info] 
	-- Add the parameters for the stored procedure here
	@IDX_M_PartnerAddress	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MPA.*, 
		MP.PartnerID, MP.PartnerName, MP.SingleIdentityNumber, MP.TaxIdentityNumber, MP.Email, MAT.AddressTypeName, MPC.Province, MPC.Info, MPC.City, MPC.Subdistrict, MPC.District, 
		CityDescription = MPC.Province + ', ' + MPC.Info + ' ' + MPC.City + ', ' + ISNULL(MPC.District,'') + ', ' + MPC.Subdistrict
	FROM GN_M_PartnerAddress MPA WITH (NOLOCK)
		LEFT JOIN GN_M_Partner MP WITH (NOLOCK) on MPA.IDX_M_Partner = MP.IDX_M_Partner
		LEFT JOIN GN_M_AddressType MAT WITH (NOLOCK) on MPA.IDX_M_AddressType = MAT.IDX_M_AddressType
		LEFT JOIN GN_M_PostalCode MPC WITH (NOLOCK) on MPA.IDX_M_PostalCode = MPC.IDX_M_PostalCode
	WHERE MPA.IDX_M_PartnerAddress = @IDX_M_PartnerAddress

END



