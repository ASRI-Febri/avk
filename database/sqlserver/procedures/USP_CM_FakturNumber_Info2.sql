
-- =============================================
-- Description	: Get detail data Faktur
-- =============================================

-- EXEC [USP_CM_FakturNumber_Info2] 2

CREATE PROCEDURE [dbo].[USP_CM_FakturNumber_Info2] 
	-- Add the parameters for the stored procedure here
	@IDX_M_FakturNumber BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	FN.IDX_M_FakturNumber, 
			FN.PeriodFaktur AS Period1,
			FN.UCreate,
			FN.DCreate,
			FN.UModified,
			FN.DModified,
			MU.Name AS UserName,
			FN.UCreate AS CreateByID,
			FN.DCreate AS CreateByDate,
			MU.Name AS CreateByName,            
			FN.UModified AS ModifiedByID,
			FN.DModified AS ModifiedByDate,
			MUM.Name AS ModifiedByName,
			DATENAME(MONTH, CONVERT(DATE,FN.PeriodFaktur +'01')) +' ' + LEFT(FN.PeriodFaktur,4) As PeriodFaktur,
			FN.StatusFaktur,
			FN.RecordStatus 		
	FROM	CM_M_FakturNumber FN
	LEFT JOIN SM_M_User MU ON MU.LoginID = FN.UCreate
	LEFT JOIN SM_M_User MUM ON MUM.LoginID = FN.UModified
	WHERE	FN.IDX_M_FakturNumber = @IDX_M_FakturNumber AND FN.RecordStatus = 'A'

END

