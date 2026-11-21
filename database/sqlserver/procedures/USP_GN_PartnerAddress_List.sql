-- =============================================
-- Author:		Samuel Febrianto
-- Create date: 25 Maret 2023
-- Description:	New version apps for Business partner address list
-- =============================================

-- USP_GN_PartnerAddress_List 303 

CREATE PROCEDURE [dbo].[USP_GN_PartnerAddress_List]
	@IDX_M_Partner		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MPA.IDX_M_PartnerAddress, MPA.IDX_M_Partner, MPA.Street, MPA.Zip, MPA.Notes, MPA.IsDefault, 
        MP.PartnerID, MP.PartnerName, MP.SingleIdentityNumber, MP.TaxIdentityNumber, MP.Email, MAT.AddressTypeName, 
        MPC.Province, MPC.Info, MPC.City, MPC.Subdistrict, MPC.District, 
        CityDescription = MPC.Province + ', ' + MPC.Info + ' ' + MPC.City + ', ' + MPC.District + ', ' + MPC.Subdistrict
    FROM GN_M_PartnerAddress MPA WITH (NOLOCK)
        LEFT JOIN GN_M_Partner MP WITH (NOLOCK) on MPA.IDX_M_Partner = MP.IDX_M_Partner
        LEFT JOIN GN_M_AddressType MAT WITH (NOLOCK) on MPA.IDX_M_AddressType = MAT.IDX_M_AddressType
        LEFT JOIN GN_M_PostalCode MPC WITH (NOLOCK) on MPA.IDX_M_PostalCode = MPC.IDX_M_PostalCode 
    WHERE MPA.RecordStatus = 'A' AND MPA.IDX_M_Partner = @IDX_M_Partner 
    ORDER BY MPA.IDX_M_AddressType
END
