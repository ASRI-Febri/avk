
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get company information
-- =============================================

-- EXEC [USP_GN_Company_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Company_Info]	
	@IDX_M_Company			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.IDX_M_Company, C.IDX_M_Currency, C.IDX_M_Parent,
		C.CompanyID, C.CompanyName, C.CompanyAlias, C.SIUP, C.NPWP, 
		C.PKPIdentityNumber, C.PKPDate,
		C.LegalAddress, C.Province, C.City, C.District, C.Subdistrict, C.Zip, 
		C.Email, C.Phone, C.Fax, C.Logo, C.Website, C.Remarks, 
		C.RecordStatus
	FROM GN_M_Company C
	WHERE IDX_M_Company = @IDX_M_Company
	
END



