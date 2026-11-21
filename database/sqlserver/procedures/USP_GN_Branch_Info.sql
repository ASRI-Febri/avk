
-- =============================================
-- Author		:	Samuel Febrianto
-- Create date	:	03 June 2023
-- Description	:	Get Branch information
-- =============================================

-- EXEC [USP_GN_Branch_Info] 1

CREATE PROCEDURE [dbo].[USP_GN_Branch_Info]	
	@IDX_M_Branch			INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.IDX_M_Branch, C.IDX_M_Company, C.IDX_M_Parent, C.IDX_M_LocationInventory,
		C.BranchID, C.BranchName, C.BranchAlias, C.BranchAddress, C.RecordStatus,
		C.COASales, C.BranchRemark, 
		LI.LocationID, LI.LocationName, 
		COA.COAID, COA.COADesc, COASalesDesc = COA.COAID + ' - ' + COA.COADesc
	FROM GN_M_Branch C
	LEFT JOIN IN_M_LocationInventory LI ON LI.IDX_M_LocationInventory = C.IDX_M_Branch
	LEFT JOIN GL_M_COA COA ON COA.IDX_M_COA = C.COASales
	WHERE IDX_M_Branch = @IDX_M_Branch
	
END



